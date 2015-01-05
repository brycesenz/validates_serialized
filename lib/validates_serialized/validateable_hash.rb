require 'active_model'

class ValidateableHash < Hash
  include ::ActiveModel::Validations

  def initialize(hash)
    @hash = hash
  end

  private
  def method_missing(method, *args, &block)
    # Delegate all methods to access the hash
    @hash[method]
  end
end