defmodule FeelEx.ConditionalStatementTest do
  use ExUnit.Case

  test "lexer - (if true then 1 else 2)+1" do
    assert %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("(if true then 1 else 2)+1")
  end
end
