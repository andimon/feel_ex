defmodule FeelEx.Functions do
  @moduledoc """
  This module defines a set of functions that may be used on FeelEx values.

  These functions can be invoked in expressions.
  """
  import Kernel, except: [floor: 1]
  require Integer
  require Logger
  alias FeelEx.Value

  #############################
  #  Conversion Functions     #
  #############################
  @doc """
  Returns any FeelEx value as a FeelEx value of type string.

  ## Examples

      iex> value = FeelEx.Value.new(1.1)
      %FeelEx.Value{value: 1.1, type: :number}
      iex> FeelEx.Functions.string(value)
      %FeelEx.Value{value: "1.1", type: :string}
      iex> value = FeelEx.Value.new([1,2])
      [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 2, type: :number}]
      iex> FeelEx.Functions.string(value)
      %FeelEx.Value{value: "[1, 2]", type: :string}
  """
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
    Value.new(nil)
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

  @doc """
  Parses a given FeelEx value of type string to a FeelEx value of type integer.
  Returns FeelEx null value if the string is not a number.

  ## Examples

      iex> value = FeelEx.Value.new("21")
      %FeelEx.Value{value: "21", type: :string}
      iex> FeelEx.Functions.number(value)
      %FeelEx.Value{value: 21, type: :number}
      iex> value = FeelEx.Value.new("21.69")
      %FeelEx.Value{value: "21.69", type: :string}
      iex> FeelEx.Functions.number(value)
      %FeelEx.Value{value: 21.69, type: :number}
      iex> value = FeelEx.Value.new("21.69wazzup")
      %FeelEx.Value{value: "21.69wazzup", type: :string}
      iex> FeelEx.Functions.number(value)
      %FeelEx.Value{value: nil, type: :null}
  """
  def number(%Value{value: string, type: :string}) do
    case parse_int(string) do
      {int, ""} ->
        Value.new(int)

      _ ->
        try_parse_float(string)
    end
  end

  defp parse_int(string), do: Integer.parse(string)

  defp try_parse_float(string) do
    case Float.parse(string) do
      {float, ""} ->
        Value.new(float)

      _ ->
        Value.new(nil)
    end
  end

  @doc """
  Constructs a FeelEx context based of a list of context where each context must contain keys:
  `key` and `value`. Returns null if the list contains a value which is not a context, or if a
  context, it does not contain the required keys.

  ## Examples

      iex(79)> value = FeelEx.Value.new([%{key: "a", value: 1},%{key: "b", value: "bee"}])
      [
      %FeelEx.Value{
        value: %{
          value: %FeelEx.Value{value: 1, type: :number},
          key: %FeelEx.Value{value: "a", type: :string}
        },
        type: :context
      },
      %FeelEx.Value{
        value: %{
          value: %FeelEx.Value{value: "bee", type: :string},
          key: %FeelEx.Value{value: "b", type: :string}
        },
        type: :context
      }
      ]
      iex(80)> FeelEx.Functions.context(value)
      %FeelEx.Value{
      value: %{
        a: %FeelEx.Value{value: 1, type: :number},
        b: %FeelEx.Value{value: "bee", type: :string}
      },
      type: :context
      }
  """
  def context([]), do: Value.new(%{})

  def context(list) when is_list(list) do
    Enum.reduce_while(list, %{}, fn element, context ->
      case {element, context} do
        {%Value{
           type: :context,
           value: %{key: %FeelEx.Value{value: key, type: :string}, value: value}
         }, _}
        when is_binary(key) ->
          {:cont, Map.put_new(context, String.to_atom(key), value)}

        _ ->
          {:halt, nil}
      end
    end)
    |> Value.new()
  end

  def context(%Value{}), do: Value.new(nil)

  #############################
  #  Numeric Functions        #
  #############################
  @doc """
  Given a number and a scale it returns the number at the given scale.

  ## Examples

  iex> number = FeelEx.Value.new(1/3)
  %FeelEx.Value{value: 0.3333333333333333, type: :number}
  iex> scale = FeelEx.Value.new(2)
  %FeelEx.Value{value: 2, type: :number}
  iex> FeelEx.Functions.decimal(number,scale)
  %FeelEx.Value{value: 0.33, type: :number}
  """
  def decimal(%Value{value: number, type: :number}, %Value{
        value: precision,
        type: :number
      }) do
    case {number, precision} do
      {number, _} when is_integer(number) ->
        Value.new(number)

      {number, precision} when is_float(number) and is_integer(precision) ->
        number
        |> Float.round(precision)
        |> Value.new()

      {number, precision} when is_float(number) and is_float(precision) ->
        number
        |> Float.round(trunc(precision))
        |> Value.new()
    end
  end

  @doc """
  Performs floor operation on the given number.

  ## Examples

      iex> number = FeelEx.Value.new(1/3)
      %FeelEx.Value{value: 0.3333333333333333, type: :number}
      iex> FeelEx.Functions.floor(number)
      %FeelEx.Value{value: 0, type: :number}
  """
  def floor(%Value{value: number, type: :number} = value) do
    case number do
      number when is_integer(number) ->
        value

      number when is_float(number) ->
        number
        |> Float.floor()
        |> trunc()
        |> Value.new()
    end
  end

  @doc """
  Performs floor operation on the given number with a given scale.

  ## Examples

      iex> number = FeelEx.Value.new(1/3)
      %FeelEx.Value{value: 0.3333333333333333, type: :number}
      iex> scale = FeelEx.Value.new(3)
      %FeelEx.Value{value: 3, type: :number}
      iex> FeelEx.Functions.floor(number,scale)
      %FeelEx.Value{value: 0.333, type: :number}
  """
  def floor(%Value{value: n1, type: :number} = value, %Value{value: n2, type: :number}) do
    case {n1, n2} do
      {n1, _} when is_integer(n1) ->
        value

      {n1, n2} when is_float(n1) ->
        n1
        |> Float.floor(trunc(n2))
        |> integer_checker()
        |> Value.new()
    end
  end

  @doc """
  Performs ceiling operation on the given number.

  ## Examples

      iex> number = FeelEx.Value.new(1/3)
      %FeelEx.Value{value: 0.3333333333333333, type: :number}
      iex> FeelEx.Functions.ceiling(number)
      %FeelEx.Value{value: 1, type: :number}
  """
  def ceiling(%Value{value: number, type: :number}) do
    case number do
      number when is_integer(number) -> %Value{value: number, type: :number}
      number when is_float(number) -> %Value{value: trunc(Float.ceil(number)), type: :number}
    end
  end

  @doc """
  Performs ceiling operation on the given number, with a given scale.

  ## Examples

      iex> number = FeelEx.Value.new(1/3)
      %FeelEx.Value{value: 0.3333333333333333, type: :number}
      iex> scale = FeelEx.Value.new(3)
      %FeelEx.Value{value: 3, type: :number}
      iex> FeelEx.Functions.ceiling(number,scale)
      %FeelEx.Value{value: 0.334, type: :number}
  """
  def ceiling(%Value{value: n1, type: :number} = value, %Value{value: n2, type: :number}) do
    case {n1, n2} do
      {n1, _} when is_integer(n1) ->
        value

      {n1, n2} when is_float(n1) ->
        n1
        |> Float.ceil(trunc(n2))
        |> integer_checker()
        |> Value.new()
    end
  end

  @doc """
  Rounds up a given number with a given scale.

  ## Examples

      iex> number = FeelEx.Value.new(1/3)
      %FeelEx.Value{value: 0.3333333333333333, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_up(number,scale)
      %FeelEx.Value{value: 1, type: :number}
      iex> number = FeelEx.Value.new(1.121)
      %FeelEx.Value{value: 1.121, type: :number}
      iex> scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_up(number,scale)
      %FeelEx.Value{value: 1.13, type: :number}
      iex number = FeelEx.Value.new(-1.126)
      %FeelEx.Value{value: -1.126, type: :number}
      iex scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_up(number,scale)
      %FeelEx.Value{value: -1.13, type: :number}
  """
  def round_up(%Value{value: number1, type: :number} = value, _) when is_integer(number1) do
    value
  end

  def round_up(%Value{value: number1, type: :number} = value, %Value{
        value: number2,
        type: :number
      })
      when number1 >= 0 do
    cond do
      decimal_part_length(number1) > trunc(number2) ->
        number1
        |> Float.ceil(trunc(number2))
        |> integer_checker()
        |> Value.new()

      true ->
        value
    end
  end

  def round_up(
        %Value{value: number1, type: :number},
        %Value{value: _, type: :number} = value2
      )
      when number1 < 0 do
    round_up(Value.new(-1 * number1), value2)
    |> Map.update!(:value, fn value -> -1 * value end)
  end

  @doc """
  Rounds down a given number with a given scale.

  ## Examples

      iex> number = FeelEx.Value.new(5.5)
      %FeelEx.Value{value: 5.5, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_down(number,scale)
      %FeelEx.Value{value: 5, type: :number}
  """
  def round_down(%Value{value: number1, type: :number} = value, _) when is_integer(number1) do
    value
  end

  def round_down(%Value{value: number1, type: :number} = value, %Value{
        value: number2,
        type: :number
      })
      when number1 >= 0 do
    cond do
      decimal_part_length(number1) > trunc(number2) ->
        number1
        |> Float.floor(trunc(number2))
        |> integer_checker()
        |> Value.new()

      true ->
        value
    end
  end

  def round_down(
        %Value{value: number1, type: :number},
        %Value{value: _, type: :number} = value2
      )
      when number1 < 0 do
    round_down(Value.new(-1 * number1), value2)
    |> Map.update!(:value, fn value -> -1 * value end)
  end

  @doc """
  Rounds a number using round-half-up mode.

  ## Examples

      iex> number = FeelEx.Value.new(5.5)
      %FeelEx.Value{value: 5.5, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_half_up(number,scale)
      %FeelEx.Value{value: 6, type: :number}
      iex> number = FeelEx.Value.new(-5.5)
      %FeelEx.Value{value: -5.5, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_half_up(number,scale)
      %FeelEx.Value{value: -6, type: :number}
      iex> number = FeelEx.Value.new(1.121)
      %FeelEx.Value{value: 1.121, type: :number}
      iex> scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_half_up(number,scale)
      %FeelEx.Value{value: 1.12, type: :number}
      iex> number = FeelEx.Value.new(-1.126)
      %FeelEx.Value{value: -1.126, type: :number}
      iex> scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_half_up(number,scale)
      %FeelEx.Value{value: -1.13, type: :number}

  """
  def round_half_up(%Value{value: number, type: :number} = value, _) when is_integer(number) do
    value
  end

  def round_half_up(
        %Value{value: number, type: :number} = value,
        %Value{
          value: decimal,
          type: :number
        } = decimal_value
      )
      when number >= 0 do
    decimal_part = decimal_part(number)
    n = String.at(decimal_part, decimal)

    cond do
      is_nil(n) ->
        value

      String.to_integer(n) in 1..4 ->
        round_down(value, decimal_value)

      String.to_integer(n) in 5..9 ->
        round_up(value, decimal_value)
    end
  end

  def round_half_up(
        %Value{value: number, type: :number},
        %Value{
          value: _decimal,
          type: :number
        } = decimal_value
      )
      when number < 0 do
    round_half_up(Value.new(-1 * number), decimal_value)
    |> Map.update!(:value, fn value -> -1 * value end)
  end

  @doc """
  Rounds a number using round-half-up mode.

  ## Examples

      iex> number = FeelEx.Value.new(5.5)
      %FeelEx.Value{value: 5.5, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_half_down(number,scale)
      %FeelEx.Value{value: 5, type: :number}
      iex> number = FeelEx.Value.new(-5.5)
      %FeelEx.Value{value: -5.5, type: :number}
      iex> scale = FeelEx.Value.new(0)
      %FeelEx.Value{value: 0, type: :number}
      iex> FeelEx.Functions.round_half_down(number,scale)
      %FeelEx.Value{value: -5, type: :number}
      iex> number = FeelEx.Value.new(1.121)
      %FeelEx.Value{value: 1.121, type: :number}
      iex> scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_half_down(number,scale)
      %FeelEx.Value{value: 1.12, type: :number}
      iex> number = FeelEx.Value.new(-1.126)
      %FeelEx.Value{value: -1.126, type: :number}
      iex> scale = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.round_half_down(number,scale)
      %FeelEx.Value{value: -1.13, type: :number}
  """
  def round_half_down(%Value{value: number, type: :number} = value, _) when is_integer(number) do
    value
  end

  def round_half_down(
        %Value{value: number, type: :number} = value,
        %Value{
          value: decimal,
          type: :number
        } = decimal_value
      )
      when number >= 0 do
    decimal_part = decimal_part(number)
    n = String.at(decimal_part, decimal)

    cond do
      is_nil(n) ->
        value

      String.to_integer(n) in 1..5 ->
        round_down(value, decimal_value)

      String.to_integer(n) in 5..9 ->
        round_up(value, decimal_value)
    end
  end

  def round_half_down(
        %Value{value: number, type: :number},
        %Value{
          value: _decimal,
          type: :number
        } = decimal_value
      )
      when number < 0 do
    round_half_down(Value.new(-1 * number), decimal_value)
    |> Map.update!(:value, fn value -> -1 * value end)
  end

  @doc """
  Returns the absolute value of the given number.

  ## Examples

      iex> number = FeelEx.Value.new(-1.21)
      %FeelEx.Value{value: -1.21, type: :number}
      iex> FeelEx.Functions.abs(number)
      %FeelEx.Value{value: 1.21, type: :number}
      iex> number = FeelEx.Value.new(10)
      %FeelEx.Value{value: 10, type: :number}
      iex> FeelEx.Functions.abs(number)
      %FeelEx.Value{value: 10, type: :number}

  """
  def abs(%Value{value: number, type: :number}) do
    number = if number < 0, do: number * -1, else: number
    %Value{value: number, type: :number}
  end

  @doc """
  Returns the remainder returned by division of the divedend by the divisor.

  ## Examples

      iex> number = FeelEx.Value.new(12)
      %FeelEx.Value{value: 12, type: :number}
      iex> scale = FeelEx.Value.new(5)
      %FeelEx.Value{value: 5, type: :number}
      iex> FeelEx.Functions.modulo(number,scale)
      %FeelEx.Value{value: 2, type: :number}
  """
  def modulo(%Value{value: divedend, type: :number}, %Value{value: divisor, type: :number}) do
    value = integer_checker(:math.fmod(divedend, divisor))

    %Value{value: value, type: :number}
  end

  @doc """
  Returns the square root of the given value.

  ## Examples

      iex> number = FeelEx.Value.new(16)
      %FeelEx.Value{value: 16, type: :number}
      iex> FeelEx.Functions.sqrt(number)
      %FeelEx.Value{value: 4, type: :number}
  """
  def sqrt(%Value{value: number, type: :number}) do
    value = integer_checker(:math.sqrt(number))

    %Value{value: value, type: :number}
  end

  @doc """
  Returns natural logarithm (base e) of the given number.

  ## Examples

      iex> number = FeelEx.Value.new(10)
      %FeelEx.Value{value: 10, type: :number}
      iex> FeelEx.Functions.log(number)
      %FeelEx.Value{value: 2.302585092994046, type: :number}
  """
  def log(%Value{value: number, type: :number}) do
    value = integer_checker(:math.log(number))

    %Value{value: value, type: :number}
  end

  @doc """
  Returns e raised to the power of the given number.

  ## Examples
      iex> number = FeelEx.Value.new(5)
      %FeelEx.Value{value: 5, type: :number}
      iex> FeelEx.Functions.exp(number)
      %FeelEx.Value{value: 148.4131591025766, type: :number}
  """
  def exp(%Value{value: number, type: :number}) do
    value = integer_checker(:math.exp(number))

    %Value{value: value, type: :number}
  end

  @doc """
  Returns true if the given number is odd, otherwise returns false.

  ## Examples

      iex> value = FeelEx.Value.new(5)
      %FeelEx.Value{value: 5, type: :number}
      iex> FeelEx.Functions.odd(value)
      %FeelEx.Value{value: true, type: :boolean}
      iex> value = FeelEx.Value.new(6)
      %FeelEx.Value{value: 6, type: :number}
      iex> FeelEx.Functions.odd(value)
      %FeelEx.Value{value: false, type: :boolean}
  """
  def odd(%Value{value: number, type: :number}) do
    case number do
      number when is_float(number) -> Value.new(false)
      number when is_integer(number) -> Value.new(Integer.is_odd(number))
    end
  end

  @doc """
  Returns true if the given number is even, otherwise returns false.

  ## Examples

      iex> value = FeelEx.Value.new(5)
      %FeelEx.Value{value: 5, type: :number}
      iex> FeelEx.Functions.even(value)
      %FeelEx.Value{value: false, type: :boolean}
      iex> value = FeelEx.Value.new(6)
      %FeelEx.Value{value: 6, type: :number}
      iex> FeelEx.Functions.even(value)
      %FeelEx.Value{value: true, type: :boolean}
  """
  def even(%Value{value: number, type: :number}) do
    case number do
      number when is_float(number) -> Value.new(false)
      number when is_integer(number) -> Value.new(Integer.is_even(number))
    end
  end

  @doc """
  Returns a number between 0 and 1.

  ## Examples

      iex> FeelEx.Functions.random()
      %FeelEx.Value{value: 0.5189989081813825, type: :number}
  """
  def random() do
    Value.new(:rand.uniform())
  end

  # convert float to integer if decimal part is 0
  defp integer_checker(float) do
    if trunc(float) == float do
      trunc(float)
    else
      float
    end
  end

  defp decimal_part_length(float) when is_float(float) do
    string = float |> Float.to_string()
    {start, _} = :binary.match(string, ".")
    byte_size(string) - start - 1
  end

  defp decimal_part(float) when is_float(float) do
    float |> Float.to_string() |> String.split(".") |> Enum.at(1)
  end

  @doc """
  Returns a substring of string using 1-based indexing.

  ## Examples

  ```
      iex> string = FeelEx.Value.new("Aw dinja")
      %FeelEx.Value{value: "Aw dinja", type: :string}
      iex> index = FeelEx.Value.new(4)
      %FeelEx.Value{value: 4, type: :number}
      iex> FeelEx.Functions.substring(string,index)
      %FeelEx.Value{value: "dinja", type: :string}
  ```
  """
  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: index}) do
    case {trunc(index), string} do
      {0, _} -> Value.new("")
      {index, string} when index > 0 -> Value.new(String.slice(string, (index - 1)..-1//1))
      {index, string} when index < 0 -> Value.new(String.slice(string, index..-1//1))
    end
  end

  @doc """
  Returns a substring of specified length of string using 1-based indexing.

  ## Examples

        iex> string = FeelEx.Value.new("Aw dinja")
        %FeelEx.Value{value: "Aw dinja", type: :string}
        iex> index = FeelEx.Value.new(4)
        %FeelEx.Value{value: 4, type: :number}
        iex> length = FeelEx.Value.new(2)
        %FeelEx.Value{value: 2, type: :number}
        iex> FeelEx.Functions.substring(string,index,length)
        %FeelEx.Value{value: "di", type: :string}
  ```
      iex> string = FeelEx.Value.new("Aw dinja")
      %FeelEx.Value{value: "Aw dinja", type: :string}
      iex> index = FeelEx.Value.new(4)
      %FeelEx.Value{value: 4, type: :number}
      iex> FeelEx.Functions.substring(string,index)
      %FeelEx.Value{value: "dinja", type: :string}
  ```
  """
  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: index}, %Value{
        type: :number,
        value: length
      }) do
    case {string, trunc(index), trunc(length)} do
      {_string, index, _length} when index == 0 ->
        Value.new("")

      {string, index, length} when index > 0 ->
        Value.new(String.slice(string, index - 1, length))

      {string, index, length} when index < 0 ->
        Value.new(String.slice(string, index, length))
    end
  end

  @doc """
  Returns length of a given string.

  ## Examples

      iex> string = FeelEx.Value.new("Aw dinja")
      %FeelEx.Value{value: "Aw dinja", type: :string}
      iex> FeelEx.Functions.string_length(string)
      %FeelEx.Value{value: 8, type: :number}
  """
  def string_length(%Value{type: :string, value: string}) do
    string
    |> String.length()
    |> Value.new()
  end

  @doc """
  Transforms every character in a given string into upper case.

  ## Examples

    iex> string = FeelEx.Value.new("Aw dinja !!")
    %FeelEx.Value{value: "Aw dinja !!", type: :string}
    iex> FeelEx.Functions.upper_case(string)
    %FeelEx.Value{value: "AW DINJA !!", type: :string}
  """
  def upper_case(%Value{type: :string, value: string}) do
    string
    |> String.upcase()
    |> Value.new()
  end

  @doc """
  Transforms every character in a given string into upper case.

  ## Examples

    iex> string = FeelEx.Value.new("Aw Dinja !!")
    %FeelEx.Value{value: "Aw Dinja !!", type: :string}
    iex> FeelEx.Functions.upper_case(string)
    %FeelEx.Value{value: "aw dinja !!", type: :string}
  """
  def lower_case(%Value{type: :string, value: string}) do
    string
    |> String.downcase()
    |> Value.new()
  end

  @doc """
  Given a string and a match it returns all the characters before match.

  ## Examples

      iex> string = FeelEx.Value.new("Aw Dinja !!")
      %FeelEx.Value{value: "Aw Dinja !!", type: :string}
      iex> match = FeelEx.Value.new(" Di")
      %FeelEx.Value{value: " Di", type: :string}
      iex> FeelEx.Functions.substring_before(string,match)
      %FeelEx.Value{value: "Aw", type: :string}

  """
  def substring_before(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    case String.split(string1, string2) do
      [^string1] ->
        ""

      list when is_list(list) ->
        List.first(list)
    end
    |> Value.new()
  end

  @doc """
  Given a string and a match it returns all the characters before match.

  ## Examples

      iex> string = FeelEx.Value.new("Aw Dinja !!")
      %FeelEx.Value{value: "Aw Dinja !!", type: :string}
      iex> match = FeelEx.Value.new(" Di")
      %FeelEx.Value{value: " Di", type: :string}
      iex> FeelEx.Functions.substring_after(string,match)
      %FeelEx.Value{value: "nja !!", type: :string}

  """
  def substring_after(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    case String.split(string1, string2) do
      [^string1] ->
        ""

      list when is_list(list) ->
        List.last(list)
    end
    |> Value.new()
  end

  @doc """
  Given a string and a match check if string contains a given match, otherwise it returns false.

  iex> string = FeelEx.Value.new("Aw Dinja !!")
  %FeelEx.Value{value: "Aw Dinja !!", type: :string}
  iex> match = FeelEx.Value.new("ew")
  %FeelEx.Value{value: "ew", type: :string}
  iex> FeelEx.Functions.contains(string,match)
  %FeelEx.Value{value: false, type: :boolean}

  """
  def contains(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    String.contains?(string1, string2)
    |> Value.new()
  end

  @doc """
  Given a string and a match. It returns true if the given string starts with match, otherwise it returns false.


  ## Examples

      iex> string = FeelEx.Value.new("Aw Dinja !!")
      %FeelEx.Value{value: "Aw Dinja !!", type: :string}
      iex> match = FeelEx.Value.new("Aw D")
      %FeelEx.Value{value: "Aw D", type: :string}
      iex> FeelEx.Functions.starts_with(string,match)
      %FeelEx.Value{value: true, type: :boolean}
  """
  def starts_with(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    String.starts_with?(string1, string2)
    |> Value.new()
  end

  @doc """
  Given a string and a match. It returns true if the given string ends with match, otherwise it returns false.


  ## Examples

      iex> string = FeelEx.Value.new("Aw Dinja !!")
      %FeelEx.Value{value: "Aw Dinja !!", type: :string}
      iex> match = FeelEx.Value.new("Aw D")
      %FeelEx.Value{value: "ja" , type: :string}
      iex> FeelEx.Functions.starts_with(string,match)
      %FeelEx.Value{value: true, type: :boolean}
  """
  def ends_with(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    String.ends_with?(string1, string2)
    |> Value.new()
  end

  @doc """
  Given a string and delimeter it splits string into a list of string,
  breaking at each occurence of delimeter

  ## Examples
  iex> FeelEx.evaluate("split(\"Hello World\",\"\s\")")
      [
        %FeelEx.Value{value: "Hello", type: :string},
        %FeelEx.Value{value: "World", type: :string}
      ]

  """
  def split(%Value{type: :string, value: string1}, %Value{
        type: :string,
        value: string2
      }) do
    String.split(string1, string2)
    |> Enum.map(fn string -> Value.new(string) end)
  end

  @doc """
  Remove leading and trailing spaces from string

  ## Examples

      iex> string = FeelEx.Value.new("         Aw Dinja !!       ")
      %FeelEx.Value{value: "         Aw Dinja !!       ", type: :string}
      iex> FeelEx.Functions.trim(string)
      %FeelEx.Value{value: "Aw Dinja !!", type: :string}

  """
  def trim(%Value{type: :string, value: string}) do
    String.trim(string)
    |> Value.new()
  end

  @doc """
  Returns FeelEx date value from a given string. If date cannot be parsed FeelEx's null value
  is returned. For example, "2024-06-31" is invalid because June only contains 30 days.

  This function can be used exract a date value from date-time value.

  ## Examples

      iex> value = FeelEx.Value.new("2021-01-03")
      %FeelEx.Value{value: "2021-01-03", type: :string}
      iex> FeelEx.Functions.date(value)
      %FeelEx.Value{value: ~D[2021-01-03], type: :date}
      iex> value = FeelEx.Value.new(NaiveDateTime.utc_now,"+01:00")
      %FeelEx.Value{
      value: {~N[2025-01-19 20:40:52.380623], "+01:00"},
      type: :date_time
      }
      iex> FeelEx.Functions.date(value)
      %FeelEx.Value{value: ~D[2025-01-19], type: :date}
  """
  def date(%Value{value: value, type: :string}) do
    case Date.from_iso8601(value) do
      {:ok, date} -> Value.new(date)
      {:error, _} -> Value.new(nil)
    end
  end

  def date(%Value{type: :date_time, value: %NaiveDateTime{} = date_time}) do
    NaiveDateTime.to_date(date_time)
    |> Value.new()
  end

  def date(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _}}) do
    NaiveDateTime.to_date(date_time)
    |> Value.new()
  end

  def date(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _, _}}) do
    NaiveDateTime.to_date(date_time)
    |> Value.new()
  end

  def date(%Value{}) do
    Value.new(nil)
  end

  @doc """
  Creates a FeelEx's date value using year, month, day components represented by FeelEx's numbers.
  If the date components are invalid a FeelEx's null value is returned.

  ## Examples

        iex> year = FeelEx.Value.new(2021)
        %FeelEx.Value{value: 2021, type: :number}
        iex> month = FeelEx.Value.new(6)
        %FeelEx.Value{value: 6, type: :number}
        iex> day = FeelEx.Value.new(1)
        %FeelEx.Value{value: 1, type: :number}
        iex)> FeelEx.Functions.date(year,month,day)
        %FeelEx.Value{value: ~D[2021-06-01], type: :date}
  """
  def date(%Value{value: year, type: :number}, %Value{value: month, type: :number}, %Value{
        value: day,
        type: :number
      }) do
    case Date.new(trunc(year), trunc(month), trunc(day)) do
      {:ok, date} -> Value.new(date)
      {:error, _} -> Value.new(nil)
    end
  end

  @doc """
  Returns FeelEx time value from a given string. If time cannot be parsed FeelEx's null value
  is returned.

  This function can be used exract a time value from date-time value.

  ## Examples

      iex> value = FeelEx.Value.new("08:02:01")
      %FeelEx.Value{value: "08:02:01", type: :string}
      iex> FeelEx.Functions.time(value)
      %FeelEx.Value{value: ~T[08:02:01], type: :time}
      iex> value = FeelEx.Value.new("08:02:01+02:00")
      %FeelEx.Value{value: "08:02:01+02:00", type: :string}
      iex> FeelEx.Functions.time(value)
      %FeelEx.Value{value: {~T[08:02:01], "+02:00"}, type: :time}
      iex> value = FeelEx.Value.new("08:02:01@Europe/Malta")
      %FeelEx.Value{value: "08:02:01@Europe/Malta", type: :string}
      iex> FeelEx.Functions.time(value)
      %FeelEx.Value{value: {~T[08:02:01], "+01:00", "Europe/Malta"}, type: :time}
      iex> value = FeelEx.Value.new(NaiveDateTime.utc_now,"+01:00")
      %FeelEx.Value{
      value: {~N[2025-01-19 20:50:37.065020], "+01:00"},
      type: :date_time
      }
      iex> value = FeelEx.Value.new(NaiveDateTime.utc_now,"+01:00")
      %FeelEx.Value{
      value: {~N[2025-01-19 20:50:48.964545], "+01:00"},
      type: :date_time
      }
      iex> FeelEx.Functions.date(value)
      %FeelEx.Value{value: ~D[2025-01-19], type: :date}
      iex> FeelEx.Functions.time(value)
      %FeelEx.Value{value: ~T[20:50:48.964545], type: :time}
  """
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

  def time(%Value{type: :date_time, value: %NaiveDateTime{} = date_time}) do
    NaiveDateTime.to_time(date_time)
    |> Value.new()
  end

  def time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _}}) do
    NaiveDateTime.to_time(date_time)
    |> Value.new()
  end

  def time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _, _}}) do
    NaiveDateTime.to_time(date_time)
    |> Value.new()
  end

  def time(%Value{}) do
    Value.new(nil)
  end

  @doc """
  Create a FeelEx's time value using hour, minute and second component.

  ## Examples

      iex> hour = FeelEx.Value.new(8)
      %FeelEx.Value{value: 8, type: :number}
      iex> minute = FeelEx.Value.new(16)
      %FeelEx.Value{value: 16, type: :number}
      iex> second = FeelEx.Value.new(3)
      %FeelEx.Value{value: 3, type: :number}
      iex> FeelEx.Functions.time(hour,minute,second)
      %FeelEx.Value{value: ~T[08:16:03], type: :time}
  """
  def time(%Value{type: number, value: hour}, %Value{type: number, value: minute}, %Value{
        type: number,
        value: second
      }) do
    case Time.new(trunc(hour), trunc(minute), trunc(second)) do
      {:ok, time} -> Value.new(time)
      {:error, _} -> Value.new(nil)
    end
  end

  @doc """
  Create time with hour, minute offset, time and duration FeelEx's components.

  ## Examples

      iex>  hour = FeelEx.Value.new(8)
      %FeelEx.Value{value: 8, type: :number}
      iex> minute = FeelEx.Value.new(16)
      %FeelEx.Value{value: 16, type: :number}
      iex> second = FeelEx.Value.new(3)
      %FeelEx.Value{value: 3, type: :number}
      iex> duration = FeelEx.Value.new(Duration.new!(hour: 1, minute: 32))
      %FeelEx.Value{value: %Duration{hour: 1, minute: 32}, type: :days_time_duration}
      iex> FeelEx.Functions.time(hour,minute,second,duration)
      %FeelEx.Value{value: {~T[08:16:03], "+01:32"}, type: :time}
  """

  def time(
        %Value{type: number, value: hour},
        %Value{type: number, value: minute},
        %Value{
          type: number,
          value: second
        },
        %Value{type: :days_time_duration, value: duration}
      ) do
    case Time.new(trunc(hour), trunc(minute), trunc(second)) do
      {:ok, time} -> Value.new(time, days_time_duration_to_offset(duration))
      {:error, _} -> Value.new(nil)
    end
  end

  defp days_time_duration_to_offset(%Duration{
         day: day,
         hour: hour,
         minute: minute,
         year: 0,
         month: 0
       }) do
    minutes = day * 1440 + hour * 60 + minute

    cond do
      is_integer(minutes) ->
        hour =
          div(minutes, 60)
          |> Integer.to_string()

        minute =
          rem(minutes, 60)
          |> Integer.to_string()

        calculate_offset_string(hour, minute)

      true ->
        nil
    end
  end

  defp calculate_offset_string(hour, minute) do
    cond do
      String.starts_with?(hour, "-") and String.starts_with?(minute, "-") ->
        hour =
          String.slice(hour, 1..-1//1)
          |> String.pad_leading(2, "0")

        minute =
          String.slice(hour, 1..-1//1)
          |> String.pad_leading(2, "0")

        "-" <> hour <> ":" <> minute

      String.starts_with?(hour, "-") and minute == "0" ->
        hour =
          String.slice(hour, 1..-1//1)
          |> String.pad_leading(2, "0")

        "-" <> hour <> ":" <> "00"

      hour == 0 and String.starts_with?(minute, "-") ->
        minute =
          String.slice(minute, 1..-1//1)
          |> String.pad_leading(2, "0")

        "-" <> "00" <> ":" <> minute

      true ->
        hour =
          String.pad_leading(hour, 2, "0")

        minute =
          String.pad_leading(minute, 2, "0")

        "+" <> hour <> ":" <> minute
    end
  end

  @doc """
  Create date and time value from string.

  ## Examples

      iex> value = FeelEx.Value.new("2018-04-29T09:30:00")
      %FeelEx.Value{value: "2018-04-29T09:30:00", type: :string}
      iex> FeelEx.Functions.date_and_time(value)
      %FeelEx.Value{value: ~N[2018-04-29 09:30:00], type: :date_time}
      iex> value = FeelEx.Value.new("2018-04-29T09:30:00+02:00")
      %FeelEx.Value{value: "2018-04-29T09:30:00+02:00", type: :string}
      iex> FeelEx.Functions.date_and_time(value)
      %FeelEx.Value{value: {~N[2018-04-29 09:30:00], "+02:00"}, type: :date_time}
      iex> value = FeelEx.Value.new("2018-04-29T09:30:00@Europe/Malta")
      %FeelEx.Value{value: "2018-04-29T09:30:00@Europe/Malta", type: :string}
      iex> FeelEx.Functions.date_and_time(value)
      %FeelEx.Value{
      value: {~N[2018-04-29 09:30:00], "+01:00", "Europe/Malta"},
      type: :date_time
      }
  """
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

  @doc """
  Create date time value from date and time components.

  ## Examples

      iex> date = FeelEx.Value.new(Date.utc_today)
      %FeelEx.Value{value: ~D[2025-01-19], type: :date}
      iex> date = FeelEx.Value.new(Time.utc_now)
      %FeelEx.Value{value: ~T[21:47:33.597814], type: :time}
      iex> date = FeelEx.Value.new(Date.utc_today)
      %FeelEx.Value{value: ~D[2025-01-19], type: :date}
      iex> time = FeelEx.Value.new(Time.utc_now)
      %FeelEx.Value{value: ~T[21:47:41.988770], type: :time}
      iex> FeelEx.Functions.date_and_time(date,time)
      %FeelEx.Value{value: ~N[2025-01-19 21:47:41.988770], type: :date_time}
      iex> date_time = FeelEx.Value.new(NaiveDateTime.utc_now)
      %FeelEx.Value{value: ~N[2025-01-19 21:58:55.449808], type: :date_time}
      iex> time = FeelEx.Value.new(Time.new!(8,2,3))
      %FeelEx.Value{value: ~T[08:02:03], type: :time}
      iex> FeelEx.Functions.date_and_time(date_time,time)
      %FeelEx.Value{value: ~N[2025-01-19 08:02:03], type: :date_time}
  """
  def date_and_time(%Value{type: :date, value: %Date{} = date}, %Value{
        type: :time,
        value: %Time{} = time
      }) do
    case NaiveDateTime.new(date, time) do
      {:ok, time} -> Value.new(time)
      _ -> Value.new(nil)
    end
  end

  def date_and_time(%Value{type: :date_time, value: %NaiveDateTime{} = date_time}, %Value{
        type: :time,
        value: %Time{} = time
      }) do
    case NaiveDateTime.new(NaiveDateTime.to_date(date_time), time) do
      {:ok, time} -> Value.new(time)
      _ -> Value.new(nil)
    end
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _}}, %Value{
        type: :time,
        value: %Time{} = time
      }) do
    case NaiveDateTime.new(NaiveDateTime.to_date(date_time), time) do
      {:ok, time} -> Value.new(time)
      _ -> Value.new(nil)
    end
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _, _}}, %Value{
        type: :time,
        value: %Time{} = time
      }) do
    case NaiveDateTime.new(NaiveDateTime.to_date(date_time), time) do
      {:ok, time} -> Value.new(time)
      _ -> Value.new(nil)
    end
  end

  def date_and_time(%Value{type: :date, value: %Date{} = date}, %Value{
        type: :time,
        value: {%Time{} = time, offset}
      }) do
    NaiveDateTime.new(date, time)
    |> Value.new(offset)
  end

  def date_and_time(%Value{type: :date, value: %Date{} = date}, %Value{
        type: :time,
        value: {%Time{} = time, _offset, timezone}
      }) do
    NaiveDateTime.new(date, time)
    |> Value.new(timezone)
  end

  def date_and_time(%Value{type: :date_time, value: %NaiveDateTime{} = date_time}, %Value{
        type: :time,
        value: {%Time{} = time, offset}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(offset)
  end

  def date_and_time(%Value{type: :date_time, value: %NaiveDateTime{} = date_time}, %Value{
        type: :time,
        value: {%Time{} = time, _offset, timezone}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(timezone)
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _}}, %Value{
        type: :time,
        value: {%Time{} = time, offset}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(offset)
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _}}, %Value{
        type: :time,
        value: {%Time{} = time, _offset, timezone}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(timezone)
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _, _}}, %Value{
        type: :time,
        value: {%Time{} = time, offset}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(offset)
  end

  def date_and_time(%Value{type: :date_time, value: {%NaiveDateTime{} = date_time, _, _}}, %Value{
        type: :time,
        value: {%Time{} = time, _offset, timezone}
      }) do
    NaiveDateTime.new(NaiveDateTime.to_date(date_time), time)
    |> Value.new(timezone)
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

  @doc """
  Creates a duration from string. FeelEx supports two types of durations:
  `days-time-duration` and `years-months-duration`. With the former containing
  day, hour, minute, and second components and the latter containing year and month components.

  ## Examples

    iex> value = FeelEx.Value.new("P1DT1H2M")
    %FeelEx.Value{value: "P1DT1H2M", type: :string}
    iex> FeelEx.Functions.duration(value)
    %FeelEx.Value{
    value: %Duration{day: 1, hour: 1, minute: 2},
    type: :days_time_duration
    }
    iex> value = FeelEx.Value.new("P1Y1M")
    %FeelEx.Value{value: "P1Y1M", type: :string}
    iex> FeelEx.Functions.duration(value)
    %FeelEx.Value{value: %Duration{year: 1, month: 1}, type: :years_months_duration}
  """
  def duration(%Value{value: duration, type: :string}) do
    Value.new(Duration.from_iso8601!(duration))
  end

  def string_transformation(%Value{type: :string, value: _string} = value) do
    functions = [
      &date/1,
      &time/1,
      &date_and_time/1,
      &duration/1
    ]

    result =
      Enum.find_value(functions, fn func ->
        try do
          value = func.(value)
          if value.type == :null, do: nil, else: value
        rescue
          _e -> nil
        end
      end)

    if is_nil(result), do: Value.new(nil), else: result
  end

  #############################
  #  Boolean Functions        #
  #############################
  @doc """
  Negates a value of type boolean. Returns null on other type of values

  ## Examples

      iex> value = FeelEx.Value.new(true)
      %FeelEx.Value{value: true, type: :boolean}
      iex> FeelEx.Functions.negate(value)
      %FeelEx.Value{value: false, type: :boolean}
  """
  def negate(%Value{type: :boolean, value: boolean}) do
    Value.new(not boolean)
  end

  #############################
  #  List Functions           #
  #############################
  @doc """
  Checks if list contains some value.

  ## Examples

      iex> list = FeelEx.Value.new([1,2,3])
      [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number}
      ]
      iex> member = FeelEx.Value.new(1)
      %FeelEx.Value{value: 1, type: :number}
      iex> FeelEx.Functions.list_contains(list,member)
      %FeelEx.Value{value: true, type: :boolean}

  """
  def list_contains(list, %Value{} = value) when is_list(list) do
    Enum.member?(list, value)
    |> Value.new()
  end

  @doc """
  Returns the number of elements of the given list.

  ## Examples

    iex> list = FeelEx.Value.new([1,2,3])
    [
    %FeelEx.Value{value: 1, type: :number},
    %FeelEx.Value{value: 2, type: :number},
    %FeelEx.Value{value: 3, type: :number}
    ]
    iex> FeelEx.Functions.count(list)
    %FeelEx.Value{value: 3, type: :number}
  """
  def count(list) when is_list(list) do
    length(list)
    |> Value.new()
  end

  @doc """
  Returns the minimum in a list. All elements in the list should have the same type and
  be comparable.

  ## Examples

      iex> list = FeelEx.Value.new([2,4,1,2])
      [
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 4, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number}
      ]
      iex> FeelEx.Functions.min(list)
      %FeelEx.Value{value: 1, type: :number}
      iex> list = FeelEx.Value.new([2,4,1,"a"])
      [
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 4, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: "a", type: :string}
      ]
      iex> FeelEx.Functions.min(list)
      [warning] [Elixir.FeelEx.Functions][min/1] Failed to invoke function 'min': [%FeelEx.Value{value: 2, type: :number}, %FeelEx.Value{value: 4, type: :number}, %FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: "a", type: :string}] is not comparable
      %FeelEx.Value{value: nil, type: :null}
  """
  def min(list) when is_list(list) do
    cond do
      all_same_type(list) ->
        Enum.min(list)
        |> Value.new()

      true ->
        Logger.warning("Failed to invoke function 'min': #{inspect(list)} is not comparable")
        Value.new(nil)
    end
  end

  @doc """
  Returns the maximum, in a list. All elements in the list should have the same type and
  be comparable.

  ## Examples

      iex> list = FeelEx.Value.new([2,4,1,2])
      [
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 4, type: :number},
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number}
      ]
      iex> FeelEx.Functions.max(list)
      %FeelEx.Value{value: 4, type: :number}
  """
  def max(list) when is_list(list) do
    cond do
      all_same_type(list) ->
        Enum.max(list)
        |> Value.new()

      true ->
        Logger.warning("Failed to invoke function 'max': #{inspect(list)} is not comparable")

        Value.new(nil)
    end
  end

  defp all_same_type(list) do
    Enum.uniq_by(list, &Map.get(&1, :type))
    |> length()
    |> (&(&1 == 1)).()
  end

  @doc """
  Returns the sum of the given list of numbers.

  ## Examples

      iex> list = FeelEx.Value.new([2,4,1,2])
      [
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 4, type: :number},
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number}
      ]
      iex> FeelEx.Functions.sum(list)
      %FeelEx.Value{value: 9, type: :number}
      iex> FeelEx.Functions.sum(list)
      [warning] [Elixir.FeelEx.Functions][sum/1] Failed to invoke function 'sum': expected number but found '%FeelEx.Value{value: "a", type: :string}'
      %FeelEx.Value{value: nil, type: :null}
  """
  def sum(list) when is_list(list) do
    non_number = non_number(list)

    cond do
      is_nil(non_number) ->
        list
        |> Stream.map(fn value -> Map.get(value, :value) end)
        |> Enum.sum()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'sum': expected number but found '#{inspect(non_number)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns the product of the given list of numbers.


  ## Examples
  iex > list = FeelEx.Value.new([2,4,1,2])
  [
  %FeelEx.Value{value: 2, type: :number},
  %FeelEx.Value{value: 4, type: :number},
  %FeelEx.Value{value: 1, type: :number},
  %FeelEx.Value{value: 2, type: :number}
  ]
  iex > FeelEx.Functions.product(list)
  %FeelEx.Value{value: 16, type: :number}

  """
  def product(list) when is_list(list) do
    non_number = non_number(list)

    cond do
      is_nil(non_number) ->
        list
        |> Stream.map(fn value -> Map.get(value, :value) end)
        |> Enum.product()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected number but found '#{inspect(non_number)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns arithmetic mean given a list of numbers.
  ## Examples
      iex> list = FeelEx.Value.new([1,2,3])
      [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number}
      ]
      iex> FeelEx.Functions.mean(list)
      %FeelEx.Value{value: 2, type: :number}
  """
  def mean(list) when is_list(list) do
    sum = sum(list)

    cond do
      not is_nil(sum) ->
        Map.update!(sum, :value, &integer_checker(&1 / length(list)))

      true ->
        sum
    end
  end

  @doc """
  Returns the median element of the given list of numbers.

  ## Examples

      iex> value = FeelEx.Value.new([6, 1, 2, 3])
      [
        %FeelEx.Value{value: 6, type: :number},
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
      iex> FeelEx.Functions.median(value)
      %FeelEx.Value{value: 2.5, type: :number}
  """
  def median(list) when is_list(list) do
    non_number = non_number(list)

    cond do
      is_nil(non_number) ->
        list
        |> Enum.map(fn value -> Map.get(value, :value) end)
        |> do_median()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected number but found '#{inspect(non_number)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns the standard deviation of the given list of numbers.

  ## Examples


  iex> value = FeelEx.Value.new([2, 4, 7, 5])
  [
    %FeelEx.Value{value: 2, type: :number},
    %FeelEx.Value{value: 4, type: :number},
    %FeelEx.Value{value: 7, type: :number},
    %FeelEx.Value{value: 5, type: :number}
  ]
  iex> FeelEx.Functions.stddev(value)
  %FeelEx.Value{value: 2.0816659994661326, type: :number}
  """
  def stddev(list) when is_list(list) do
    non_number = non_number(list)

    cond do
      is_nil(non_number) ->
        list
        |> Enum.map(fn value -> Map.get(value, :value) end)
        |> do_stddev()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected number but found '#{inspect(non_number)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns the mode of the given list of numbers.

  ## Examples

      iex> value = FeelEx.Value.new([6, 1, 9, 6, 1])
      [
        %FeelEx.Value{value: 6, type: :number},
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 9, type: :number},
        %FeelEx.Value{value: 6, type: :number},
        %FeelEx.Value{value: 1, type: :number}
      ]
      iex> FeelEx.Functions.mode(value)
      [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 6, type: :number}]
  """
  def mode(list) when is_list(list) do
    non_number = non_number(list)

    cond do
      is_nil(non_number) ->
        list
        |> Enum.map(fn value -> Map.get(value, :value) end)
        |> do_mode()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected number but found '#{inspect(non_number)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Expects a list of bollean values.
  Returns true if all elements in a list are true, otherwise returns false.
  If the given list is empty it returns true.

  ## Examples

      iex> value = FeelEx.Value.new([true,false])
      [
        %FeelEx.Value{value: true, type: :boolean},
        %FeelEx.Value{value: false, type: :boolean}
      ]
      iex> FeelEx.Functions.all(value)
      %FeelEx.Value{value: false, type: :boolean}
      iex> value = FeelEx.Value.new([false,nil,true,false])
      [
        %FeelEx.Value{value: false, type: :boolean},
        %FeelEx.Value{value: nil, type: :null},
        %FeelEx.Value{value: true, type: :boolean},
        %FeelEx.Value{value: false, type: :boolean}
      ]
      iex> FeelEx.Functions.all(value)
      %FeelEx.Value{value: false, type: :boolean}
  """
  def all(list) when is_list(list) do
    non_boolean = non_boolean(list)

    cond do
      hd(list).value == false ->
        hd(list)

      is_nil(non_boolean) ->
        list
        |> Enum.map(fn value -> Map.get(value, :value) end)
        |> do_all()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected boolean but found '#{inspect(non_boolean)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns true if any element of the given list is true. Othewise return false.
  If the given list is empty return false.

  ## Examples

      iex> value = FeelEx.Value.new([false,true])
      [
        %FeelEx.Value{value: false, type: :boolean},
        %FeelEx.Value{value: true, type: :boolean}
      ]
      iex> FeelEx.Functions.any(value)
      %FeelEx.Value{value: true, type: :boolean}
  """
  def any(list) when is_list(list) do
    non_boolean = non_boolean(list)

    cond do
      list == [] ->
        Value.new(false)

      Enum.any?(list, fn x -> x.value == true end) ->
        Value.new(true)

      is_nil(non_boolean) ->
        Value.new(false)

      true ->
        Logger.warning(
          "Failed to invoke function 'product': expected boolean but found '#{inspect(non_boolean)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns a partial list of the given value starting at start position.
  ## Examples
      iex> value = FeelEx.Value.new([1,2,3])
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
      iex> start_index = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.sublist(value,start_index)
      [%FeelEx.Value{value: 2, type: :number}, %FeelEx.Value{value: 3, type: :number}]
  """
  def sublist(list, %FeelEx.Value{value: start_position, type: :number}) do
    cond do
      start_position == 0 ->
        Logger.warning(
          "Failed to invoke function 'sublist': start position must be a non-zero number"
        )

      start_position > 0 ->
        Enum.slice(list, (start_position - 1)..-1//1)

      start_position < 0 ->
        Enum.slice(list, start_position..-1//1)
    end
  end

  @doc """
  Returns a partial list of the given value starting at start position. The maximum length of the sublist returned is max_length.

  ## Examples

      iex> value = FeelEx.Value.new([1,2,3])
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
      iex> length = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> start_index = FeelEx.Value.new(1)
      %FeelEx.Value{value: 1, type: :number}
      iex> FeelEx.Functions.sublist(value,start_index,length)
      [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 2, type: :number}]
  """
  def sublist(list, %FeelEx.Value{value: start_position, type: :number}, %FeelEx.Value{
        value: length,
        type: :number
      }) do
    cond do
      start_position == 0 ->
        Logger.warning(
          "Failed to invoke function 'sublist': start position must be a non-zero number"
        )

      start_position > 0 ->
        Enum.slice(list, start_position - 1, length)

      start_position < 0 ->
        Enum.slice(list, start_position, length)
    end
  end

  @doc """
  Append a list of items to a list.

  ## Examples

      iex> list = FeelEx.Value.new([1,2,3])
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
      iex> items = FeelEx.Value.new(["a","b"])
      [
        %FeelEx.Value{value: "a", type: :string},
        %FeelEx.Value{value: "b", type: :string}
      ]
      iex> FeelEx.Functions.append(list,items)
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number},
        %FeelEx.Value{value: "a", type: :string},
        %FeelEx.Value{value: "b", type: :string}
      ]
  """
  def append(list, items) when is_list(list) and is_list(list) do
    list ++ items
  end

  @doc """
  Given a list of lists, perform concatenation.

  ## Examples

    iex> list = FeelEx.Value.new([1,2,3])
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number}
    ]
    iex> items = FeelEx.Value.new([[1,2],["a","b"]])
    [
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number}
    ],
    [
      %FeelEx.Value{value: "a", type: :string},
      %FeelEx.Value{value: "b", type: :string}
    ]
    ]

    iex> FeelEx.Functions.concatenate(items)
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: "a", type: :string},
      %FeelEx.Value{value: "b", type: :string}
    ]
  """
  def concatenate(list) when is_list(list) do
    Enum.reduce_while(list, [], fn x, acc -> {:cont, acc ++ x} end)
  end

  @doc """
  Returns the given list with newItem inserted at position.

  ## Examples

      iex> list  = FeelEx.Value.new([1,3])
      [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 3, type: :number}]
      iex> position = FeelEx.Value.new(1)
      %FeelEx.Value{value: 1, type: :number}
      iex> value = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.insert_before(list,position,value)
      [
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
  """
  def insert_before(
        list,
        %FeelEx.Value{value: start_position, type: :number},
        %FeelEx.Value{} = value
      ) do
    List.insert_at(list, start_position - 1, value)
  end

  def insert_before(
        _list,
        %FeelEx.Value{value: 0, type: :number},
        _value
      ) do
    Logger.warning(
      "[FUNCTION_INVOCATION_FAILURE] Failed to invoke function 'insert before': position must be a non-zero number"
    )

    Value.new(nil)
  end

  @doc """
  Returns the given list without the element at position.

  ## Examples

      iex> list  = FeelEx.Value.new([1,2,3])
      [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number}
      ]
      iex> position = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.remove(list,position)
      [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 3, type: :number}]
  """
  def remove(
        list,
        %FeelEx.Value{value: start_position, type: :number}
      )
      when start_position > 0 do
    List.delete_at(list, start_position - 1)
  end

  def remove(
        list,
        %FeelEx.Value{value: start_position, type: :number}
      )
      when start_position < 0 do
    List.delete_at(list, start_position)
  end

  def remove(
        _list,
        %FeelEx.Value{value: 0, type: :number}
      ) do
    Logger.warning(
      "[FUNCTION_INVOCATION_FAILURE] Failed to invoke function 'remove': position must be a non-zero number"
    )

    Value.new(nil)
  end

  @doc """
  Returns the given list in revered order.

  ## Examples

  iex> list  = FeelEx.Value.new([1,3])
  [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 3, type: :number}]
  iex> FeelEx.Functions.reverse(list)
  [%FeelEx.Value{value: 3, type: :number}, %FeelEx.Value{value: 1, type: :number}]
  """
  def reverse(list) when is_list(list) do
    Enum.reverse(list)
  end

  @doc """
  Returns 1-based indices of a given list corresponding to a given match.

  ## Examples

      iex> list  = FeelEx.Value.new([1,2,3,2])
      [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number},
      %FeelEx.Value{value: 2, type: :number}
      ]
      iex> value = FeelEx.Value.new(2)
      %FeelEx.Value{value: 2, type: :number}
      iex> FeelEx.Functions.index_of(list,value)
      [%FeelEx.Value{value: 2, type: :number}, %FeelEx.Value{value: 4, type: :number}]
  """
  def index_of(list, %FeelEx.Value{} = match) do
    Stream.with_index(list)
    |> Stream.filter(fn {v, _i} -> v == match end)
    |> Enum.map(fn {_v, i} -> Value.new(i + 1) end)
  end

  @doc """
  Returns a list that includes all elements of the given lists without duplicates.
      iex> list  = FeelEx.Value.new([[1,2],[3,2]])
      [
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number}
      ],
      [
        %FeelEx.Value{value: 3, type: :number},
        %FeelEx.Value{value: 2, type: :number}
      ]
      ]
      iex> FeelEx.Functions.union(list)
      [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number}
      ]
  """
  def union(list) when is_list(list) do
    list |> Enum.concat() |> Enum.uniq()
  end

  @doc """
  Returns the given list without duplicates.

  ## Examples

      iex> list  = FeelEx.Value.new([1,2,3,2,1])
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 1, type: :number}
      ]
      iex> FeelEx.Functions.distinct_values(list)
      [
        %FeelEx.Value{value: 1, type: :number},
        %FeelEx.Value{value: 2, type: :number},
        %FeelEx.Value{value: 3, type: :number}
      ]
  """
  def distinct_values(list) when is_list(list) do
    Enum.uniq(list)
  end

  @doc """
  Returns duplicate values within a list.

  ## Examples

    iex> list  = FeelEx.Value.new([1,2,3,2,1])
    [
      %FeelEx.Value{value: 1, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 3, type: :number},
      %FeelEx.Value{value: 2, type: :number},
      %FeelEx.Value{value: 1, type: :number}
    ]
    iex> FeelEx.Functions.duplicate_value(list)
    [%FeelEx.Value{value: 1, type: :number}, %FeelEx.Value{value: 2, type: :number}]
  """
  def duplicate_values([]), do: []

  def duplicate_value(list) when is_list(list) do
    freq = Enum.frequencies(list)

    Stream.filter(freq, fn {_, v} -> v > 1 end)
    |> Enum.map(fn {k, _} -> k end)
  end

  def flatten(list) when is_list(list) do
    List.flatten(list)
  end

  @doc """
  Joins a list of strings into a single string.

  ## Examples

      iex> list  = FeelEx.Value.new(["a","b","c"])
      [
        %FeelEx.Value{value: "a", type: :string},
        %FeelEx.Value{value: "b", type: :string},
        %FeelEx.Value{value: "c", type: :string}
      ]
      iex> FeelEx.Functions.string_join(list)
      %FeelEx.Value{value: "abc", type: :string}
      iex> list  = FeelEx.Value.new(["a",nil,"c"])
      [
        %FeelEx.Value{value: "a", type: :string},
        %FeelEx.Value{value: nil, type: :null},
        %FeelEx.Value{value: "c", type: :string}
      ]
      iex> FeelEx.Functions.string_join(list)
      %FeelEx.Value{value: "ac", type: :string}
  """
  def string_join(list) do
    non_string_or_null = non_string_or_null(list)

    cond do
      is_nil(non_string_or_null) ->
        list
        |> Stream.map(fn value -> Map.get(value, :value) end)
        |> Enum.join()
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'string-join': expected string or null but found '#{inspect(non_string_or_null)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Joins a list of strings into a single string, with a delimeter between eech element.


  ## Examples

  iex)> list  = FeelEx.Value.new(["a"])
  [%FeelEx.Value{value: "a", type: :string}]
  iex)> delimiter  = FeelEx.Value.new("X")
  %FeelEx.Value{value: "X", type: :string}
  iex)> FeelEx.Functions.string_join(list,delimiter)
  %FeelEx.Value{value: "a", type: :string}
  iex> list  = FeelEx.Value.new(["a","b","c"])
  [
    %FeelEx.Value{value: "a", type: :string},
    %FeelEx.Value{value: "b", type: :string},
    %FeelEx.Value{value: "c", type: :string}
  ]
  iex> delimiter  = FeelEx.Value.new(", ")
  %FeelEx.Value{value: ", ", type: :string}
  iex> FeelEx.Functions.string_join(list,delimiter)
  %FeelEx.Value{value: "a, b, c", type: :string}
  """
  def string_join(list, %Value{value: string, type: :string}) do
    non_string_or_null = non_string_or_null(list)

    cond do
      is_nil(non_string_or_null) ->
        list
        |> Stream.map(fn value -> Map.get(value, :value) end)
        |> Enum.join(string)
        |> Value.new()

      true ->
        Logger.warning(
          "Failed to invoke function 'string-join': expected string or null but found '#{inspect(non_string_or_null)}'"
        )

        Value.new(nil)
    end
  end

  @doc """
  Returns true if the given list is empty. Otherwise, returns false.

  ## Examples

  iex> list  = FeelEx.Value.new([])
  []
  iex> FeelEx.Functions.is_empty(list)
  %FeelEx.Value{value: true, type: :boolean}
  iex> list  = FeelEx.Value.new([1,2,3])
  [
  %FeelEx.Value{value: 1, type: :number},
  %FeelEx.Value{value: 2, type: :number},
  %FeelEx.Value{value: 3, type: :number}
  ]
  iex> FeelEx.Functions.is_empty(list)
  %FeelEx.Value{value: false, type: :boolean}
  """
  def is_empty([]), do: Value.new(true)
  def is_empty(list) when is_list(list), do: Value.new(false)

  defp non_number(list) do
    Enum.find(list, fn value -> Map.get(value, :type) != :number end)
  end

  defp non_string_or_null(list) do
    Enum.find(list, fn value -> Map.get(value, :type) not in [:string, :null] end)
  end

  defp non_boolean(list) do
    Enum.find(list, fn value -> Map.get(value, :type) != :boolean end)
  end

  defp do_mode([]) do
    nil
  end

  defp do_mode(list) do
    freq = Enum.frequencies(list)

    max_length =
      elem(Enum.max_by(freq, fn {_, v} -> v end), 1)

    Stream.filter(freq, fn {_, v} -> v == max_length end)
    |> Enum.map(fn {k, _} -> k end)
  end

  defp do_median([]) do
    nil
  end

  defp do_median(list) do
    length = length(list)
    list = Enum.sort(list)

    cond do
      length == 0 ->
        nil

      length == 1 ->
        [a] = list
        a

      length == 2 ->
        Enum.sum(list) / 2

      Integer.is_even(length) ->
        index = div(length, 2)
        v1 = Enum.at(list, index)
        v2 = Enum.at(list, index - 1)
        (v1 + v2) / 2

      Integer.is_odd(length) ->
        index = div(length, 2)
        Enum.at(list, index)
    end
    |> integer_checker()
  end

  defp do_stddev(list) when is_list(list) do
    length = length(list)
    mean = Enum.sum(list) / length

    :math.sqrt(
      Enum.reduce_while(list, 0, fn x, acc ->
        {:cont, acc + (x - mean) ** 2}
      end) / (length - 1)
    )
  end

  defp do_all([]), do: true

  defp do_all(list) when is_list(list) do
    Enum.all?(list, fn x -> x == true end)
  end
end
