defmodule FeelEx.ValueTests do
  use ExUnit.Case
  doctest FeelEx

  alias FeelEx.Value

  test "null" do
    assert %Value{value: nil, type: :null} == Value.new(nil)
  end

  test "string" do
    assert %Value{value: "aw dinja", type: :string} == Value.new("aw dinja")
  end

  test "number - integer" do
    assert %Value{value: 1, type: :number} == Value.new(1)
  end

  test "number - negative integer" do
    assert %Value{value: -5, type: :number} == Value.new(-5)
  end

  test "number - negative float" do
    assert %Value{value: -5.5, type: :number} == Value.new(-5.5)
  end

  test "number - float" do
    assert %Value{value: 5.5, type: :number} == Value.new(5.5)
  end

  test "boolean - true" do
    assert %Value{value: true, type: :boolean} == Value.new(true)
  end

  test "boolean - false" do
    assert %Value{value: false, type: :boolean} == Value.new(false)
  end

  test "date" do
    date = Date.utc_today()
    assert %Value{value: date, type: :date} == Value.new(date)
  end

  test "time" do
    time = Time.utc_now()
    assert %Value{value: time, type: :time} == Value.new(time)
  end

  test "time with zone id" do
    time = Time.utc_now()
    zone_id = "Europe/Paris"
    assert %Value{value: {time, "+01:00"}, type: :time} == Value.new(time, zone_id)
  end

  test "time with utc zone id" do
    time = Time.utc_now()
    zone_id = "Iceland"
    assert %Value{value: {time, "+00:00"}, type: :time} == Value.new(time, zone_id)
  end

  test "time positive offset" do
    time = Time.utc_now()
    offset = "+01:00"
    assert %Value{value: {time, "+01:00"}, type: :time} == Value.new(time, offset)
  end

  test "time negative offset" do
    time = Time.utc_now()
    offset = "-01:00"
    assert %Value{value: {time, "-01:00"}, type: :time} == Value.new(time, offset)
  end

  test "date time - without offset or time zone id " do
    date_time = NaiveDateTime.from_iso8601!("2015-09-18T10:31:10")
    assert %Value{value: date_time, type: :date_time} == Value.new(date_time)
  end

  test "date time - with offset" do
    date_time = NaiveDateTime.from_iso8601!("2015-09-18T10:31:10")
    offset = "+01:00"
    assert %Value{value: {date_time, offset}, type: :date_time} == Value.new(date_time, offset)
  end

  test "date time - with zone id" do
    date_time = NaiveDateTime.from_iso8601!("2015-09-18T10:31:10")
    zone_id = "Europe/Paris"
    assert %Value{value: {date_time, "+01:00"}, type: :date_time} == Value.new(date_time, zone_id)
  end

  test "duration - P4D" do
    duration = Duration.from_iso8601!("P4D")
    assert %Value{value: duration, type: :duration} == Value.new(duration)
  end

  test "duration - PT2H" do
    duration = Duration.from_iso8601!("PT2H")
    assert %Value{value: duration, type: :duration} == Value.new(duration)
  end

  test "duration - P1DT6H30M" do
    duration = Duration.from_iso8601!("P1DT6H30M")
    assert %Value{value: duration, type: :duration} == Value.new(duration)
  end

  test "duration - {b: 2, c: \"valid\"}" do
    context = %{b: 2, c: "valid"}
    assert %Value{value: context, type: :context} == Value.new(context)
  end
end
