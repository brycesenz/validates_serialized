require 'spec_helper'

describe ValidateableArrayValue do
  let!(:array) { [1, 2, 3] }
  let!(:value) { array.first }
  let!(:record) { double }

  subject { described_class.new(record, value) }

  it "responds to valid?" do
    subject.should be_valid
  end

  it "responds to .errors" do
    subject.errors.should be_empty
  end

  describe "delegating attributes" do
    it "returns itself on :value method" do
      subject.value.should eq(1)
    end

    it "delegates object methods without error" do
      expect { subject.object_id }.not_to raise_error
    end

    it "does not raise error for non-existent methods" do
      expect { subject.arglebargle }.not_to raise_error
    end
  end
end
