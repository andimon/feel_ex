defmodule FeelEx.Parser do
  alias FeelEx.Token
  alias FeelEx.Expression
  require Logger

    # parse string
    def parse_expression([%Token{type: :string, value: string}, %Token{type: :eof}]) do
      Expression.new(:string, string)
    end

    def parse_expression([%Token{type: :string, value: string}]) do
      Expression.new(:string, string)
    end

  # parse boolean values
  def parse_expression([%Token{type: :boolean, value: "true"}, %Token{type: :eof}]) do
    Expression.new(:boolean, true)
  end

  def parse_expression([%Token{type: :boolean, value: "false"}, %Token{type: :eof}]) do
    Expression.new(:boolean, false)
  end

  def parse_expression([%Token{type: :boolean, value: "true"}]) do
    Expression.new(:boolean, true)
  end

  def parse_expression([%Token{type: :boolean, value: "false"}]) do
    Expression.new(:boolean, false)
  end

  # parse numbers
  def parse_expression([%Token{type: :int, value: int}, %Token{type: :eof}]) do
    Expression.new(:int, int)
  end

  def parse_expression([%Token{type: :float, value: float}, %Token{type: :eof}]) do
    Expression.new(:float, float)
  end

  def parse_expression([%Token{type: :int, value: int}]) do
    Expression.new(:int, int)
  end

  def parse_expression([%Token{type: :float, value: float}]) do
    Expression.new(:float, float)
  end

  # parse name
  def parse_expression([%Token{type: :name, value: name}, %Token{type: :eof}]) do
    Expression.new(:name, name)
  end

  def parse_expression([%Token{type: :name, value: name}]) do
    Expression.new(:name, name)
  end

  def parse_expression([%Token{type: :if} | remaining_tokens]) do
    # check that remaning tokens have a then and else after each other
    tokens_contains_then_and_else!(remaining_tokens)
    # parse expression for condition
    {condition_expression, remaining_tokens} = parse_expression_for_if_condition(remaining_tokens)
    # parse expression for condition statement
    {conitional_statement, remaining_tokens} =
      parse_expression_for_if_conditional_statement(remaining_tokens)

    # parse expression for else statement
    else_condition = parse_expression(remaining_tokens)
    Expression.new(:if, condition_expression, conitional_statement, else_condition)
  end

  def parse_expression([%Token{type: :eof}]) do
    {:ok, nil}
  end

  # handle addition
  def parse_expression([
        left_token,
        %Token{type: :arithemtic_op_add, value: "+"} | right_expression
      ]) do
    left_tree = parse_expression([left_token])
    right_tree = parse_expression(right_expression)
    Expression.new(:op_add, left_tree, right_tree)
  end

  def parse_expression([
        left_token,
        %Token{type: :arithemtic_op_sub, value: "-"} | right_expression
      ]) do
    left_tree = parse_expression([left_token, %Token{type: :eof}])
    right_tree = parse_expression(right_expression)
    Expression.new(:op_subtract, left_tree, right_tree)
  end

  def parse_expression([
        left_token,
        %Token{type: :arithemtic_op_mul, value: "*"} | right_expression
      ]) do
    left_tree = parse_expression([left_token, %Token{type: :eof}])
    right_tree = parse_expression(right_expression)
    Expression.new(:op_multiply, left_tree, right_tree)
  end

  def parse_expression([
        left_token,
        %Token{type: :arithemtic_op_div, value: "/"} | right_expression
      ]) do
    left_tree = parse_expression([left_token, %Token{type: :eof}])
    right_tree = parse_expression(right_expression)
    Expression.new(:op_divide, left_tree, right_tree)
  end

  defp tokens_contains_then_and_else!(tokens) do
    then_index = get_then_index!(tokens)
    else_index = get_else_index!(tokens)

    if else_index > then_index do
      :ok
    else
      raise ArgumentError, "Keyword then expected after keyword else."
    end
  end

  defp get_then_index!(tokens) do
    index = Enum.find_index(tokens, fn tok -> Map.get(tok, :type) == :then end)

    if is_nil(index) do
      raise ArgumentError, "Expected keyword then."
    else
      index
    end
  end

  defp get_else_index!(tokens) do
    index = Enum.find_index(tokens, fn tok -> Map.get(tok, :type) == :else end)

    if is_nil(index) do
      raise ArgumentError, "Expected keyword else."
    else
      index
    end
  end

  defp parse_expression_for_if_condition(tokens) do
    {condition, remaining_tokens} =
      Enum.split_while(tokens, fn tok -> Map.get(tok, :type) != :then end)

    parsed_condition = parse_expression(condition)
    [%Token{type: :then} | remaining_tokens] = remaining_tokens
    {parsed_condition, remaining_tokens}
  end

  defp parse_expression_for_if_conditional_statement(tokens) do
    {conditional_statement, remaining_tokens} =
      Enum.split_while(tokens, fn tok -> Map.get(tok, :type) != :else end)

    parsed_conditional_statement = parse_expression(conditional_statement)
    [%Token{type: :else} | remaining_tokens] = remaining_tokens
    {parsed_conditional_statement, remaining_tokens}
  end
end
