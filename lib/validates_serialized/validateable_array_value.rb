require 'active_model'

class ValidateableArrayValue
  include ::ActiveModel::Validations

  def initialize(value)
    @value = value
  end

  def value
    @value
  end
end