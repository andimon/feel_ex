defmodule FeelEx.FunctionDefinitions.Numeric do
  @moduledoc false
  require Integer
  alias FeelEx.{Helper, Value}

  def round_half_up(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    n2 = trunc(n2)
    Value.new(Helper.round_half_up(n1, n2))
  end

  def round_half_down(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    n2 = trunc(n2)
    Value.new(Helper.round_half_down(n1, n2))
  end

  def round_up(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    n2 = trunc(n2)
    Value.new(Helper.round_up(n1, n2))
  end

  def round_down(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    n2 = trunc(n2)
    Value.new(Helper.round_down(n1, n2))
  end

  def floor(%Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %Value{value: number, type: :number}
      is_float(number) -> %Value{value: trunc(Float.floor(number)), type: :number}
    end
  end

  def floor(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    cond do
      is_integer(n1) ->
        %Value{value: n1, type: :number}

      is_float(n1) ->
        n = Float.floor(n1, trunc(n2))
        n = if n - trunc(n) == 0, do: trunc(n), else: n
        %Value{value: n, type: :number}
    end
  end

  def ceiling(%Value{value: number, type: :number}) do
    cond do
      is_integer(number) -> %Value{value: number, type: :number}
      is_float(number) -> %Value{value: trunc(Float.ceil(number)), type: :number}
    end
  end

  def ceiling(%Value{value: n1, type: :number}, %Value{value: n2, type: :number}) do
    cond do
      is_integer(n1) ->
        %Value{value: n1, type: :number}

      is_float(n1) ->
        n = Float.ceil(n1, trunc(n2))
        trunc_n = trunc(n)
        n = if n - trunc_n == 0, do: trunc_n, else: n
        %Value{value: n, type: :number}
    end
  end

  def decimal(%Value{value: number, type: :number}, %Value{
        value: precision,
        type: :number
      }) do
    cond do
      is_integer(number) ->
        %Value{value: number, type: :number}

      is_float(number) and is_integer(precision) ->
        %Value{value: Float.round(number, precision), type: :number}

      is_float(number) and is_float(precision) ->
        %Value{value: Float.round(number, trunc(precision)), type: :number}
    end
  end

  def abs(%Value{value: number, type: :number}) do
    number = if number < 0, do: number * -1, else: number
    %Value{value: number, type: :number}
  end

  def sqrt(%Value{value: number, type: :number}) do
    value = :math.sqrt(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %Value{value: value, type: :number}
  end

  def log(%Value{value: number, type: :number}) do
    value = :math.log(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %Value{value: value, type: :number}
  end

  def exp(%Value{value: number, type: :number}) do
    value = :math.exp(number)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %Value{value: value, type: :number}
  end

  def odd(%Value{value: number, type: :number}) do
    cond do
      is_float(number) -> Value.new(false)
      is_integer(number) -> Value.new(Integer.is_odd(number))
    end
  end

  def even(%Value{value: number, type: :number}) do
    cond do
      is_float(number) -> Value.new(false)
      is_integer(number) -> Value.new(Integer.is_even(number))
    end
  end

  def modulo(%Value{value: divedend, type: :number}, %Value{
        value: divisor,
        type: :number
      }) do
    value = :math.fmod(divedend, divisor)
    value = if value - trunc(value) == 0, do: trunc(value), else: value

    %Value{value: value, type: :number}
  end
end
