require "./spec_helper"
require "../src/json-serializable-fake"

Spectator.describe JSON::FakeField do
  @[JSON::Serializable::Options(ignore_deserialize: true)]
  class Sum
    include JSON::Serializable
    include JSON::Serializable::Fake

    property a : UInt32
    property b : UInt32

    def initialize(@a, @b)
    end

    def result
      r = to_json
      Hash(String, UInt32).from_json(r)
    end

    @[JSON::FakeField]
    def sum(json : ::JSON::Builder) : Nil
      json.number(a + b)
    end
  end

  let(a) { 10_u32 }
  let(b) { 5_u32 }

  subject { Sum.new(a, b).result }

  it "integrates with JSON::Serializable" do
    expect(subject["a"]).to eq(a)
    expect(subject["b"]).to eq(b)
    expect(subject["sum"]).to eq(a + b)
  end

  context "annotation" do
    class Mathy < Sum
      @[JSON::FakeField]
      def diff(json : ::JSON::Builder) : Nil
        json.number(a - b)
      end

      @[JSON::FakeField(key: multiply)]
      def mathamagic(json : ::JSON::Builder) : Nil
        json.number(a * b)
      end

      @[JSON::FakeField(suppress_key: true)]
      def create_multifields(json : ::JSON::Builder) : Nil
        json.field "div", (a / b).to_i
        json.field "const" do
          [a].each do |x|
            # it's also possible to delgate to any other object's .to_json method
            x.to_json json
          end
        end
      end
    end

    subject { Mathy.new(a, b).result }

    it "supports inheritance" do
      expect(subject["a"]).to eq(a)
      expect(subject["b"]).to eq(b)
      expect(subject["sum"]).to eq(a + b)
      expect(subject["diff"]).to eq(a - b)
    end

    it "#key" do
      expect(subject.has_key?("mathamagic")).to be_false
      expect(subject["multiply"]).to eq(a * b)
    end

    it "#supress_key" do
      expect(subject["div"]).to eq((a / b).to_i)
      expect(subject["const"]).to eq(a)
    end
  end

  context "enums" do
    # This was actually the usecase that started all this
    enum Color
      Red
      Green
      Blue
    end

    @[JSON::Serializable::Options(ignore_deserialize: true)]
    class Widget(T)
      include JSON::Serializable
      include JSON::Serializable::Fake

      property a : T
      property b : T

      def initialize(@a, @b)
      end

      @[JSON::FakeField]
      def types(json : ::JSON::Builder) : Nil
        json.array do
          T.each do |e|
            e.to_json(json)
          end
        end
      end
    end

    it "includes types" do
      # A universal widget that can be fed any enum type...
      widget = Widget.new(Color::Red, Color::Blue)
      expect(widget.to_json).to eq(%q({"a":"red","b":"blue","types":["red","green","blue"]}))
    end
  end

  context "JSON::Serializable::Unmapped" do
    class SumDeserializable
      include JSON::Serializable
      include JSON::Serializable::Unmapped
      include JSON::Serializable::Fake # This **MUST** be last

      property a : UInt32
      property b : UInt32

      def initialize(@a, @b)
      end

      @[JSON::FakeField]
      def sum(json : ::JSON::Builder) : Nil
        json.number(a + b)
      end
    end

    it "deserializes" do
      expected = SumDeserializable.new(a, b)
      results_text = expected.to_json
      expect(results_text).to be_a(String)

      parsed = Hash(String, UInt32).from_json(results_text)
      expect(parsed["a"]).to eq(a)
      expect(parsed["b"]).to eq(b)
      expect(parsed["sum"]).to eq(a + b)

      result = SumDeserializable.from_json(results_text)
      expect(result.a).to eq(expected.a)
      expect(result.b).to eq(expected.b)
      expect(result.json_unmapped["sum"]).to eq(a + b)
    end
  end

  context "inheritance" do
    class UniversalAnswer < Sum
      # we override the existing fake function
      def sum(json : ::JSON::Builder) : Nil
        json.number(universal_constant)
      end

      # add a new field
      property universal_constant : UInt32 = 42_u32
    end

    # The use of typecasting "as(Sum)", allows us to explore if we slice
    # classes.  Since Crystal Classes are referenced based, this should not
    # be a problem, but I'd like confirmation
    sample [UniversalAnswer.new(10_u32, 5_u32), UniversalAnswer.new(10_u32, 5_u32).as(Sum) ] do |subj|

      it "supports overriding fake functions" do
        expect(subj.to_json).to eq(%q({"a":10,"b":5,"universal_constant":42,"sum":42}))
        # verify that a function in our base class "Sum::result" calls the
        # proper child function "UniversalAnswer::sum"
        result = subj.result
        expect(result["sum"]).to eq(42_u32)
        # Even if we're referring to the parent class, we still
        # have access to the child's fields via the proxied .to_json method
        expect(result["universal_constant"]).to eq(42_u32)
        expect(result["a"]).to eq(a)
        expect(result["b"]).to eq(b)
      end
    end

  end
end
