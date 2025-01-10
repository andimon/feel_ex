defmodule FeelEx.Parser.Evaluators.Precedence do
  @moduledoc false
  def precedence(:or), do: 0
  def precedence(:and), do: 0
  def precedence(:between), do: 0
  def precedence(:eq), do: 1
  def precedence(:neq), do: 1
  def precedence(:geq), do: 1
  def precedence(:leq), do: 1
  def precedence(:lt), do: 1
  def precedence(:gt), do: 1
  def precedence(:arithmetic_op_add), do: 2
  def precedence(:arithmetic_op_sub), do: 2
  def precedence(:arithmetic_op_div), do: 3
  def precedence(:arithmetic_op_mul), do: 3
  def precedence(:exponentiation), do: 4
end
