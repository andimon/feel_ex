defmodule FeelEx.Value do
  @moduledoc """
  Construct a FeelEx's value from Elixir's terms.
  """
  alias FeelEx.Helper

  defstruct [:value, :type]

  @type feelex_number_value() :: %__MODULE__{value: number(), type: :number}
  @type feelex_string_value() :: %__MODULE__{value: String.t(), type: :string}
  @type feelex_null_value() :: %__MODULE__{value: nil, type: :null}
  @type feelex_boolean_value() :: %__MODULE__{value: boolean(), type: :boolean}
  @type feelex_date_value() :: %__MODULE__{value: Date.t(), type: :date}
  @type feelex_datetime_value() :: %__MODULE__{value: NaiveDateTime.t(), type: :datetime}
  @type feelex_time_value() :: %__MODULE__{value: Time.t(), type: :time}
  @typedoc """
  Offset in the form +dd:dd or -dd:dd, where 'dd' represents two digits for hours and minutes, e.g., "+02:30" or "-05:00".
  """
  @type offset :: String.t()
  @typedoc """
  Timezone ID is a timezone identifier, e.g., "Europe/Malta".
  """
  @type zone_id :: String.t()
  @type feelex_datetime_with_timezone_or_offset_value() ::
          %__MODULE__{value: {NaiveDateTime.t(), offset()}, type: :datetime}
          | %__MODULE__{value: {NaiveDateTime.t(), offset(), zone_id()}, type: :datetime}
  @type feelex_time_with_timezone_or_offset_value() ::
          %__MODULE__{value: {Time.t(), offset()}, type: :datetime}
          | %__MODULE__{value: {Time.t(), offset(), zone_id()}, type: :datetime}

  @type feelex_context_value() :: %__MODULE__{value: map(), type: :context}
  @type feelex_days_time_duration_value() :: %__MODULE__{
          value: Duration.t(),
          type: :days_time_duration
        }
  @type feelex_years_months_duration_value() :: %__MODULE__{
          value: Duration.t(),
          type: :years_months_duration
        }

  @type t() ::
          feelex_number_value()
          | feelex_string_value()
          | feelex_null_value()
          | feelex_boolean_value()
          | feelex_date_value()
          | feelex_datetime_value()
          | feelex_time_value()
          | offset()
          | zone_id()

  @spec new(t()) :: t()
  @spec new(number()) :: feelex_number_value()
  @spec new(list) :: [t()]
  @spec new(boolean()) :: feelex_boolean_value()
  @spec new(String.t()) :: feelex_string_value()
  @spec new(nil) :: feelex_null_value()
  @spec new(Date.t()) :: feelex_date_value()
  @spec new(map()) :: feelex_context_value()
  @spec new(NaiveDateTime.t()) :: feelex_datetime_value()
  @spec new(Time.t()) :: feelex_time_value()
  @spec new(Duration.t()) ::
          feelex_days_time_duration_value() | feelex_years_months_duration_value()
  @spec new(NaiveDateTime.t(), String.t()) ::
          feelex_datetime_with_timezone_or_offset_value()
  @spec new(Time.t(), String.t()) ::
          feelex_time_with_timezone_or_offset_value()
  @doc """
  Create a FeelEx's value from Elixir terms. Refer to the function's spec for more information.
  """
  def new(%__MODULE__{} = value), do: value

  def new(number) when is_number(number) do
    %__MODULE__{value: number, type: :number}
  end

  def new(list) when is_list(list) do
    Enum.map(list, fn item -> new(item) end)
  end

  def new(boolean) when is_boolean(boolean) do
    %__MODULE__{value: boolean, type: :boolean}
  end

  def new(string) when is_binary(string) do
    %__MODULE__{value: string, type: :string}
  end

  def new(nil) do
    %__MODULE__{value: nil, type: :null}
  end

  def new(%Date{} = temporal) do
    %__MODULE__{value: temporal, type: :date}
  end

  def new(%NaiveDateTime{} = temporal) do
    %__MODULE__{value: temporal, type: :datetime}
  end

  def new(%{} = context) when not is_struct(context) do
    context =
      Stream.map(context, fn {key, value} ->
        key = if is_atom(key), do: key, else: String.to_atom(key)
        {key, new(value)}
      end)
      |> Enum.into(%{})

    %__MODULE__{value: context, type: :context}
  end

  def new(%__MODULE__{} = value), do: value

  def new(%Time{} = time) do
    %__MODULE__{value: time, type: :time}
  end

  def new(
        %Duration{year: 0, month: 0, day: day, hour: hour, minute: minute, second: second} =
          duration
      )
      when day != 0 or hour != 0 or minute != 0 or
             second != 0 do
    %__MODULE__{value: duration, type: :days_time_duration}
  end

  def new(%Duration{year: year, month: month, day: 0, hour: 0, minute: 0, second: 0} = duration)
      when year != 0 or month != 0 do
    %__MODULE__{value: duration, type: :years_months_duration}
  end

  def new(%Duration{year: 0, month: 0, day: 0, hour: 0, minute: 0, second: 0} = d) do
    %__MODULE__{value: d, type: :years_months_duration}
  end

  @doc """
  Create a FeelEx's temporal value by specifying an offset or timezone id. Refer to the function's spec for more information.
  """
  def new(%NaiveDateTime{} = date, offset_or_zone_id) do
    offset = Helper.get_offset(offset_or_zone_id)

    case offset do
      {:error, _} ->
        new(nil)

      offset ->
        if String.starts_with?(offset_or_zone_id, "+") or
             String.starts_with?(offset_or_zone_id, "-") do
          %__MODULE__{value: {date, offset}, type: :datetime}
        else
          %__MODULE__{
            value: {date, offset, offset_or_zone_id},
            type: :datetime
          }
        end
    end
  end

  def new(%Time{} = time, offset_or_zone_id) do
    offset = Helper.get_offset(offset_or_zone_id)

    case offset do
      {:error, _} ->
        new(nil)

      offset ->
        if String.starts_with?(offset_or_zone_id, "+") or
             String.starts_with?(offset_or_zone_id, "-") do
          %__MODULE__{value: {time, offset}, type: :time}
        else
          %__MODULE__{
            value: {time, offset, offset_or_zone_id},
            type: :time
          }
        end
    end
  end
end
