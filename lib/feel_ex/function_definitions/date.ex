defmodule FeelEx.FunctionDefinitions.Date do
  @moduledoc false
  alias FeelEx.Value

  def date(%Value{value: value, type: :string}) do
    Value.new(Date.from_iso8601!(value))
  end
end
