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

      it "adds error for invalid value" do
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

  context "#validates_hash_keys!" do
    class ValidatorBlockHashTestStrict
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

      validates_hash_keys! :my_attr do
        validates :first_key, presence: true
        validates :second_key, inclusion: { in: [1, 2, 3, 4] }
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorBlockHashTestStrict.new(my_attr: {first_key: 2, second_key: 3})
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "raises error for invalid value" do
        record = ValidatorBlockHashTestStrict.new(my_attr: {first_key: 2, second_key: 5})
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'second_key is not included in the list')
      end

      it "raises error for multiple invalid value" do
        record = ValidatorBlockHashTestStrict.new(my_attr: {first_key: nil, second_key: 9})
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "first_key can't be blank")
      end

      it "raises error for non-array" do
        record = ValidatorBlockHashTestStrict.new(my_attr: 4)
        expect { record.valid? }.to raise_error(TypeError, 'my_attr is not a Hash')
      end
    end
  end
end