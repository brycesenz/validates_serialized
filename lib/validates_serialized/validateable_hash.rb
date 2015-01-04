require 'active_model'

class ValidateableHash < Hash
  include ::ActiveModel::Validations

  def initialize(hash)
    @hash = hash
    define_attributes(hash)
  end

  private
  def define_attributes(hash)
    hash.each_pair do |key, value|
      self.class.send(:define_method, "#{key}") do
        value
      end
    end
  end
end