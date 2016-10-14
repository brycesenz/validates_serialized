require 'active_model'

class ValidateableObject
  include ::ActiveModel::Validations

  attr_reader :record
  def initialize(record, object)
    @object = object
    @record = record
  end

  def self.validates(method, *args, &block)
    if args.first[:if].is_a?(Symbol)
      args.first[:if] = proc do |if_method|
        proc do |serialized_object|
          serialized_object.record.send(if_method)
        end
      end.call(args.first[:if])
    end
    super
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
