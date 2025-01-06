defmodule FeelEx.ProjectionTest do
  use ExUnit.Case

  test "access elem from empty list" do
    assert [] = FeelEx.evaluate("[].a")
  end

  test "access elem from list with contexts contaning different properties" do
    program =
      """
      [
      {
      a: "x",
      b: 10
      },
      {
      a: "y",
      d: 30
      },
      {
      a: "z",
      b: 50,
      d: 40
      }
      ].b
      """

    assert [
             %FeelEx.Value{value: 10, type: :number},
             %FeelEx.Value{value: nil, type: :null},
             %FeelEx.Value{value: 50, type: :number}
           ] = FeelEx.evaluate(program)
  end

  test "accessing non existing properties" do
    program =
      """
      [
      {
      a: "p1",
      b: 5
      },
      {
      a: "p2",
      c: 20
      }
      ].d
      """

    assert [
             %FeelEx.Value{type: :null, value: nil},
             %FeelEx.Value{type: :null, value: nil}
           ] = FeelEx.evaluate(program)
  end

  test "Accessing 'c' from an array where only the second object contains 'c'" do
    program =
      """
      [
      {
      a: "p1",
      b: 5
      },
      {
      a: "p2",
      c: 20
      }
      ].c
      """

    assert [
             %FeelEx.Value{type: :null, value: nil},
             %FeelEx.Value{type: :number, value: 20}
           ] = FeelEx.evaluate(program)
  end

  test "accessing a value within a context within a context" do
    assert [
             %FeelEx.Value{type: :number, value: 1},
             %FeelEx.Value{type: :null, value: nil}
           ] = FeelEx.evaluate("[{a: {b: 1}},2].a.b")
  end
end
