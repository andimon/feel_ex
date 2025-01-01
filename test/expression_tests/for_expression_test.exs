defmodule FeelEx.ForExpressionTest do
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
           ] = FeelEx.evaluate("for x in [1,2,3], y in [2,3] return x+y")
  end

  test "evalaute for x in [true, false] return true and x" do
    assert [
             %FeelEx.Value{value: true, type: :boolean},
             %FeelEx.Value{value: false, type: :boolean}
           ] = FeelEx.evaluate("for x in [true, false] return true and x")
  end

  test "evaluate for i in 1.3..8.1 return i" do
    assert [
             %FeelEx.Value{value: 1.3, type: :number},
             %FeelEx.Value{value: 2.3, type: :number},
             %FeelEx.Value{value: 3.3, type: :number},
             %FeelEx.Value{value: 4.3, type: :number},
             %FeelEx.Value{value: 5.3, type: :number},
             %FeelEx.Value{value: 6.3, type: :number},
             %FeelEx.Value{value: 7.3, type: :number}
           ] = FeelEx.evaluate("for i in 1.3..8.1 return i")
  end

  test "evaluate for x in [1,2], y in [3,4] return x" do
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 2, type: :number}
    ] = FeelEx.evaluate("for x in [1,2], y in [3,4] return x")
  end

  test "evaluate for x in 1..2, y in [3,4] return x+y" do
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 2, type: :number}
    ] = FeelEx.evaluate("for x in [1,2], y in [3,4] return x")
  end

  test "evaluate FeelEx.evaluate(%{y: 1}, \"for x in 8..-1 return x+y\")" do
    [
      %FeelEx.Value{value: 9, type: :number},
      %FeelEx.Value{value: 8, type: :number},
      %FeelEx.Value{value: 7, type: :number},
      %FeelEx.Value{value: 6, type: :number},
      %FeelEx.Value{value: 5, type: :number},
      %FeelEx.Value{value: 4, type: :number},
      %FeelEx.Value{value: 3, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 0, type: :number}
    ] = FeelEx.evaluate(%{y: 1}, "for x in 8..-1 return x+y")
  end
end
