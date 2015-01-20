require 'spec_helper'

class Consumer
  include ActiveModel::Validations

  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def income_sources
    @income_sources || []
  end

  def income_sources=(val)
    @income_sources = val
  end

  def credit_card
    @credit_card || {}
  end

  def credit_card=(val)
    @credit_card = val
  end

  validates_hash_keys :credit_card do
    validates :brand, presence: true, inclusion: { in: ['visa', 'mastercard'] }
    validates :number, presence: true, length: { minimum: 10 }
  end

  validates :income_sources, presence: true
  validates_each_in_array :income_sources do
    validates_hash_keys :value do
      validates :name, presence: true
      validates :amount, presence: true, numericality: { greater_than: 0 }
    end
  end
end

describe Consumer do
  it "does not add error for valid income_sources" do
    model = described_class.new(income_sources: [{ amount: 40, name: "Widget Co." }])
    model.valid?
    model.errors[:income_sources].should be_empty
  end

  it "adds correct income_sources errors" do
    model = described_class.new(income_sources: [{ amount: -40 }])
    model.valid?
    model.errors[:income_sources].should eq(["income_sources has a value that name can't be blank, amount must be greater than 0"])
  end

  it "does not add error for valid credit_card" do
    model = described_class.new(credit_card: { brand: "visa", number: "4111333322221111" }, income_sources: [{name: nil}])
    model.valid?
    model.errors[:credit_card].should be_empty
  end

  it "adds correct credit_card errors" do
    model = described_class.new(credit_card: { number: "112233" })
    model.valid?
    model.errors[:credit_card].should eq(["brand can't be blank, is not included in the list", "number is too short (minimum is 10 characters)"])
  end

  # it "is valid without comments" do
  #   model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"))
  #   model.should be_valid
  # end

  # it "is valid with valid tags" do
  #   model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, tags: ["sweet", "awesome"])
  #   model.should be_valid
  # end

  # it "is valid with valid metadata" do
  #   model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, metadata: [{timestamp: Time.new(2014, 1, 2)}, {timestamp: Time.new(2014, 2, 2)}])
  #   model.should be_valid
  # end

  # it "is invalid without Serialized author" do
  #   model = Blog.new(ratings: [1, 3, 1], comments: { admin: "This is great!" })
  #   model.should_not be_valid
  # end

  # it "is invalid without author name" do
  #   model = Blog.new(ratings: [1, 3, 1], author: Author.new, comments: { admin: "This is great!" })
  #   model.should_not be_valid
  #   model.errors[:author].should eq(["name can't be blank"])
  # end

  # it "is invalid without comment admin key" do
  #   model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), comments: { other: "This is great!" })
  #   model.should_not be_valid
  #   model.errors[:comments].should eq(["admin can't be blank"])
  # end

  # it "raises error without ratings" do
  #   model = Blog.new(ratings: nil, author: Author.new(name: "Tom"), comments: { admin: "This is great!" })
  #   expect { model.valid? }.to raise_error
  # end

  # it "is invalid with invalid ratings value" do
  #   model = Blog.new(ratings: [1, 8], author: Author.new(name: "Tom"), comments: { admin: "This is great!" })
  #   model.should_not be_valid
  #   model.errors[:ratings].should eq(["is not included in the list"])
  # end

  # it "is invalid with invalid tags" do
  #   model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, tags: ["sweet", "awesome", "i"])
  #   model.should_not be_valid
  #   model.errors[:tags].should eq(["tags has a value that is too short (minimum is 4 characters)"])
  # end
end