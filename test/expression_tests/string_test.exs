defmodule FeelEx.StringTest do
  use ExUnit.Case
  alias FeelEx.Value

  test "create string" do
    assert %Value{value: "Aw dinja", type: :string} == FeelEx.evaluate("\"Aw dinja\"")
  end

  test "string concatenation" do
    assert %Value{value: "Aw Dinja", type: :string} == FeelEx.evaluate("\"Aw\"+\" Dinja\"")
  end

  test "string() - null" do
    assert %Value{value: "null", type: :string} == FeelEx.evaluate("string(null)")
  end

  test "string() - number" do
    assert %Value{value: "12", type: :string} == FeelEx.evaluate("string(12)")
    assert %Value{value: "0.22", type: :string} == FeelEx.evaluate("string(.22)")
    assert %Value{value: "-2.22", type: :string} == FeelEx.evaluate("string(-2.22)")
    assert %Value{value: "-0.22", type: :string} == FeelEx.evaluate("string(-.22)")
  end

  test "string() - string" do
    assert %Value{value: "Aw Dinja", type: :string} == FeelEx.evaluate("string(\"Aw Dinja\")")
  end

  test "string() - boolean" do
    assert %Value{value: "true", type: :string} == FeelEx.evaluate("string(true)")
    assert %Value{value: "false", type: :string} == FeelEx.evaluate("string(false)")
  end

  test "string() - date" do
    assert FeelEx.evaluate("string(@\"2024-01-01\")") == %Value{
             value: "2024-01-01",
             type: :string
           }

    assert FeelEx.evaluate("string(date(\"2024-01-01\"))") == %Value{
             value: "2024-01-01",
             type: :string
           }
  end

  test "string() - time" do
    assert FeelEx.evaluate("string(time(\"11:45:30\"))") == %FeelEx.Value{
             value: "11:45:30",
             type: :string
           }

    assert FeelEx.evaluate("string(time(\"11:45\"))") == %FeelEx.Value{
             value: "11:45:00",
             type: :string
           }

    assert FeelEx.evaluate("string(time(\"11:45:30+02:00\"))") == %FeelEx.Value{
             value: "11:45:30+02:00",
             type: :string
           }

    assert FeelEx.evaluate("string(time(\"11:45:30+02:00\"))") == %FeelEx.Value{
             value: "11:45:30+02:00",
             type: :string
           }

    assert FeelEx.evaluate("string(time(\"10:31:10@Europe/Paris\"))") == %FeelEx.Value{
             value: "10:31:10@Europe/Paris",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"11:45:30\")") == %FeelEx.Value{
             value: "11:45:30",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"13:30\")") == %FeelEx.Value{
             value: "13:30:00",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"10:45:30+02:00\")") == %FeelEx.Value{
             value: "10:45:30+02:00",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"10:31:10@Europe/Paris\")") == %FeelEx.Value{
             value: "10:31:10@Europe/Paris",
             type: :string
           }
  end

  test "string() - date-time" do
    assert FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10\"))") == %FeelEx.Value{
             value: "2015-09-18T10:31:10",
             type: :string
           }

    assert FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10+01:00\"))") ==
             %FeelEx.Value{
               value: "2015-09-18T10:31:10+01:00",
               type: :string
             }

    assert FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10@Europe/Paris\"))") ==
             %FeelEx.Value{
               value: "2015-09-18T10:31:10@Europe/Paris",
               type: :string
             }

    assert FeelEx.evaluate("string(@\"2015-09-18T10:31:10\")") == %FeelEx.Value{
             value: "2015-09-18T10:31:10",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"2015-09-18T10:31:10+01:00\")") == %FeelEx.Value{
             value: "2015-09-18T10:31:10+01:00",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"2015-09-18T10:31:10@Europe/Paris\")") == %FeelEx.Value{
             value: "2015-09-18T10:31:10@Europe/Paris",
             type: :string
           }
  end

  test "string() - days-time-duration" do
    assert FeelEx.evaluate("string(duration(\"P4D\"))") == %FeelEx.Value{
             value: "P4D",
             type: :string
           }

    assert FeelEx.evaluate("string(duration(\"PT2H\"))") == %FeelEx.Value{
             value: "PT2H",
             type: :string
           }

    assert FeelEx.evaluate("string(duration(\"PT30M\"))") == %FeelEx.Value{
             value: "PT30M",
             type: :string
           }

    assert FeelEx.evaluate("string(duration(\"P1DT6H\"))") == %FeelEx.Value{
             value: "P1DT6H",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"P4D\")") == %FeelEx.Value{
             value: "P4D",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"PT2H\")") == %FeelEx.Value{
             value: "PT2H",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"PT30M\")") == %FeelEx.Value{
             value: "PT30M",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"P1DT6H\")") == %FeelEx.Value{
             value: "P1DT6H",
             type: :string
           }
  end

  test "string() - years-month-duration" do
    assert FeelEx.evaluate("string(duration(\"P2Y\"))") == %FeelEx.Value{
             value: "P2Y",
             type: :string
           }

    assert FeelEx.evaluate("string(duration(\"P6M\"))") == %FeelEx.Value{
             value: "P6M",
             type: :string
           }

    assert FeelEx.evaluate("string(duration(\"P1Y6M\"))") == %FeelEx.Value{
             value: "P1Y6M",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"P2Y\")") == %FeelEx.Value{
             value: "P2Y",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"P6M\")") == %FeelEx.Value{
             value: "P6M",
             type: :string
           }

    assert FeelEx.evaluate("string(@\"P1Y6M\")") == %FeelEx.Value{
             value: "P1Y6M",
             type: :string
           }
  end

  test "string() - list" do
        assert FeelEx.evaluate("string([1,2+4])") == %FeelEx.Value{
             value: "[1, 6]",
             type: :string
           }
  end

  test "string() - context" do
    # context =
    #   """
    #   string(
    #   {a: 1,
    #   "b": date and time("2021-01-01T01:00:00"),
    #   c: @\"P2Y\"
    #   }
    #   )
    #   """

    # assert FeelEx.evaluate(context) == %FeelEx.Value{
    #          value: "{a:1, b:2021-01-01T01:00:00, c: P2Y}",
    #          type: :string
    #        }
  end
end
