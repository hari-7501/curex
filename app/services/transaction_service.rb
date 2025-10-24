class TransactionService
    include ParamsValidator

    CONVERSION_FEE_PERCENTAGE = BigDecimal('0.0001')
    PAGINATION_DEFAULT_PER_PAGE = 10
    PAGINATION_MAX_PER_PAGE = 100

    def initialize(user, params)
      @user = user
      @params = params
    end

    def list_transactions
        missing = required_fields_missing(@params, [:page, :per_page])
        return Result.new(false, nil, "Missing fields: #{missing.join(', ')}") if missing.any?

        page = (@params[:page] || 1).to_i
        per_page = (@params[:per_page] || PAGINATION_DEFAULT_PER_PAGE).to_i
        per_page = [per_page, PAGINATION_MAX_PER_PAGE].min
        transactions = @user.transactions.order(created_at: :desc)
                             .page(page)
                             .per(per_page)
        Result.new(true, transactions, nil)
        rescue => e
        Result.new(false, nil, e.message)
    end

    def call
      missing = required_fields_missing(@params, [:receiver_id, :from_currency, :to_currency, :amount])
      return Result.new(false, nil, "Missing fields: #{missing.join(', ')}") if missing.any?

      sender_wallet = @user.wallets.find_by!(currency: @params[:from_currency])
      receiver_wallet = Wallet.find_by!(user_id: @params[:receiver_id], currency: @params[:to_currency])
      amount = BigDecimal(@params[:amount].to_s)
      currency_conversion_rate = fetch_conversion_rate
      currency_conversion_fee = calculate_conversion_fee(sender_wallet, receiver_wallet, amount)

      Wallet.transaction do
        raise 'Insufficient balance' if sender_wallet.balance < amount + currency_conversion_fee
        update_wallets!(sender_wallet, receiver_wallet, amount, currency_conversion_rate, currency_conversion_fee)
        create_transaction_record(sender_wallet, receiver_wallet, amount, currency_conversion_rate, currency_conversion_fee)
      end
      SmsWorker.perform_async(@mobile, "Your transfer of #{amount} #{@params[:from_currency]} to #{@params[:to_currency]} was successful.")
      Result.new(true, { message: 'Transfer successful' }, nil)
    end

    private

    def calculate_conversion_fee(sender_wallet, receiver_wallet, amount)
      return BigDecimal('0') if sender_wallet.user_id == receiver_wallet.user_id
      (amount * CONVERSION_FEE_PERCENTAGE).round(10)
    end

    def fetch_conversion_rate
      BigDecimal(RedisService.hget("rates:#{@params[:from_currency]}", @params[:to_currency]))
    end

    def update_wallets!(sender_wallet, receiver_wallet, amount, rate, fee)
      sender_wallet.update!(balance: sender_wallet.balance - amount - fee)
      receiver_wallet.update!(balance: receiver_wallet.balance + amount * rate)
    end

    def create_transaction_record(sender_wallet, receiver_wallet, amount, rate, fee)
        Transaction.create!(
        sender_user_id: sender_wallet.user_id,
        receiver_user_id: receiver_wallet.user_id,
        sender_currency: sender_wallet.currency,
        receiver_currency: receiver_wallet.currency,
        transaction_amount: amount,
        currency_conversion_rate: rate,
        currency_conversion_fee: fee
        )
    end
end