class TransactionService
    include ParamsValidator
    include TransactionUtils

    CONVERSION_FEE_PERCENTAGE = BigDecimal('0.0001')

    def initialize(user, params)
      @user = user
      @params = params
    end

    def list_transactions
      @user.transactions.order(created_at: :desc).page(@params[:page]).per(@params[:per_page])
    rescue => e
      raise ValidationError.new(e.message)
    end

    def transfer_funds
      missing = required_fields_missing(@params, [:receiver_id, :from_currency, :to_currency, :amount])
      raise ValidationError.new("Missing fields: #{missing.join(', ')}") if missing.any?
      raise ValidationError.new("amount should be > 0") if @params[:amount] <= 0
      
      sender_wallet = @user.wallets.find_by!(currency: @params[:from_currency])
      receiver_wallet = Wallet.find_by!(user_id: @params[:receiver_id], currency: @params[:to_currency])
      if(sender_wallet.nil? || receiver_wallet.nil?)
        raise ValidationError.new("Wallet not found")
      end
      if((@user.id == @params[:receiver_id])&&(@params[:from_currency] == @params[:to_currency]))
        raise ValidationError.new("Cannot transfer to the same wallet")
      end

      amount = BigDecimal(@params[:amount].to_s)
      currency_conversion_rate = fetch_conversion_rate
      currency_conversion_fee = calculate_conversion_fee(sender_wallet, receiver_wallet, amount)

      ActiveRecord::Base.transaction do
        raise 'Insufficient balance' if sender_wallet.balance < amount + currency_conversion_fee
        update_wallets!(sender_wallet, receiver_wallet, amount, currency_conversion_rate, currency_conversion_fee)
        create_transaction_record!(sender_wallet, receiver_wallet, amount, currency_conversion_rate, currency_conversion_fee)
      end

      sender_mobile = @user.mobile
      receiver_mobile = receiver_wallet.user.mobile
      if(sender_mobile != receiver_mobile)
        SmsWorker.perform_async(sender_mobile, "Your transfer of #{amount} #{@params[:from_currency]} to #{receiver_mobile} was successful.")
        SmsWorker.perform_async(receiver_mobile, "You have received #{amount * currency_conversion_rate} #{@params[:to_currency]} from #{@user.first_name} #{@user.last_name}.")
      end

      nil
    end

    private

    def calculate_conversion_fee(sender_wallet, receiver_wallet, amount)
      return BigDecimal('0') if sender_wallet.user_id == receiver_wallet.user_id
      (amount * CONVERSION_FEE_PERCENTAGE).round(10)
    end

    def fetch_conversion_rate
      BigDecimal(REDIS.hget("currency_rates:#{@params[:from_currency]}", @params[:to_currency]))
    end

    def update_wallets!(sender_wallet, receiver_wallet, amount, rate, fee)
      first, second = [sender_wallet, receiver_wallet].sort_by(&:id)
      ActiveRecord::Base.transaction do
        first.with_lock do
          second.with_lock do
            sender_wallet.update!(balance: sender_wallet.balance - amount - fee)
            receiver_wallet.update!(balance: receiver_wallet.balance + amount * rate)
          end
        end
      end
    end
    
end