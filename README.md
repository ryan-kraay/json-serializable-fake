<div align="center">
  <a href="https://github.com/ryan-kraay/serialize-fake-cr/" target="_blank" rel="noopener noreferrer">
    <img width="300" src="https://raw.githubusercontent.com/ryan-kraay/serialize-fake-cr/master/assets/logo.png" alt="Logo">
  </a>
  
  <h1>The Unofficial Stremio Addon SDK for Crystal</h1>
  
  <p>
    <a href="https://github.com/ryan-kraay/serialize-fake-cr/actions/workflows/ci.yml">
      <img src="https://github.com/ryan-kraay/serialize-fake-cr/actions/workflows/ci.yml/badge.svg" alt="Build Status">
    </a>
    <a href="https://github.com/ryan-kraay/serialize-fake-cr/blob/main/LICENSE">
      <img src="https://img.shields.io/github/license/ryan-kraay/serialize-fake-cr.svg" alt="License">
    </a>
    <a href="https://ryan-kraay.github.io/serialize-fake-cr/index.html">
      <img src="https://img.shields.io/badge/documentation-API-f06" alt="API Documentation">
    </a>
    <a href="https://github.com/ryan-kraay/serialize-fake-cr/releases">
      <img src="https://img.shields.io/github/release/ryan-kraay/serialize-fake-cr.svg" alt="GitHub release">
    </a>
  </p>

  <h3>
    <a href="https://github.com/ryan-kraay/serialize-fake-cr/">Website</a>
    <span> • </span>
    <a href="https://ryan-kraay.github.io/serialize-fake-cr/index.html">Shard Docs</a>
  </h3>
</div>

<hr/>


A Crystal Library which extends JSON::Serializable to allow JSON to be generated via method calls, instead of _requiring_ the use of variables.

**NOTE**:  This library _only_ supports **Serialization**.  **Deserialization** to _Fake FIelds_ is not possible.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     serialize-fake-cr:
       github: ryan-kraay/serialize-fake-cr
   ```

2. Run `shards install`

## Usage

```crystal
require "serialize-fake-cr"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/ryan-kraay/serialize-fake-cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ryan Kraay](https://github.com/ryan-kraay) - creator and maintainer
