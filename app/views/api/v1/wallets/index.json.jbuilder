json.wallets @wallets do |wallet|
  json.currency wallet.currency
  json.balance wallet.balance
end