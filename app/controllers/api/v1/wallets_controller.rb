class Api::V1::WalletsController < ApplicationController
  
  def index
    @wallets = WalletService.new(current_user).list_wallets
  end

end
