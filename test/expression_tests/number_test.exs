defmodule FeelEx.NumberTest do
  use ExUnit.Case
  alias FeelEx.Value

  test "" do
    assert FeelEx.evaluate("-000002") ==
             %FeelEx.Value{value: -2, type: :number}

    assert FeelEx.evaluate("0001.5") ==
             %FeelEx.Value{value: 1.5, type: :number}
  end
end
