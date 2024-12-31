defmodule FeelEx.ConditionalStatementTest do
  use ExUnit.Case

  test "evalaute for x in [1,2,3] return 4" do
    assert [
             %FeelEx.Value{value: 4, type: :number},
             %FeelEx.Value{value: 4, type: :number},
             %FeelEx.Value{value: 4, type: :number}
           ] = FeelEx.evaluate("for x in [1,2,3] return 4")
  end

  test "evalaute for x in [1,2,3] y in [2,3] return x+y" do
    assert [
             %FeelEx.Value{value: 3, type: :number},
             %FeelEx.Value{value: 4, type: :number},
             %FeelEx.Value{value: 4, type: :number},
             %FeelEx.Value{value: 5, type: :number},
             %FeelEx.Value{value: 5, type: :number},
             %FeelEx.Value{value: 6, type: :number}
           ] = FeelEx.evaluate("for x in [1,2,3] y in [2,3] return x+y")
  end

  test "evalaute for x in [true, false] return true and x" do
    assert [
             %FeelEx.Value{value: true, type: :boolean},
             %FeelEx.Value{value: false, type: :boolean}
           ] = FeelEx.evaluate("for x in [true, false] return true and x")
  end
end
