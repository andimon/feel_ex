defmodule FeelEx.Parser do
  alias FeelEx.Token
  alias FeelEx.Expression
  alias FeelEx.Parser.Evaluators.Precedence
  require Logger

  def parse_expression(tokens) do
    {exp, []} = do_parse_expression(tokens, -1)
    exp
  end

  def do_parse_expression([%Token{type: :eof}], _precedence) do
    nil
  end

  def do_parse_expression(%Token{type: :eof}, _precedence) do
    nil
  end

  def do_parse_expression(
        [%Token{type: :left_square_bracket, value: "["} | remaining_tokens],
        _precedence
      ) do
    right_parenthesis_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :right_square_bracket end)

    if is_nil(right_parenthesis_index) do
      raise ArgumentError, message: "Expected ] after ["
    else
      expression_list = get_expression_list(remaining_tokens, right_parenthesis_index)

      expression = {Expression.new(:list, expression_list), []}
      remaining_tokens = Enum.slice(remaining_tokens, (right_parenthesis_index + 1)..-1//1)

      do_parse_expression(expression, remaining_tokens, -1)
    end
  end

  def do_parse_expression(
        [%Token{type: :left_parenthesis, value: "("} | remaining_tokens],
        _precedence
      ) do
    right_parenthesis_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :right_parenthesis end)

    if is_nil(right_parenthesis_index) do
      raise ArgumentError, message: "Expected ) after ("
    else
      tokens_inside_brackets = Enum.slice(remaining_tokens, 0..(right_parenthesis_index - 1))
      remaining_tokens = Enum.slice(remaining_tokens, (right_parenthesis_index + 1)..-1//1)
      expression = do_parse_expression(tokens_inside_brackets, -1)
      do_parse_expression(expression, remaining_tokens, -1)
    end
  end

  def do_parse_expression([%Token{type: type, value: value}, %Token{type: :eof}], _precedence)
      when type in [:int, :float, :name, :string] do
    {Expression.new(type, value), []}
  end

  def do_parse_expression([%Token{type: type, value: value}, %Token{type: :eof}], _precedence)
      when type in [:int, :float, :name, :string] do
    {Expression.new(type, value), []}
  end

  def do_parse_expression(%Token{type: type, value: value}, _precedence)
      when type in [:float, :int, :name, :string] do
    {Expression.new(type, value), []}
  end

  def do_parse_expression([%Token{type: type, value: value}], _precedence)
      when type in [:int, :float, :name, :string] do
    {Expression.new(type, value), []}
  end

  def do_parse_expression([%Token{type: :boolean, value: value}], _precedence)
      when value in ["true", "false"] do
    {Expression.new(:boolean, String.to_atom(value)), []}
  end

  def do_parse_expression(
        [%Token{type: :boolean, value: value}, %Token{type: :eof}],
        _precedence
      )
      when value in ["true", "false"] do
    {Expression.new(:boolean, String.to_atom(value)), []}
  end

  def do_parse_expression(
        [
          %Token{type: :arithmetic_op_sub, value: "-"},
          %Token{type: :int} = number | remaining_tokens
        ],
        precedence
      ) do
    {number, []} = do_parse_expression(number, precedence)

    negated_int = Expression.new(:negation, number)
    do_parse_expression(negated_int, remaining_tokens, precedence)
  end

  def do_parse_expression([%Token{type: :string, value: string} | tl], precedence) do
    string_expression = Expression.new(:string, string)
    do_parse_expression(string_expression, tl, precedence)
  end

  def do_parse_expression([%Token{type: :if} | remaining_tokens], precedence) do
    tokens_contains_then_and_else!(remaining_tokens)

    {condition_expression, remaining_tokens} =
      parse_expression_for_if_condition(remaining_tokens, precedence)

    {conitional_statement, remaining_tokens} =
      parse_expression_for_if_conditional_statement(remaining_tokens, precedence)

    else_condition = do_parse_expression(remaining_tokens, precedence)
    {Expression.new(:if, condition_expression, conitional_statement, else_condition), []}
  end

  def do_parse_expression(
        [
          left_token,
          %Token{type: type, value: value} | remaining_tokens
        ],
        precedence
      )
      when type in [
             :arithmetic_op_add,
             :arithmetic_op_sub,
             :arithmetic_op_mul,
             :arithmetic_op_div,
             :geq,
             :leq,
             :eq,
             :neq,
             :gt,
             :lt,
             :or,
             :and,
             :exponentiation
           ] do
    left_expression = do_parse_expression([left_token], precedence)

    parse_precedence_loop(
      left_expression,
      [%Token{type: type, value: value} | remaining_tokens],
      precedence
    )
  end

  def do_parse_expression(
        {%Expression{}, []} = left_expression,
        [
          %Token{type: type} = token_type | remaining_tokens
        ],
        precedence
      )
      when type in [
             :arithmetic_op_add,
             :arithmetic_op_sub,
             :arithmetic_op_mul,
             :arithmetic_op_div,
             :geq,
             :leq,
             :eq,
             :neq,
             :gt,
             :lt,
             :or,
             :and,
             :exponentiation
           ] do
    parse_precedence_loop(left_expression, [token_type | remaining_tokens], precedence)
  end

  def do_parse_expression(
        {%Expression{}, []} = left_expression,
        [%Token{type: :eof}],
        _precedence
      ) do
    left_expression
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

  defp parse_expression_for_if_condition(tokens, precedence) do
    {condition, remaining_tokens} =
      Enum.split_while(tokens, fn tok -> Map.get(tok, :type) != :then end)

    parsed_condition = do_parse_expression(condition, precedence)
    [%Token{type: :then} | remaining_tokens] = remaining_tokens
    {parsed_condition, remaining_tokens}
  end

  defp parse_expression_for_if_conditional_statement(tokens, precedence) do
    {conditional_statement, remaining_tokens} =
      Enum.split_while(tokens, fn tok -> Map.get(tok, :type) != :else end)

    parsed_conditional_statement = do_parse_expression(conditional_statement, precedence)
    [%Token{type: :else} | remaining_tokens] = remaining_tokens
    {parsed_conditional_statement, remaining_tokens}
  end

  defp parse_increasing_precedence(
         left_expression,
         [%Token{type: type, value: value} | remaining_tokens],
         min_prec
       )
       when type in [
              :arithmetic_op_sub,
              :arithmetic_op_add,
              :arithmetic_op_div,
              :arithmetic_op_mul,
              :geq,
              :leq,
              :eq,
              :neq,
              :gt,
              :lt,
              :or,
              :and,
              :exponentiation
            ] do
    next_prec = Precedence.precedence(type)

    if next_prec <= min_prec do
      {left_expression, [%Token{type: type, value: value} | remaining_tokens]}
    else
      {right_expression, remaining_tokens} =
        do_parse_expression(
          remaining_tokens,
          next_prec
        )

      {Expression.new(type, left_expression, right_expression), remaining_tokens}
    end
  end

  defp parse_precedence_loop(left_expression, remaining_tokens, precedence) do
    {node, remaining_tokens} =
      parse_increasing_precedence(left_expression, remaining_tokens, precedence)

    if node == left_expression or remaining_tokens == [] do
      {node, remaining_tokens}
    else
      parse_precedence_loop(node, remaining_tokens, precedence)
    end
  end

  defp delimit_comma([], new_list, []), do: new_list

  defp delimit_comma([], new_list, current_sub_list) do
    Enum.reverse([current_sub_list | new_list])
  end

  defp delimit_comma([%Token{type: :comma} | tl], new_list, current_sub_list) do
    new_list = [current_sub_list] ++ new_list
    delimit_comma(tl, new_list, [])
  end

  defp delimit_comma([hd | tl], new_list, current_sub_list) do
    current_sub_list = current_sub_list ++ [hd]
    delimit_comma(tl, new_list, current_sub_list)
  end

  defp get_expression_list(_remaining_tokens, 0), do: []

  defp get_expression_list(remaining_tokens, right_parenthesis_index) do
    Enum.slice(remaining_tokens, 0..(right_parenthesis_index - 1))
    |> delimit_comma([], [])
    |> Enum.map(fn sub_tokens -> do_parse_expression(sub_tokens, -1) end)
  end
end
