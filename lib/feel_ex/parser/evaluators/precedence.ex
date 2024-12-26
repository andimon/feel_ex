defmodule FeelEx.Parser.Evaluators.Precedence do
  # relation ops

  def precedence(:or), do: 0
  def precedence(:and), do: 0

  def precedence(:eq), do: 1
  def precedence(:geq), do: 1
  def precedence(:leq), do: 1
  def precedence(:lt), do: 1
  def precedence(:gt), do: 1



# additive ops

  def precedence(:arithmetic_op_add), do: 2
  def precedence(:arithmetic_op_sub), do: 2

  # multiplicative ops
  def precedence(:arithmetic_op_div), do: 3
  def precedence(:arithmetic_op_mul), do: 3
  # others
  # def precedene(other) when is_atom(other), do: -1
end
