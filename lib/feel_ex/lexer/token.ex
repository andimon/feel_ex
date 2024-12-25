defmodule FeelEx.Token do
  defstruct [:type, :value, :line_number]

  def new(:eof) do
    %__MODULE__{type: :eof}
  end

  def new(%{current_state: :state_1, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :int, value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_3, lexeme: ".", current_line_number: line_number}) do
    %__MODULE__{type: :dot, value: ".", line_number: line_number}
  end

  def new(%{current_state: :state_3, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :float, value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_6, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :comment, value: lexeme, line_number: line_number - 1}
  end

  def new(%{current_state: :state_4, lexeme: "/", current_line_number: line_number}) do
    %__MODULE__{type: :arithmetic_op_div, value: "/", line_number: line_number - 1}
  end

  def new(%{current_state: :state_9, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :comment, value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_10, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: check_for_keywords(lexeme), value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_11, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: check_for_keywords(lexeme), value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_12, lexeme: "*", current_line_number: line_number}) do
    %__MODULE__{type: :arithmetic_op_mul, value: "*", line_number: line_number - 1}
  end

  def new(%{current_state: :state_12, lexeme: "+", current_line_number: line_number}) do
    %__MODULE__{type: :arithmetic_op_add, value: "+", line_number: line_number - 1}
  end

  def new(%{current_state: :state_12, lexeme: "-", current_line_number: line_number}) do
    %__MODULE__{type: :arithmetic_op_sub, value: "-", line_number: line_number - 1}
  end

  def new(%{current_state: :state_14, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :string, value: unescape(lexeme), line_number: line_number - 1}
  end

  def new(%{current_state: :state_15, lexeme: "<", current_line_number: line_number}) do
    %__MODULE__{type: :lt, value: "<", line_number: line_number - 1}
  end

  def new(%{current_state: :state_15, lexeme: ">", current_line_number: line_number}) do
    %__MODULE__{type: :gt, value: ">", line_number: line_number - 1}
  end

  def new(%{current_state: :state_16, lexeme: "<=", current_line_number: line_number}) do
    %__MODULE__{type: :leq, value: "<=", line_number: line_number - 1}
  end

  def new(%{current_state: :state_16, lexeme: "!=", current_line_number: line_number}) do
    %__MODULE__{type: :neq, value: "!=", line_number: line_number - 1}
  end

  def new(%{current_state: :state_16, lexeme: ">=", current_line_number: line_number}) do
    %__MODULE__{type: :geq, value: ">=", line_number: line_number - 1}
  end

  def new(%{current_state: :state_17, lexeme: "=", current_line_number: line_number}) do
    %__MODULE__{type: :eq, value: "=", line_number: line_number - 1}
  end

  def new(%{current_state: :state_18, lexeme: "(", current_line_number: line_number}) do
    %__MODULE__{type: :left_bracket, value: "(", line_number: line_number - 1}
  end

  def new(%{current_state: :state_18, lexeme: ")", current_line_number: line_number}) do
    %__MODULE__{type: :right_bracket, value: ")", line_number: line_number - 1}
  end

  defp check_for_keywords("if"), do: :if
  defp check_for_keywords("then"), do: :then
  defp check_for_keywords("else"), do: :else
  defp check_for_keywords("for"), do: :for
  defp check_for_keywords("in"), do: :in
  defp check_for_keywords("return"), do: :return
  defp check_for_keywords("some"), do: :some
  defp check_for_keywords("every"), do: :every
  defp check_for_keywords("or"), do: :or
  defp check_for_keywords("and"), do: :and
  defp check_for_keywords("true"), do: :boolean
  defp check_for_keywords("false"), do: :boolean
  defp check_for_keywords(_), do: :name

  defp unescape(string) when is_binary(string) do
    string
    |> String.replace("\"", "")
  end
end
