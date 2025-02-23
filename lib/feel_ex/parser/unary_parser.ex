defmodule FeelEx.UnaryParser do
  require Logger
  alias FeelEx.{Token, Parser, Helper, Expression}

  def parse_unary_expression(tokens) do
    tokens =
      if List.last(tokens).type == :eof,
        do: List.delete_at(tokens, -1),
        else: tokens

    [hd | tl] =
      cond do
        hd(tokens).type == :left_square_bracket or hd(tokens).type == :left_parenthesis ->
          [tokens]

        true ->
          Helper.get_list_values(tokens)
      end
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
      cond do
        type == :left_square_bracket -> %Token{value: ">=", type: :geq}
        type == :left_parenthesis -> %Token{value: ">", type: :gt}
      end

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

        Parser.parse_expression(left_tokens ++ [%Token{type: :and, value: "and"}] ++ right_tokens)

      true ->
        raise ArgumentError, message: "Expected ],) to close interval, or .. to seperate interval"
    end
  end

  def do_parse_unary_expression([
        %Token{type: :name, value: "not"} | [%Token{type: :left_parenthesis} | tokens]
      ]) do
    tokens =
      if List.last(tokens).type == :right_parenthesis,
        do: List.delete_at(tokens, -1),
        else: raise(ArgumentError, message: "Expected ) after ( in not unary expression")

    [hd | tl] =
      Helper.get_list_values(tokens)
      |> Enum.map(fn x ->
        Expression.Function.new(Expression.Name.new("not"), [do_parse_unary_expression(x)])
      end)

    build_and_tree(hd, tl)
  end

  def do_parse_unary_expression(tokens) do
    contains_question_mark? =
      Enum.any?(tokens, fn token -> token.value == "?" and token.type == :name end)

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
    build_or_tree(
      Expression.BinaryOp.new(
        :or,
        Helper.filter_expression(hd),
        Helper.filter_expression(hd(tl))
      ),
      tl(tl)
    )
  end

  defp build_and_tree(hd, []), do: hd

  defp build_and_tree(hd, tl) do
    build_and_tree(
      Expression.BinaryOp.new(
        :and,
        Helper.filter_expression(hd),
        Helper.filter_expression(hd(tl))
      ),
      tl(tl)
    )
  end
end
