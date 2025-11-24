class Api::V1::WalletsController < ApplicationController
  include ParamsHelper

  ALLOWED_FIELDS = [:currency, :amount, :type].freeze

  def index
    wallets = WalletService.new(current_user).list_wallets
    render json: { wallets: WalletBlueprint.render_as_hash(wallets) }, status: :ok
  end

  def create
    wallet_params = permitted_params(ALLOWED_FIELDS)
    wallet = WalletService.new(current_user, wallet_params).add_or_remove_funds
    render json: { wallet: WalletBlueprint.render_as_hash(wallet) }, status: :ok
  end
end
