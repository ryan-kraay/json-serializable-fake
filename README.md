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

## Limitations

1. This library only supports JSON _Serialization_ (not YAML).  There is no technical reason for this limitation, just a lack of time.
2. This library only support _Serialization_.  _Deserializing_ into a method call is not support.  Again, there is no technical limitation, only time.  However, `JSON::FakeFields` will appear as `objecct.json_unmapped[<fakefield>]`, when `JSON::Serializable::Unmapped` is used.

## Contributing

1. Fork it (<https://github.com/ryan-kraay/json-serializable-fake/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
