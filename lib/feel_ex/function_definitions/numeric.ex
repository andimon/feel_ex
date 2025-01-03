defmodule FeelEx.FunctionDefinitions.Numeric do
  @moduledoc false
  require Integer

  def floor(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %FeelEx.Value{value: number, type: :number}
      is_float(number) -> %FeelEx.Value{value: trunc(Float.floor(number)), type: :number}
    end
  end

  def ceiling(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %FeelEx.Value{value: number, type: :number}
      is_float(number) -> %FeelEx.Value{value: trunc(Float.ceil(number)), type: :number}
    end
  end

  def decimal(%FeelEx.Value{value: number, type: :number}, %FeelEx.Value{
        value: precision,
        type: :number
      }) do
    cond do
      is_integer(number) ->
        %FeelEx.Value{value: number, type: :number}

      is_float(number) and is_integer(precision) ->
        %FeelEx.Value{value: Float.round(number, precision), type: :number}

      is_float(number) and is_float(precision) ->
        %FeelEx.Value{value: Float.round(number, trunc(precision)), type: :number}
    end
  end

  def abs(%FeelEx.Value{value: number, type: :number}) do
    number = if number < 0, do: number * -1, else: number
    %FeelEx.Value{value: number, type: :number}
  end

  def sqrt(%FeelEx.Value{value: number, type: :number}) do
    value = :math.sqrt(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %FeelEx.Value{value: value, type: :number}
  end

  def log(%FeelEx.Value{value: number, type: :number}) do
    value = :math.log(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %FeelEx.Value{value: value, type: :number}
  end

  def exp(%FeelEx.Value{value: number, type: :number}) do
    value = :math.exp(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %FeelEx.Value{value: value, type: :number}
  end

  def odd(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_float(number) -> FeelEx.Value.new(false)
      is_integer(number) -> FeelEx.Value.new(Integer.is_odd(number))
    end
  end

  def even(%FeelEx.Value{value: number, type: :number}) do
    cond do
      is_float(number) -> FeelEx.Value.new(false)
      is_integer(number) -> FeelEx.Value.new(Integer.is_even(number))
    end
  end

  def modulo(%FeelEx.Value{value: divedend, type: :number}, %FeelEx.Value{
        value: divisor,
        type: :number
      }) do
    value = :math.fmod(divedend, divisor)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %FeelEx.Value{value: value, type: :number}
  end
end
