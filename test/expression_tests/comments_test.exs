defmodule FeelEx.CommentsTest do
  use ExUnit.Case
  alias FeelEx.Value

  test "single line comment" do
    program =
      """
      // dsadas
      1
      """

    assert Value.new(1) == FeelEx.evaluate(program)
  end

  test "multi line comment without new lines" do
    program =
      """
      /* dsadas */
      1
      """

    assert Value.new(1) == FeelEx.evaluate(program)
  end

  test "multi line comment with new lines" do
    program =
      """
      /*
      dsadas
      */
      1
      """

    assert Value.new(1) == FeelEx.evaluate(program)
  end
end
