every 1.day, at: '7:00 am' do
  runner "RefreshCurrencyMatrixWorker.perform_async"
end
