every 1.day, at: '02:49' do
  runner "RefreshCurrencyMatrixWorker.perform_async", environment: 'development'
end
