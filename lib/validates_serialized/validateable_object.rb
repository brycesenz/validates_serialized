require 'active_model'

class ValidateableObject
  include ::ActiveModel::Validations

  def initialize(object)
    @object = object
  end

  private
  def method_missing(method, *args, &block)
    @object.send(method, *args, &block)
  end
end