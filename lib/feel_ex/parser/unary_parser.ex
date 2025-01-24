defmodule FeelEx.UnaryParser do
  require Logger
  alias FeelEx.{Token, Parser, Helper, Expression}

  def parse_unary_expression(tokens) do
    tokens =
      if List.last(tokens).type == :eof,
        do: List.delete_at(tokens, -1),
        else: tokens

    [hd | tl] =
      Helper.get_list_values(tokens)
      |> Enum.map(fn x -> do_parse_unary_expression(x) end)

    build_or_tree(hd, tl)
  end

  def do_parse_unary_expression([%Token{type: type} | _] = tokens)
      when type in [
             :geq,
             :leq,
             :gt,
             :lt
           ] do
    IO.inspect(tokens)

    Parser.parse_expression([%Token{type: :name, value: "?"} | tokens])
  end

  def do_parse_unary_expression([%Token{type: type} | _] = tokens)
      when type in [
             :left_square_bracket,
             :left_parenthesis
           ] do
    last_item =
      List.last(tokens)

    compare_token =
      if type == :left_square_bracket,
        do: %Token{value: ">=", type: :geq},
        else: %Token{value: ">", type: :gt}

    tokens =
      tokens
      |> tl()
      |> List.delete_at(-1)

    dd_index =
      Enum.find_index(tokens, fn value -> value.type == :double_dot end)

    cond do
      last_item.type == :right_parenthesis and not is_nil(dd_index) ->
        left_tokens =
          [%Token{type: :name, value: "?"}, compare_token] ++
            Enum.slice(tokens, 0..(dd_index - 1))

        right_tokens =
          [%Token{type: :name, value: "?"}, %Token{value: "<", type: :lt}] ++
            Enum.slice(tokens, (dd_index + 1)..-1//1)

        Parser.parse_expression(left_tokens ++ [%Token{type: :and, value: "and"}] ++ right_tokens)

      last_item.type == :right_square_bracket and not is_nil(dd_index) ->
        left_tokens =
          [%Token{type: :name, value: "?"}, compare_token] ++
            Enum.slice(tokens, 0..(dd_index - 1))

        right_tokens =
          [%Token{type: :name, value: "?"}, %Token{value: "<=", type: :leq}] ++
            Enum.slice(tokens, (dd_index + 1)..-1//1)

        tokens =
          left_tokens ++ [%Token{type: :and, value: "and"}] ++ right_tokens

        Parser.parse_expression(tokens)

      true ->
        raise ArgumentError, message: "Expected ],) to close interval, or .. to seperate interval"
    end
  end

  def do_parse_unary_expression([
        %Token{type: :name, value: "not"} | [%Token{type: :left_parenthesis} | tokens]
      ]) do
    tokens =
      if List.last(tokens).type == :right_parenthesis,
        do: List.delete_at(tokens, -1) |> IO.inspect(),
        else:
          raise(ArgumentError, message: "Expected ) after ( in not unary expression")
          |> IO.inspect()

    [hd | tl] =
      Helper.get_list_values(tokens)
      |> Enum.map(fn x ->
        Expression.new(:function, "negate", [do_parse_unary_expression(x)])
      end)

    build_and_tree(hd, tl)
  end

  def do_parse_unary_expression(tokens) do
    contains_question_mark? =
      Enum.any?(tokens, fn token -> token.value == "?" and token.type == "name" end)

    if contains_question_mark? do
      Parser.parse_expression(tokens)
    else
      Parser.parse_expression([
        %Token{type: :name, value: "?"},
        %Token{type: :eq, value: "="} | tokens
      ])
    end
  end

  defp build_or_tree(hd, []), do: hd

  defp build_or_tree(hd, tl) do
    build_or_tree(Expression.new(:or, hd, hd(tl)), tl(tl))
  end

  defp build_and_tree(hd, []), do: hd

  defp build_and_tree(hd, tl) do
    build_and_tree(Expression.new(:and, hd, hd(tl)), tl(tl))
  end
end
