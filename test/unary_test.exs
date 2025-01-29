defmodule FeelEx.UnaryTests do
  use ExUnit.Case
  alias FeelEx.Value

  describe "comparison" do
    test "equality" do
      assert FeelEx.unary_test("a", 5, %{a: 5}) == Value.new(true)
      assert FeelEx.unary_test("a", 5, %{a: 6}) == Value.new(false)
    end

    test "leq" do
      assert FeelEx.unary_test("<= a", 5, %{a: 4}) == Value.new(false)
      assert FeelEx.unary_test("<= a", 5, %{a: 5}) == Value.new(true)
      assert FeelEx.unary_test("<= a", 5, %{a: 6}) == Value.new(true)
    end

    test "geq" do
      assert FeelEx.unary_test(">= a", 5, %{a: 6}) == Value.new(false)
      assert FeelEx.unary_test(">= a", 5, %{a: 5}) == Value.new(true)
      assert FeelEx.unary_test(">= a", 5, %{a: 4}) == Value.new(true)
    end

    test "gt" do
      assert FeelEx.unary_test("> a", 5, %{a: 6}) == Value.new(false)
      assert FeelEx.unary_test("> a", 5, %{a: 5}) == Value.new(false)
      assert FeelEx.unary_test("> a", 5, %{a: 4}) == Value.new(true)
    end

    test "lt" do
      assert FeelEx.unary_test("< a", 5, %{a: 4}) == Value.new(false)
      assert FeelEx.unary_test("< a", 5, %{a: 5}) == Value.new(false)
      assert FeelEx.unary_test("< a", 5, %{a: 6}) == Value.new(true)
    end
  end

  describe "interval" do
    test "(x..y)" do
      assert FeelEx.unary_test("(1..a)", 5, %{a: 5}) == Value.new(false)
    end

    test "(x..y]" do
      assert FeelEx.unary_test("(1..a]", 5, %{a: 5}) == Value.new(true)
    end

    test "[x..y]" do
      assert FeelEx.unary_test("[1..a]", 5, %{a: 5}) == Value.new(true)
    end

    test "[x..y)" do
      assert FeelEx.unary_test("[1..a)", 5, %{a: 5}) == Value.new(false)
    end
  end

  describe "disjunction" do
    test "2,3,4" do
      assert FeelEx.unary_test("2, 3, 4", 2) == Value.new(true)
      assert FeelEx.unary_test("2, 3, 4", 5) == Value.new(false)
    end

    test ">2, >3, >4" do
      assert FeelEx.unary_test(">2, >3, >4", 2) == Value.new(false)
      assert FeelEx.unary_test(">2, >3, >4", 3) == Value.new(true)
    end
  end

  describe "negation" do
    test "negate(string)" do
      assert FeelEx.unary_test("not(\"valid1\")", "valid") == Value.new(true)
    end
  end
end
