module ParamsHelper
  extend ActiveSupport::Concern

  def permitted_params_for(resource_name, allowed_fields)
    params.require(resource_name).permit(*allowed_fields)
  end

  def permitted_params(allowed_fields)
    params.permit(*allowed_fields)
  end
end