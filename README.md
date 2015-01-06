# Validates Serialized

ActiveModel provides ways to validate attributes, and to serialize objects.  This gem provides some ActiveModel extensions and syntactic sugar to simplify the process of validating those serialized objects.

This gem provides:
  * A generic validation method that supports any serializable object
  * A validation method for serialized hashes, to validate specific key values
  * A validation method for serialized hashes, to support validating all hash values
  * A validation method for serialized arrays, to support validating all array values

## Installation

Add this line to your application's Gemfile:

    gem 'validates_serialized', '~> 0.0.1'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install validates_serialized

## Validating a generic object

Here we have an example, serializable class called 'Person' with a name and age attribute.

```ruby
class Person
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
```

Now we can serialize this object and validate its properties in another class

```ruby
class Family < ActiveRecord::Base
  include ActiveModel
  ...

  serialize :father, Person
  validates_serialized :father do
    validates :name, presence: true
    validates :age, numericality: { greater_than: 21 }
  end
end
```
The validations will be run against the serialized object whenever validation hooks are fired.  E.g.

```ruby
# With valid serialized object
valid_father = Person.new(name: "Bob", age: 31)
family = Family.new(father: valid_father)
family.valid? #=> true

# With invalid serialized object
valid_father = Person.new(name: "Bob", age: 13)
family = Family.new(father: valid_father)
family.valid? #=> false
family.errors[:father] #=> ["age must be greater than 13"]
```

## Validating a serialized hash by keys
```ruby
class Comment < ActiveRecord::Base
  include ActiveModel
  ...

  serialize :metadata, Hash
  validates_hash_keys :metadata do
    validates :timestamp, presence: true
    validates :locale, presence: true
  end
end

# With valid hash
comment = Comment.new(metadata: { timestamp: Time.new(2014, 1, 1), locale: "Ohio" })
comment.valid? #=> true

# With invalid hash
comment = Comment.new(metadata: { timestamp: Time.new(2014, 1, 1), locale: nil })
comment.valid? #=> false
comment.errors[:metadata] #=> ["locale can't be blank"]
```

## Validating serialized hash values
```ruby
class Comment < ActiveRecord::Base
  include ActiveModel
  ...

  serialize :ratings, Hash
  validates_hash_values_with :ratings, numericality: { greater_than: 0 }
end

# With valid hash
comment = Comment.new(ratings: { tom: 4, jim: 2 })
comment.valid? #=> true

# With invalid hash
comment = Comment.new(ratings: { tom: 4, jim: -1 })
comment.valid? #=> false
comment.errors[:ratings] #=> ["ratings must be greater than 0"]
```

## Validating a serialized array (syntax #1)
```ruby
class Comment < ActiveRecord::Base
  include ActiveModel
  ...

  serialize :tags, Array
  validates_array_values_with :tags, length: { minimum: 4 }
end

# With valid hash
comment = Comment.new(tags: ["ruby" "rails"])
comment.valid? #=> true

# With invalid hash
comment = Comment.new(tags: ["ruby" "rails", "ror"])
comment.valid? #=> false
comment.errors[:tags] #=> ["tags is too short (minimum is 4 characters)"]
```

## Validating a serialized array (syntax #2)
```ruby
class Comment < ActiveRecord::Base
  include ActiveModel
  ...

  serialize :tags, Array
  validates_each_in_array :tags do
    validates :value, length: { minimum: 4 } #the attribute 'value' with access each value
  end
end

# With valid hash
comment = Comment.new(tags: ["ruby" "rails"])
comment.valid? #=> true

# With invalid hash
comment = Comment.new(tags: ["ruby" "rails", "ror"])
comment.valid? #=> false
comment.errors[:tags] #=> ["tags is too short (minimum is 4 characters)"]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
