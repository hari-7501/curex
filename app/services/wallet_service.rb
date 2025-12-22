class WalletService

  def initialize(user, params = {})
    @user = user
    @params = params
  end

  def list_wallets
    @user.wallets
  end
end
