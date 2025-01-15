defmodule FeelEx do
  @moduledoc """
    A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the FEEL(Friendly Enough Expression Language). For more information regarding FEEL, please take a look at the official OMG specification at https://www.omg.org/dmn/.
  """

  require Logger
  alias FeelEx.{Helper, Lexer, Parser, Expression}

  @doc """
  Evaluates an expression against a context. See https://github.com/ExSemantic/feel_ex/blob/master/README.md
  to see more examples in detail.

  ## Examples

      iex> FeelEx.evaluate(%{a: true}, "if a then 2+2 else 3+3")
      %FeelEx.Value{value: 4, type: :number}

  """
  def evaluate(context, expression) when is_map(context) and is_binary(expression) do
    context = Helper.transform_context(context)
    tokens = Lexer.tokens(expression)
    tokens = Helper.filter_out_comments(tokens)
    expression = Parser.parse_expression(tokens)
    Expression.evaluate(expression, context)
  end

  @doc """
  Evaluates an expression.


  ## Examples

      iex> FeelEx.evaluate("if true then 2+2 else 3+3")
      %FeelEx.Value{value: 4, type: :number}

  """
  def evaluate(expression) when is_binary(expression) do
    evaluate(%{}, expression)
  end
end
