module ServiceResponseHandler
  extend ActiveSupport::Concern

  def render_service_result(result)
    if result.success?
      render json: result.payload, status: :ok
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end
end
