defmodule FeelEx.FunctionDefinitions do
  @moduledoc false

  def floor(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %FeelEx.Value{value: number, type: :number}
      is_float(number) -> %FeelEx.Value{value: trunc(Float.floor(number)), type: :number}
    end
  end

  def ceil(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %FeelEx.Value{value: number, type: :number}
      is_float(number) -> %FeelEx.Value{value: trunc(Float.ceil(number)), type: :number}
    end
  end
end
