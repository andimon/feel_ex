defmodule FeelEx.FilterTest do
  use ExUnit.Case

  test "filter key b" do
    program =
      """
      [
      {
      a: "p1",
      b: 5
      },
      {
      a: "p2",
      b: 10
      }
      ][b > 7]
      """

    assert [
             %FeelEx.Value{
               value: %{
                 b: %FeelEx.Value{value: 10, type: :number},
                 a: %FeelEx.Value{value: "p2", type: :string}
               },
               type: :context
             }
           ] = FeelEx.evaluate(program)
  end
end
