class TransactionBlueprint < Blueprinter::Base
  field :id, name: :transaction_id
  fields :sender_user_id, :receiver_user_id,
         :sender_currency, :receiver_currency,
         :transaction_amount, :currency_conversion_rate,
         :currency_conversion_fee
end