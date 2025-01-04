defmodule FeelEx.FunctionDefinitions.String do
  @moduledoc false
  require Integer
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

  def transformation(%Value{type: :string, value: string}) do
    cond do
      is_date?(string) -> Value.new(Date.from_iso8601!(string))
    end
  end

  defp is_date?(date) do
    case Date.from_iso8601(date) do
      {:ok, _} -> true
      _ -> false
    end
  end
end
