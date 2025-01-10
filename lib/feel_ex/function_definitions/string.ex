defmodule FeelEx.FunctionDefinitions.String do
  @moduledoc false
  require Integer
  alias FeelEx.FunctionDefinitions.Temporal
  alias FeelEx.Value

  def string(%Value{type: type, value: string})
      when type in [:number, :boolean, :string, nil],
      do: Value.new(to_string(string))

  def string(%Value{type: :time, value: %Time{} = time}) do
    Value.new(Time.to_iso8601(time))
  end

  def string(%Value{type: :time, value: {%Time{} = time, offset}}) do
    Value.new(Time.to_iso8601(time) <> offset)
  end

  def string(%Value{type: :time, value: {%Time{} = time, _offset, zone_id}}) do
    Value.new(Time.to_iso8601(time) <> "@#{zone_id}")
  end

  def string(%Value{type: :null, value: nil}) do
    Value.new("null")
  end

  def string(%Value{type: :date, value: date}) do
    Value.new(Date.to_iso8601(date))
  end

  def string(%Value{type: :context, value: map}) do
    Value.new(
      "{" <>
        Enum.map_join(map, ", ", fn {k, v} -> to_string(k) <> ":" <> string(v).value end) <> "}"
    )
  end

  def string(%Value{type: :date_time, value: %NaiveDateTime{} = date}) do
    Value.new(NaiveDateTime.to_iso8601(date))
  end

  def string(%Value{type: :date_time, value: {%NaiveDateTime{} = date, offset}}) do
    Value.new(NaiveDateTime.to_iso8601(date) <> offset)
  end

  def string(%Value{type: :date_time, value: {%NaiveDateTime{} = date, _offset, zone}}) do
    Value.new(NaiveDateTime.to_iso8601(date) <> "@" <> zone)
  end

  def string(%Value{type: %Time{} = time, value: :time}) do
    Value.new(Time.to_iso8601(time))
  end

  def string(%Value{type: type, value: %Duration{} = duration})
      when type in [:days_time_duration, :years_months_duration] do
    Value.new(Duration.to_iso8601(duration))
  end

  def string(list) when is_list(list) do
    Value.new("[" <> Enum.map_join(list, ", ", fn item -> string(item).value end) <> "]")
  end

  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: index}) do
    index = trunc(index)

    cond do
      index == 0 -> Value.new("")
      index > 0 -> Value.new(String.slice(string, (index - 1)..-1//1))
      index < 0 -> Value.new(String.slice(string, index..-1//1))
    end
  end

  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: index}, %Value{
        type: :number,
        value: length
      }) do
    index = trunc(index)
    length = trunc(length)

    cond do
      index == 0 -> Value.new("")
      index > 0 -> Value.new(String.slice(string, index - 1, length))
      index < 0 -> Value.new(String.slice(string, index, length))
    end
  end

  def length(%Value{type: :string, value: string}) do
    Value.new(Elixir.String.length(string))
  end

  def transformation(%Value{type: :string} = value) do
    functions = [
      &Temporal.date/1,
      &Temporal.time/1,
      &Temporal.date_and_time/1,
      &Temporal.duration/1
    ]

    result =
      Enum.find_value(functions, fn func ->
        try do
          func.(value)
        rescue
          _e -> nil
        end
      end)

    if is_nil(result), do: Value.new(nil), else: result
  end
end
