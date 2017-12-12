module ActiveModel
  module Validations
    class HashBlockValidator < BlockValidator #:nodoc:
      def initialize(options, &block)
        @options = options
        super
      end

      private
      def validate_each(record, attribute, value)
        raise TypeError, "#{attribute} is not a Hash" unless value.is_a?(Hash)
        error_hash = get_serialized_object_errors(value, record)
        add_errors_to_record(record, attribute, error_hash)
        ValidateableHash.clear_validators!
      end

      def build_serialized_object(value, record)
        ValidateableHash.clear_validators!
        ValidateableHash.new(value, record)
      end

      def get_serialized_object_errors(value, record)
        serialized_object = build_serialized_object(value, record)
        serialized_object.class_eval &@block
        serialized_object.valid?
        serialized_object.errors.messages
      end

      def add_errors_to_record(record, attribute, error_hash)
        error_hash.each_pair do |key, array|
          text = array.join(", ")
          message = "#{key} #{text}"
          if exception = options[:strict]
            exception = ActiveModel::StrictValidationFailed if exception == true
            raise exception, message
          end
          record.errors.add(attribute, message)
        end
      end

      def get_message_from_error_hash(error_hash)
        message = nil
        error_hash.each_pair do |key, array|
          message = array.join(", ")
        end
        message
      end
    end

    module ClassMethods
      # Helper to accept arguments in the style of the +validates+ class method
      def validates_hash_keys(*attr_names, &block)
        raise ArgumentError, "You need to supply at least one attribute" if attr_names.empty?
        validates_with HashBlockValidator, _merge_attributes(attr_names), &block
      end

      def validates_hash_keys!(*attr_names, &block)
        options = attr_names.extract_options!
        options[:strict] = true
        validates_hash_keys(*(attr_names << options), &block)
      end
    end
  end
end
