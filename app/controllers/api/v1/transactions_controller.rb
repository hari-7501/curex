class Api::V1::TransactionsController < ApplicationController
  include ParamsHelper

  ALLOWED_FIELDS = [:receiver_id, :from_currency, :to_currency, :amount, :page, :per_page].freeze

  def index
    result = TransactionService.new(current_user, {page: page, per_page: per_page}).list_transactions
    render json: {
      transactions: TransactionBlueprint.render_as_hash(result),
      meta: {
        page: result.current_page,
        per_page: result.limit_value,
        total_records: result.total_count,
        total_pages: result.total_pages,
        next_page: result.next_page,
        prev_page: result.prev_page
      }
    },
    status: :ok
  end

  def create
    transaction_params = permitted_params(ALLOWED_FIELDS)
    TransactionService.new(current_user, transaction_params).transfer_funds
    render json: { message: "Transfer successful" }, status: :ok
  end
end
