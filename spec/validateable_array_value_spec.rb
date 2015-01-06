require 'spec_helper'

describe ValidateableArrayValue do
  let!(:array) { [1, 2, 3] }
  let!(:value) { array.first }

  subject { described_class.new(value) }

  it "responds to valid?" do
    subject.should be_valid
  end

  it "responds to .errors" do
    subject.errors.should be_empty
  end

  it "returns itself on :value method" do
    subject.value.should eq(1)
  end
end