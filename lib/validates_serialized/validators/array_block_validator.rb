module ActiveModel
  module Validations
    class ArrayBlockValidator < BlockValidator #:nodoc:
      def initialize(options, &block)
        @block = block
        @options = options
        super
      end

      private
      def validate_each(record, attribute, array)
        raise TypeError, "#{attribute} is not an Array" unless array.is_a?(Array)
        errors = get_serialized_object_errors(array)
        add_errors_to_record(record, attribute, errors)
      end

      def get_serialized_object_errors(array)
        messages = []
        array.each do |value|
          serialized_object = ValidateableArrayValue.new(value)
          serialized_object.class_eval &@block
          serialized_object.valid?
          message = serialized_object.errors.messages[:value]
          messages << message unless message.blank?
        end
        messages
      end

      def add_errors_to_record(record, attribute, error_array)
        error_array.each do |value|
          text = value.join(", ")
          message = "#{attribute} has a value that #{text}"
          record.errors.add(attribute, message)
        end
        if exception = options[:strict]
          exception = ActiveModel::StrictValidationFailed if exception == true
          exception_message = record.errors[attribute].join(", ")
          raise exception, exception_message unless exception_message.blank?
        end
      end

      # def get_message_from_error_hash(error_hash)
      #   message = nil
      #   error_hash.each_pair do |key, array|
      #     message = array.join(", ")
      #   end
      #   message
      # end
    end

    module ClassMethods
      # Helper to accept arguments in the style of the +validates+ class method
      def validates_each_in_array(*attr_names, &block)
        raise ArgumentError, "You need to supply at least one attribute" if attr_names.empty?
        validates_with ArrayBlockValidator, _merge_attributes(attr_names), &block
      end

      def validates_each_in_array!(*attr_names, &block)
        options = attr_names.extract_options!
        options[:strict] = true
        validates_each_in_array(*(attr_names << options), &block)
      end
    end
  end
end
