defmodule FeelEx do
  @moduledoc """
  FeelEx business oriented langauge based on (Friendly Enough Expression Language).
  """
  require Logger
  alias FeelEx.{Helper, Lexer, Parser, Expression}

  @doc """
  """
  def evaluate(context, feel_expression) when is_map(context) and is_binary(feel_expression) do
    tokens = Lexer.tokens(feel_expression)
    tokens = Helper.filter_out_comments(tokens)
    expression = Parser.parse_expression(tokens)
    Expression.evaluate(expression, context)
  end

  @doc """
  """
  def evaluate(feel_expression) when is_binary(feel_expression) do
    evaluate(%{}, feel_expression)
  end
end
