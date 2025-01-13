defmodule FeelEx.FunctionDefinitions.Temporal do
  @moduledoc false
  alias FeelEx.Value

  def date(%Value{value: value, type: :string}) do
    Value.new(Date.from_iso8601!(value))
  end

  def time(%Value{value: time, type: :string}) do
    cond do
      String.contains?(time, "@") ->
        temporal_with_zone_id(time, Time)

      String.contains?(time, "+") ->
        temporal_with_offset(time, "+", Time)

      String.contains?(time, "-") ->
        temporal_with_offset(time, "-", Time)

      Regex.match?(~r/^\d{2}:\d{2}$/, time) ->
        time = time <> ":00"
        Value.new(Time.from_iso8601!(time))

      true ->
        Value.new(Time.from_iso8601!(time))
    end
  end

  def date_and_time(%Value{value: time, type: :string}) do
    cond do
      Regex.match?(~r/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$/, time) ->
        Value.new(NaiveDateTime.from_iso8601!(time))

      String.contains?(time, "@") ->
        temporal_with_zone_id(time, NaiveDateTime)

      String.contains?(time, "+") ->
        temporal_with_offset(time, "+", NaiveDateTime)

      String.contains?(time, "-") ->
        temporal_with_offset(time, "-", NaiveDateTime)
    end
  end

  defp temporal_with_offset(datetime, _offset, NaiveDateTime) do
    {new_time, offset_val} =
      String.split_at(datetime, 19)

    datetime = NaiveDateTime.from_iso8601!(new_time)
    Value.new(datetime, offset_val)
  end

  defp temporal_with_offset(time, offset, temporal_type) do
    [new_time, offset_val] = String.split(time, offset, parts: 2)
    time = temporal_type.from_iso8601!(new_time)
    Value.new(time, offset <> offset_val)
  end

  defp temporal_with_zone_id(time, temporal_type) do
    [time, zone_id] = String.split(time, "@", parts: 2)
    time = temporal_type.from_iso8601!(time)
    Value.new(time, zone_id)
  end

  def duration(%Value{value: duration, type: :string}) do
    Value.new(Duration.from_iso8601!(duration))
  end
end
