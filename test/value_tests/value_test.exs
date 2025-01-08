defmodule FeelEx.ValueTests do
  use ExUnit.Case
  doctest FeelEx

  alias FeelEx.Value

  test "evaluate null" do
    assert %FeelEx.Value{value: nil, type: :null} == FeelEx.evaluate("null")
  end

  test "evaluate number positive integer" do
    assert %FeelEx.Value{value: 1, type: :number} == FeelEx.evaluate("1")
  end

  test "evaluate number positive float" do
    assert %FeelEx.Value{value: 2.4, type: :number} == FeelEx.evaluate("2.4")
  end

  test "evaluate number float with no leading 0" do
    assert %FeelEx.Value{value: 0.4, type: :number} == FeelEx.evaluate(".4")
  end

  test "evaluate number float with negative integer" do
    assert %FeelEx.Value{value: -5, type: :number} == FeelEx.evaluate("-5")
  end

  test "evaluate string" do
    assert %FeelEx.Value{value: "valid", type: :string} == FeelEx.evaluate("\"valid\"")
  end

  test "evaluate boolean true" do
    assert %FeelEx.Value{value: true, type: :boolean} == FeelEx.evaluate("true")
  end

  test "evaluate boolean false" do
    assert %FeelEx.Value{value: false, type: :boolean} == FeelEx.evaluate("false")
  end

  test "evaluate date" do
    assert %FeelEx.Value{value: ~D[2017-03-10], type: :date} ==
             FeelEx.evaluate("date(\"2017-03-10\")")

    assert %FeelEx.Value{value: ~D[2017-03-10], type: :date} ==
             FeelEx.evaluate("@\"2017-03-10\"")
  end

  test "evaluate time" do
    assert %FeelEx.Value{value: ~T[11:45:30], type: :time} ==
             FeelEx.evaluate("time(\"11:45:30\")")

    assert %FeelEx.Value{value: ~T[13:30:00], type: :time} ==
             FeelEx.evaluate("time(\"13:30\")")

    assert %FeelEx.Value{value: {~T[11:45:30], "+02:00"}, type: :time} ==
             FeelEx.evaluate("time(\"11:45:30+02:00\")")

    assert %FeelEx.Value{value: {~T[10:31:10], "+01:00"}, type: :time} ==
             FeelEx.evaluate("time(\"10:31:10@Europe/Paris\")")

    assert %FeelEx.Value{value: ~T[11:45:30], type: :time} ==
             FeelEx.evaluate("@\"11:45:30\"")

    assert %FeelEx.Value{value: ~T[13:30:00], type: :time} ==
             FeelEx.evaluate("@\"13:30\"")

    assert %FeelEx.Value{value: {~T[11:45:30], "+02:00"}, type: :time} ==
             FeelEx.evaluate("@\"11:45:30+02:00\"")

    assert %FeelEx.Value{value: {~T[10:31:10], "+01:00"}, type: :time} ==
             FeelEx.evaluate("@\"10:31:10@Europe/Paris\"")
  end
end
