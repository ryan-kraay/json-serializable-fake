require "json"

module JSON::Serializable::Fake
  VERSION = "0.0.1"
end

module JSON::Serializable # < reference documentation
end

module JSON
  # :nodoc:
  annotation FakeField
  end

  # `JSON::Serializable::Fake` allows method calls to generate JSON content.
  #
  # ### Example
  #
  # ```
  # require "json/fakefield"
  #
  # class Sum
  #   include JSON::Serializable
  #   include JSON::Serializable::Fake
  #
  #   property a : UInt32
  #   property b : UInt32
  #
  #   def initialize(@a, @b)
  #   end
  #
  #   @[JSON::FakeField]
  #   def sum(json : ::JSON::Builder) : Nil
  #     json.number(a + b)
  #   end
  # end
  #
  # s = Sum.new(10, 5)
  # puts s.to_json # => { "a": 10, "b": 5, "sum": 15 }
  # ```
  #
  # ### Usage
  #
  # `JSON::Serializable::Fake` will create `extend_to_json` (which will actually call
  # your methods) and will replace the `on_to_json` method generated by `JSON::Serializable`.
  #
  # `JSON::Serializable::Fake` **is** compatible with `JSON::Serializable::Unmapped` and
  # `JSON::Serializable::Strict` _as long as_ `JSON::Serializable::Fake` is included **last**.
  #
  # You can customize the behavior of each fake field via the `JSON::FakeField` annotation.
  # Method calls **MUST** accept `::JSON::Builder` as a parameter and return `::Nil`.  The
  # construction of JSON elements is handled via [::JSON::Builder](https://github.com/crystal-lang/crystal/blob/master/src/json/builder.cr#L6).
  #
  # `JSON::FakeField` properties:
  # * **key**: an explicit name of the field added to the json string (by default it uses the method name)
  # * **suppress_key**: if `true` no json field will be implictly added.  This allows the method call to create multiple json fields
  #
  # WARNING: At the moment it is **not** possible to deserialize fake fields into a method call.  There is no technical limitation,
  # just a lack of time.  However, you can use `JSON::Serializable::Unmapped` to capture all the fake fields.
  #
  module Serializable::Fake
    # heavily modelled after:
    # https://github.com/crystal-lang/crystal/blob/fda656c71/src/json/serialization.cr#L181
    def to_json(json : ::JSON::Builder)
      {% begin %}
        {% options = @type.annotation(::JSON::Serializable::Options) %}
        {% emit_nulls = options && options[:emit_nulls] %}

        {% properties = {} of Nil => Nil %}
        {% for ivar in @type.instance_vars %}
          {% ann = ivar.annotation(::JSON::Field)
             key = ((ann && ann[:key]) || ivar).id %}
          {% unless ann && (ann[:ignore] || ann[:ignore_serialize] == true) %}
            {%
              properties[key] = {
                key:              key.stringify,
                root:             ann && ann[:root],
                converter:        ann && ann[:converter],
                emit_null:        (ann && (ann[:emit_null] != nil) ? ann[:emit_null] : emit_nulls),
                ignore_serialize: ann && ann[:ignore_serialize],
                ivar:             ivar.id,
                imeth:            nil,
                suppress_key:     nil,
              }
            %}
          {% end %}
        {% end %}

        {% for t in (@type.ancestors + [@type]) %}
          {% for imeth in t.methods %}
            {% ann = imeth.annotation(::JSON::FakeField) %}
            {% if ann && !(ann[:ignore] || ann[:ignore_serialize] == true) %}
              {%
                key = ((ann && ann[:key]) || imeth.name).id
                properties[key] = {
                  key:              key.stringify,
                  root:             nil,
                  converter:        nil,
                  emit_null:        nil,
                  ignore_serialize: nil,
                  ivar:             nil,
                  imeth:            imeth.name,
                  suppress_key:     (ann && ann[:suppress_key]),
                }
              %}
            {% end %}
          {% end %}
        {% end %}

        json.object do
          {% for name, value in properties %}
            {% if value[:imeth] %}
              {% if value[:suppress_key] %}
                {{ value[:imeth] }} json
              {% else %}
                json.field {{ value[:key] }} do
                  {{ value[:imeth] }} json
                end
              {% end %}
            {% else %}
              {% name = value[:ivar] %}
              _{{name}} = @{{name}}

              {% if value[:ignore_serialize] %}
                unless {{ value[:ignore_serialize] }}
              {% end %}

                {% unless value[:emit_null] %}
                  unless _{{name}}.nil?
                {% end %}

                  json.field({{value[:key]}}) do
                    {% if value[:root] %}
                      {% if value[:emit_null] %}
                        if _{{name}}.nil?
                          nil.to_json(json)
                        else
                      {% end %}

                      json.object do
                        json.field({{value[:root]}}) do
                    {% end %}

                    {% if value[:converter] %}
                      if _{{name}}
                        {{ value[:converter] }}.to_json(_{{name}}, json)
                      else
                        nil.to_json(json)
                      end
                    {% else %}
                      _{{name}}.to_json(json)
                    {% end %}

                    {% if value[:root] %}
                      {% if value[:emit_null] %}
                        end
                      {% end %}
                        end
                      end
                    {% end %}
                  end

                {% unless value[:emit_null] %}
                  end
                {% end %}
              {% if value[:ignore_serialize] %}
                end
              {% end %}
            {% end %}
          {% end %}
          on_to_json(json)
        end
      {% end %}
    end
  end
end
