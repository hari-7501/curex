class Api::V1::TransactionsController < Api::V1::BaseController
  include ParamsHelper
  include ServiceResponseHandler

  ALLOWED_FIELDS = [:receiver_id, :from_currency, :to_currency, :amount, :page, :per_page].freeze

  def index
    transaction_params = permitted_params(ALLOWED_FIELDS)
    result = TransactionService.new(current_user, transaction_params).list_transactions
    render_service_result(result)
  end

  def create
    transaction_params = permitted_params(ALLOWED_FIELDS)
    result = TransactionService.new(current_user, transaction_params).call
    render_service_result(result)
  end
end
