require 'spec_helper'
require 'ostruct'

class MyValidator < ::ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if invalid_format?(value)
      record.errors.add(attribute, "is an invalid email")
    end
  end

  def invalid_format?(email)
    email !~ /.*\@gmail\.com/
  end
end

class MyTestClass < OpenStruct
  include ActiveModel::Validations
end

describe ActiveModel::EachValidator do
  describe "#validate_each_in_array" do
    it "does not add errors for all valid values" do
      record = MyTestClass.new(my_attr: ["tom@gmail.com"])
      MyValidator.new(attributes: [:my_attr]).validate_each_in_array(record)
      record.errors.should be_empty
    end

    it "adds errors for single invalid value" do
      record = MyTestClass.new(my_attr: ["tom"])
      MyValidator.new(attributes: [:my_attr]).validate_each_in_array(record)
      record.errors[:"my_attr[0]"].should eq(["is an invalid email"])
    end

    it "adds errors for multiple invalid value" do
      record = MyTestClass.new(my_attr: ["tom", "rob@gmail.com", "steve@email.com"])
      MyValidator.new(attributes: [:my_attr]).validate_each_in_array(record)
      record.errors[:"my_attr[0]"].should eq(["is an invalid email"])
      record.errors[:"my_attr[1]"].should eq([])
      record.errors[:"my_attr[2]"].should eq(["is an invalid email"])
    end

    it "raises TypeError for non array" do
      record = MyTestClass.new(my_attr: {email: "tom"})
      expect { MyValidator.new(attributes: [:my_attr]).validate_each_in_array(record) }.to raise_error(TypeError, '{:email=>"tom"} is not an array')
    end
  end
end