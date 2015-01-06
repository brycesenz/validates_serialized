require 'active_model'

class ValidateableArrayValue < ValidateableObject
  include ::ActiveModel::Validations

  def value
    @object
  end
end