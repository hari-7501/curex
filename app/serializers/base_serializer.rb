class BaseSerializer
  def initialize(object, fields: [], root: :data)
    @object = object
    @fields = fields
    @root = root
  end

  def serialize
    { @root => serialize_object(@object) }
  end

  private

  def serialize_object(obj)
    return {} unless obj

    if obj.respond_to?(:map) 
      obj.map { |item| serialize_fields(item) }
    else
      serialize_fields(obj)
    end
  end

  def serialize_fields(obj)
    @fields.each_with_object({}) do |field, hash|
      hash[field] = obj.public_send(field) if obj.respond_to?(field)
    end
  end
end
