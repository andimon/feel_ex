defmodule FunctionTest do
  use ExUnit.Case
  alias FeelEx.Value

  describe "string functions" do
    test "substring(\"foobar\", 3)" do
      assert %Value{value: "obar", type: :string} == FeelEx.evaluate("substring(\"foobar\", 3)")
    end

    test "substring(\"foobar\", -2)" do
      assert %Value{value: "ar", type: :string} == FeelEx.evaluate("substring(\"foobar\", -2)")
    end

    test "substring(\"foobar\", 0)" do
      assert %Value{value: "", type: :string} == FeelEx.evaluate("substring(\"foobar\", -2)")
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
               FeelEx.evaluate("substring before(\"hello world\",\" world\")")
    end

    test "contains(\"hello world\",\" worlds\")" do
      assert %Value{value: false, type: :boolean} ==
               FeelEx.evaluate("substring before(\"hello world\",\" worlds\")")
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
      assert %FeelEx.Value{value: 0.33, type: :number} == FeelEx.evaluate("decimal(1/3,2)")
    end

    test "ceiling(1+1+0.5)" do
      %FeelEx.Value{value: 3, type: :number} = FeelEx.evaluate("ceiling(1+1+0.5)")
    end

    test "floor(1+1+0.5)" do
      %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("floor(1+1+0.5)")
    end

    test "random()" do
      %FeelEx.Value{value: number, type: :number} = %FeelEx.Value{
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
