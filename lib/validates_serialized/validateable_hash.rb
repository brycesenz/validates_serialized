require 'active_model'

class ValidateableHash < ValidateableObject
  include ::ActiveModel::Validations

  private
  def method_missing(method, *args, &block)
    if @object.keys.include?(method)
      @object[method]
    else
      super
    end
  rescue NoMethodError => e
  end
end