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
    if @object.key?(method)
      @object[method]
    elsif @object.key?(method.to_s)
      @object[method.to_s]
    else
      super
    end
  end
end
