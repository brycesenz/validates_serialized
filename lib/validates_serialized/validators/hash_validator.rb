module ActiveModel
  module Validations
    class HashValidator < ::ActiveModel::EachValidator #:nodoc:
      def initialize(*args, &block)
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
          hash = record.read_attribute_for_validation(attribute)
          raise TypeError, "#{array} is not a Hash" unless hash.is_a?(Hash)
          array.each_pair do |key, value|
            next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
            # TODO: It would be great to add errors to the keys, but it throws a method error
            # validate_each(record, :"#{attribute}[#{key}]", value)
            validate_each(record, attribute, value)
          end
        end
      end

      def validate_each(record, attribute, value)
        @validators.each do |validator|
          validator.validate_each(record, attribute, value)
        end
      end
    end

    module ClassMethods
      def validates_hash_with(*args, &block)
        options = args.extract_options!
        options[:class] = self

        validator = HashValidator.new(args, options, &block)

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

    def validates_hash_with(*args, &block)
      options = args.extract_options!
      args.each do |klass|
        validator = HashValidator.new(args, options, &block)
        validator.validate(self)
      end
    end
  end
end
