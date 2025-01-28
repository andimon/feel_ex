defmodule FeelEx.StringFunctionsTests do
  use ExUnit.Case
  alias FeelEx.Value

  describe "substring(string, index)" do
    test "with 0 index" do
      assert FeelEx.evaluate("substring(\"adsda\", 0)") == Value.new("")
    end

    test "with 3 index" do
      assert FeelEx.evaluate("substring(\"adadas\", 3)") == Value.new("adas")
    end

    test "with index greater than string length" do
      assert FeelEx.evaluate("substring(\"adsda\", 10)") == Value.new("")
    end

    test "with negative index" do
      assert FeelEx.evaluate("substring(\"adsda\", -2)") == Value.new("da")
    end

    test "with index within the string length" do
      assert FeelEx.evaluate("substring(\"elixir\", 2)") == Value.new("lixir")
    end
  end

  describe "substring(string, index, length)" do
    test "substring from a string starting at a valid index" do
      assert FeelEx.evaluate("substring(\"Hello, world!\", 7, 5)") == %Value{
               value: " worl",
               type: :string
             }
    end

    test "substring with a length longer than the string" do
      assert FeelEx.evaluate("substring(\"Hi\", 1, 10)") == %Value{value: "Hi", type: :string}
    end

    test "substring with index out of bounds (negative index)" do
      assert FeelEx.evaluate("substring(\"Hello\", -1, 3)") == %Value{value: "o", type: :string}
    end

    test "substring with index out of bounds (index too large)" do
      assert FeelEx.evaluate("substring(\"Hello\", 10, 3)") == %Value{value: "", type: :string}
    end

    test "substring with zero length" do
      assert FeelEx.evaluate("substring(\"Hello\", 1, 0)") == %Value{value: "", type: :string}
    end

    test "substring with index and length equal to the string length" do
      assert FeelEx.evaluate("substring(\"Hello\", 1, 5)") == %Value{
               value: "Hello",
               type: :string
             }
    end

    test "substring of an empty string" do
      assert FeelEx.evaluate("substring(\"\", 0, 3)") == %Value{value: "", type: :string}
    end

    test "substring with a negative length (invalid)" do
      assert FeelEx.evaluate("substring(\"Hello\", 1, -3)") == %Value{value: nil, type: :null}
    end

    test "substring with valid index but length exceeding string length" do
      assert FeelEx.evaluate("substring(\"abc\", 1, 10)") == %Value{value: "abc", type: :string}
    end

    test "substring with special characters in the string" do
      assert FeelEx.evaluate("substring(\"abc??/*\", 3, 4)") == %Value{
               value: "c??/",
               type: :string
             }
    end

    test "substring with invalid parameters" do
      assert FeelEx.evaluate("substring(12, 3, 4)") == Value.new(nil)
    end
  end

  describe "substring before(string1, string2)" do
    test "extract substring before the first occurrence of string2" do
      assert FeelEx.evaluate("substring before(\"213123\", \"31\")") == Value.new("21")
    end

    test "returns the empty string if string2 is not found" do
      assert FeelEx.evaluate("substring before(\"213123\", \"99\")") == Value.new("")
    end

    test "returns an empty string if string1 is empty" do
      assert FeelEx.evaluate("substring before(\"\", \"31\")") == Value.new("")
    end

    test "returns an empty string if string2 is empty" do
      assert FeelEx.evaluate("substring before(\"213123\", \"\")") == Value.new("")
    end

    test "returns the string before the first occurrence of string2 when string2 is at the beginning" do
      assert FeelEx.evaluate("substring before(\"313123\", \"31\")") == Value.new("")
    end

    test "handles case where string1 and string2 are the same" do
      assert FeelEx.evaluate("substring before(\"31\", \"31\")") == Value.new("")
    end

    test "works with multi-character substrings" do
      assert FeelEx.evaluate("substring before(\"thisisatest\", \"is\")") == Value.new("th")
    end
  end

  describe "substring after(string1, string2)" do
    test "extract substring after the first occurrence of string2" do
      assert FeelEx.evaluate("substring after(\"213123\", \"31\")") == Value.new("23")
    end

    test "returns an empty string if string2 is not found" do
      assert FeelEx.evaluate("substring after(\"213123\", \"99\")") == Value.new("")
    end

    test "returns empty string if string2 is empty" do
      assert FeelEx.evaluate("substring after(\"213123\", \"\")") == Value.new("")
    end

    test "returns an empty string if string1 is empty" do
      assert FeelEx.evaluate("substring after(\"\", \"31\")") == Value.new("")
    end

    test "returns everything after the first occurrence of string2 when string2 is at the beginning" do
      assert FeelEx.evaluate("substring after(\"31abc\", \"31\")") == Value.new("abc")
    end

    test "works with multi-character substrings" do
      assert FeelEx.evaluate("substring after(\"thisisatest\", \"is\")") == Value.new("atest")
    end

    test "handles case where string1 and string2 are the same" do
      assert FeelEx.evaluate("substring after(\"31\", \"31\")") == Value.new("")
    end
  end

  describe "contains(string1, string2)" do
    test "returns true when string1 contains string2" do
      assert FeelEx.evaluate("contains(\"hello world\", \"world\")") == Value.new(true)
    end

    test "returns false when string1 does not contain string2" do
      assert FeelEx.evaluate("contains(\"hello world\", \"planet\")") == Value.new(false)
    end

    test "returns true when string2 is empty" do
      assert FeelEx.evaluate("contains(\"hello world\", \"\")") == Value.new(true)
    end

    test "returns true when string1 and string2 are identical" do
      assert FeelEx.evaluate("contains(\"hello\", \"hello\")") == Value.new(true)
    end

    test "returns true when string2 is at the beginning of string1" do
      assert FeelEx.evaluate("contains(\"hello world\", \"hello\")") == Value.new(true)
    end

    test "returns true when string2 is at the end of string1" do
      assert FeelEx.evaluate("contains(\"hello world\", \"world\")") == Value.new(true)
    end

    test "returns false when string1 is empty" do
      assert FeelEx.evaluate("contains(\"\", \"hello\")") == Value.new(false)
    end

    test "handles case sensitivity" do
      assert FeelEx.evaluate("contains(\"Hello World\", \"world\")") == Value.new(false)
    end

    test "handles special characters" do
      assert FeelEx.evaluate("contains(\"hello!@ world\", \"!@\")") == Value.new(true)
    end
  end

  describe "string length(string)" do
    test "length of a non-empty string" do
      assert FeelEx.evaluate("string length(\"Hello, world!\")") == %Value{
               value: 13,
               type: :number
             }
    end

    test "length of an empty string" do
      assert FeelEx.evaluate("string length(\"\")") == %Value{value: 0, type: :number}
    end

    test "length of a string with spaces" do
      assert FeelEx.evaluate("string length(\"   \")") == %Value{value: 3, type: :number}
    end

    test "length of a string with numbers" do
      assert FeelEx.evaluate("string length(\"12345\")") == %Value{value: 5, type: :number}
    end

    test "length of a very long string" do
      long_string = String.duplicate("a", 1000)

      assert FeelEx.evaluate("string length(\"#{long_string}\")") == %Value{
               value: 1000,
               type: :number
             }
    end

    test "length of a string with mixed case letters" do
      assert FeelEx.evaluate("string length(\"AbCdEf\")") == %Value{value: 6, type: :number}
    end

    test "length of a string with newlines and tabs" do
      assert FeelEx.evaluate("string length(\"Hello\\nWorld\\t\")") == %Value{
               value: 14,
               type: :number
             }
    end
  end

  describe "starts_with(string1, string2)" do
    test "returns true when string1 starts with string2" do
      assert FeelEx.evaluate("starts_with(\"hello world\", \"hello\")") == Value.new(true)
    end

    test "returns false when string1 does not start with string2" do
      assert FeelEx.evaluate("starts_with(\"hello world\", \"world\")") == Value.new(false)
    end

    test "returns true when string2 is an empty string" do
      assert FeelEx.evaluate("starts_with(\"hello world\", \"\")") == Value.new(true)
    end

    test "returns true when string1 and string2 are identical" do
      assert FeelEx.evaluate("starts_with(\"hello\", \"hello\")") == Value.new(true)
    end

    test "returns false when string1 is empty and string2 is not" do
      assert FeelEx.evaluate("starts_with(\"\", \"hello\")") == Value.new(false)
    end

    test "returns true when string1 starts with string2 (case-sensitive)" do
      assert FeelEx.evaluate("starts_with(\"Hello World\", \"Hello\")") == Value.new(true)
    end

    test "returns false when string1 starts with string2 but case does not match" do
      assert FeelEx.evaluate("starts_with(\"hello World\", \"Hello\")") == Value.new(false)
    end

    test "returns false when string1 starts with a different substring" do
      assert FeelEx.evaluate("starts_with(\"hello world\", \"world\")") == Value.new(false)
    end

    test "handles special characters correctly" do
      assert FeelEx.evaluate("starts_with(\"!@hello world\", \"!@\")") == Value.new(true)
    end
  end

  describe "ends_with(string1, string2)" do
    test "returns true when string1 ends with string2" do
      assert FeelEx.evaluate("ends_with(\"hello world\", \"world\")") == Value.new(true)
    end

    test "returns false when string1 does not end with string2" do
      assert FeelEx.evaluate("ends_with(\"hello world\", \"hello\")") == Value.new(false)
    end

    test "returns true when string2 is an empty string" do
      assert FeelEx.evaluate("ends_with(\"hello world\", \"\")") == Value.new(true)
    end

    test "returns true when string1 and string2 are identical" do
      assert FeelEx.evaluate("ends_with(\"hello\", \"hello\")") == Value.new(true)
    end

    test "returns false when string1 is empty and string2 is not" do
      assert FeelEx.evaluate("ends_with(\"\", \"hello\")") == Value.new(false)
    end

    test "returns true when string1 ends with string2 (case-sensitive)" do
      assert FeelEx.evaluate("ends_with(\"Hello World\", \"World\")") == Value.new(true)
    end

    test "returns false when string1 ends with string2 but case does not match" do
      assert FeelEx.evaluate("ends_with(\"hello World\", \"world\")") == Value.new(false)
    end

    test "returns false when string1 ends with a different substring" do
      assert FeelEx.evaluate("ends_with(\"hello world\", \"hello\")") == Value.new(false)
    end

    test "handles special characters correctly" do
      assert FeelEx.evaluate("ends_with(\"hello!@world\", \"@world\")") == Value.new(true)
    end
  end

  describe "split(string, delimiter)" do
    test "space delimiter" do
      assert FeelEx.evaluate("split(\"hello world\", \" \")") == [
               Value.new("hello"),
               Value.new("world")
             ]
    end

    test "comma delimiter" do
      assert FeelEx.evaluate("split(\"apple,banana,orange\", \",\")") == [
               Value.new("apple"),
               Value.new("banana"),
               Value.new("orange")
             ]
    end

    test "empty string with space delimiter" do
      assert FeelEx.evaluate("split(\"\", \" \")") == [Value.new("")]
    end

    test "empty string with comma delimiter" do
      assert FeelEx.evaluate("split(\"\", \",\")") == [Value.new("")]
    end

    test "delimiter not found in string" do
      assert FeelEx.evaluate("split(\"hello world\", \",\")") == [
               Value.new("hello world")
             ]
    end

    test "multiple consecutive delimiters" do
      assert FeelEx.evaluate("split(\"hello  world\", \" \")") == [
               Value.new("hello"),
               Value.new(""),
               Value.new("world")
             ]
    end

    test "delimiter at the start of string" do
      assert FeelEx.evaluate("split(\",apple,banana\", \",\")") == [
               Value.new(""),
               Value.new("apple"),
               Value.new("banana")
             ]
    end

    test "delimiter at the end of string" do
      assert FeelEx.evaluate("split(\"apple,banana,\", \",\")") == [
               Value.new("apple"),
               Value.new("banana"),
               Value.new("")
             ]
    end

    test "works with special characters as delimiter" do
      assert FeelEx.evaluate("split(\"a?b?c?d\", \"?\")") == [
               Value.new("a"),
               Value.new("b"),
               Value.new("c"),
               Value.new("d")
             ]
    end

    test "works with multi-character delimiter" do
      assert FeelEx.evaluate("split(\"one--two--three\", \"--\")") == [
               Value.new("one"),
               Value.new("two"),
               Value.new("three")
             ]
    end

    test "delimiter is empty string" do
      assert FeelEx.evaluate("split(\"hello world\", \"\")") == [
               Value.new("h"),
               Value.new("e"),
               Value.new("l"),
               Value.new("l"),
               Value.new("o"),
               Value.new(" "),
               Value.new("w"),
               Value.new("o"),
               Value.new("r"),
               Value.new("l"),
               Value.new("d")
             ]
    end

    test "string contains only delimiter" do
      assert FeelEx.evaluate("split(\",,,,\", \",\")") == [
               Value.new(""),
               Value.new(""),
               Value.new(""),
               Value.new(""),
               Value.new("")
             ]
    end
  end

  describe "trim(string)" do
    test "removes leading and trailing spaces" do
      assert FeelEx.evaluate("trim(\"  hello world  \")") == Value.new("hello world")
    end

    test "does not alter a string with no leading or trailing spaces" do
      assert FeelEx.evaluate("trim(\"hello world\")") == Value.new("hello world")
    end

    test "removes only leading spaces" do
      assert FeelEx.evaluate("trim(\"  hello world\")") == Value.new("hello world")
    end

    test "removes only trailing spaces" do
      assert FeelEx.evaluate("trim(\"hello world  \")") == Value.new("hello world")
    end

    test "returns an empty string when the input is only spaces" do
      assert FeelEx.evaluate("trim(\"     \")") == Value.new("")
    end

    test "returns an empty string when the input is an empty string" do
      assert FeelEx.evaluate("trim(\"\")") == Value.new("")
    end

    test "handles spaces at the beginning and end of a string with special characters" do
      assert FeelEx.evaluate("trim(\"  @!hello world@!  \")") == Value.new("@!hello world@!")
    end

    test "handles spaces in strings with newlines and tabs" do
      assert FeelEx.evaluate("trim(\"  \nhello world\n  \")") == Value.new("hello world")
    end

    test "does not alter a string with spaces in the middle" do
      assert FeelEx.evaluate("trim(\"hello  world\")") == Value.new("hello  world")
    end
  end
end
