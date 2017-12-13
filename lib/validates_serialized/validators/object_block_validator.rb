module ActiveModel
  module Validations
    class ObjectBlockValidator < BlockValidator #:nodoc:
      def initialize(options, &block)
        @block = block
        @options = options
        super
      end

      private
      def validate_each(record, attribute, value)
        error_hash = get_serialized_object_errors(value, record)
        add_errors_to_record(record, attribute, error_hash)
        ValidateableObject.clear_validators!
      end

      def build_serialized_object(value, record)
        ValidateableObject.clear_validators!
        ValidateableObject.new(value, record)
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
      def validates_serialized(*attr_names, &block)
        raise ArgumentError, "You need to supply at least one attribute" if attr_names.empty?
        validates_with ObjectBlockValidator, _merge_attributes(attr_names), &block
      end

      def validates_serialized!(*attr_names, &block)
        options = attr_names.extract_options!
        options[:strict] = true
        validates_serialized(*(attr_names << options), &block)
      end
    end
  end
end
