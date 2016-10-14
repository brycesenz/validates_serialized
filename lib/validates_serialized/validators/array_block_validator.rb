module ActiveModel
  module Validations
    class ArrayBlockValidator < BlockValidator #:nodoc:
      def initialize(options, &block)
        @options = options
        super
      end

      private
      def validate_each(record, attribute, array)
        raise TypeError, "#{attribute} is not an Array" unless array.is_a?(Array)
        errors = get_serialized_object_errors(record, array)
        add_errors_to_record(record, attribute, errors)
      end

      def build_serialized_object(record, value)
        #TODO: For the Rails 4 version, I can just clear_validators! on the ValidateableHash
        temp_class = Class.new(ValidateableArrayValue)
        temp_class_name = "ValidateableArrayValue_#{SecureRandom.hex}"
        if self.class.constants.include?(temp_class_name)
          self.class.send(:remove_const, temp_class_name)
        end
        self.class.const_set(temp_class_name, temp_class)
        temp_class.new(record, value)
      end

      def get_serialized_object_errors(record, array)
        messages = []
        array.each do |value|
          serialized_object = build_serialized_object(record, value)
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
          message = I18n.t("activerecord.errors.messages.array_has_invalid_value",
            :attribute => attribute,
            :text => text,
            :default => "#{attribute} has a value that #{text}"
          )
          record.errors.add(attribute, message)
        end
        if exception = options[:strict]
          exception = ActiveModel::StrictValidationFailed if exception == true
          exception_message = record.errors[attribute].join(", ")
          raise exception, exception_message unless exception_message.blank?
        end
      end
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
