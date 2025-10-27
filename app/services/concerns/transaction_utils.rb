module TransactionUtils
  def create_transaction_record(sender_wallet, receiver_wallet, amount, rate, fee)
    Transaction.create!(
      sender_user_id: sender_wallet&.user_id,
      receiver_user_id: receiver_wallet&.user_id,
      sender_currency: sender_wallet&.currency,
      receiver_currency: receiver_wallet&.currency,
      transaction_amount: amount,
      currency_conversion_rate: rate,
      currency_conversion_fee: fee
    )
  end
end