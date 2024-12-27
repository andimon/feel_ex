defmodule FeelEx do
  @moduledoc """
    A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the FEEL(Friendly Enough Expression Language). For more information regarding FEEL, please take a look at the official OMG specification at https://www.omg.org/dmn/.
  """

  require Logger
  alias FeelEx.{Helper, Lexer, Parser, Expression}

  @doc """
  ## Examples

    iex> FeelEx.evaluate(%{a: 1, b: 2},"a+b")
    %FeelEx.Value{value: 3, type: :number}
  """

  def evaluate(context, feel_expression) when is_map(context) and is_binary(feel_expression) do
    tokens = Lexer.tokens(feel_expression)
    tokens = Helper.filter_out_comments(tokens)
    expression = Parser.parse_expression(tokens)
    Expression.evaluate(expression, context)
  end

  def evaluate(feel_expression) when is_binary(feel_expression) do
    evaluate(%{}, feel_expression)
  end
end
