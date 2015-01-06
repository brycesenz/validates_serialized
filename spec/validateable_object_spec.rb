require 'spec_helper'

describe ValidateableObject do
  class TestPerson
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

  let!(:object) { TestPerson.new(age: 26, name: "Thomas") }

  subject { described_class.new(object) }

  it "responds to valid?" do
    subject.should be_valid
  end

  it "responds to .errors" do
    subject.errors.should be_empty
  end

  describe "delegating attributes" do
    it "delegates age attribute" do
      subject.age.should eq(26)
    end

    it "delegates name attribute" do
      subject.name.should eq("Thomas")
    end

    it "delegates object methods without error" do
      expect { subject.object_id }.not_to raise_error
    end

    it "does not raise error for non-existent methods" do
      expect { subject.arglebargle }.not_to raise_error
    end
  end

  describe "validation block" do
    it "validates when passes validation methods" do
      subject.class_eval do
        validates :name, presence: true
        validates :age, presence: true
      end
      subject.should be_valid
    end

    it "handles errors when invalid" do
      subject.class_eval do
        validates :name, inclusion: { in: [ 'a', 'b', 'c' ] }
      end
      subject.should_not be_valid
      subject.errors[:name].should eq(["is not included in the list"])
    end

    it "raises error when validating non-existent property" do
      subject.class_eval do
        validates :other_property, inclusion: { in: [ 'a', 'b', 'c' ] }
      end
      expect { subject.valid? }.not_to raise_error
    end
  end
end