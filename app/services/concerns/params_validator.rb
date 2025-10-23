module ParamsValidator
    extend ActiveSupport::Concern
    
    def required_fields_missing(param_hash, required_fields)
        required_fields.select { |field| param_hash[field].blank? }
    end
end