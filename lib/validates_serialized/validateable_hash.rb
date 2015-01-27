require 'active_model'

class ValidateableHash < ValidateableObject
  include ::ActiveModel::Validations

  def self.method_missing(method, *args, &block)
    if method.to_sym == :clear_validators!
      reset_callbacks(:validate)
      _validators.clear
    end
  end

  private
  def method_missing(method, *args, &block)
    if @object.keys.include?(method)
      @object[method]
    else
      super
    end
  end
end