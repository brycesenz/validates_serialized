module ActiveModel
  module Validations
    # Special case of EachValidator that exists to allow other EachValidators to validate
    # individual properties of a serialized object
    class SerializedValidator < ::ActiveModel::EachValidator #:nodoc:
      def initialize(*args, &block)
        #TODO: Need a method for extracting serialized_attributes
        @serialized_attributes = nil
        options = args.extract_options!
        @validators = []
        args.first.each do |klass|
          validator = klass.new(options.dup, &block)
          @validators << validator
        end
        super(options)
      end

      def validate(record)
        attributes.each do |attribute|
          serialized = record.read_attribute_for_validation(attribute)
          type_check!(serialized)
          validate_serialized(record, attribute, serialized)
        end
      end

      def validate_each(record, attribute, value)
        @validators.each do |validator|
          validator.validate_each(record, attribute, value)
        end
      end

      protected
      def validate_serialized(record, attribute, serialized)
        serialized.each do |value|
          next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
          validate_each(record, attribute, value)
        end
      end

      def type_check!(value)
        raise TypeError, "#{value} is not an Object" unless array.is_a?(Object)
      end
    end

    module ClassMethods
      def validates_serialized_with(*args, &block)
        options = args.extract_options!
        options[:class] = self
        serialized_validator_class = args.shift
        validator = serialized_validator_class.new(args, options, &block)

        if validator.respond_to?(:attributes) && !validator.attributes.empty?
          validator.attributes.each do |attribute|
            _validators[attribute.to_sym] << validator
          end
        else
          _validators[nil] << validator
        end

        validate(validator, options)
      end
    end

    def validates_serialized_with!(*args, &block)
      options = args.extract_options!
      serialized_validator_class = args.shift
      args.each do |klass|
        validator = serialized_validator_class.new(args, options, &block)
        validator.validate(self)
      end
    end
  end
end
