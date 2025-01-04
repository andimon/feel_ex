defmodule FeelEx.ListsTests do
  use ExUnit.Case

  test "evaluate - []" do
    assert [] = FeelEx.evaluate("[]")
  end

  test "evaluate - [2.1]" do
    assert [%FeelEx.Value{value: 2.1, type: :number}] = FeelEx.evaluate("[2.1]")
  end

  test "evaluate - [5+1]" do
    assert [%FeelEx.Value{value: 6, type: :number}] = FeelEx.evaluate("[5+1]")
  end

  test "evaluate - [5+1,true]" do
    assert [%FeelEx.Value{value: 6, type: :number}, %FeelEx.Value{value: true, type: :boolean}] =
             FeelEx.evaluate("[5+1,true]")
  end

  test "evaluate - [5+1, 2>3]" do
    assert [%FeelEx.Value{value: 6, type: :number}, %FeelEx.Value{value: false, type: :boolean}] =
             FeelEx.evaluate("[5+1,2>3]")
  end

  test "evaluate - [2+3*2,5+1, 2>3]" do
    assert [%FeelEx.Value{value: 6, type: :number}, %FeelEx.Value{value: false, type: :boolean}] =
             FeelEx.evaluate("[5+1,2>3]")
  end

  test "evaluate - %{a: 5}, [5+1, a, 2>3]" do
    assert [
             %FeelEx.Value{value: 6, type: :number},
             %FeelEx.Value{value: 5, type: :number},
             %FeelEx.Value{value: false, type: :boolean}
           ] =
             FeelEx.evaluate(
               %{a: 5},
               "[5+1, a, 2>3]"
             )
  end

  test "evaluate [1,\"a\",3][-2]" do
    assert %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("[1, \"a\", 3][1]+1")
  end

  test "evaluate [1,\"a\",3][1]+1" do
    assert %FeelEx.Value{value: 2, type: :number} = FeelEx.evaluate("[1, \"a\", 3][1]+1")
  end

  test "evaluate [1,2,3,4][item > 2]" do
    assert [
             %FeelEx.Value{value: 3, type: :number},
             %FeelEx.Value{value: 4, type: :number}
           ] = FeelEx.evaluate("[1,2,3,4][item > 2]")
  end

  test "evaluate [1,2,3,4][item > 10]" do
    assert [] = FeelEx.evaluate("[1,2,3,4][item > 10]")
  end

  test "evaluate [1,2,3,4][even(item)]" do
    assert [
             %FeelEx.Value{value: 4, type: :number}
           ] = FeelEx.evaluate("[2,4][item > 2]")
  end
end
