defmodule FeelEx.Value do
  @moduledoc false
  alias FeelEx.Helper

  defstruct [:value, :type]

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
    %__MODULE__{value: context, type: :context}
  end

  def new(%Time{} = time) do
    %__MODULE__{value: time, type: :time}
  end

  def new(%Duration{} = duration) do
    %__MODULE__{value: duration, type: :duration}
  end

  def new(%NaiveDateTime{} = date, offset_or_zone_id) do
    %__MODULE__{value: {date, Helper.get_offset(offset_or_zone_id)}, type: :date_time}
  end

  def new(%Time{} = time, offset_or_zone_id) do
    %__MODULE__{value: {time, Helper.get_offset(offset_or_zone_id)}, type: :time}
  end
end
