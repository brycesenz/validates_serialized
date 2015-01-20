require 'spec_helper'
require 'ostruct'

describe ActiveModel::Validations::ArrayBlockValidator do
  context "#validates_each_in_array" do
    class ValidatorBlockArrayTestOne
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

      validates_each_in_array :my_attr do
        validates :value, presence: true
      end
    end

    describe "validating" do
      it "does not raise error for valid value" do
        record = ValidatorBlockArrayTestOne.new(my_attr: [2, 4])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorBlockArrayTestOne.new(my_attr: [nil, 4])
        record.valid?
        record.errors[:my_attr].should eq(["my_attr has a value that can't be blank"])
      end

      it "adds multiple errors for multiple invalid value" do
        record = ValidatorBlockArrayTestOne.new(my_attr: [nil, 4, nil])
        record.valid?
        record.errors[:my_attr].should eq(["my_attr has a value that can't be blank", "my_attr has a value that can't be blank"])
      end

      it "raises error for non-array" do
        record = ValidatorBlockArrayTestOne.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, 'my_attr is not an Array')
      end
    end

    describe "clearing ValidateableArrayValue validators" do
      it "clears validators after validation" do
        record = ValidatorBlockArrayTestOne.new(my_attr: [2, 4])
        record.valid?
        ValidateableArrayValue.validators.should be_empty        
      end
    end
  end

  context "#validates_each_in_array!" do
    class ValidatorBlockArrayTestStrict
      include ActiveModel::Validations

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= {}
      end

      def my_attr=(val)
        @my_attr = val
      end

      validates_each_in_array! :my_attr do
        validates :value, inclusion: { in: [1, 2, 3, 4] }
      end
    end

    describe "validating" do
      it "does not raise error for valid value" do
        record = ValidatorBlockArrayTestStrict.new(my_attr: [2, 3])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "raises error for invalid value" do
        record = ValidatorBlockArrayTestStrict.new(my_attr: [2, 5])
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'my_attr has a value that is not included in the list')
      end

      it "raises error for multiple invalid value" do
        record = ValidatorBlockArrayTestStrict.new(my_attr: [nil, 9])
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "my_attr has a value that is not included in the list, my_attr has a value that is not included in the list")
      end

      it "raises error for non-array" do
        record = ValidatorBlockArrayTestStrict.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, 'my_attr is not an Array')
      end
    end

    describe "clearing ValidateableArrayValue validators" do
      it "clears validators after validation" do
        record = ValidatorBlockArrayTestStrict.new(my_attr: [2, 3])
        record.valid?
        ValidateableArrayValue.validators.should be_empty        
      end
    end
  end
end