defmodule FunctionTest do
  use ExUnit.Case
  alias FeelEx.Value

  describe "conversion function - string" do
    test "test converting integer to string" do
      assert FeelEx.evaluate("string(1)") == %Value{value: "1", type: :string}
      assert FeelEx.evaluate("string(12)") == %Value{value: "12", type: :string}
    end

    test "converting negative integer to string" do
      assert FeelEx.evaluate("string(-1)") == %Value{value: "-1", type: :string}
      assert FeelEx.evaluate("string(-12)") == %Value{value: "-12", type: :string}
    end

    test "converting float without integral part to string" do
      assert FeelEx.evaluate("string(.12)") == %Value{value: "0.12", type: :string}
      assert FeelEx.evaluate("string(.1)") == %Value{value: "0.1", type: :string}
    end

    test "convert null to string still returns null" do
      assert FeelEx.evaluate("string(null)") == %Value{value: nil, type: :null}
    end

    test "converting a string to a string is idempotent" do
      assert FeelEx.evaluate("string(\"this is a wonderful string\")") == %Value{
               value: "this is a wonderful string",
               type: :string
             }
    end

    test "converting a boolean value to string" do
      assert FeelEx.evaluate("string(true)") == %Value{value: "true", type: :string}
      assert FeelEx.evaluate("string(false)") == %Value{value: "false", type: :string}
    end

    test "converting a date to string" do
      assert FeelEx.evaluate("string(date(\"2021-01-01\"))") ==
               %Value{value: "2021-01-01", type: :string}
    end

    test "converting time without timezone or offset to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00\"))") == %Value{
               value: "08:01:00",
               type: :string
             }
    end

    test "converting time with timezone to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00@Europe/Malta\"))") ==
               %Value{value: "08:01:00@Europe/Malta", type: :string}
    end

    test "converting time with offset to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00+01:00\"))") ==
               %Value{value: "08:01:00+01:00", type: :string}
    end

    test "converting  datetime without timezone or offset to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01\"))") == %Value{
               value: "2021-01-01T08:01:01",
               type: :string
             }
    end

    test "converting  datetime with timezone to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01@Europe/Malta\"))") ==
               %Value{
                 value: "2021-01-01T08:01:01@Europe/Malta",
                 type: :string
               }
    end

    test "converting  datetime with offset to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01+01:00\"))") ==
               %Value{
                 value: "2021-01-01T08:01:01+01:00",
                 type: :string
               }
    end

    test "converting days time duration to string" do
      assert FeelEx.evaluate("string(duration(\"P4D\"))") == %Value{value: "P4D", type: :string}
    end

    test "converting years months duration to string" do
      assert FeelEx.evaluate("string(duration(\"P1Y6M\"))") == %Value{
               value: "P1Y6M",
               type: :string
             }
    end

    test "converting list with various datatype to string" do
      assert FeelEx.evaluate("string([duration(\"P4D\"),2, 200.0,time(\"08:01:01\")])") == %Value{
               value: "[P4D, 2, 200.0, 08:01:01]",
               type: :string
             }
    end

    test "convert context with list value to string" do
      assert FeelEx.evaluate("string({a: [duration(\"P4D\"),2, 200.0,time(\"08:01:01\")]})") ==
               %Value{value: "{a:[P4D, 2, 200.0, 08:01:01]}", type: :string}
    end
  end

  describe "conversion function - number" do
    test "converting integer string to number" do
      assert FeelEx.evaluate("11") == %Value{value: 11, type: :number}
      assert FeelEx.evaluate("1") == %Value{value: 1, type: :number}
    end

    test "converting negative integer string to number" do
      assert FeelEx.evaluate("-11") == %Value{value: -11, type: :number}
      assert FeelEx.evaluate("-1") == %Value{value: -1, type: :number}
    end

    test "converting float without integrand to number" do
      assert FeelEx.evaluate("number(\".1\")") == %Value{value: 0.1, type: :number}
      assert FeelEx.evaluate("number(\".12\")") == %Value{value: 0.12, type: :number}
    end

    test "converting negative float without integrand to number" do
      assert FeelEx.evaluate("number(\"-.1\")") == %Value{value: -0.1, type: :number}
      assert FeelEx.evaluate("number(\"-.12\")") == %Value{value: -0.12, type: :number}
    end

    test "converting float to number" do
      assert FeelEx.evaluate("number(\"1.1\")") == %Value{value: 1.1, type: :number}
      assert FeelEx.evaluate("number(\"22.12\")") == %Value{value: 22.12, type: :number}
    end

    test "converting negative float to number" do
      assert FeelEx.evaluate("number(\"-1.1\")") == %Value{value: -1.1, type: :number}
      assert FeelEx.evaluate("number(\"-22.12\")") == %Value{value: -22.12, type: :number}
    end

    test "converting a non number string" do
      assert FeelEx.evaluate("number(\"aa\")") == %Value{value: nil, type: :null}
    end

    test "trying to convert anything but string to number" do
      assert FeelEx.evaluate("number(@\"2021-01-01\")") == %Value{value: nil, type: :null}
    end
  end

  describe "string functions" do
    test "substring(\"foobar\", 3)" do
      assert %Value{value: "obar", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3)")
    end

    test "substring(\"foobar\", -2)" do
      assert %Value{value: "ar", type: :string} == FeelEx.evaluate("substring(\"foobar\", -2)")
    end

    test "substring(\"foobar\", 0)" do
      assert %Value{value: "", type: :string} == FeelEx.evaluate("substring(\"foobar\",0)")
    end

    test "substring(\"foobar\", 3,0)" do
      assert %Value{value: "", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,0)")
    end

    test "substring(\"foobar\", 3,1)" do
      assert %Value{value: "o", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,1)")
    end

    test "substring(\"foobar\", 3,2)" do
      assert %Value{value: "ob", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,2)")
    end

    test "substring(\"foobar\", 3,3)" do
      assert %Value{value: "oba", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,3)")
    end

    test "substring(\"foobar\", 3,4)" do
      assert %Value{value: "obar", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,4)")
    end

    test "substring(\"foobar\", 3,5)" do
      assert %Value{value: "obar", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3,5)")
    end

    test "string length(\"Hello World\")" do
      assert %Value{value: 11, type: :number} ==
               FeelEx.evaluate("string length(\"Hello World\")")
    end

    test "upper case(\"Hello World\")" do
      assert %Value{value: "HELLO WORLD", type: :string} ==
               FeelEx.evaluate("upper case(\"Hello World\")")
    end

    test "lower case(\"Hello World\")" do
      assert %Value{value: "hello world", type: :string} ==
               FeelEx.evaluate("lower case(\"Hello World\")")
    end

    test "substring before(\"hello world\",\" world\")" do
      assert %Value{value: "hello", type: :string} ==
               FeelEx.evaluate("substring before(\"hello world\",\" world\")")
    end

    test "substring after(\"hello world\",\"hello \")" do
      assert %Value{value: "world", type: :string} ==
               FeelEx.evaluate("substring after(\"hello world\",\"hello \")")
    end

    test "contains(\"hello world\",\" world\")" do
      assert %Value{value: true, type: :boolean} ==
               FeelEx.evaluate("contains(\"hello world\",\" world\")")
    end

    test "contains(\"hello world\",\" worlds\")" do
      assert %Value{value: false, type: :boolean} ==
               FeelEx.evaluate("contains(\"hello world\",\" worlds\")")
    end

    test "starts with(\"hello world\",\"hello \")" do
      assert %Value{value: true, type: :boolean} ==
               FeelEx.evaluate("starts with(\"hello world\",\"hello \")")
    end

    test "starts with(\"hello world\",\" world\")" do
      assert %Value{value: false, type: :boolean} ==
               FeelEx.evaluate("starts with(\"hello world\",\" world\")")
    end

    test "ends with(\"hello world\",\"hello \")" do
      assert %Value{value: false, type: :boolean} ==
               FeelEx.evaluate("ends with(\"hello world\",\"hello \")")
    end

    test "ends with(\"hello world\",\" world\")" do
      assert %Value{value: true, type: :boolean} ==
               FeelEx.evaluate("ends with(\"hello world\",\" world\")")
    end

    test "split(\"Hello World\",\"\s\")" do
      assert [
               %Value{value: "Hello", type: :string},
               %Value{value: "World", type: :string}
             ] == FeelEx.evaluate("split(\"Hello World\",\"\s\")")
    end

    test "trim(\" sss    \")" do
      assert %Value{value: "sss", type: :string} == FeelEx.evaluate("trim(\" sss    \")")
    end
  end

  describe "numeric functions" do
    test "decimal(1/3,2)" do
      assert %Value{value: 0.33, type: :number} == FeelEx.evaluate("decimal(1/3,2)")
    end

    test "ceiling(1+1+0.5)" do
      %Value{value: 3, type: :number} = FeelEx.evaluate("ceiling(1+1+0.5)")
    end

    test "floor(1+1+0.5)" do
      %Value{value: 2, type: :number} = FeelEx.evaluate("floor(1+1+0.5)")
    end

    test "random()" do
      %Value{value: number, type: :number} = %Value{
        value: 0.5189989081813825,
        type: :number
      }

      assert is_number(number)
    end
  end

  describe "list functions" do
    test "contains([1,2,3],2)" do
      assert %Value{value: true, type: :boolean} ==
               FeelEx.evaluate("list contains([1,2,3],2)")
    end

    test "count([1,2,3])" do
      assert %Value{value: 3, type: :number} == FeelEx.evaluate("count([1,2,3])")
    end
  end
end
