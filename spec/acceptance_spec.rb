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

class WebsiteUrl
  def initialize(h={})
    h.each {|k,v| send("#{k}=",v)}
  end

  def url
    @url ||= nil
  end

  def url=(val)
    @url = val
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

  def tags
    @tags
  end

  def tags=(val)
    @tags = val
  end

  def comments
    @comments
  end

  def comments=(val)
    @comments = val
  end

  def metadata
    @metadata
  end

  def metadata=(val)
    @metadata = val
  end

  validates_serialized :author do
    validates :name, presence: true
  end

  validates_array_values :ratings, inclusion: { in: [1, 2, 3] }

  validates_each_in_array :tags, if: :tags do
    validates :value, length: { in: 4..20 }
  end

  validates_each_in_array :metadata, if: :metadata do
    validates_hash_keys :value do
      validates :timestamp, presence: true
    end
  end

  validates_hash_keys :comments, allow_blank: true do
    validates :admin, presence: true
  end

  # validates_hash_keys :data, allow_blank: true do
  #   validates :url, presence: true, if: Proc.new{|f| f.required_data_field?(:url) }
  # end
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

  it "is valid with valid tags" do
    model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, tags: ["sweet", "awesome"])
    model.should be_valid
  end

  it "is valid with valid metadata" do
    model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, metadata: [{timestamp: Time.new(2014, 1, 2)}, {timestamp: Time.new(2014, 2, 2)}])
    model.should be_valid
  end

  it "is invalid without Serialized author" do
    model = Blog.new(ratings: [1, 3, 1], comments: { admin: "This is great!" })
    model.should_not be_valid
  end

  it "is invalid without author name" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new, comments: { admin: "This is great!" })
    model.should_not be_valid
    model.errors[:author].should eq(["name can't be blank"])
  end

  it "is invalid without comment admin key" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), comments: { other: "This is great!" })
    model.should_not be_valid
    model.errors[:"comments.admin"].should eq(["can't be blank"])
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

  it "is invalid with invalid tags" do
    model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, tags: ["sweet", "awesome", "i"])
    model.should_not be_valid
    model.errors["tags.2"].should eq(["is too short (minimum is 4 characters)"])
  end
end
