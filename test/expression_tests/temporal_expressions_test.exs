defmodule FeelEx.TemporalExpressionTest do
  use ExUnit.Case

  test "date+duration=date" do
    assert %FeelEx.Value{value: ~D[2020-04-07], type: :date} =
             FeelEx.evaluate("date(\"2020-04-06\") + duration(\"P1D\")")
  end

  test "duration+date=date" do
    assert %FeelEx.Value{value: ~D[2020-04-07], type: :date} =
             FeelEx.evaluate("duration(\"P1D\") + date(\"2020-04-06\")")
  end

  test "time+duration=time" do
    assert FeelEx.evaluate("time(\"08:00:00\") + duration(\"PT1H\")") ==
             %FeelEx.Value{value: ~T[09:00:00], type: :time}

    assert FeelEx.evaluate("time(\"08:00:00@Europe/Paris\") + duration(\"PT1H\")") ==
             %FeelEx.Value{value: {~T[09:00:00], "+01:00", "Europe/Paris"}, type: :time}

    assert FeelEx.evaluate("time(\"08:00:00+01:00\") + duration(\"PT1H\")") ==
             %FeelEx.Value{value: {~T[09:00:00], "+01:00"}, type: :time}
  end

  test "duration+time=time" do
    assert FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00\")") ==
             %FeelEx.Value{value: ~T[09:00:00], type: :time}

    assert FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00@Europe/Paris\")") ==
             %FeelEx.Value{type: :time, value: {~T[09:00:00], "+01:00", "Europe/Paris"}}

    assert FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00+01:00\")") ==
             %FeelEx.Value{value: {~T[09:00:00], "+01:00"}, type: :time}
  end

  test "date-time+duration=date-time" do
    assert FeelEx.evaluate("date and time(\"2020-04-06T08:00:00\") + duration(\"P7D\")") ==
             %FeelEx.Value{value: ~N[2020-04-13 08:00:00], type: :date_time}

    assert FeelEx.evaluate("date and time(\"2020-04-06T08:00:00+01:00\") + duration(\"P7D\")") ==
             %FeelEx.Value{value: {~N[2020-04-13 08:00:00], "+01:00"}, type: :date_time}

    assert FeelEx.evaluate(
             "date and time(\"2020-04-06T08:00:00@Europe/Malta\") + duration(\"P7D\")"
           ) ==
             %FeelEx.Value{
               value: {~N[2020-04-13 08:00:00], "+01:00", "Europe/Malta"},
               type: :date_time
             }
  end

  test "duration+date-time=date-time" do
    assert FeelEx.evaluate("duration(\"P7D\")+date and time(\"2020-04-06T08:00:00\")") ==
             %FeelEx.Value{value: ~N[2020-04-13 08:00:00], type: :date_time}

    assert FeelEx.evaluate("duration(\"P7D\") + date and time(\"2020-04-06T08:00:00+01:00\")") ==
             %FeelEx.Value{value: {~N[2020-04-13 08:00:00], "+01:00"}, type: :date_time}

    assert FeelEx.evaluate(
             "duration(\"P7D\")+date and time(\"2020-04-06T08:00:00@Europe/Malta\")"
           ) ==
             %FeelEx.Value{
               value: {~N[2020-04-13 08:00:00], "+01:00", "Europe/Malta"},
               type: :date_time
             }
  end

  test "duration+duration=duration" do
    assert FeelEx.evaluate("duration(\"P2D\") + duration(\"P5D\")") ==
             %FeelEx.Value{value: %Duration{day: 7}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"P1DT2H\") + duration(\"P1DT3H\")") ==
             %FeelEx.Value{value: %Duration{day: 2, hour: 5}, type: :days_time_duration}

    assert FeelEx.evaluate("duration(\"P1D\") + duration(\"PT1H\")") ==
             %FeelEx.Value{value: %Duration{day: 1, hour: 1}, type: :days_time_duration}
  end

  test "date-date=duration" do
    assert FeelEx.evaluate("date(\"2020-04-06\") - date(\"2020-04-01\")") ==
             %FeelEx.Value{value: %Duration{day: 5}, type: :days_time_duration}

    assert FeelEx.evaluate("date(\"2023-10-01\") - date(\"2023-07-01\")") ==
             %FeelEx.Value{value: %Duration{day: 92}, type: :days_time_duration}

    assert FeelEx.evaluate("date(\"2023-01-01\") - date(\"2022-12-31\")") ==
             %FeelEx.Value{value: %Duration{day: 1}, type: :days_time_duration}
  end

  test "date-duration=date" do
    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P5D\")") ==
             %FeelEx.Value{value: ~D[2020-04-01], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-10\") - duration(\"P10D\")") ==
             %FeelEx.Value{value: ~D[2020-03-31], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P0D\")") ==
             %FeelEx.Value{value: ~D[2020-04-06], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P1M\")") ==
             %FeelEx.Value{value: ~D[2020-03-06], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P-5D\")") ==
             %FeelEx.Value{value: ~D[2020-04-11], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P15D\")") ==
             %FeelEx.Value{value: ~D[2020-03-22], type: :date}

    assert FeelEx.evaluate("date(\"2020-03-01\") - duration(\"P29D\")") ==
             %FeelEx.Value{value: ~D[2020-02-01], type: :date}

    assert FeelEx.evaluate("date(\"2022-01-01\") - duration(\"P1Y\")") ==
             %FeelEx.Value{value: ~D[2021-01-01], type: :date}

    assert FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P365D\")") ==
             %FeelEx.Value{value: ~D[2019-04-07], type: :date}

    assert FeelEx.evaluate("date(\"2021-08-15\") - duration(\"P5D\")") ==
             %FeelEx.Value{value: ~D[2021-08-10], type: :date}
  end

  describe "date-time-date-time=days time duration" do
    test "date-time duration without offset" do
      assert FeelEx.evaluate(
               "date and time(\"2025-01-01T08:00:00\") - date and time(\"2024-01-01T06:00:01\")"
             ) ==
               %FeelEx.Value{
                 value: %Duration{hour: 8785, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "time duration with same offset" do
      assert FeelEx.evaluate(
               "date and time(\"2025-01-01T08:00:00+01:00\") - date and time(\"2024-01-01T06:00:01+01:00\")"
             ) ==
               %FeelEx.Value{
                 value: %Duration{hour: 8785, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "date time duration with different offset" do
      assert FeelEx.evaluate(
               "date and time(\"2025-01-01T08:00:00+01:00\") - date and time(\"2024-01-01T06:00:01-01:00\")"
             ) ==
               %FeelEx.Value{
                 value: nil,
                 type: :null
               }
    end

    test " date time duration with same zone id" do
      assert FeelEx.evaluate(
               "date and time(\"2025-01-01T08:00:00@Europe/Malta\") - date and time(\"2024-01-01T06:00:01@Europe/Malta\")"
             ) ==
               %FeelEx.Value{
                 value: %Duration{hour: 8785, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "time duration with different zone ids" do
      assert FeelEx.evaluate(
               "date and time(\"2025-01-01T08:00:00@Europe/Malta\") - date and time(\"2024-01-01T06:00:01@Europe/Paris\")"
             ) ==
               %FeelEx.Value{
                 value: nil,
                 type: :null
               }
    end
  end

  describe "time-time=days time duration" do
    test "time duration without offset" do
      assert FeelEx.evaluate("time(\"08:00:00\") - time(\"06:00:01\")") ==
               %FeelEx.Value{
                 value: %Duration{hour: 1, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "time duration with same offset" do
      assert FeelEx.evaluate("time(\"08:00:00+01:00\") - time(\"06:00:01+01:00\")") ==
               %FeelEx.Value{
                 value: %Duration{hour: 1, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "time duration with different offset" do
      assert FeelEx.evaluate("time(\"08:00:00+01:00\") - time(\"06:00:01-01:00\")") ==
               %FeelEx.Value{
                 value: nil,
                 type: :null
               }
    end

    test "time duration with same zone id" do
      assert FeelEx.evaluate("time(\"08:00:00@Europe/Malta\") - time(\"06:00:01@Europe/Malta\")") ==
               %FeelEx.Value{
                 value: %Duration{hour: 1, minute: 59, second: 59},
                 type: :days_time_duration
               }
    end

    test "time duration with different zone ids" do
      assert FeelEx.evaluate("time(\"08:00:00@Europe/Malta\") - time(\"06:00:01@Europe/Paris\")") ==
               %FeelEx.Value{
                 value: nil,
                 type: :null
               }
    end
  end

  describe "date-time duration =date-time" do
    test "reduce duration from date-time without offset or zone id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:00:00\") - duration(\"PT2H\")") ==
               %FeelEx.Value{value: ~N[2021-01-01 06:00:00], type: :date_time}
    end

    test "reduce duration from date-time with offset" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:00:00+01:00\") - duration(\"PT2H\")") ==
               %FeelEx.Value{value: {~N[2021-01-01 06:00:00], "+01:00"}, type: :date_time}
    end

    test "reduce duration from date-time with zone id" do
      assert FeelEx.evaluate(
               "date and time(\"2021-01-01T08:00:00@Europe/Malta\") - duration(\"PT2H\")"
             ) ==
               %FeelEx.Value{
                 value: {~N[2021-01-01 06:00:00], "+01:00", "Europe/Malta"},
                 type: :date_time
               }
    end
  end

  describe "days-time - days-time-duration-days-time-duration = days-time-duration" do
    test "test days-time-duration-days-time-duration = days-time-duration" do
      assert FeelEx.evaluate("duration(\"P7D\") - duration(\"P8DT1S\")") ==
               %FeelEx.Value{
                 value: %Duration{hour: -24, second: -1},
                 type: :days_time_duration
               }
    end
  end

  describe "years-months-duration-year-months-duration =  year-months-duration" do
    test "test days-time-duration-days-time-duration = days-time-duration" do
      assert FeelEx.evaluate("duration(\"P1Y\") - duration(\"P3M\")") ==
               %FeelEx.Value{
                 value: %Duration{month: 9},
                 type: :years_months_duration
               }

      assert FeelEx.evaluate("duration(\"P3Y1M\") - duration(\"P1Y12M\")") ==
               %FeelEx.Value{value: %Duration{year: 1, month: 1}, type: :years_months_duration}
    end
  end

  describe "duration*number= duration" do
    test "duration(\"P1D\") * 5" do
      assert FeelEx.evaluate("duration(\"P1D\") * 5") == %FeelEx.Value{
               value: %Duration{day: 5},
               type: :days_time_duration
             }

      assert FeelEx.evaluate("duration(\"P1M\") * 13") == %FeelEx.Value{
               value: %Duration{year: 1, month: 1},
               type: :years_months_duration
             }
    end
  end

  describe "number*duration= duration" do
    test "duration(\"P1D\") * 5" do
      assert FeelEx.evaluate("5*duration(\"P1D\")") == %FeelEx.Value{
               value: %Duration{day: 5},
               type: :days_time_duration
             }

      assert FeelEx.evaluate("13 * duration(\"P1M\")") == %FeelEx.Value{
               value: %Duration{year: 1, month: 1},
               type: :years_months_duration
             }
    end
  end

  describe "duration/number= duration" do
    test "duration(\"P5D\") / 5" do
      assert FeelEx.evaluate("duration(\"P5D\")/5") == %FeelEx.Value{
               value: %Duration{day: 1},
               type: :days_time_duration
             }
    end

    test "duration(\"P1Y\") /  12" do
      assert FeelEx.evaluate("duration(\"P1Y\") / 12") == %FeelEx.Value{
               value: %Duration{month: 1},
               type: :years_months_duration
             }
    end
  end

  describe "days-time-duration/days-time-duration= number" do
    test "duration(\"P5D\") / duration(\"P1D\")" do
      assert FeelEx.evaluate("duration(\"P5D\") / duration(\"P1D\")") == %FeelEx.Value{
               value: 5,
               type: :number
             }
    end
  end

  describe "years-months-duration/years-months-duration= number" do
    test "duration(\"P1Y\") / duration(\"P2M\")" do
      assert FeelEx.evaluate("duration(\"P1Y\") / duration(\"P2M\")") == %FeelEx.Value{
               value: 6,
               type: :number
             }
    end
  end

  describe "properties" do
    test "access year for date" do
      assert FeelEx.evaluate("@\"2021-01-01\".year") ==
               %FeelEx.Value{value: 2021, type: :number}

      assert FeelEx.evaluate("date(\"2021-01-01\").year") ==
               %FeelEx.Value{value: 2021, type: :number}
    end

    test "access year for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").year") ==
               %FeelEx.Value{value: 2021, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".year") ==
               %FeelEx.Value{value: 2021, type: :number}
    end

    test "access year for datetime with offset" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").year") ==
               %FeelEx.Value{value: 2021, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".year") ==
               %FeelEx.Value{value: 2021, type: :number}
    end

    test "access year for datetime with zoneid" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").year") ==
               %FeelEx.Value{value: 2021, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".year") ==
               %FeelEx.Value{value: 2021, type: :number}
    end

    test "access month for date" do
      assert FeelEx.evaluate("@\"2021-01-01\".month") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("date(\"2021-01-01\").month") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access month for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").month") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".month") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access month for datetime with offset" do
      assert FeelEx.evaluate("date and time(\"2021-05-01T08:01:05+01:00\").month") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-05-01T08:05:05+01:00\".month") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access month for datetime with zoneid" do
      assert FeelEx.evaluate("date and time(\"2021-05-01T08:01:05@Europe/Malta\").month") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-05-01T08:05:05@Europe/Malta\".month") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access day for date" do
      assert FeelEx.evaluate("@\"2021-01-01\".day") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("date(\"2021-01-01\").day") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access day for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").day") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".day") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access day for datetime with offset" do
      assert FeelEx.evaluate("date and time(\"2021-05-01T08:01:05+01:00\").day") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:05:05+01:00\".day") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access day for datetime with zoneid" do
      assert FeelEx.evaluate("date and time(\"2021-05-01T08:01:05@Europe/Malta\").day") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:05:05@Europe/Malta\".day") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access weekday for date" do
      assert FeelEx.evaluate("date(\"2021-01-01\").weekday") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01\".weekday") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access weekday for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").weekday") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".weekday") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access weekday for datetime with offset" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").weekday") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".weekday") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access weekday for datetime with zoneid" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").weekday") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".weekday") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access hour for time" do
      assert FeelEx.evaluate("time(\"08:01:05\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"08:01:05\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access hour for time with offset id" do
      assert FeelEx.evaluate("time(\"08:01:05+01:00\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"08:01:05+01:00\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access hour for time with zone id" do
      assert FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"08:01:05@Europe/Malta\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access hour for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access hour for datetime with offset id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access hour for datetime with zone id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").hour") ==
               %FeelEx.Value{value: 8, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".hour") ==
               %FeelEx.Value{value: 8, type: :number}
    end

    test "access minute for time" do
      assert FeelEx.evaluate("time(\"08:01:05\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"08:01:05\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access minute for time with offset id" do
      assert FeelEx.evaluate("time(\"08:01:05+01:00\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"08:01:05+01:00\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access minute for time with offset zone id" do
      assert FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"08:01:05@Europe/Malta\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access minute for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access minute for datetime with offset id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access minute for datetime with zone id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").minute") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".minute") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access second for time" do
      assert FeelEx.evaluate("time(\"08:01:05\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"08:01:05\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access second for time with offset id" do
      assert FeelEx.evaluate("time(\"08:01:05+01:00\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"08:01:05+01:00\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access second for time with zone id" do
      assert FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"08:01:05@Europe/Malta\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access second for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access second for datetime with offset id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access second for datetime with offset zone id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").second") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".second") ==
               %FeelEx.Value{value: 5, type: :number}
    end

    test "access time offset for time" do
      assert FeelEx.evaluate("@\"08:01:05\".time offset") == %FeelEx.Value{
               value: nil,
               type: :null
             }

      assert FeelEx.evaluate("time(\"08:01:05\").time offset") == %FeelEx.Value{
               value: nil,
               type: :null
             }
    end

    test "access time offset for time with offset id" do
      assert FeelEx.evaluate("@\"08:01:05+01:32\".time offset") == %FeelEx.Value{
               value: %Duration{hour: 1, minute: 32},
               type: :days_time_duration
             }

      assert FeelEx.evaluate("time(\"08:01:05-02:21\").time offset") == %FeelEx.Value{
               value: %Duration{hour: -2, minute: -21},
               type: :days_time_duration
             }
    end

    test "access time offset for time with offset zone id" do
      assert FeelEx.evaluate("@\"08:01:05@Europe/Malta\".time offset") == %FeelEx.Value{
               value: %Duration{hour: 1},
               type: :days_time_duration
             }

      assert FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").time offset") == %FeelEx.Value{
               value: %Duration{hour: 1},
               type: :days_time_duration
             }
    end

    test "access time offset for datetime" do
      assert FeelEx.evaluate("@\"2021-01-03T08:01:05\".time offset") ==
               %FeelEx.Value{value: nil, type: :null}

      assert FeelEx.evaluate("date and time(\"2021-01-03T08:01:05\").time offset") ==
               %FeelEx.Value{value: nil, type: :null}
    end

    test "access time offset for datetime with offset id" do
      assert FeelEx.evaluate("@\"2021-01-03T08:01:05+01:02\".time offset") ==
               %FeelEx.Value{value: %Duration{hour: 1, minute: 2}, type: :days_time_duration}

      assert FeelEx.evaluate("date and time(\"2021-01-03T08:01:05-02:01\").time offset") ==
               %FeelEx.Value{value: %Duration{hour: -2, minute: -1}, type: :days_time_duration}
    end

    test "access time offset for datetime with offset zone id" do
      assert FeelEx.evaluate("@\"2021-01-03T08:01:05@Europe/Malta\".time offset") ==
               %FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}

      assert FeelEx.evaluate("date and time(\"2021-01-03T08:01:05@Europe/Malta\").time offset") ==
               %FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}
    end

    test "access timezone for time" do
      assert FeelEx.evaluate("time(\"08:01:05\").timezone") ==
               %FeelEx.Value{value: nil, type: :null}

      assert FeelEx.evaluate("@\"08:01:05\".timezone") ==
               %FeelEx.Value{value: nil, type: :null}
    end

    test "access timezone for time with offset id" do
      assert FeelEx.evaluate("\"08:01:05+01:00\".timezone") ==
               %FeelEx.Value{value: nil, type: :null}

      assert FeelEx.evaluate("\"08:01:05+01:00\".timezone") ==
               %FeelEx.Value{value: nil, type: :null}
    end

    test "access timezone for time with offset zone id" do
      assert FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").timezone") ==
               %FeelEx.Value{value: "Europe/Malta", type: :string}

      assert FeelEx.evaluate("@\"08:01:05@Europe/Malta\".timezone") ==
               %FeelEx.Value{value: "Europe/Malta", type: :string}
    end

    test "access timezone for datetime" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").timezone") == %FeelEx.Value{
               value: nil,
               type: :null
             }

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05\".timezone") == %FeelEx.Value{
               value: nil,
               type: :null
             }
    end

    test "access timezone for datetime with offset id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").timezone") ==
               %FeelEx.Value{
                 value: nil,
                 type: :null
               }

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".timezone") == %FeelEx.Value{
               value: nil,
               type: :null
             }
    end

    test "access timezone for datetime with offset zone id" do
      assert FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").timezone") ==
               %FeelEx.Value{value: "Europe/Malta", type: :string}

      assert FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".timezone") ==
               %FeelEx.Value{value: "Europe/Malta", type: :string}
    end

    test "access  days for days-time-duration" do
      assert FeelEx.evaluate("@\"PT24H\".days") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"P2DT-24H\".days") ==
               %FeelEx.Value{value: 1, type: :number}

      assert FeelEx.evaluate("@\"P3DT-24H\".days") ==
               %FeelEx.Value{value: 2, type: :number}

      assert FeelEx.evaluate("@\"P3DT24H\".days") ==
               %FeelEx.Value{value: 4, type: :number}

      assert FeelEx.evaluate("@\"P3DT24H1440M\".days") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"P3DT24H1441M\".days") ==
               %FeelEx.Value{value: 5, type: :number}

      assert FeelEx.evaluate("@\"P3DT48H1441M\".days") ==
               %FeelEx.Value{value: 6, type: :number}
    end

    test "access  hours for days-time-duration" do
      assert FeelEx.evaluate("@\"PT25H\".hours") ==
               %FeelEx.Value{value: 1, type: :number}
    end

    test "access  minutes for days-time-duration" do
      assert FeelEx.evaluate("@\"PT25H63M\".minutes") ==
               %FeelEx.Value{value: 3, type: :number}
    end

    test "access seconds for days-time-duration" do
      assert FeelEx.evaluate("@\"PT25H63M119S\".seconds") ==
               %FeelEx.Value{value: 59, type: :number}
    end

    test "access years for years-months-duration" do
      assert FeelEx.evaluate("@\"P1Y13M\".years") ==
               %FeelEx.Value{value: 2, type: :number}
    end

    test "access months for years-months-duration" do
      assert FeelEx.evaluate("@\"P1Y13M\".months") ==
               %FeelEx.Value{value: 1, type: :number}
    end
  end
end
