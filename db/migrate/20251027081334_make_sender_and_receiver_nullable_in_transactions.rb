class MakeSenderAndReceiverNullableInTransactions < ActiveRecord::Migration[6.0]
  def change
    change_column_null :transactions, :sender_user_id, true
    change_column_null :transactions, :receiver_user_id, true
    change_column_null :transactions, :sender_currency, true
    change_column_null :transactions, :receiver_currency, true
  end
end
