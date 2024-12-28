defmodule FeelEx.Value do
  @moduledoc false
  defstruct [:value, :type]

  def new(number) when is_number(number) do
    %__MODULE__{value: number, type: :number}
  end

  def new(boolean) when is_boolean(boolean) do
    %__MODULE__{value: boolean, type: :boolean}
  end

  def new(string) when is_binary(string) do
    %__MODULE__{value: string, type: :string}
  end

  def new(list) when is_list(list) do
    Enum.map(list, fn elem -> new(elem) end)
  end
end
