every 1.day, at: '07:00' do
  runner "RefreshCurrencyMatrixWorker.perform_async", environment: 'development'
end
