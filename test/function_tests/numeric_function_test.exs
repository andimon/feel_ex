defmodule FeelEx.NumericFunctionTests do
  use ExUnit.Case

  test "ceiling(1+1+0.5)" do
    %FeelEx.Value{value: 3, type: :number} = FeelEx.evaluate("ceiling(1+1+0.5)")
  end

  test "floor(1+1+0.5)" do
    %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("floor(1+1+0.5)")
  end
end
