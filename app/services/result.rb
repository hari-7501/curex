class Result
  attr_reader :success, :data, :error

  alias_method :payload, :data

  def initialize(success, data = nil, error = nil)
    @success = success
    @data = data
    @error = error
  end

  def success?
    @success
  end
end
