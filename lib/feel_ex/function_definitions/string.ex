defmodule FeelEx.FunctionDefinitions.String do
  @moduledoc false
  require Integer
  alias FeelEx.FunctionDefinitions.Temporal
  alias FeelEx.Value

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
