defmodule FeelEx.OperatorPrecedenceTest do
  use ExUnit.Case

  test "evaluate - 3+5-2" do
    assert %FeelEx.Value{value: 6, type: :number} = FeelEx.evaluate("3+5-2")
  end

  test "evaluate - 3+5*2" do
    assert %FeelEx.Value{value: 13, type: :number} = FeelEx.evaluate("3+5*2")
  end

  test "evaluate - 6/2*3" do
    assert %FeelEx.Value{value: 9.0, type: :number} = FeelEx.evaluate("6/2*3")
  end

  test "evaluate - 6/2/3" do
    assert %FeelEx.Value{value: 1.0, type: :number} = FeelEx.evaluate("6/2/3")
  end

  test "evaluate - 2+1>=3-2+1+1" do
    assert %FeelEx.Value{value: false, type: :boolean} = FeelEx.evaluate("2+1>=3-2+2+1")
  end

  test "evaluate - 2+1>=3-2+1" do
    assert %FeelEx.Value{value: true, type: :boolean} = FeelEx.evaluate("2+1>=3-2")
  end
end
