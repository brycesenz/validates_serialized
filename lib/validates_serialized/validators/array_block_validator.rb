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
        errors = get_serialized_object_errors(array)
        add_errors_to_record(record, attribute, errors)

        new_errors = {}

        record.errors.each do |attr, value|
          if attr.to_s.include?("value")
            record.errors.delete(attr)
            new_errors[attr.to_s.gsub(/value\.?/, "").to_sym] = value
          else
            new_errors[attr] = value
          end
        end

        record.errors.clear

        new_errors.each do |attr, value|
          record.errors.add(attr, value)
        end
      end

      def build_serialized_object(value)
        #TODO: For the Rails 4 version, I can just clear_validators! on the ValidateableHash
        temp_class = Class.new(ValidateableArrayValue)
        temp_class_name = "ValidateableArrayValue_#{SecureRandom.hex}"
        if self.class.constants.include?(temp_class_name)
          self.class.send(:remove_const, temp_class_name)
        end
        self.class.const_set(temp_class_name, temp_class)
        temp_class.new(value)
      end

      def get_serialized_object_errors(array)
        messages = {}
        array.each_with_index do |value, index|
          serialized_object = build_serialized_object(value)
          serialized_object.class_eval &@block
          serialized_object.valid?
          message = serialized_object.errors.messages
          messages[index] = message unless message.blank?
        end
        messages
      end

      def add_errors_to_record(record, attribute, error_hash)
        error_hash.each do |index, value|
          value.each do |subattribute, errors|
            if subattribute == :value
              field = "#{attribute}.#{index}"
            elsif subattribute.to_s.include?("value")
              attr = subattribute.to_s.gsub(/value\.?/, "").to_sym
              field = "#{attribute}.#{index}.#{attr}"
            else
              field = "#{attribute}.#{index}.#{subattribute}"
            end

            if options[:strict] == true
              raise ActiveModel::StrictValidationFailed, "#{field} #{errors.join(", ")}"
            end

            record.errors.add(field, errors.join(", "))
          end
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
