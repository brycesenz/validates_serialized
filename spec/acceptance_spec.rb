require 'spec_helper'

class Foo
  include ActiveModel::Validations

  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def my_attr
    @my_attr ||= []
  end

  def my_attr=(val)
    @my_attr = val
  end

  validates_array_values :my_attr, inclusion: { in: ['a', 'b', 'c'] }
end

describe ValidatesSerialized do
  describe "#validating array" do
  end
end