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
    @enforce_min_length = true
  end

  attr_accessor :author, :ratings, :tags, :comments, :metadata, :data
  attr_accessor :enforce_min_length

  def needs_uuid?
    true
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

  validates_hash_keys :data, allow_blank: true do
    validates :url, presence: true, if: Proc.new{ |hsh| hsh.needs_url }
    validates :date, presence: true, if: Proc.new{ |hsh| hsh[:needs_date] }
    validates :slug, presence: true, if: :needs_slug?
    validates :uuid, presence: true, if: Proc.new{ |hsh| hsh.record.needs_uuid? }
    validates_each_in_array :posts, allow_blank: true do
      validates :value, length: { minimum: 5, if: Proc.new { |arr| arr.record.enforce_min_length } }
    end

    def needs_slug?
      true
    end
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

  it "is invalid with invalid tags" do
    model = Blog.new(ratings: [1, 3], author: Author.new(name: "Tom"), comments: { admin: "This is great!" }, tags: ["sweet", "awesome", "i"])
    model.should_not be_valid
    model.errors[:tags].should eq(["tags has a value that is too short (minimum is 4 characters)"])
  end

    it "is valid with dependent hash keys" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"),
                     data: { url: 'http://example.com',
                             needs_url: true,
                             date: 'yesterday',
                             needs_date: true,
                             slug: 'blog-name',
                             uuid: '123-abc-456-def' })
    model.should be_valid
  end

  it "is valid with dependent nested array values" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), data: { posts: %w[hello world fantastic], uuid: '123-abc-456-def', slug: 'blog-name' })
    model.should be_valid

    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), data: { posts: %w[wow], uuid: '123-abc-456-def', slug: 'blog-name' })
    model.enforce_min_length = false
    model.should be_valid
  end

  it "is invalid with missing dependent hash keys" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"),
                     data: { needs_url: true,
                             needs_date: true })
    model.should_not be_valid
    model.errors.details[:data].map { |err| err[:error].split[0] }.sort.should eql %w[date slug url uuid]
  end

  it "is invalid with incorrect dependent nested array values" do
    model = Blog.new(ratings: [1, 3, 1], author: Author.new(name: "Tom"), data: { posts: %w[wow], uuid: '123-abc-456-def', slug: 'blog-name' })
    model.should_not be_valid
  end
end
