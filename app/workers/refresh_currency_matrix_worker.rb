class RefreshCurrencyMatrixWorker
  include Sidekiq::Worker
  sidekiq_options queue: :default, retry: 3

  def perform
    CurrencyMatrixService.refresh_matrix
  end
end
