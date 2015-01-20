require 'spec_helper'
require 'ostruct'

describe ActiveModel::Validations::ObjectBlockValidator do
  class Foo
    def initialize(h={})
      h.each {|k,v| send("#{k}=",v)}
    end

    def name
      @name ||= nil
    end

    def name=(val)
      @name = val
    end

    def age
      @age ||= nil
    end

    def age=(val)
      @age = val
    end
  end

  context "#validates_serialized" do
    class ValidatorBlockObjectTestOne
      include ActiveModel::Validations

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= Foo.new
      end

      def my_attr=(val)
        @my_attr = val
      end

      validates_serialized :my_attr do
        validates :name, presence: true
        validates :age, inclusion: { in: [1, 2, 3, 4] }
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorBlockObjectTestOne.new(my_attr: Foo.new(name: "Tom", age: 4))
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "adds error for invalid value" do
        record = ValidatorBlockObjectTestOne.new(my_attr: Foo.new(name: nil, age: 4))
        record.valid?
        record.errors[:my_attr].should eq(["name can't be blank"])
      end

      it "adds multiple errors for multiple invalid value" do
        record = ValidatorBlockObjectTestOne.new(my_attr: Foo.new(name: nil, age: 9))
        record.valid?
        record.errors[:my_attr].should eq(["name can't be blank", "age is not included in the list"])
      end
    end

    describe "clearing ValidateableObject validators" do
      it "clears validators after validation" do
        record = ValidatorBlockObjectTestOne.new(my_attr: Foo.new(name: nil, age: 9))
        record.valid?
        ValidateableObject.validators.should be_empty        
      end
    end
  end

  context "#validates_serialized!" do
    class ValidatorBlockObjectTestStrict
      include ActiveModel::Validations

      def initialize(h={})
        h.each {|k,v| send("#{k}=",v)}
      end

      def my_attr
        @my_attr ||= Foo.new
      end

      def my_attr=(val)
        @my_attr = val
      end

      validates_serialized! :my_attr do
        validates :name, presence: true
        validates :age, inclusion: { in: [1, 2, 3, 4] }
      end
    end

    describe "#validate" do
      it "does not raise error for valid value" do
        record = ValidatorBlockObjectTestStrict.new(my_attr: Foo.new(name: "Jim", age: 3))
        record.valid?
        record.errors[:my_attr].should eq([])
      end

      it "raises error for invalid value" do
        record = ValidatorBlockObjectTestStrict.new(my_attr: Foo.new(name: "Jim", age: 9))
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, 'age is not included in the list')
      end

      it "raises error for multiple invalid value" do
        record = ValidatorBlockObjectTestStrict.new(my_attr: Foo.new(name: nil, age: 9))
        expect { record.valid? }.to raise_error(ActiveModel::StrictValidationFailed, "name can't be blank")
      end
    end

    describe "clearing ValidateableObject validators" do
      it "clears validators after validation" do
        record = ValidatorBlockObjectTestStrict.new(my_attr: Foo.new(name: "Jim", age: 3))
        record.valid?
        ValidateableObject.validators.should be_empty        
      end
    end
  end
end