defmodule FeelEx.Helper do
  @moduledoc false
  alias FeelEx.Value
  alias FeelEx.Token

  def transform_context(context) when is_map(context) do
    Enum.map(context, fn {k, v} ->
      {k, do_transform_context_value(v)}
    end)
    |> Enum.into(%{})
  end

  defp do_transform_context_value(v) when is_map(v) do
    transform_context(v)
  end

  defp do_transform_context_value(v) do
    Value.new(v)
  end

  def offset_to_duration("+" <> time) do
    hours = String.to_integer(String.slice(time, 0, 2))
    minutes = String.to_integer(String.slice(time, 3, 2))
    %Duration{hour: hours, minute: minutes}
  end

  def offset_to_duration("-" <> time) do
    hours = String.to_integer(String.slice(time, 0, 2))
    minutes = String.to_integer(String.slice(time, 3, 2))
    %Duration{hour: -hours, minute: -minutes}
  end

  def normalise(days, hours, minutes, seconds) do
    days_in_hours = div(hours, 24)
    hours = rem(hours, 24)
    days_in_minutes = div(minutes, 1440)
    minutes = rem(minutes, 1440)
    days_in_seconds = div(seconds, 86400)
    seconds = rem(seconds, 86400)
    hours_in_minutes = div(minutes, 60)
    minutes = rem(minutes, 60)
    hours_in_seconds = div(seconds, 3600)
    seconds = rem(seconds, 3600)
    minutes_in_seconds = div(seconds, 60)
    seconds = rem(seconds, 60)

    {days + days_in_hours + days_in_minutes + days_in_seconds,
     hours + hours_in_minutes +
       hours_in_seconds, minutes + minutes_in_seconds, seconds}
  end

  def normalise(years, months) do
    years_in_months = div(months, 12)
    months = rem(months, 12)

    {years + years_in_months, months}
  end

  def duration_from_seconds(diff_seconds) when is_integer(diff_seconds) do
    hours = div(diff_seconds, 3600)
    minutes = div(rem(diff_seconds, 3600), 60)
    seconds = rem(diff_seconds, 60)
    %Duration{hour: hours, minute: minutes, second: seconds}
  end

  def filter_expression(exp) do
    case exp do
      {exp, _tokens} -> exp
      exp -> exp
    end
  end

  def get_parenthesis([%Token{type: :left_parenthesis} = left_parenthesis | remaining_tokens]) do
    accumulator = {1, left_parenthesis, [left_parenthesis], remaining_tokens}

    result =
      Enum.reduce_while(remaining_tokens, accumulator, fn token, state ->
        case state do
          {0, _, _, _} ->
            {:halt, state}

          {left_parenthesis_count, left_parenthesis_token, context_tokens, [hd | tl]} ->
            cond do
              hd.type == :left_parenthesis ->
                {:cont, {left_parenthesis_count + 1, hd, [hd | context_tokens], tl}}

              token.type == :right_parenthesis ->
                {:cont,
                 {left_parenthesis_count - 1, left_parenthesis_token, [hd | context_tokens], tl}}

              true ->
                {:cont,
                 {left_parenthesis_count, left_parenthesis_token, [hd | context_tokens], tl}}
            end
        end
      end)

    case result do
      {0, _, context_tokens, remaining_tokens} ->
        context_tokens =
          Enum.reverse(context_tokens)

        {context_tokens, remaining_tokens}

      {_, %FeelEx.Token{type: :opening_brace, value: "[", line_number: line_number}, _} ->
        raise ArgumentError, message: "Expected ] after [ in line #{line_number}"
    end
  end

  def get_list([%Token{type: :left_square_bracket} = left_square_bracket | remaining_tokens]) do
    accumulator = {1, left_square_bracket, [left_square_bracket], remaining_tokens}

    result =
      Enum.reduce_while(remaining_tokens, accumulator, fn token, state ->
        case state do
          {0, _, _, _} ->
            {:halt, state}

          {left_square_bracket_count, left_square_bracket_token, context_tokens, [hd | tl]} ->
            cond do
              hd.type == :left_square_bracket ->
                {:cont, {left_square_bracket_count + 1, hd, [hd | context_tokens], tl}}

              token.type == :right_square_bracket ->
                {:cont,
                 {left_square_bracket_count - 1, left_square_bracket_token, [hd | context_tokens],
                  tl}}

              true ->
                {:cont,
                 {left_square_bracket_count, left_square_bracket_token, [hd | context_tokens], tl}}
            end
        end
      end)

    case result do
      {0, _, context_tokens, remaining_tokens} ->
        context_tokens =
          Enum.reverse(context_tokens)

        {context_tokens, remaining_tokens}

      {_, %FeelEx.Token{type: :opening_brace, value: "[", line_number: line_number}, _} ->
        raise ArgumentError, message: "Expected ] after [ in line #{line_number}"
    end
  end

  def get_context([%Token{type: :opening_brace} = opening_brace | remaining_tokens]) do
    accumulator = {1, opening_brace, [opening_brace], remaining_tokens}

    result =
      Enum.reduce_while(remaining_tokens, accumulator, fn token, state ->
        case state do
          {0, _, _, _} ->
            {:halt, state}

          {opening_brace_count, opening_brace_token, context_tokens, [hd | tl]} ->
            cond do
              hd.type == :opening_brace ->
                {:cont, {opening_brace_count + 1, hd, [hd | context_tokens], tl}}

              token.type == :closing_brace ->
                {:cont, {opening_brace_count - 1, opening_brace_token, [hd | context_tokens], tl}}

              true ->
                {:cont, {opening_brace_count, opening_brace_token, [hd | context_tokens], tl}}
            end
        end
      end)

    case result do
      {0, _, context_tokens, remaining_tokens} ->
        context_tokens =
          Enum.reverse(context_tokens)

        {context_tokens, remaining_tokens}

      {_, %FeelEx.Token{type: :opening_brace, value: "{", line_number: line_number}, _} ->
        raise ArgumentError, message: "Expected } after { in line #{line_number}"
    end
  end

  def get_context(tokens), do: {[], tokens}

  def break_key_values(tokens) do
    Enum.reverse(do_break_key_values(tokens, []))
  end

  defp do_break_key_values([], new_list), do: new_list
  defp do_break_key_values([%Token{type: :closing_brace}], new_list), do: new_list

  defp do_break_key_values([%Token{type: type} | tl], new_list)
       when type in [:comma, :opening_brace],
       do: do_break_key_values(tl, new_list)

  defp do_break_key_values(
         [
           %Token{type: type} = type_token,
           %Token{type: :colon} = colon,
           %Token{type: :opening_brace} = opening_brace | tl
         ],
         new_list
       )
       when type in [:name, :string] do
    {context, remaining_tokens} = get_context([opening_brace | tl])
    new_list = [[type_token, colon | context] | new_list]

    do_break_key_values(remaining_tokens, new_list)
  end

  defp do_break_key_values(
         [
           %Token{type: type} = type_token,
           %Token{type: :colon} = colon,
           %Token{type: :left_square_bracket} = left_square_bracket | tl
         ],
         new_list
       )
       when type in [:name, :string] do
    {list, remaining_tokens} =
      get_list([left_square_bracket | tl])

    new_list =
      [[type_token, colon | list] | new_list]

    do_break_key_values(remaining_tokens, new_list)
  end

  defp do_break_key_values(
         [
           %Token{type: type} = name_token,
           %Token{type: :colon} = colon
           | tl
         ],
         new_list
       )
       when type in [:name, :string] do
    comma_index = Enum.find_index(tl, fn token -> Map.get(token, :type) == :comma end)

    if is_nil(comma_index) do
      [%Token{type: :closing_brace} | tl] = Enum.reverse(tl)

      [[name_token, colon | Enum.reverse(tl)] | new_list]
    else
      value_tokens = Enum.slice(tl, 0..(comma_index - 1))
      remaining_tokens = Enum.slice(tl, (comma_index + 1)..-1//1)

      do_break_key_values(
        remaining_tokens,
        [[name_token, colon | value_tokens] | new_list]
      )
    end
  end

  def get_list_values([%Token{type: :left_square_bracket} | list]) do
    list = Enum.reverse(tl(Enum.reverse(list)))

    Enum.reverse(do_get_list_values(list, []))
  end

  def get_list_values(list) do
    Enum.reverse(do_get_list_values(list, []))
  end

  defp do_get_list_values([], new_list), do: new_list

  defp do_get_list_values([%Token{type: :comma} | tl], new_list) do
    do_get_list_values(tl, new_list)
  end

  defp do_get_list_values([%Token{type: :opening_brace} | _] = list, new_list) do
    {context_tokens, remaining_tokens} = get_context(list)
    do_get_list_values(remaining_tokens, [context_tokens | new_list])
  end

  defp do_get_list_values(
         [%Token{type: :name} = name, %Token{type: :left_parenthesis} | _] = list,
         new_list
       ) do
    parenthesis = tl(list)
    {context_tokens, remaining_tokens} = get_parenthesis(parenthesis)
    do_get_list_values(remaining_tokens, [[name | context_tokens] | new_list])
  end

  defp do_get_list_values([%Token{type: :left_parenthesis} | _] = list, new_list) do
    {context_tokens, remaining_tokens} = get_parenthesis(list)
    do_get_list_values(remaining_tokens, [context_tokens | new_list])
  end

  defp do_get_list_values([%Token{type: :left_square_bracket} | _] = list, new_list) do
    {context_tokens, remaining_tokens} = get_list(list)
    do_get_list_values(remaining_tokens, [context_tokens | new_list])
  end

  defp do_get_list_values([%Token{type: type} | _] = list, new_list)
       when type != :opening_brace do
    comma_index = Enum.find_index(list, fn token -> Map.get(token, :type) == :comma end)

    if is_nil(comma_index) do
      [list | new_list]
    else
      value_tokens = Enum.slice(list, 0..(comma_index - 1))
      remaining_tokens = Enum.slice(list, (comma_index + 1)..-1//1)

      do_get_list_values(
        remaining_tokens,
        [value_tokens | new_list]
      )
    end
  end

  def get_offset(offset_or_zone_id) when is_binary(offset_or_zone_id) do
    offset_regex = ~r/^(?:(?:[+-](?:1[0-4]|0[1-9]):[0-5][0-9])|[+-]00:00)$/

    if Regex.match?(offset_regex, offset_or_zone_id) do
      offset_or_zone_id
    else
      get_offset_from_zone_id(offset_or_zone_id)
    end
  end

  defp get_offset_from_zone_id(zone_id) when is_binary(zone_id) do
    {:ok, datetime} = DateTime.now(zone_id, Tzdata.TimeZoneDatabase)

    offset_seconds = datetime.utc_offset

    hours = div(offset_seconds, 3600)
    minutes = div(rem(offset_seconds, 3600), 60)

    "#{sign(hours)}#{format_hours_and_minutes(abs(hours))}:#{format_hours_and_minutes(minutes)}"
  end

  defp sign(n) when n < 0, do: "-"
  defp sign(_n), do: "+"

  defp format_hours_and_minutes(minutes) do
    if minutes < 10, do: "0#{abs(minutes)}", else: "#{abs(minutes)}"
  end

  def gen_list_from_range(first_bound, second_bound)
      when is_number(first_bound) and is_number(second_bound) do
    Enum.reverse(do_gen_list_from_range(first_bound, second_bound, []))
  end

  # if first bound is equal to second bound
  def do_gen_list_from_range(limit, limit, []), do: [limit]

  # include first bound in list when is empty
  def do_gen_list_from_range(first_bound, second_bound, []) do
    do_gen_list_from_range(first_bound, second_bound, [first_bound])
  end

  def do_gen_list_from_range(first_bound, second_bound, [hd | _] = list)
      when first_bound < second_bound and hd + 1 > second_bound do
    list
  end

  def do_gen_list_from_range(first_bound, second_bound, [hd | _] = list)
      when first_bound < second_bound and hd + 1 <= second_bound do
    do_gen_list_from_range(first_bound, second_bound, [hd + 1 | list])
  end

  def do_gen_list_from_range(first_bound, second_bound, [hd | _] = list)
      when first_bound > second_bound and hd - 1 < second_bound do
    list
  end

  def do_gen_list_from_range(first_bound, second_bound, [hd | _] = list)
      when first_bound > second_bound and hd - 1 >= second_bound do
    do_gen_list_from_range(first_bound, second_bound, [hd - 1 | list])
  end

  def cartesian([]), do: []

  def cartesian(list) when is_list(list) do
    cartesian(list, [])
  end

  def cartesian([list], []) when is_list(list) do
    Enum.map(list, fn element -> [element] end)
  end

  def cartesian([list | tl], []) when is_list(list) do
    current_list = Enum.map(list, fn element -> [element] end)
    cartesian(tl, current_list)
  end

  def cartesian([list | tl], current_list) when is_list(list) do
    new_list =
      Enum.reduce(current_list, [], fn element, acc ->
        acc ++
          Enum.map(list, fn element_to_append ->
            [element_to_append | element]
          end)
      end)

    cartesian(tl, new_list)
  end

  def cartesian([], current_list) do
    Enum.map(current_list, fn list ->
      Enum.reverse(list)
    end)
  end

  def filter_out_comments(list) when is_list(list) do
    Enum.reject(list, fn x -> Map.get(x, :type) == :comment end)
  end
end
