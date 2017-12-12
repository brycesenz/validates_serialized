require 'active_model'

class ValidateableObject
  include ::ActiveModel::Validations
  attr_reader :record

  def initialize(object, record)
    @object = object
    @record = record
    @record = @record.record while @record.is_a? ValidateableObject
  end

  def self.method_missing(method, *args, &block)
    if method.to_sym == :clear_validators!
      reset_callbacks(:validate)
      _validators.clear
    end
  end

  private
  def method_missing(method, *args, &block)
    @object.send(method, *args, &block)
  rescue NoMethodError => e
  end
end