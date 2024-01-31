<div align="center">
  <a href="https://github.com/ryan-kraay/json-serializable-fake/" target="_blank" rel="noopener noreferrer">
    <img width="300" src="https://raw.githubusercontent.com/ryan-kraay/json-serializable-fake/master/assets/logo.png" alt="Logo">
  </a>
  
  <h1>Use JSON::Serializable to generate dynamic JSON/fields</h1>
  
  <p>
    <a href="https://github.com/ryan-kraay/json-serializable-fake/actions/workflows/ci.yml">
      <img src="https://github.com/ryan-kraay/json-serializable-fake/actions/workflows/ci.yml/badge.svg" alt="Build Status">
    </a>
    <a href="https://github.com/ryan-kraay/json-serializable-fake/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/ryan-kraay/json-serializable-fake.svg" alt="License">
    </a>
    <a href="https://ryan-kraay.github.io/json-serializable-fake/index.html">
      <img src="https://img.shields.io/badge/documentation-API-f06" alt="API Documentation">
    </a>
    <a href="https://github.com/ryan-kraay/json-serializable-fake/releases">
      <img src="https://img.shields.io/github/release/ryan-kraay/json-serializable-fake.svg" alt="GitHub release">
    </a>
  </p>

  <h3>
    <a href="https://github.com/ryan-kraay/json-serializable-fake/">Website</a>
    <span> • </span>
    <a href="https://ryan-kraay.github.io/json-serializable-fake/index.html">Shard Docs</a>
  </h3>
</div>

<hr/>


A Crystal Library which extends JSON::Serializable to allow JSON to be generated via method calls, instead of _requiring_ the use of variables.

**NOTE**:  This library _only_ supports **Serialization**.  **Deserialization** to _Fake FIelds_ is not possible.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     serializable-fake:
       github: ryan-kraay/json-serializable-fake
   ```

2. Run `shards install`

## Usage

```crystal
require "json"
require "json-serializable-fake"

class Sum
  include JSON::Serializable
  include JSON::Serializable::Fake

  property a : UInt32
  property b : UInt32

  def initialize(@a, @b)
  end

  @[JSON::FakeField]
  def sum(json : ::JSON::Builder) : Nil
    json.number(a + b)
  end
end

s = Sum.new(10, 5)
puts s.to_json    # => { "a": 10, "b": 5, "sum": 15 }
```

Additional documentation can be found [here](https://ryan-kraay.github.io/json-serializable-fake/JSON/Serializable/Fake.html).

## Features

This library was born out of desire to use classes and members to construct JSON object, but **also** to use methods to construct JSON fields that _do not necessarily need to be stored as members in a class definition_.

Some additional features:
* `JSON::FakeField(key: <name>)`:  creates a field with an explicit name (by default it uses the method name)
* `JSON::FakeField(supress_key: true)`:  if `true` no json field will be implicitly added.  This allows the method to create multiple json fields or an entire JSON document using `JSON::Builder`.
* Integrates with `JSON::Serializable` and `JSON::Serializable::Unmapped`:  this allows you to mix-and-match and create nested `JSON::Serializable` and `JSON::Serializable::Fake` objects.
* It is possible to change, manipulate, or remove `JSON::Serializable` fields _at runtime_.

**NOTE**:  The use of `JSON::Serializable` relies on an "opt-out" feature (ie: `JSON::Field(ignore_serialization: true)]`).  Meaning _all_ instance variables will be added to the json document, _unless you explicitly "opt-out"._.  `JSON::Serializable::Fake` relies on an "opt-in" for instance methods.  Meaning that _only_ those instance methods which contain the `JSON::FakeField` annotation will be added to the json document.

## Advanced Example

```crystal
require "json"
require "json-serializable-fake"

class User
  include JSON::Serializable
  include JSON::Serializable::Fake

  property first : String
  property last : String
  property password : String

  @[JSON::FakeField]
  def user(json : ::JSON::Builder) : Nil
    json.string( (@first + @last).downcase )
  end

  def initialize(@first, @last, @password)
  end
end

class SecuredUser < User
  property age : UInt32

  # replace our user() implementation via simple inheritance
  def user(json : ::JSON::Builder) : Nil
    json.string("retracted")
  end

  @[JSON::FakeField(key: password)]
  def hide_password(json : ::JSON::Builder) : Nil
    json.string("******")
  end

  @[JSON::FakeField(suppress_key: true)]
  def age(json : ::JSON::Builder) : Nil
    # Only show the age, if the user is over 18
    if age > 18
      json.field "age", @age
    end
  end

  def initialize(@first, @last, @age, @password)
  end
end

user = User.new("John", "Doe", "hunter2")
puts user.to_json     # => {"first":"John","last":"Doe","password":"hunter2","user":"johndoe"}

child = SecuredUser.new("Jimmy", "Doe", 5_u32, "hunter2")
puts child.to_json    # => {"first":"Jimmy","last":"Doe","password":"******","user":"retracted"}
puts child.password   # => hunter2

adult = SecuredUser.new("Jane", "Doe", 24_u32, "hunter2")
puts adult.to_json    # => {"first":"Jane","last":"Doe","password":"******","age":24,"user":"retracted"}
puts adult.password   # => hunter2

```

## Limitations

1. This library only supports JSON _Serialization_ (not YAML).  There is no technical reason for this limitation, just a lack of time.
2. This library only support _Serialization_.  _Deserializing_ into a method call is not support.  Again, there is no technical limitation, only time.  However, `JSON::FakeFields` will appear as `objecct.json_unmapped[<fakefield>]`, when `JSON::Serializable::Unmapped` is used.

## Contributing

1. Fork it (<https://github.com/ryan-kraay/json-serializable-fake/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
