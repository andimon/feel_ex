defmodule FeelEx do
  @moduledoc """
    A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the FEEL(Friendly Enough Expression Language). For more information regarding FEEL, please take a look at the official OMG specification at https://www.omg.org/dmn/.
  """

  require Logger
  alias FeelEx.{Value, Helper, Lexer, Parser, Expression, UnaryParser}

  @doc """
  Evaluates an expression against a context. See https://github.com/ExSemantic/feel_ex/blob/master/README.md
  to see more examples in detail.

  ## Examples

      iex> FeelEx.evaluate(%{a: true}, "if a then 2+2 else 3+3")
      %FeelEx.Value{value: 4, type: :number}

  """
  @spec evaluate(map(), String.t()) :: Value.t()
  def evaluate(context, expression) when is_map(context) and is_binary(expression) do
    context = Helper.transform_context(context)

    Lexer.tokens(expression)
    |> Helper.filter_out_comments()
    |> Parser.parse_expression()
    |> (&Expression.Evaluator.evaluate(&1, context)).()
  end

  @doc """
  Evaluates an expression.


  ## Examples

      iex> FeelEx.evaluate("if true then 2+2 else 3+3")
      %FeelEx.Value{value: 4, type: :number}

  """
  @spec evaluate(String.t()) :: Value.t()
  def evaluate(expression) when is_binary(expression) do
    evaluate(%{}, expression)
  end

  @doc """
  Run a unary test with a given unary expression, input value, context.

  ## Examples

      iex> FeelEx.unary_test("<a","3",%{a: 2})
      %FeelEx.Value{value: false, type: :boolean}
      iex> FeelEx.unary_test("<a","3",%{a: 5})
      %FeelEx.Value{value: true, type: :boolean}

  """
  @spec unary_test(String.t(), String.t(), map()) :: Value.t()
  def unary_test(expression, input_value, context)
      when is_binary(expression) and is_binary(input_value) and is_map(context) do
    context =
      evaluate(context,input_value)
      |> (&Map.put(context, :"?", &1)).()

    Lexer.tokens(expression)
    |> Helper.filter_out_comments()
    |> UnaryParser.parse_unary_expression()
    |> (&Expression.Evaluator.evaluate(&1, context)).()
  end

  @doc """
  Run a unary test with a given unary expression and input value.

  ## Examples

      iex> FeelEx.unary_test("<5","3")
      %FeelEx.Value{value: true, type: :boolean}
      iex> FeelEx.unary_test("<2","3")
      %FeelEx.Value{value: false, type: :boolean}
      iex> FeelEx.unary_test("(2..5)","3")
      %FeelEx.Value{value: true, type: :boolean}
      iex> FeelEx.unary_test("(2..5)","2")
      %FeelEx.Value{value: false, type: :boolean}
      %FeelEx.Value{value: false, type: :boolean}
      iex> FeelEx.unary_test("[2..5]","5")
      %FeelEx.Value{value: true, type: :boolean}
      iex> FeelEx.unary_test("[2..5)","5")
      %FeelEx.Value{value: false, type: :boolean}
  """
  @spec unary_test(String.t(), String.t()) :: Value.t()
  def unary_test(expression, input_value) when is_binary(expression) and is_binary(input_value) do
    unary_test(expression, input_value, %{})
  end
end
