defmodule FeelEx.BooleanExpressionTests do
  use ExUnit.Case

  test "equality of string" do
    assert %FeelEx.Value{value: true, type: :boolean} ==
             FeelEx.evaluate("\"Hello World\" = \"Hello \" +\"World\"")
  end

  test "equality of numbers" do
    assert %FeelEx.Value{value: true, type: :boolean} == FeelEx.evaluate("3+1=2+2")
  end

  test "equality of float and integer" do
    assert %FeelEx.Value{value: true, type: :boolean} == FeelEx.evaluate("3+1=2+2")
  end

  test "equality of list" do
    assert %FeelEx.Value{value: true, type: :boolean} == FeelEx.evaluate("[2,true]=[1+1,true]")
  end

  test "comparison of date" do
    assert FeelEx.evaluate("date(\"2020-04-05\") < date(\"2020-04-06\")") == %FeelEx.Value{
             value: true,
             type: :boolean
           }

    assert FeelEx.evaluate("date(\"2020-04-05\") <= date(\"2020-04-06\")") ==
             %FeelEx.Value{value: true, type: :boolean}

    assert FeelEx.evaluate("date(\"2020-04-05\") >= date(\"2020-04-06\")") == %FeelEx.Value{
             value: false,
             type: :boolean
           }

    assert FeelEx.evaluate("date(\"2020-04-05\") = date(\"2020-04-06\")") ==
             %FeelEx.Value{value: false, type: :boolean}
  end

  test "comparison days_time_duration duration" do
    assert FeelEx.evaluate("duration(\"P6D\") > duration(\"P5DT24H\")") ==
             %FeelEx.Value{value: false, type: :boolean}

    assert FeelEx.evaluate("duration(\"P6D\") < duration(\"P5DT24H\")") ==
             %FeelEx.Value{value: false, type: :boolean}

    assert FeelEx.evaluate("duration(\"P6D\") <= duration(\"P5DT24H\")") ==
             %FeelEx.Value{value: true, type: :boolean}

    assert FeelEx.evaluate("duration(\"P6D\") >= duration(\"P5DT24H\")") ==
             %FeelEx.Value{value: true, type: :boolean}

    assert FeelEx.evaluate("duration(\"P6D\") = duration(\"P5DT24H\")") ==
             %FeelEx.Value{value: true, type: :boolean}
  end

  test "comparison of time" do
    assert %FeelEx.Value{value: nil, type: :null} ==
             FeelEx.evaluate("@\"08:00:00\" = @\"08:00:00@Europe/Paris\"")

    assert %FeelEx.Value{value: nil, type: :null} ==
             FeelEx.evaluate("@\"08:00:00@Europe/Paris\"=@\"08:00:00\"")

    assert FeelEx.evaluate("@\"08:00:00@Europe/Paris\" = @\"08:00:00+01:00\"") ==
             %FeelEx.Value{value: false, type: :boolean}

    assert FeelEx.evaluate("@\"08:00:00@Europe/Paris\" = @\"08:00:00@Europe/Paris\"") ==
             %FeelEx.Value{value: true, type: :boolean}
  end

  test "null check" do
    assert FeelEx.evaluate("null = null") == %FeelEx.Value{value: true, type: :boolean}
    assert FeelEx.evaluate("\"foo\" = null") == %FeelEx.Value{value: false, type: :boolean}
    assert FeelEx.evaluate("{x: null}.x = null") == %FeelEx.Value{value: true, type: :boolean}
    assert FeelEx.evaluate("{}.y = null") == %FeelEx.Value{value: true, type: :boolean}
  end

  test "between of" do
    assert %FeelEx.Value{value: true, type: :boolean} ==
             FeelEx.evaluate(
               " date(\"2020-04-06\") between date(\"2020-04-05\") and date(\"2020-04-09\")"
             )

    assert %FeelEx.Value{value: true, type: :boolean} == FeelEx.evaluate(" 5 between 3 and 7")
  end
end
