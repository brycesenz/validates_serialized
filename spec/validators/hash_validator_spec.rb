require 'spec_helper'
require 'ostruct'

describe ActiveModel::Validations::HashValidator do
  context "#validates_hash_values" do
    class ValidatorHashTestOne
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

      validates_hash_values :my_attr, presence: true, inclusion: { in: [1, 2, 3, 4] }
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorHashTestOne.new(my_attr: { a: 2 })
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorHashTestOne.new(my_attr: { a: 1, b: 5 })
        record.valid?
        record.errors[:my_attr].should eq(["is not included in the list"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorHashTestOne.new(my_attr: { a: nil, b: 1, c: 7 })
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "is not included in the list", "is not included in the list"])
      end

      it "raises error for non-array" do
        record = ValidatorHashTestOne.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
      end
    end
  end

  context "#validates_hash_values!" do
    class ValidatorHashTestStrict
      include ActiveModel::Validations
      validates_hash_values! :my_attr, presence: true, inclusion: { in: [1, 2, 3, 4] }

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
        record = ValidatorHashTestStrict.new(my_attr: {a: 2})
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "raises error for invalid value" do
        record = ValidatorHashTestStrict.new(my_attr: {a: 1, b: 5})
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'My attr is not included in the list')
      end

      it "raises error for multiple invalid value" do
        record = ValidatorHashTestStrict.new(my_attr: {a: nil, b: 1, c: 7})
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "My attr can't be blank")
      end

      it "raises error for non-array" do
        record = ValidatorHashTestStrict.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
      end
    end
  end

  context "with class #validates_hash_values_with" do
    class ValidatorHashClassTest
      include ActiveModel::Validations
      validates_hash_values_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]

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
        record = ValidatorHashClassTest.new(my_attr: {a: 2})
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorHashClassTest.new(my_attr: {a: 1, b: nil})
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorHashClassTest.new(my_attr: {a: nil, b: 1, c: nil})
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
      end

      it "raises error for non-array" do
        record = ValidatorHashClassTest.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
      end
    end
  end

  context "with instance #validates_hash_values_with" do
    class ValidatorHashInstanceTest
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
        validates_hash_values_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorHashInstanceTest.new(my_attr: {a: 2})
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorHashInstanceTest.new(my_attr: {a: 1, b: nil})
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank"])
      end

      it "adds multiple errors for invalid value" do
        record = ValidatorHashInstanceTest.new(my_attr: {a: nil, b: 1, c: nil})
        record.valid?
        record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
      end

      it "raises error for non-array" do
        record = ValidatorHashInstanceTest.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
      end
    end
  end
end