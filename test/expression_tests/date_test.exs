defmodule FeelEx.DateTest do
  use ExUnit.Case

  test "evaluate date(\"2021-01-02\")" do
    assert %FeelEx.Value{value: ~D[2021-01-02], type: :date} =
             FeelEx.evaluate("date(\"2021-01-02\")")
  end

  test "evaluate date(\"2021-03-02\")" do
    assert %FeelEx.Value{value: ~D[2021-03-02], type: :date} =
             FeelEx.evaluate("@\"2021-03-02\"")
  end
end
