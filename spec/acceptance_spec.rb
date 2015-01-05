require 'spec_helper'

class Author
  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def name
    @name ||= nil
  end

  def name=(val)
    @name = val
  end
end

class Blog
  include ActiveModel::Validations

  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def author
    @author
  end

  def author=(val)
    @author = val
  end

  def ratings
    @ratings
  end

  def ratings=(val)
    @ratings = val
  end

  def comments
    @comments
  end

  def comments=(val)
    @comments = val
  end

  validates_serialized :author do
    validates :name, presence: true
  end
  validates_array_values :ratings, inclusion: { in: [1, 2, 3] }
  validates_hash_keys :comments, allow_blank: true do 
    validates :admin, presence: true
  end
end

describe ValidatesSerialized do
  it "is valid with all params" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), comments: { admin: "This is great!" })
    model.should be_valid
  end

  it "is valid without comments" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"))
    model.should be_valid
  end

  it "raises error without Serialized author" do
    model = Blog.new(ratings: [1, 3, 1], comments: { admin: "This is great!" })
    expect { model.valid? }.to raise_error
  end

  it "is invalid without author name" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new, comments: { admin: "This is great!" })
    model.should_not be_valid
    model.errors[:author].should eq(["name can't be blank"])
  end

  it "is invalid without comment admin key" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), comments: { other: "This is great!" })
    model.should_not be_valid
    model.errors[:comments].should eq(["admin can't be blank"])
  end

  it "raises error without ratings" do
    model = Blog.new(ratings: nil, author: Author.new(name: "Tom"), comments: { admin: "This is great!" })
    expect { model.valid? }.to raise_error
  end

  it "is invalid with invalid ratings value" do
    model = Blog.new(ratings: [1, 8], author: Author.new(name: "Tom"), comments: { admin: "This is great!" })
    model.should_not be_valid
    model.errors[:ratings].should eq(["is not included in the list"])
  end
end