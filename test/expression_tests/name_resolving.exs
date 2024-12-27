defmodule FeelEx.NameResolving do
  use ExUnit.Case

  test "evaluate - %{a: [1,[2,true]]}, \"a\"" do
    assert [
             %FeelEx.Value{value: 1, type: :number},
             [
               %FeelEx.Value{value: 2, type: :number},
               %FeelEx.Value{value: true, type: :boolean}
             ]
           ] = FeelEx.evaluate(%{a: [1, [2, true]]}, "a")
  end
end
