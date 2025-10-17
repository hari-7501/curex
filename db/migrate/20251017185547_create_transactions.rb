class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions, id: :uuid do |t|
      t.uuid :sender_user_id, null: false
      t.uuid :receiver_user_id, null: false
      t.string :sender_currency, null: false
      t.string :receiver_currency, null: false
      t.decimal :transaction_amount, precision: 25, scale: 10, null: false
      t.decimal :currency_conversion_rate, precision: 25, scale: 10, null: false
      t.decimal :currency_conversion_fee, precision: 25, scale: 10, null: false

      t.timestamps
    end

    add_foreign_key :transactions, :users, column: :sender_user_id
    add_foreign_key :transactions, :users, column: :receiver_user_id

    add_index :transactions, :sender_user_id
    add_index :transactions, :receiver_user_id
    add_index :transactions, [:sender_user_id, :receiver_user_id]
  end
end
