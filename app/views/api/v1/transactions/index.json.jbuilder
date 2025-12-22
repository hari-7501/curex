json.transactions @transactions 
json.meta do
  json.page @transactions.current_page
  json.per_page @transactions.limit_value
  json.total_records @transactions.total_count
end