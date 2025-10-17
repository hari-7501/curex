class CreateWallets < ActiveRecord::Migration[6.0]
  def change
    create_table :wallets do |t|
      t.uuid :user_id, null: false
      t.string :currency, null: false
      t.decimal :balance, precision: 25, scale: 10, default: 0.0, null: false

      t.timestamps
    end

    add_foreign_key :wallets, :users, column: :user_id

    add_index :wallets, [:user_id, :currency], unique: true
  end
end
