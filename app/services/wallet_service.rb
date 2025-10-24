class WalletService
  include ParamsValidator

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def list_wallets
    wallets = @user.wallets
    serialized_wallets = BaseSerializer.new(wallets, fields: [:currency, :balance]).serialize
    Result.new(true, serialized_wallets, nil)
  end

  def update_wallet
    missing = required_fields_missing(@params, [:currency, :amount, :type])
    return Result.new(false, nil, "Missing fields: #{missing.join(', ')}") if missing.any?

    wallet = @user.wallets.find_by(currency: @params[:currency])
    return Result.new(false, nil, "Wallet not found") unless wallet

    Wallet.transaction do
      case @params[:type] 
      when 'deposit'
        wallet.update!(balance: wallet.balance + @params[:amount])
      when 'withdraw'
        return Result.new(false, nil, "Insufficient balance") if wallet.balance < @params[:amount]
        wallet.update!(balance: wallet.balance - @params[:amount])
      else
        return Result.new(false, nil, "Invalid type: #{@params[:type]}")
      end
    end

    serialized_wallet = BaseSerializer.new(wallet, fields: [:currency, :balance]).serialize
    Result.new(true, serialized_wallet, nil)
  end
end
