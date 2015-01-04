require 'spec_helper'

describe ValidateableArray do
  let!(:array) { Array.new }

  subject { described_class.new(array) }

  it "responds to valid?" do
    subject.should be_valid
  end

  it "responds to .errors" do
    subject.errors.should be_empty
  end
end