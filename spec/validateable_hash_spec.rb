require 'spec_helper'

describe ValidateableHash do
  let!(:hash) { { key_1: "boy", key_2: "girl" } }
  let!(:record) { double }

  subject { described_class.new(record, hash) }

  it "responds to valid?" do
    subject.should be_valid
  end

  it "responds to .errors" do
    subject.errors.should be_empty
  end

  describe "attributes" do
    it "defines key_1 attribute" do
      subject.key_1.should eq("boy")
    end

    it "defines key_2 attribute" do
      subject.key_2.should eq("girl")
    end

    it "returns nil for non-existent key_3" do
      subject.key_3.should be_nil
    end

    it "delegates object methods without error" do
      expect { subject.object_id }.not_to raise_error
    end

    it "does not raises error for non-existent methods" do
      expect { subject.arglebargle }.not_to raise_error
    end
    context "foo" do
      let!(:hash) { {"key_1" => "boy"} }
      it "defines key_1 attribute" do
        subject.key_1.should eq("boy")
      end
    end
  end

  describe "validation block" do
    it "validates when passes validation methods" do
      subject.class_eval do
        validates :key_1, presence: true
      end
      subject.should be_valid
    end

    it "handles errors when invalid" do
      subject.class_eval do
        validates :key_1, inclusion: { in: [ 'a', 'b', 'c' ] }
      end
      subject.should_not be_valid
      subject.errors[:key_1].should eq(["is not included in the list"])
    end

    it "is invalid when validating non-existent property" do
      subject.class_eval do
        validates :other_key, inclusion: { in: [ 'a', 'b', 'c' ] }
      end
      subject.should_not be_valid
      subject.errors[:other_key].should eq(["is not included in the list"])
    end
  end
end
