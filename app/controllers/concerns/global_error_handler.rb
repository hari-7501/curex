module GlobalErrorHandler extend ActiveSupport::Concern
  included do
    rescue_from StandardError, with: :custom_exception_handler
  end

  def custom_exception_handler(exception)
    log_error(exception)

    case exception
    when ValidationError, ActionController::ParameterMissing, ActionDispatch::Http::Parameters::ParseError
      render json: { error: exception.message }, status: :bad_request
    when AuthError
      render json: { error: exception.message }, status: :unauthorized
    when NetworkCallError
      render json: { error: exception.message }, status: :service_unavailable
    when ActiveRecord::RecordNotFound
      render json: { error: "resource not found" }, status: :not_found
    when ActiveRecord::RecordInvalid
      render json: { error: exception.message }, status: :unprocessable_entity
    else
      notify_exception_on_slack(exception)
      render json: { error: "please try later" }, status: :internal_server_error
    end
    return
  end

  private

  def notify_exception_on_slack(exception)
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
    )
  end

  def log_error(exception)
    Rails.logger.error({ error_class: exception.class.name, message: exception.message, backtrace: exception.backtrace&.first(10) }.to_json)
  end
end
