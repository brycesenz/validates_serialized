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
    validates :name, precence: true
    validatse :age, numericality: { greater_than: 21 }
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

## Validating a serialized hash

## Validating a serialized array


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
