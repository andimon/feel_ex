defmodule FeelEx.PartialTest do
  use ExUnit.Case
  alias FeelEx.Value

  test "partial - fibonacci" do
    assert [
             %Value{value: 1, type: :number},
             %Value{value: 1, type: :number},
             %Value{value: 2, type: :number},
             %Value{value: 3, type: :number},
             %Value{value: 5, type: :number},
             %Value{value: 8, type: :number},
             %Value{value: 13, type: :number},
             %Value{value: 21, type: :number},
             %Value{value: 34, type: :number},
             %Value{value: 55, type: :number}
           ] =
             FeelEx.evaluate(
               "for i in 1..10 return if (i <= 2) then 1 else partial[-1] + partial[-2]"
             )
  end
end
