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

  def new(%{current_state: :state_9, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :comment, value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_10, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :name, value: lexeme, line_number: line_number}
  end

  def new(%{current_state: :state_11, lexeme: lexeme, current_line_number: line_number}) do
    %__MODULE__{type: :name, value: lexeme, line_number: line_number}
  end
end
