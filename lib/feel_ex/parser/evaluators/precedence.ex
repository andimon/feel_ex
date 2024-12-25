defmodule FeelEx.Parser.Evaluators.Precedence do
  # relation ops
  def precedence(:eq), do: 0
  def precedence(:geq), do: 0
  def precedence(:leq), do: 0
  def precedence(:lt), do: 0
  def precedence(:gt), do: 0

  # additive ops

  def precedence(:arithmetic_op_add), do: 1
  def precedence(:arithmetic_op_sub), do: 1

  # multiplicative ops
  def precedence(:arithmetic_op_div), do: 2
  def precedence(:arithmetic_op_mul), do: 2
  # others
  def precedene(other) when is_atom(other), do: -1
end
