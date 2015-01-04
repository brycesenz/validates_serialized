module ActiveModel
  module Validations
    class ArrayValidator < SerializedValidator #:nodoc:
      protected
      def validate_serialized(record, attribute, serialized)
        serialized.each do |value|
          next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
          validate_each(record, attribute, value)
        end
      end

      def type_check!(value)
        raise TypeError, "#{value} is not an Array" unless value.is_a?(Array)
      end
    end

    module ClassMethods
      def validates_array_with(*args, &block)
        # TODO: It would be nice for these to all make a call to 'validates_serialized_with'
        #    so that there's more code re-use
        # validates_serialized_with args.push(ArrayValidator), &block

        options = args.extract_options!
        options[:class] = self

        validator = ArrayValidator.new(args, options, &block)

        if validator.respond_to?(:attributes) && !validator.attributes.empty?
          validator.attributes.each do |attribute|
            _validators[attribute.to_sym] << validator
          end
        else
          _validators[nil] << validator
        end

        validate(validator, options)
      end

      # Helper to accept arguments in the style of the +validates+ class method
      def validates_array_values(*attributes)
        defaults = attributes.extract_options!.dup
        validations = defaults.slice!(*_validates_default_keys)

        raise ArgumentError, "You need to supply at least one attribute" if attributes.empty?
        raise ArgumentError, "You need to supply at least one validation" if validations.empty?

        defaults[:attributes] = attributes

        validations.each do |key, options|
          next unless options
          key = "#{key.to_s.camelize}Validator"

          begin
            validator = key.include?('::') ? key.constantize : const_get(key)
          rescue NameError
            raise ArgumentError, "Unknown validator: '#{key}'"
          end

          validates_array_with(validator, defaults.merge(_parse_validates_options(options)))
        end
      end

      def validates_array_values!(*attributes)
        options = attributes.extract_options!
        options[:strict] = true
        validates_array_values(*(attributes << options))
      end
    end

    def validates_array_with(*args, &block)
      options = args.extract_options!
      args.each do |klass|
        validator = ArrayValidator.new(args, options, &block)
        validator.validate(self)
      end
    end
  end
end
