require 'active_model'

class ValidateableArrayValue
  include ::ActiveModel::Validations

  def initialize(value)
    @value = value
  end

  def value
    @value
  end

  def method_missing(sym, *args, &block)
    @value.send sym, *args, &block
  end
end