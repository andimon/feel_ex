defmodule FeelEx.ConditionalStatementTest do
  use ExUnit.Case

  test "evaluate - (if true then 1 else 2)+1" do
    assert %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("(if true then 1 else 2)+1")
  end

  test "evaluate - true or false" do
    assert %FeelEx.Value{value: true, type: :boolean} = FeelEx.evaluate("true or false")
  end

  test "evaluate - false or true" do
    assert %FeelEx.Value{value: true, type: :boolean} = FeelEx.evaluate("false or true")
  end

  test "evaluate - true and false" do
    assert %FeelEx.Value{value: false, type: :boolean} = FeelEx.evaluate("true and false")
  end

  test "evaluate - false and true" do
    assert %FeelEx.Value{value: false, type: :boolean} = FeelEx.evaluate("false and true")
  end

  test "evaluate - true and true and 3>5" do
    assert %FeelEx.Value{value: false, type: :boolean} = FeelEx.evaluate("true and true and 3>5")
  end
end
