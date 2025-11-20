class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from StandardError, with: :internal_error

  private

  def not_found(exception = nil)
    log_error(exception) if exception
    render json: { error: "Resource Not Found" }, status: :not_found
  end

  def internal_error(exception)
    log_error(exception)
    SlackNotifyWorker.perform_async(
      <<~MSG,
      🚨 *[#{Rails.env.upcase}] #{exception.class}*
      *Message:* #{exception.message}
      *File:* #{exception.backtrace&.first}
      *Request ID:* #{request&.request_id}
      *Path:* #{request&.path}
      *HTTP Method:* #{request&.method}
      *Controller:* #{controller_name}##{action_name}
      *User ID:* #{current_user&.id || 'N/A'}
      *Params:* #{request&.filtered_parameters.to_json}
      *Occurred At:* #{Time.current}

      *Backtrace (top 10):*
      ```#{exception.backtrace&.first(10)&.join("\n")}```
      MSG
      "fatal"
    )
    render json: { error: "Internal Server Error" }, status: :internal_server_error
  end

  def log_error(exception)
    Rails.logger.error({ error_class: exception.class.name, message: exception.message, backtrace: exception.backtrace&.first(0) }.to_json)
  end
end
