require 'spec_helper'

class Foo
  include ActiveModel::Validations

  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def my_array
    @my_array ||= []
  end

  def my_array=(val)
    @my_array = val
  end

  validates_array_values :my_array, inclusion: { in: ['a', 'b', 'c'] }
end

describe ValidatesSerialized do
  describe "#validating array" do
    it "accepts valid params" do
      model = Foo.new(my_array: ['a', 'a', 'b'])
      model.should be_valid
    end

    it "rejects invalid params" do
      model = Foo.new(my_array: ['a', 'x', 'b'])
      model.should_not be_valid
      model.errors[:my_array].should eq(["is not included in the list"])
    end
  end
end