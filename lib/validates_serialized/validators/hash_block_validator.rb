module ActiveModel
  module Validations
    class HashBlockValidator < BlockValidator #:nodoc:
      def initialize(options, &block)
        @block = block
        super
      end

      private
      def validate_each(record, attribute, value)
        raise TypeError, "#{attribute} is not a Hash" unless value.is_a?(Hash)
        error_hash = get_serialized_object_errors(value)
        error_hash.each_pair do |key, array|
          message = array.join(", ")
          record.errors[attribute] << "#{key} #{message}"
        end
      end

      def get_serialized_object_errors(value)
        serialized_object = ValidateableHash.new(value)
        serialized_object.class_eval &@block
        serialized_object.valid?
        serialized_object.errors.messages
      end
    end

    module ClassMethods
      # Helper to accept arguments in the style of the +validates+ class method
      def validates_hash_keys(*attr_names, &block)
        raise ArgumentError, "You need to supply at least one attribute" if attr_names.empty?
        validates_with HashBlockValidator, _merge_attributes(attr_names), &block
      end

      def validates_hash_keys!(*attributes)
        options = attributes.extract_options!
        options[:strict] = true
        validates_hash_keys(*(attributes << options))
      end
    end
  end
end
