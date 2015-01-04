require 'active_model'

class ValidateableArray < Array
  include ::ActiveModel::Validations

  def initialize(array)
    @array = array
  end
end