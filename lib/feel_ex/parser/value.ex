defmodule FeelEx.Value do
  @moduledoc false
  alias FeelEx.Helper

  defstruct [:value, :type]

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

  def new(%Date{} = date) do
    %__MODULE__{value: date, type: :date}
  end

  def new(%NaiveDateTime{} = date) do
    %__MODULE__{value: date, type: :date_time}
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

  def new(%NaiveDateTime{} = date, offset_or_zone_id) do
    offset = Helper.get_offset(offset_or_zone_id)

    case offset do
      {:error, _} ->
        new(nil)

      offset ->
        if String.starts_with?(offset_or_zone_id, "+") or
             String.starts_with?(offset_or_zone_id, "-") do
          %__MODULE__{value: {date, offset}, type: :date_time}
        else
          %__MODULE__{
            value: {date, offset, offset_or_zone_id},
            type: :date_time
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
