defmodule FeelEx.ValueTests do
  use ExUnit.Case
  doctest FeelEx

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

    assert %FeelEx.Value{value: {~T[10:31:10], "+01:00", "Europe/Paris"}, type: :time} ==
             FeelEx.evaluate("time(\"10:31:10@Europe/Paris\")")

    assert %FeelEx.Value{value: ~T[11:45:30], type: :time} ==
             FeelEx.evaluate("@\"11:45:30\"")

    assert %FeelEx.Value{value: ~T[13:30:00], type: :time} ==
             FeelEx.evaluate("@\"13:30\"")

    assert %FeelEx.Value{value: {~T[11:45:30], "+02:00"}, type: :time} ==
             FeelEx.evaluate("@\"11:45:30+02:00\"")

    assert %FeelEx.Value{value: {~T[10:31:10], "+01:00", "Europe/Paris"}, type: :time} ==
             FeelEx.evaluate("@\"10:31:10@Europe/Paris\"")
  end

  test "evaluate date-time" do
    assert FeelEx.evaluate("date and time(\"2015-09-18T10:31:10\")") ==
             %FeelEx.Value{value: ~N[2015-09-18 10:31:10], type: :datetime}

    assert FeelEx.evaluate("date and time(\"2015-09-18T10:31:10+01:00\")") ==
             %FeelEx.Value{value: {~N[2015-09-18 10:31:10], "+01:00"}, type: :datetime}

    assert FeelEx.evaluate("date and time(\"2015-09-18T10:31:10@Europe/Paris\")") ==
             %FeelEx.Value{
               value: {~N[2015-09-18 10:31:10], "+01:00", "Europe/Paris"},
               type: :datetime
             }

    assert FeelEx.evaluate("@\"2015-09-18T10:31:10\"") ==
             %FeelEx.Value{value: ~N[2015-09-18 10:31:10], type: :datetime}

    assert FeelEx.evaluate("@\"2015-09-18T10:31:10+01:00\"") ==
             %FeelEx.Value{value: {~N[2015-09-18 10:31:10], "+01:00"}, type: :datetime}

    assert FeelEx.evaluate("@\"2015-09-18T10:31:10@Europe/Paris\"") ==
             %FeelEx.Value{
               value: {~N[2015-09-18 10:31:10], "+01:00", "Europe/Paris"},
               type: :datetime
             }
  end

  test "evaluate duration" do
    assert FeelEx.evaluate("duration(\"P4D\")") ==
             %FeelEx.Value{value: %Duration{day: 4}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"PT2H\")") ==
             %FeelEx.Value{value: %Duration{hour: 2}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"PT30M\")") ==
             %FeelEx.Value{value: %Duration{minute: 30}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"P1DT6H\")") ==
             %FeelEx.Value{value: %Duration{day: 1, hour: 6}, type: :days_time_duration}

    assert FeelEx.evaluate("@\"P4D\"") ==
             %FeelEx.Value{value: %Duration{day: 4}, type: :days_time_duration}

    assert FeelEx.evaluate("@\"PT2H\"") ==
             %FeelEx.Value{value: %Duration{hour: 2}, type: :days_time_duration}

    assert FeelEx.evaluate("@\"PT30M\"") ==
             %FeelEx.Value{value: %Duration{minute: 30}, type: :days_time_duration}

    assert FeelEx.evaluate("@\"P1DT6H\"") ==
             %FeelEx.Value{value: %Duration{day: 1, hour: 6}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"P2Y\")") ==
             %FeelEx.Value{value: %Duration{year: 2}, type: :years_months_duration}

    assert FeelEx.evaluate("duration(\"P6M\")") ==
             %FeelEx.Value{value: %Duration{month: 6}, type: :years_months_duration}

    assert FeelEx.evaluate("duration(\"P1Y6M\")") ==
             %FeelEx.Value{value: %Duration{year: 1, month: 6}, type: :years_months_duration}

    assert FeelEx.evaluate("@\"P2Y\"") ==
             %FeelEx.Value{value: %Duration{year: 2}, type: :years_months_duration}

    assert FeelEx.evaluate("@\"P6M\"") ==
             %FeelEx.Value{value: %Duration{month: 6}, type: :years_months_duration}

    assert FeelEx.evaluate("@\"P1Y6M\"") ==
             %FeelEx.Value{value: %Duration{year: 1, month: 6}, type: :years_months_duration}
  end

  test "list" do
    assert FeelEx.evaluate("[]") ==
             []

    assert FeelEx.evaluate("[1,2,3]") ==
             [
               %FeelEx.Value{value: 1, type: :number},
               %FeelEx.Value{value: 2, type: :number},
               %FeelEx.Value{value: 3, type: :number}
             ]

    assert FeelEx.evaluate("[\"a\",\"b\"]") ==
             [
               %FeelEx.Value{value: "a", type: :string},
               %FeelEx.Value{value: "b", type: :string}
             ]
  end

  test "contexts" do
    assert FeelEx.evaluate("{}") ==
             %FeelEx.Value{value: %{}, type: :context}

    assert FeelEx.evaluate("{a:1}") ==
             %FeelEx.Value{
               value: %{a: %FeelEx.Value{value: 1, type: :number}},
               type: :context
             }

    assert FeelEx.evaluate("{b:1, c: \"wow\"}") ==
             %FeelEx.Value{
               value: %{
                 c: %FeelEx.Value{value: "wow", type: :string},
                 b: %FeelEx.Value{value: 1, type: :number}
               },
               type: :context
             }

    assert FeelEx.evaluate("{nested: {d: 3}}") ==
             %FeelEx.Value{
               value: %{
                 nested: %FeelEx.Value{
                   value: %{d: %FeelEx.Value{value: 3, type: :number}},
                   type: :context
                 }
               },
               type: :context
             }

    assert FeelEx.evaluate("{\"a\": 1}") ==
             %FeelEx.Value{
               value: %{a: %FeelEx.Value{value: 1, type: :number}},
               type: :context
             }

    assert FeelEx.evaluate("{\"b\": 2, \"c\": \"valid\"}") ==
             %FeelEx.Value{
               value: %{
                 c: %FeelEx.Value{value: "valid", type: :string},
                 b: %FeelEx.Value{value: 2, type: :number}
               },
               type: :context
             }
  end
end
