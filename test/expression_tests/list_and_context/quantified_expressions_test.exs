defmodule FeelEx.QuantifiedExpressionsTest do
  use ExUnit.Case

  test "some x in [1,2,3] satisfies x > 2" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("some x in [1,2,3] satisfies x > 2")
  end

  test "every x in [1,2,3] satisfies x > 0" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("every x in [1,2,3] satisfies x > 0")
  end

  test "every x in [1,2,3] satisfies x < 0" do
    assert %FeelEx.Value{type: :boolean, value: false} =
             FeelEx.evaluate("every x in [1,2,3] satisfies x < 0")
  end

  test "some x in [1,2,3] satisfies x = 1" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("some x in [1,2,3] satisfies x = 1")
  end

  test "some x in [1,2,3] satisfies x != 3" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("some x in [1,2,3] satisfies x != 3")
  end

  test "some x in [1,2,3] satisfies x < 0" do
    assert %FeelEx.Value{type: :boolean, value: false} =
             FeelEx.evaluate("some x in [1,2,3] satisfies x < 0")
  end

  test "every x in [10, 20, 30] satisfies x > 5" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("every x in [10, 20, 30] satisfies x > 5")
  end

  test "some x in [10, 20, 30] satisfies x <= 10" do
    assert %FeelEx.Value{type: :boolean, value: true} =
             FeelEx.evaluate("some x in [10, 20, 30] satisfies x <= 10")
  end
end
