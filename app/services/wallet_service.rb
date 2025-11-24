class WalletService
  include ParamsValidator
  include TransactionUtils

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def list_wallets
    @user.wallets
  end

  def add_or_remove_funds
    missing = required_fields_missing(@params, [:currency, :amount, :type])
    raise ValidationError.new("Missing fields: #{missing.join(', ')}") if missing.any?
    raise ValidationError.new("amount should be > 0") if @params[:amount] <= 0
    wallet = @user.wallets.find_by(currency: @params[:currency])
    raise ValidationError.new("Wallet not found") unless wallet

    ActiveRecord::Base.transaction do
      wallet.with_lock do
        case @params[:type]
        when 'deposit'
          wallet.update!(balance: wallet.balance + @params[:amount])
          create_transaction_record!(nil, wallet, @params[:amount], 1, 0)
        when 'withdraw'
          if wallet.balance < @params[:amount]
            raise ValidationError.new("Insufficient balance")
          end
          wallet.update!(balance: wallet.balance - @params[:amount])
          create_transaction_record!(wallet, nil, @params[:amount], 1, 0)
        else
          raise ValidationError.new("Invalid type: #{@params[:type]}")
        end
      end
    end
    wallet
  end
end
