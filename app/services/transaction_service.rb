class TransactionService

    CONVERSION_FEE_PERCENTAGE = BigDecimal('0.0001')

    def initialize(user, params)
      @user = user
      @params = params
    end

    def list_transactions
      @user.transactions.order(created_at: :desc).page(@params[:page]).per(@params[:per_page])
    end

    def transfer_funds
      raise ValidationError.new("amount should be greater than 0") unless @params[:amount].to_f > 0
      
      @sender_wallet = @user.wallets.find_by!(currency: @params[:from_currency]) if @params[:from_currency].present?
      @receiver_wallet = Wallet.find_by!(user_id: @params[:receiver_id], currency: @params[:to_currency]) if @params[:receiver_id].present? && @params[:to_currency].present?
      if @sender_wallet.nil? && @receiver_wallet.nil?
        raise ValidationError.new("Wallets not found")
      end
      if @sender_wallet == @receiver_wallet
        raise ValidationError.new("Cannot transfer to the same wallet")
      end

      @amount = @params[:amount]
      if @sender_wallet.blank? || @receiver_wallet.blank?
        @currency_conversion_rate = 1
        @currency_conversion_fee = 0
      else
        @currency_conversion_rate = fetch_conversion_rate
        @currency_conversion_fee = calculate_conversion_fee
      end
      ActiveRecord::Base.transaction do
        raise ValidationError.new("Insufficient balance") if @sender_wallet.present? && @sender_wallet.balance < @amount + @currency_conversion_fee
        update_wallets
        create_transaction_record
      end
      send_transaction_sms

      nil
    end

    private

    def calculate_conversion_fee
      return BigDecimal('0') if @sender_wallet.user_id == @receiver_wallet.user_id
      (@amount * CONVERSION_FEE_PERCENTAGE).round(10)
    end

    def fetch_conversion_rate
      rate = REDIS.hget("currency_rates:#{@params[:from_currency]}", @params[:to_currency])
      raise NetworkCallError.new("currency conversions are unavailable at the moment, please try later") if rate.nil?
      rate.to_d
    end

    def update_wallets
      wallets = [@sender_wallet, @receiver_wallet].compact
      wallets.each(&:lock!)
      @sender_wallet.update!(balance: @sender_wallet.balance - @amount - @currency_conversion_fee) if @sender_wallet.present?
      @receiver_wallet.update!(balance: @receiver_wallet.balance + @amount * @currency_conversion_rate) if @receiver_wallet.present?
    end

    def create_transaction_record
      Transaction.create!(
        sender_user_id: @sender_wallet&.user_id,
        receiver_user_id: @receiver_wallet&.user_id,
        sender_currency: @sender_wallet&.currency,
        receiver_currency: @receiver_wallet&.currency,
        transaction_amount: @amount,
        currency_conversion_rate: @currency_conversion_rate,
        currency_conversion_fee: @currency_conversion_fee
      )
    end

    def send_transaction_sms
      sender_mobile = @user.mobile
      receiver_mobile = @receiver_wallet&.user&.mobile
      if sender_mobile != receiver_mobile
        SmsWorker.perform_async(sender_mobile, "Your transfer of #{@amount} #{@params[:from_currency]} to #{receiver_mobile} was successful.")
        SmsWorker.perform_async(receiver_mobile, "You have received #{@amount * @currency_conversion_rate} #{@params[:to_currency]} from #{@user.first_name} #{@user.last_name}.")
      else
        SmsWorker.perform_async(sender_mobile, "Deposit of #{@amount} #{@params[:to_currency]} was successful.") if @params[:to_currency].present?
        SmsWorker.perform_async(sender_mobile, "Withdrawal of #{@amount} #{@params[:from_currency]} was successful.") if @params[:from_currency].present?
      end
    end
end