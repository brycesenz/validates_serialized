require "active_model"

module ActiveModel
  # Extending ActiveModel's EachValidator to add +validate_each_in_array+
  class EachValidator #:nodoc:
    # Performs validation on the supplied record. By default this will call
    # +validates_each+ to determine validity therefore subclasses should
    # override +validates_each+ with validation logic.
    def validate_each_in_array(record)
      attributes.each do |attribute|
        array = record.read_attribute_for_validation(attribute)
        raise TypeError, "#{array} is not an array" unless array.is_a?(Array)
        array.each_with_index do |value, index|
          next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
          validate_each(record, :"#{attribute}[#{index}]", value)
        end
      end
    end
  end
end