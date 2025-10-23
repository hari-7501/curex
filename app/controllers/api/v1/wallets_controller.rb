class Api::V1::WalletsController < Api::V1::BaseController
  include ParamsHelper
  include ServiceResponseHandler

  ALLOWED_FIELDS = [:currency, :amount, :type].freeze

  def index
    result = WalletService.new(current_user).list_wallets
    render_service_result(result)
  end

  def create
    wallet_params = permitted_params(ALLOWED_FIELDS)
    result = WalletService.new(current_user, wallet_params).update_wallet
    render_service_result(result)
  end
end
