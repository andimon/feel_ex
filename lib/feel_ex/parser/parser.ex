defmodule FeelEx.Parser do
  @moduledoc """
  Used to get an abstract syntax tree of a program given a sequence of tokens.
  """
  require Logger

  alias FeelEx.{Helper, Token, Expression}

  @spec parse_expression([Token.t()]) :: atom()
  def parse_expression(tokens) do
    {exp, []} = do_parse_expression_first(tokens, -1)
    exp
  end

  defp do_parse_expression_first(tokens, precedence) do
    between_index = Enum.find_index(tokens, fn token -> token.value == "between" end)
    and_index = Enum.find_index(tokens, fn token -> token.type == :and end)

    cond do
      is_nil(between_index) or is_nil(and_index) ->
        do_parse_expression(tokens, precedence)

      between_index == 0 or and_index == length(tokens) - 1 ->
        do_parse_expression(tokens, precedence)

      true ->
        do_between_expression(tokens, between_index, precedence)
    end
  end

  defp do_between_expression(tokens, between_index, precedence) do
    {operand_tokens, [_ | remaining_tokens]} = Enum.split(tokens, between_index)
    and_index = Enum.find_index(remaining_tokens, fn token -> token.type == :and end)
    {min_tokens, [_ | max_tokens]} = Enum.split(remaining_tokens, and_index)

    operand =
      do_parse_expression_first(operand_tokens, precedence)
      |> Helper.filter_expression()

    min =
      do_parse_expression_first(min_tokens, precedence)
      |> Helper.filter_expression()

    max =
      do_parse_expression_first(max_tokens, precedence)
      |> Helper.filter_expression()

    {Expression.Between.new(operand, min, max), []}
  end

  defp do_parse_expression([%Token{type: :eof}], _precedence) do
    nil
  end

  defp do_parse_expression(%Token{type: :eof}, _precedence) do
    nil
  end

  defp do_parse_expression(
         [%Token{type: :for, value: "for"} | remaining_tokens],
         _precedence
       ) do
    return_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :return end)

    if is_nil(return_index) do
      raise ArgumentError, message: "Expected return after for"
    else
      iteration_contexts =
        get_iteration_contexts(Enum.slice(remaining_tokens, 0..(return_index - 1)))

      return_tokens = Enum.slice(remaining_tokens, (return_index + 1)..-1//1)

      return_expression = do_parse_expression_first(return_tokens, -1)

      {Expression.For.new(iteration_contexts, Helper.filter_expression(return_expression)), []}
    end
  end

  defp do_parse_expression(
         [%Token{type: :opening_brace, value: "{"} | _remaining_tokens] = tokens,
         _precedence
       ) do
    {context, remaining_tokens} = Helper.get_context(tokens)

    expression_list =
      context
      |> Helper.break_key_values()
      |> Enum.map(fn [
                       %FeelEx.Token{type: type, value: name},
                       %FeelEx.Token{type: :colon, value: ":"} | tl
                     ]
                     when type in [:string, :name] ->
        {String.to_atom(name), parse_expression(tl)}
      end)

    Enum.map(expression_list, fn {key, value} ->
      value = Helper.filter_expression(value)
      {key, value}
    end)
    |> (&{Expression.Context.new(&1), []}).()
    |> (&do_parse_expression(&1, remaining_tokens, -1)).()
  end

  defp do_parse_expression(
         [%Token{type: :left_square_bracket, value: "["} | _] = list,
         _precedence
       ) do
    {list_tokens, remaining_tokens} = FeelEx.Helper.get_list(list)

    expression_list =
      list_tokens
      |> Helper.get_list_values()
      |> Enum.map(fn elem_tokens -> do_parse_expression(elem_tokens, -1) end)

    expression = {Expression.List.new(Helper.filter_expression(expression_list)), []}

    do_parse_expression(expression, remaining_tokens, -1)
  end

  defp do_parse_expression(
         [%Token{type: :at, value: "@"}, %Token{type: :string} = string | remaining_tokens],
         _precedence
       ) do
    expression =
      do_parse_expression_first(
        [
          %Token{type: :name, value: "string_transformation"},
          %Token{type: :left_parenthesis, value: "("},
          string,
          %Token{type: :right_parenthesis, value: ")"}
        ],
        -1
      )

    do_parse_expression(expression, remaining_tokens, -1)
  end

  defp do_parse_expression(
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
      expression = do_parse_expression_first(tokens_inside_brackets, -1)
      do_parse_expression(expression, remaining_tokens, -1)
    end
  end

  defp do_parse_expression(
         [
           %Token{type: :name, value: _} = name,
           %Token{type: :left_parenthesis, value: "("} = lp | remaining_tokens
         ],
         precedence
       ) do
    {brackets, remaining_tokens} = Helper.get_parenthesis([lp | remaining_tokens])
    [_hd | brackets] = brackets
    expression = brackets |> Enum.reverse() |> tl() |> Enum.reverse()

    expression_list =
      ([%Token{type: :left_square_bracket}] ++
         expression ++ [%Token{type: :right_square_bracket}])
      |> Helper.get_list_values()
      |> Enum.map(fn tokens -> Helper.filter_expression(do_parse_expression(tokens, -1)) end)

    name = Helper.filter_expression(do_parse_expression(name, precedence))
    function = {Expression.Function.new(name, expression_list), []}

    do_parse_expression(function, remaining_tokens, -1)
  end

  defp do_parse_expression(
         [
           %Token{type: :name, value: _} = name1,
           %Token{type: :name, value: _} = name2,
           %Token{type: :left_parenthesis, value: "("} = lp | remaining_tokens
         ],
         _precedence
       ) do
    {brackets, remaining_tokens} = Helper.get_parenthesis([lp | remaining_tokens])
    [_hd | brackets] = brackets
    expression = brackets |> Enum.reverse() |> tl() |> Enum.reverse()

    expression_list =
      ([%Token{type: :left_square_bracket}] ++
         expression ++ [%Token{type: :right_square_bracket}])
      |> Helper.get_list_values()
      |> Enum.map(fn tokens -> Helper.filter_expression(do_parse_expression(tokens, -1)) end)

    name1 = Helper.filter_expression(do_parse_expression(name1, -1))
    name2 = Helper.filter_expression(do_parse_expression(name2, -1))

    function = {Expression.Function.new([name1, name2], expression_list), []}

    do_parse_expression(function, remaining_tokens, -1)
  end

  defp do_parse_expression(
         [
           %Token{type: :name, value: _} = name1,
           %Token{type: type, value: _} = name2,
           %Token{type: :name, value: _} = name3,
           %Token{type: :left_parenthesis, value: "("} = lp | remaining_tokens
         ],
         _precedence
       )
       when type in [:name, :and] do
    {brackets, remaining_tokens} = Helper.get_parenthesis([lp | remaining_tokens])
    [_hd | brackets] = brackets
    expression = brackets |> Enum.reverse() |> tl() |> Enum.reverse()

    expression_list =
      ([%Token{type: :left_square_bracket}] ++
         expression ++ [%Token{type: :right_square_bracket}])
      |> Helper.get_list_values()
      |> Enum.map(fn tokens -> do_parse_expression(tokens, -1) end)
      |> Helper.filter_expression()

    name1 = do_parse_expression(name1, -1)
    name2 = do_parse_expression(%{name2 | :type => :name}, -1)
    name3 = do_parse_expression(name3, -1)

    function = {Expression.Function.new([name1, name2, name3], expression_list), []}

    do_parse_expression(function, remaining_tokens, -1)
  end

  defp do_parse_expression([%Token{type: :string, value: value}, %Token{type: :eof}], _precedence) do
    {Expression.String_.new(value), []}
  end

  defp do_parse_expression([%Token{type: :name, value: value}, %Token{type: :eof}], _precedence) do
    {Expression.Name.new(value), []}
  end

  defp do_parse_expression([%Token{type: :int, value: value}, %Token{type: :eof}], _precedence) do
    String.to_integer(value)
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :float, value: value}, %Token{type: :eof}], _precedence) do
    if(String.starts_with?(value, "."), do: "0" <> value, else: value)
    |> (&String.to_float(&1)).()
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :name, value: value}, %Token{type: :eof}], _precedence) do
    {Expression.Name.new(value), []}
  end

  defp do_parse_expression([%Token{type: :string, value: value}, %Token{type: :eof}], _precedence) do
    {Expression.String_.new(value), []}
  end

  defp do_parse_expression([%Token{type: :int, value: value}, %Token{type: :eof}], _precedence) do
    String.to_integer(value)
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :float, value: value}, %Token{type: :eof}], _precedence) do
    if(String.starts_with?(value, "."), do: "0" <> value, else: value)
    |> (&String.to_float(&1)).()
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression(%Token{type: :string, value: value}, _precedence) do
    {Expression.String_.new(value), []}
  end

  defp do_parse_expression(%Token{type: :name, value: value}, _precedence) do
    {Expression.Name.new(value), []}
  end

  defp do_parse_expression(%Token{type: :int, value: value}, _precedence) do
    String.to_integer(value)
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression(%Token{type: :float, value: value}, _precedence) do
    if(String.starts_with?(value, "."), do: "0" <> value, else: value)
    |> (&String.to_float(&1)).()
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :string, value: value}], _precedence) do
    {Expression.String_.new(value), []}
  end

  defp do_parse_expression([%Token{type: :name, value: value}], _precedence) do
    {Expression.Name.new(value), []}
  end

  defp do_parse_expression([%Token{type: :int, value: value}], _precedence) do
    String.to_integer(value)
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :float, value: value}], _precedence) do
    if(String.starts_with?(value, "."), do: "0" <> value, else: value)
    |> (&String.to_float(&1)).()
    |> (&{Expression.Number.new(&1), []}).()
  end

  defp do_parse_expression([%Token{type: :boolean, value: value}], _precedence)
       when value in ["true", "false"] do
    {Expression.Boolean.new(String.to_atom(value)), []}
  end

  defp do_parse_expression(
         [%Token{type: :boolean, value: value}, %Token{type: :eof}],
         _precedence
       )
       when value in ["true", "false"] do
    {Expression.Boolean.new(String.to_atom(value)), []}
  end

  defp do_parse_expression(
         [
           %Token{type: :subtract, value: "-"},
           %Token{type: number_type} = number | remaining_tokens
         ],
         precedence
       )
       when number_type in [:int, :float] do
    number =
      do_parse_expression(number, precedence)
      |> Helper.filter_expression()

    negated_int = {Expression.Negation.new(number), []}
    do_parse_expression(negated_int, remaining_tokens, precedence)
  end

  defp do_parse_expression([%Token{type: :string, value: string} | tl], precedence) do
    string_expression = {Expression.String_.new(string), []}
    do_parse_expression(string_expression, tl, precedence)
  end

  defp do_parse_expression(
         [
           %Token{type: quantifier} | remaining_tokens
         ],
         _precedence
       )
       when quantifier in [:some, :every] do
    satisfies_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :satisfies end)

    if is_nil(satisfies_index) do
      raise ArgumentError, message: "Expected satisfied after #{quantifier}"
    else
      iteration_contexts =
        get_iteration_contexts(Enum.slice(remaining_tokens, 0..(satisfies_index - 1)))

      return_tokens = Enum.slice(remaining_tokens, (satisfies_index + 1)..-1//1)

      condition = Helper.filter_expression(do_parse_expression_first(return_tokens, -1))

      {Expression.Quantified.new(quantifier, iteration_contexts, condition), []}
    end
  end

  defp do_parse_expression([%Token{type: :if} | remaining_tokens], precedence) do
    tokens_contains_then_and_else!(remaining_tokens)

    {condition_expression, remaining_tokens} =
      parse_expression_for_if_condition(remaining_tokens, precedence)

    {conitional_statement, remaining_tokens} =
      parse_expression_for_if_conditional_statement(remaining_tokens, precedence)

    else_condition = do_parse_expression(remaining_tokens, precedence)

    {Expression.If.new(
       Helper.filter_expression(condition_expression),
       Helper.filter_expression(conitional_statement),
       Helper.filter_expression(else_condition)
     ), []}
  end

  defp do_parse_expression(
         [
           left_token,
           %Token{type: type, value: value} | remaining_tokens
         ],
         precedence
       )
       when type in [
              :add,
              :subtract,
              :multiply,
              :divide,
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

  defp do_parse_expression(
         [
           %Token{type: :name} = name_token,
           %Token{type: :left_square_bracket, value: "["},
           %Token{type: type} = number,
           %Token{type: :right_square_bracket, value: "]"} | remaining_tokens
         ],
         _precedence
       )
       when type in [:int, :float] do
    filter_expression =
      number
      |> parse_expression()
      |> Helper.filter_expression()

    name_expresion =
      name_token
      |> parse_expression()
      |> Helper.filter_expression()

    expression = {Expression.FilterList.new(name_expresion, filter_expression), []}

    do_parse_expression(expression, remaining_tokens, -1)
    |> Helper.filter_expression()
  end

  defp do_parse_expression(
         [
           %Token{type: :name, value: lname},
           %Token{type: :dot},
           %Token{type: :name, value: name} | remaining_tokens
         ],
         min_prec
       ) do
    lname = String.to_atom(lname)
    name = String.to_atom(name)

    expression = {Expression.Access.new(name, lname), []}

    do_parse_expression(expression, remaining_tokens, min_prec)
  end

  defp do_parse_expression(
         [
           %Token{type: :name} = name_token,
           %Token{type: :left_square_bracket, value: "["} | remaining_tokens
         ],
         _precedence
       ) do
    right_square_bracket_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :right_square_bracket end)

    if is_nil(right_square_bracket_index) do
      raise ArgumentError, message: "Expected ] after ["
    else
      filter_tokens = Enum.slice(remaining_tokens, 0..(right_square_bracket_index - 1))
      filter_list_expression = parse_expression(filter_tokens)

      expression =
        {Expression.FilterList.new(
           Helper.filter_expression(do_parse_expression(name_token, -1)),
           Helper.filter_expression(filter_list_expression)
         ), []}

      remaining_tokens = Enum.slice(remaining_tokens, (right_square_bracket_index + 1)..-1//1)

      do_parse_expression(expression, remaining_tokens, -1)
    end
  end

  defp do_parse_expression({%Expression{}, []} = left_expression, [], _precedence) do
    left_expression
  end

  defp do_parse_expression(
         {%Expression{}, []} = left_expression,
         [
           %Token{type: type} = token_type | remaining_tokens
         ],
         precedence
       )
       when type in [
              :add,
              :subtract,
              :multiply,
              :divide,
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

  defp do_parse_expression(
         {%Expression{}, []} = left_expression,
         [%Token{type: :eof}],
         _precedence
       ) do
    left_expression
  end

  defp do_parse_expression(
         left_expression,
         [%Token{type: :dot}, %Token{type: :name, value: name} | remaining_tokens],
         min_prec
       ) do
    name = String.to_atom(name)
    left_expression = Helper.filter_expression(left_expression)
    expression = {Expression.Access.new(name, left_expression), []}

    do_parse_expression(expression, remaining_tokens, min_prec)
  end

  defp do_parse_expression(
         list_expression,
         [
           %Token{type: :left_square_bracket, value: "["},
           %Token{type: type} = number,
           %Token{type: :right_square_bracket, value: "]"} | remaining_tokens
         ],
         precedence
       )
       when type in [:int, :float] do
    filter_expression =
      do_parse_expression(number, precedence)
      |> Helper.filter_expression()

    expression =
      {Expression.FilterList.new(Helper.filter_expression(list_expression), filter_expression),
       []}

    do_parse_expression(expression, remaining_tokens, -1)
  end

  defp do_parse_expression(
         list_expression,
         [
           %Token{type: :left_square_bracket, value: "["} | remaining_tokens
         ],
         -1
       ) do
    right_square_bracket_index =
      Enum.find_index(remaining_tokens, fn token -> token.type == :right_square_bracket end)

    if is_nil(right_square_bracket_index) do
      raise ArgumentError, message: "Expected ] after ["
    else
      filter_tokens = Enum.slice(remaining_tokens, 0..(right_square_bracket_index - 1))

      filter_list_expression =
        parse_expression(filter_tokens)
        |> Helper.filter_expression()

      expression =
        {Expression.FilterList.new(
           Helper.filter_expression(list_expression),
           filter_list_expression
         ), []}

      remaining_tokens = Enum.slice(remaining_tokens, (right_square_bracket_index + 1)..-1//1)

      do_parse_expression(expression, remaining_tokens, -1)
    end
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
              :subtract,
              :add,
              :divide,
              :multiply,
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
    next_prec = precedence(type)

    if next_prec <= min_prec do
      {left_expression, [%Token{type: type, value: value} | remaining_tokens]}
    else
      {right_expression, remaining_tokens} =
        do_parse_expression(
          remaining_tokens,
          next_prec
        )

      {Expression.BinaryOp.new(
         type,
         Helper.filter_expression(left_expression),
         Helper.filter_expression(right_expression)
       ), remaining_tokens}
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

  def delimit_iteration_contexts([], new_list, []), do: new_list

  def delimit_iteration_contexts([], new_list, current_sub_list) do
    Enum.reverse([current_sub_list | new_list])
  end

  def delimit_iteration_contexts(
        [%Token{type: :right_square_bracket} = tok, %Token{type: :comma} | tl],
        new_list,
        current_sub_list
      ) do
    new_list = [current_sub_list ++ [tok] | new_list]
    delimit_iteration_contexts(tl, new_list, [])
  end

  def delimit_iteration_contexts(
        [%Token{type: :double_dot} = tok | tl],
        new_list,
        current_sub_list
      ) do
    comma_index = Enum.find_index(tl, fn token -> Map.get(token, :type) == :comma end)

    if is_nil(comma_index) do
      list = current_sub_list ++ [tok | tl]

      [list | new_list]
    else
      second_bound = Enum.slice(tl, 0..(comma_index - 1))
      new_tl = Enum.slice(tl, (comma_index + 1)..-1//1)

      delimit_iteration_contexts(
        new_tl,
        [current_sub_list ++ [tok] ++ second_bound | new_list],
        []
      )
    end
  end

  def delimit_iteration_contexts([hd | tl], new_list, current_sub_list) do
    current_sub_list = current_sub_list ++ [hd]
    delimit_iteration_contexts(tl, new_list, current_sub_list)
  end

  defp get_iteration_contexts(tokens) do
    tokens
    |> delimit_iteration_contexts([], [])
    |> Enum.map(fn [
                     %Token{type: :name, value: name},
                     %Token{type: :in} | remaining_tokens
                   ] ->
      parse_iteration_context(name, remaining_tokens)
    end)
  end

  def parse_iteration_context(name, remaining_tokens) do
    try do
      {Helper.filter_expression(do_parse_expression(%Token{type: :name, value: name}, -1)),
       Helper.filter_expression(do_parse_expression(remaining_tokens, -1))}
    rescue
      FunctionClauseError ->
        {Helper.filter_expression(do_parse_expression(%Token{type: :name, value: name}, -1)),
         Helper.filter_expression(parse_range(remaining_tokens))}
    end
  end

  defp parse_range(remaining_tokens) do
    double_dot_index =
      Enum.find_index(remaining_tokens, fn x -> Map.get(x, :type) == :double_dot end)

    if is_nil(double_dot_index) or double_dot_index == 0 do
      raise ArgumentError, message: "Invalid iteration context"
    else
      first_bound_tokens = Enum.slice(remaining_tokens, 0..(double_dot_index - 1))

      second_bound_tokens =
        Enum.slice(remaining_tokens, (double_dot_index + 1)..-1//1)

      {Expression.Range.new(
         Helper.filter_expression(parse_expression(first_bound_tokens)),
         Helper.filter_expression(parse_expression(second_bound_tokens))
       ), []}
    end
  end

  def precedence(:or), do: 0
  def precedence(:and), do: 0
  def precedence(:between), do: 0
  def precedence(:eq), do: 1
  def precedence(:neq), do: 1
  def precedence(:geq), do: 1
  def precedence(:leq), do: 1
  def precedence(:lt), do: 1
  def precedence(:gt), do: 1
  def precedence(:add), do: 2
  def precedence(:subtract), do: 2
  def precedence(:divide), do: 3
  def precedence(:multiply), do: 3
  def precedence(:exponentiation), do: 4
end
