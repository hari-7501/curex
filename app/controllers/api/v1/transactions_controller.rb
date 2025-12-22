class Api::V1::TransactionsController < ApplicationController
  
  def index
    @transactions = TransactionService.new(current_user, paginated_params).list_transactions
  end

  def create
    TransactionService.new(current_user, transaction_params).transfer_funds
    render json: { message: "Transfer successful" }, status: :ok
  end

  private

  def transaction_params
    params.permit(:receiver_id, :from_currency, :to_currency, :amount)
  end
end
