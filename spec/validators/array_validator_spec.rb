require 'spec_helper'
require 'ostruct'

describe ActiveModel::Validations::ArrayValidator do
  context "#validates_array_values" do
    class ValidatorArrayTestOne
      include ActiveModel::Validations
      validates_array_values :my_attr, presence: true, inclusion: { in: [1, 2, 3, 4] }

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= []
      end

      def my_attr=(val)
        @my_attr = val
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorArrayTestOne.new(my_attr: [2])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorArrayTestOne.new(my_attr: [1, 5])
        record.valid?
        record.errors[:my_attr].should eq(["is not included in the list"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorArrayTestOne.new(my_attr: [nil, 1, 7])
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "is not included in the list", "is not included in the list"])
      end

      it "raises error for non-array" do
        record = ValidatorArrayTestOne.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not an Array')
      end
    end
  end

  context "#validates_array_values!" do
    class ValidatorArrayTestStrict
      include ActiveModel::Validations
      validates_array_values! :my_attr, presence: true, inclusion: { in: [1, 2, 3, 4] }

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= []
      end

      def my_attr=(val)
        @my_attr = val
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorArrayTestStrict.new(my_attr: [2])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "raises error for invalid value" do
        record = ValidatorArrayTestStrict.new(my_attr: [1, 5])
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'My attr is not included in the list')
      end

      it "raises error for multiple invalid value" do
        record = ValidatorArrayTestStrict.new(my_attr: [nil, 1, 7])
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "My attr can't be blank")
      end

      it "raises error for non-array" do
        record = ValidatorArrayTestStrict.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not an Array')
      end
    end
  end

  context "with class #validates_array_with" do
    class ValidatorClassTest
      include ActiveModel::Validations
      validates_array_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= []
      end

      def my_attr=(val)
        @my_attr = val
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorClassTest.new(my_attr: [2])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorClassTest.new(my_attr: [1, nil])
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorClassTest.new(my_attr: [nil, 1, nil])
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
      end

      it "raises error for non-array" do
        record = ValidatorClassTest.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not an Array')
      end
    end
  end

  context "with instance #validates_array_with" do
    class ValidatorInstanceTest
      include ActiveModel::Validations

      validate :instance_validations
      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= []
      end

      def my_attr=(val)
        @my_attr = val
      end

      def instance_validations
        validates_array_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]
      end
    end

    describe "#validate", failing: true do
      it "does not raise error for valid value" do
        record = ValidatorInstanceTest.new(my_attr: [2])
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorInstanceTest.new(my_attr: [1, nil])
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorInstanceTest.new(my_attr: [nil, 1, nil])
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
      end

      it "raises error for non-array" do
        record = ValidatorInstanceTest.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not an Array')
      end
    end
  end
end