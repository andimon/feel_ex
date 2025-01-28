defmodule FeelEx.ConverstionFunctionTests do
  use ExUnit.Case
  alias FeelEx.Value

  describe "conversion function - string" do
    test "test converting integer to string" do
      assert FeelEx.evaluate("string(1)") == %Value{value: "1", type: :string}
      assert FeelEx.evaluate("string(12)") == %Value{value: "12", type: :string}
    end

    test "converting negative integer to string" do
      assert FeelEx.evaluate("string(-1)") == %Value{value: "-1", type: :string}
      assert FeelEx.evaluate("string(-12)") == %Value{value: "-12", type: :string}
    end

    test "converting float without integral part to string" do
      assert FeelEx.evaluate("string(.12)") == %Value{value: "0.12", type: :string}
      assert FeelEx.evaluate("string(.1)") == %Value{value: "0.1", type: :string}
    end

    test "convert null to string still returns null" do
      assert FeelEx.evaluate("string(null)") == %Value{value: nil, type: :null}
    end

    test "converting a string to a string is idempotent" do
      assert FeelEx.evaluate("string(\"this is a wonderful string\")") == %Value{
               value: "this is a wonderful string",
               type: :string
             }
    end

    test "converting a boolean value to string" do
      assert FeelEx.evaluate("string(true)") == %Value{value: "true", type: :string}
      assert FeelEx.evaluate("string(false)") == %Value{value: "false", type: :string}
    end

    test "converting a date to string" do
      assert FeelEx.evaluate("string(date(\"2021-01-01\"))") ==
               %Value{value: "2021-01-01", type: :string}
    end

    test "converting time without timezone or offset to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00\"))") == %Value{
               value: "08:01:00",
               type: :string
             }
    end

    test "converting time with timezone to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00@Europe/Malta\"))") ==
               %Value{value: "08:01:00@Europe/Malta", type: :string}
    end

    test "converting time with offset to string" do
      assert FeelEx.evaluate("string(time(\"08:01:00+01:00\"))") ==
               %Value{value: "08:01:00+01:00", type: :string}
    end

    test "converting  datetime without timezone or offset to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01\"))") == %Value{
               value: "2021-01-01T08:01:01",
               type: :string
             }
    end

    test "converting  datetime with timezone to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01@Europe/Malta\"))") ==
               %Value{
                 value: "2021-01-01T08:01:01@Europe/Malta",
                 type: :string
               }
    end

    test "converting  datetime with offset to string" do
      assert FeelEx.evaluate("string(date and time(\"2021-01-01T08:01:01+01:00\"))") ==
               %Value{
                 value: "2021-01-01T08:01:01+01:00",
                 type: :string
               }
    end

    test "converting days time duration to string" do
      assert FeelEx.evaluate("string(duration(\"P4D\"))") == %Value{value: "P4D", type: :string}
    end

    test "converting years months duration to string" do
      assert FeelEx.evaluate("string(duration(\"P1Y6M\"))") == %Value{
               value: "P1Y6M",
               type: :string
             }
    end

    test "converting list with various datatype to string" do
      assert FeelEx.evaluate("string([duration(\"P4D\"),2, 200.0,time(\"08:01:01\")])") == %Value{
               value: "[P4D, 2, 200.0, 08:01:01]",
               type: :string
             }
    end

    test "convert context with list value to string" do
      assert FeelEx.evaluate("string({a: [duration(\"P4D\"),2, 200.0,time(\"08:01:01\")]})") ==
               %Value{value: "{a:[P4D, 2, 200.0, 08:01:01]}", type: :string}
    end
  end

  describe "conversion function - number" do
    test "converting integer string to number" do
      assert FeelEx.evaluate("number(\"11\")") == %Value{value: 11, type: :number}
      assert FeelEx.evaluate("number(\"1\")") == %Value{value: 1, type: :number}
    end

    test "converting negative integer string to number" do
      assert FeelEx.evaluate("number(\"-11\")") == %Value{value: -11, type: :number}
      assert FeelEx.evaluate("number(\"-1\")") == %Value{value: -1, type: :number}
    end

    test "converting float without integrand to number" do
      assert FeelEx.evaluate("number(\".1\")") == %Value{value: 0.1, type: :number}
      assert FeelEx.evaluate("number(\".12\")") == %Value{value: 0.12, type: :number}
    end

    test "converting negative float without integrand to number" do
      assert FeelEx.evaluate("number(\"-.1\")") == %Value{value: -0.1, type: :number}
      assert FeelEx.evaluate("number(\"-.12\")") == %Value{value: -0.12, type: :number}
    end

    test "converting float to number" do
      assert FeelEx.evaluate("number(\"1.1\")") == %Value{value: 1.1, type: :number}
      assert FeelEx.evaluate("number(\"22.12\")") == %Value{value: 22.12, type: :number}
    end

    test "converting negative float to number" do
      assert FeelEx.evaluate("number(\"-1.1\")") == %Value{value: -1.1, type: :number}
      assert FeelEx.evaluate("number(\"-22.12\")") == %Value{value: -22.12, type: :number}
    end

    test "converting a non number string" do
      assert FeelEx.evaluate("number(\"aa\")") == %Value{value: nil, type: :null}
    end

    test "trying to convert anything but string to number" do
      assert FeelEx.evaluate("number(@\"2021-01-01\")") == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - context(entries)" do
    test "converting an empty list" do
      assert FeelEx.evaluate("context([])") == %Value{value: %{}, type: :context}
    end

    test "converting with a date value" do
      assert FeelEx.evaluate(
               "context([{\"key\":\"a\", \"value\": date(\"2021-01-01\")}, {\"key\":\"b\", \"value\":2}])"
             ) == %Value{
               value: %{
                 b: %FeelEx.Value{value: 2, type: :number},
                 a: %FeelEx.Value{value: ~D[2021-01-01], type: :date}
               },
               type: :context
             }
    end

    test "converting with a non context entry" do
      assert FeelEx.evaluate(
               "context([{\"key\":\"a\", \"value\": 1}, 21, {\"key\":\"b\", \"value\":2}])"
             ) == %Value{value: nil, type: :null}
    end

    test "converting with a context that does not contain the required key/value keys" do
      assert FeelEx.evaluate(
               "context([{\"key\":\"a\", \"val\": 1}, {\"key\":\"b\", \"value\":2}])"
             ) == %Value{value: nil, type: :null}
    end

    test "context conversion with a non list value" do
      assert FeelEx.evaluate("context(1)") == %Value{value: nil, type: :null}

      assert FeelEx.evaluate("context(\"a\")") == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - date(string)" do
    test "2024-06-31 is invalid because June has 30 days" do
      assert FeelEx.evaluate("date(\"2021-06-31\")") == %Value{value: nil, type: :null}

      assert FeelEx.evaluate("date(\"2021-06-30\")") == %Value{value: ~D[2021-06-30], type: :date}
    end
  end

  describe "conversion function - date(year,month,day)" do
    test "2024-06-31 is invalid because June has 30 days" do
      assert FeelEx.evaluate("date(2026,6,31)") == %Value{value: nil, type: :null}

      assert FeelEx.evaluate("date(2026,6,30)") == %Value{value: ~D[2026-06-30], type: :date}
    end
  end

  describe "conversion function - date(date time)" do
    test "datetime without offset or zone id" do
      assert FeelEx.evaluate("date(@\"2021-06-29T08:00:01\")") == %FeelEx.Value{
               value: ~D[2021-06-29],
               type: :date
             }
    end

    test "datetime with offset" do
      assert FeelEx.evaluate("date(@\"2021-06-29T08:00:01+01:00\")") == %FeelEx.Value{
               value: ~D[2021-06-29],
               type: :date
             }
    end

    test "datetime with timezone" do
      assert FeelEx.evaluate("date(@\"2021-06-29T08:00:01@Europe/Malta\")") == %FeelEx.Value{
               value: ~D[2021-06-29],
               type: :date
             }
    end

    test "datetime with invalid timezone" do
      assert FeelEx.evaluate("date(@\"2021-06-29T08:00:01@Europe/Maltas\")") == %FeelEx.Value{
               value: nil,
               type: :null
             }
    end
  end

  describe "conversion function - time(input)" do
    test "convert string to time without offset or timezone id" do
      assert FeelEx.evaluate("time(\"08:00:01\")") == %Value{value: ~T[08:00:01], type: :time}
    end

    test "convert string to time with offset" do
      assert FeelEx.evaluate("time(\"08:00:01+01:00\")") == %Value{
               value: {~T[08:00:01], "+01:00"},
               type: :time
             }
    end

    test "convert string to time with timezone id" do
      assert FeelEx.evaluate("time(\"08:00:01@Europe/Malta\")") == %Value{
               value: {~T[08:00:01], "+01:00", "Europe/Malta"},
               type: :time
             }
    end

    test "convert datetime to time without offset or timezone id" do
      assert FeelEx.evaluate("time(date and time(\"2021-01-03T08:00:01\"))") == %Value{
               value: ~T[08:00:01],
               type: :time
             }
    end

    test "convert datetime to time with offset" do
      assert FeelEx.evaluate("time(date and time(\"2021-01-03T08:00:01+01:00\"))") == %Value{
               value: {~T[08:00:01], "+01:00"},
               type: :time
             }
    end

    test "convert datetime to time with timezone id" do
      assert FeelEx.evaluate("time(date and time(\"2021-01-03T08:00:01@Europe/Malta\"))") ==
               %Value{value: {~T[08:00:01], "+01:00", "Europe/Malta"}, type: :time}
    end


    test "convert datetime to time with  american timezone id" do
      assert FeelEx.evaluate("time(date and time(\"2021-01-03T08:00:01@America/Vancouver\"))") ==
               %Value{value: {~T[08:00:01], "-08:00", "America/Vancouver"}, type: :time}
    end

    test "invalid time string" do
      assert FeelEx.evaluate("time(\"a\")") == %Value{value: nil, type: :null}
    end

    test "invalid type" do
      assert FeelEx.evaluate("time(1)") == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - time(hour.minute,second)" do
    test "converting integer parts to time" do
      assert FeelEx.evaluate("time(23,59,0)") == %Value{value: ~T[23:59:00], type: :time}
    end

    test "converting float parts to time" do
      assert FeelEx.evaluate("time(23.2,59.11,0.21323)") == %Value{
               value: ~T[23:59:00],
               type: :time
             }
    end

    test "invalid time hour number is invalid" do
      assert FeelEx.evaluate("time(26.2,59.11,0.21323)") == Value.new(nil)
    end

    test "invalid parameter" do
      assert FeelEx.evaluate("time(\"a\",59.11,0.21323)") == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - time(hour,minute,second,duration)" do
    test "1H offset" do
      assert FeelEx.evaluate("time(8,59,11,@\"PT1H\")") == Value.new(~T[08:59:11], "+01:00")
    end

    test "-1H offset" do
      assert FeelEx.evaluate("time(8,59,11,@\"PT-1H\")") == Value.new(~T[08:59:11], "-01:00")
    end

    test "negative hour and negative minute offset" do
      assert FeelEx.evaluate("time(8,59,11,@\"PT-1H-2M\")") == Value.new(~T[08:59:11], "-01:01")
    end

    test "invalid parameter" do
      assert FeelEx.evaluate("time(25,59,11,@\"PT1H\")") == %Value{value: nil, type: :null}
    end

    test "invalid offset" do
      assert FeelEx.evaluate("time(22,59,11,@\"P1D\")") == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - date and time(date, time)" do
    test "converting with time without offset/timezone id" do
      assert FeelEx.evaluate("date and time(date(\"2012-12-24\"),time(\"T23:59:00\"))") == %Value{
               value: ~N[2012-12-24 23:59:00],
               type: :date_time
             }
    end

    test "converting with time with offset" do
      assert FeelEx.evaluate("date and time(date(\"2012-12-24\"),time(\"T23:59:00+01:00\"))") ==
               %Value{value: {~N[2012-12-24 23:59:00], "+01:00"}, type: :date_time}
    end

    test "convert with time with timezone id" do
      assert FeelEx.evaluate(
               "date and time(date(\"2012-12-24\"),time(\"T23:59:00@Europe/Malta\"))"
             ) == %Value{
               value: {~N[2012-12-24 23:59:00], "+01:00", "Europe/Malta"},
               type: :date_time
             }
    end

    test "convert with 2 invalid parameters" do
      assert FeelEx.evaluate(
               "  date and time(date(\"2012-12-24\"),time(\"T23:59:00@Europe/Maltsa\"))"
             ) == %Value{value: nil, type: :null}
    end
  end

  describe "conversion function - date and time(date and time, time)" do
    test "converting with time without offset/timezone id" do
      assert FeelEx.evaluate(
               "date and time(date and time(\"2012-12-24T08:01:01\"),time(\"T23:59:00\"))"
             ) == %Value{value: ~N[2012-12-24 23:59:00], type: :date_time}
    end

    test "converting with time with offset" do
      assert FeelEx.evaluate(
               "date and time(date and time(\"2012-12-24T08:01:01\"),time(\"T23:59:00+01:00\"))"
             ) == %Value{value: {~N[2012-12-24 23:59:00], "+01:00"}, type: :date_time}
    end

    test "convert with time with timezone id" do
      assert FeelEx.evaluate(
               "date and time(date and time(\"2012-12-24T08:01:01\"),time(\"T23:59:00@Europe/Malta\"))"
             ) == %Value{
               value: {~N[2012-12-24 23:59:00], "+01:00", "Europe/Malta"},
               type: :date_time
             }
    end

    test "convert with 2 invalid parameters" do
      assert FeelEx.evaluate(
               "date and time(date and time(\"2012-12-24T08:012:01\"),time(\"T23:59:00@Europe/Malta\"))"
             ) == %Value{value: nil, type: :null}
    end
  end

  describe "duration(from)" do
    test "duration with day" do
      FeelEx.evaluate("duration(\"P5D\")") == %Value{
        value: %Duration{day: 5},
        type: :days_time_duration
      }
    end

    test "duration with years" do
    end
  end
end
