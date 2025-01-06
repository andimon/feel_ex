defmodule FeelEx.ContextTest do
  use ExUnit.Case
  alias FeelEx.Value

  test "evaluate context with singleton - {a: 1}" do
    assert %Value{value: %{a: %FeelEx.Value{value: "p1", type: :string}}, type: :context} =
             FeelEx.evaluate("{a:\"p1\"}")
  end

  test "evaluate with names - {a: 1, b:2}" do
    assert %Value{
             value: %{
               a: %FeelEx.Value{value: 1, type: :number},
               b: %FeelEx.Value{value: 2, type: :number}
             },
             type: :context
           } = FeelEx.evaluate("{a: 1, b: 2}")
  end

  test "evaluate with string keys - {\"a\": 1, \"b\":2}" do
    assert %Value{
             value: %{
               a: %FeelEx.Value{value: 1, type: :number},
               b: %FeelEx.Value{value: 2, type: :number}
             },
             type: :context
           } = FeelEx.evaluate("{\"a\": 1, \"b\": 2}")
  end

  test "get entry - {\"a\": 2, \"b\": a*2}.a" do
    assert %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("{\"a\": 2, \"b\": a*2}.a")
  end

  test "get entry nested - {a: {b: 3}}.a.b" do
    assert %FeelEx.Value{value: 3, type: :number} = FeelEx.evaluate("{a: {b: 3}}.a.b")
  end

  test "get context - {a: {b: 3}}.a" do
    assert %FeelEx.Value{type: :context, value: %{b: %FeelEx.Value{value: 3, type: :number}}} =
             FeelEx.evaluate("{a: {b: 3}}.a")
  end

  test "accessing null - {a: 1}.b.c" do
    assert %FeelEx.Value{type: :null, value: nil} = FeelEx.evaluate("{a: 1}.b.c")
  end
end
