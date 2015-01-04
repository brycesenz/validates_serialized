require 'spec_helper'
require 'ostruct'

describe ActiveModel::Validations::HashBlockValidator do
  context "#validates_hash_values" do
    class ValidatorBlockHashTestOne
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

      validates_hash_keys :my_attr do
        validates :first_key, presence: true
        validates :second_key, inclusion: { in: [1, 2, 3, 4] }
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorBlockHashTestOne.new(my_attr: { first_key: 2, second_key: 4 })
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value", failing: true do
        record = ValidatorBlockHashTestOne.new(my_attr: { first_key: nil, second_key: 4 })
        record.valid?
        record.errors[:my_attr].should eq(["first_key can't be blank"])
      end

      it "adds multiple errors for multiple invalid value" do
        record = ValidatorBlockHashTestOne.new(my_attr: { first_key: nil, second_key: 6 })
        record.valid?
        record.errors[:my_attr].should eq(["first_key can't be blank", "second_key is not included in the list"])
      end

      it "raises error for non-array" do
        record = ValidatorBlockHashTestOne.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, 'my_attr is not a Hash')
      end
    end
  end

  # context "#validates_hash_values!" do
  #   class ValidatorBlockHashTestStrict
  #     include ActiveModel::Validations
  #     validates_hash_values! :my_attr, presence: true, inclusion: { in: [1, 2, 3, 4] }

  #     def initialize(h={})
  #       h.each {|k,v| send("#{k}=",v)}
  #     end

  #     def my_attr
  #       @my_attr ||= []
  #     end

  #     def my_attr=(val)
  #       @my_attr = val
  #     end
  #   end

  #   describe "#validate" do
  #     it "does not raise error for valid value" do
  #       record = ValidatorBlockHashTestStrict.new(my_attr: {a: 2})
  #       record.valid?
  #       record.errors[:my_attr].should eq([])
  #     end

  #     it "raises error for invalid value" do
  #       record = ValidatorBlockHashTestStrict.new(my_attr: {a: 1, b: 5})
  #       expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'My attr is not included in the list')
  #     end

  #     it "raises error for multiple invalid value" do
  #       record = ValidatorBlockHashTestStrict.new(my_attr: {a: nil, b: 1, c: 7})
  #       expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "My attr can't be blank")
  #     end

  #     it "raises error for non-array" do
  #       record = ValidatorBlockHashTestStrict.new(my_attr: 4)
  #       expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
  #     end
  #   end
  # end

  # context "with class #validates_hash_with" do
  #   class ValidatorBlockHashClassTest
  #     include ActiveModel::Validations
  #     validates_hash_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]

  #     def initialize(h={})
  #       h.each {|k,v| send("#{k}=",v)}
  #     end

  #     def my_attr
  #       @my_attr ||= []
  #     end

  #     def my_attr=(val)
  #       @my_attr = val
  #     end
  #   end

  #   describe "#validate" do
  #     it "does not raise error for valid value" do
  #       record = ValidatorBlockHashClassTest.new(my_attr: {a: 2})
  #       record.valid?
  #       record.errors[:my_attr].should eq([])
  #     end

  #     it "adds error for invalid value" do
  #       record = ValidatorBlockHashClassTest.new(my_attr: {a: 1, b: nil})
  #       record.valid?
  #       record.errors[:my_attr].should eq(["can't be blank"])
  #     end

  #     it "adds multiple errors for invalid value" do
  #       record = ValidatorBlockHashClassTest.new(my_attr: {a: nil, b: 1, c: nil})
  #       record.valid?
  #       record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
  #     end

  #     it "raises error for non-array" do
  #       record = ValidatorBlockHashClassTest.new(my_attr: 4)
  #       expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
  #     end
  #   end
  # end

  # context "with instance #validates_hash_with" do
  #   class ValidatorBlockHashInstanceTest
  #     include ActiveModel::Validations

  #     validate :instance_validations
  #     def initialize(h={})
  #       h.each {|k,v| send("#{k}=",v)}
  #     end

  #     def my_attr
  #       @my_attr ||= []
  #     end

  #     def my_attr=(val)
  #       @my_attr = val
  #     end

  #     def instance_validations
  #       validates_hash_with ::ActiveModel::Validations::PresenceValidator, attributes: [:my_attr]
  #     end
  #   end

  #   describe "#validate" do
  #     it "does not raise error for valid value" do
  #       record = ValidatorBlockHashInstanceTest.new(my_attr: {a: 2})
  #       record.valid?
  #       record.errors[:my_attr].should eq([])
  #     end

  #     it "adds error for invalid value" do
  #       record = ValidatorBlockHashInstanceTest.new(my_attr: {a: 1, b: nil})
  #       record.valid?
  #       record.errors[:my_attr].should eq(["can't be blank"])
  #     end

  #     it "adds multiple errors for invalid value" do
  #       record = ValidatorBlockHashInstanceTest.new(my_attr: {a: nil, b: 1, c: nil})
  #       record.valid?
  #       record.errors[:my_attr].should eq(["can't be blank", "can't be blank"])
  #     end

  #     it "raises error for non-array" do
  #       record = ValidatorBlockHashInstanceTest.new(my_attr: 4)
  #       expect { record.valid? }.to raise_error(TypeError, '4 is not a Hash')
  #     end
  #   end
  # end
end