class SlackNotifyWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :default

  def perform(message, level = "error")
    SlackNotifyService.notify(message, level: level)
  end
end
