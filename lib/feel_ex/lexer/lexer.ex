defmodule FeelEx.Lexer do
  @moduledoc """
  Parse a program string into tokens.
  """
  alias FeelEx.Token

  @start_state :state_0
  @bad_state :state_bad
  @error_state :state_error
  @states [
    :state_0,
    :state_1,
    :state_2,
    :state_3,
    :state_4,
    :state_5,
    :state_6,
    :state_7,
    :state_8,
    :state_9,
    :state_10,
    :state_11,
    :state_12,
    :state_13,
    :state_14,
    :state_15,
    :state_16,
    :state_17,
    :state_18,
    :state_19,
    :state_20,
    :state_21,
    :state_22,
    :state_23
  ]
  @final_states [
    :state_1,
    :state_2,
    :state_3,
    :state_4,
    :state_6,
    :state_9,
    :state_10,
    :state_11,
    :state_12,
    :state_14,
    :state_15,
    :state_16,
    :state_17,
    :state_18,
    :state_19,
    :state_20
  ]
  @states_excluding_error_state @states -- [@error_state]
  @transition_table %{
    dot: [
      state_0: :state_3,
      state_3: :state_20,
      state_1: :state_21,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    digit: [
      state_0: :state_1,
      state_1: :state_1,
      state_2: :state_2,
      state_3: :state_2,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_21: :state_2,
      state_22: :state_13,
      state_23: :state_13
    ],
    back_slash: [
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_22,
      state_22: :state_22
    ],
    forward_slash: [
      state_0: :state_4,
      state_4: :state_5,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_9,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    line_feed: [
      state_5: :state_6,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    asterisk: [
      state_0: :state_12,
      state_4: :state_7,
      state_5: :state_5,
      state_7: :state_8,
      state_8: :state_8,
      state_12: :state_19,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    question_mark: [
      state_0: :state_10,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_10: :state_11,
      state_11: :state_11,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    capital_a_to_z: [
      state_5: :state_5,
      state_8: :state_7,
      state_10: :state_11,
      state_11: :state_11,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    underscore: [
      state_5: :state_5,
      state_7: :state_7,
      state_11: :state_11,
      state_22: :state_13,
      state_23: :state_13
    ],
    small_a_to_z: [
      state_0: :state_10,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_10: :state_11,
      state_11: :state_11,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    space: [
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    plus: [
      state_0: :state_12,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    at: [
      state_0: :state_12,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    opening_brace: [
      state_0: :state_12,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    colon: [
      state_0: :state_12,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    closing_brace: [
      state_0: :state_12,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    minus: [
      state_0: :state_12,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    quote: [
      state_0: :state_13,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_14,
      state_22: :state_23
    ],
    less_than: [
      state_0: :state_15,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    greater_than: [
      state_0: :state_15,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    exclamation: [
      state_0: :state_15,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    equal: [
      state_0: :state_17,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_15: :state_16,
      state_22: :state_13,
      state_23: :state_13
    ],
    left_parenthesis: [
      state_0: :state_18,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    right_parenthesis: [
      state_0: :state_18,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    left_square_bracket: [
      state_0: :state_18,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    right_square_bracket: [
      state_0: :state_18,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ],
    comma: [
      state_0: :state_18,
      state_5: :state_5,
      state_7: :state_7,
      state_8: :state_7,
      state_13: :state_13,
      state_22: :state_13,
      state_23: :state_13
    ]
  }

  @spec tokens(String.t()) :: [Token.t()]
  def tokens(program) when is_binary(program) do
    current_token = next_token(program, 0, 1)
    do_get_tokens(program, current_token)
  end

  defp next_token(program, current_index, current_line_number) do
    program_length = String.length(program)

    {current_index, current_line_number} =
      move_current_index_ignoring_whitespace(program, current_index, current_line_number)

    if current_index == program_length do
      {:eof, current_line_number}
    else
      calculate_lexeme(
        @start_state,
        program,
        current_index,
        "",
        @bad_state,
        0,
        program_length,
        current_line_number
      )
      |> rollback_to_final_state()
    end
  end

  defp move_current_index_ignoring_whitespace(program, current_index, current_line_number) do
    current_char = String.at(program, current_index)

    if current_index < String.length(program) and is_char_whitespace?(current_char) do
      current_line_number =
        increment_line_number_with_line_feed(current_char, current_line_number)

      move_current_index_ignoring_whitespace(program, current_index + 1, current_line_number)
    else
      {current_index, current_line_number}
    end
  end

  defp calculate_lexeme(
         current_state,
         _program,
         current_index,
         lexeme,
         current_states,
         lexeme_length,
         program_length,
         current_line_number
       )
       when current_index == program_length do
    %{
      current_state: current_state,
      current_index: current_index,
      lexeme_length: lexeme_length,
      lexeme: lexeme,
      current_states: current_states,
      current_line_number: current_line_number
    }
  end

  defp calculate_lexeme(
         current_state,
         program,
         current_index,
         lexeme,
         current_states,
         lexeme_length,
         program_length,
         current_line_number
       )
       when current_state != @error_state do
    current_symbol = String.at(program, current_index)
    lexeme = lexeme <> current_symbol
    current_states = if current_state in @final_states, do: [], else: current_states
    current_states = [current_state | current_states]
    current_state = transition_function(current_symbol, current_state)
    current_index = current_index + 1
    lexeme_length = lexeme_length + 1

    current_line_number =
      increment_line_number_with_line_feed(current_symbol, current_line_number)

    calculate_lexeme(
      current_state,
      program,
      current_index,
      lexeme,
      current_states,
      lexeme_length,
      program_length,
      current_line_number
    )
  end

  defp calculate_lexeme(
         @error_state,
         _program,
         current_index,
         lexeme,
         current_states,
         lexeme_length,
         _program_length,
         current_line_number
       ) do
    %{
      current_state: @error_state,
      current_index: current_index,
      lexeme_length: lexeme_length,
      lexeme: lexeme,
      current_states: current_states,
      current_line_number: current_line_number
    }
  end

  defp transition_function(symbol, state) when state in @states_excluding_error_state do
    get_transition_type(symbol)
    |> access_elem_from_table(state)
  end

  defp access_elem_from_table(transition_type, state) do
    next_state =
      Map.get(@transition_table, transition_type)
      |> Keyword.get(state)

    if is_nil(next_state), do: @error_state, else: next_state
  end

  defp is_char_whitespace?(<<10::utf8>>), do: true
  defp is_char_whitespace?(<<32::utf8>>), do: true
  defp is_char_whitespace?(_), do: false

  defp do_get_tokens(_program, {:eof, line_number}), do: [Token.new({:eof, line_number})]

  defp do_get_tokens(
         program,
         %{
           lexeme: lexeme,
           current_line_number: current_line_number,
           current_index: current_index,
           lexeme_length: lexeme_length
         } = current_token
       ) do
    {cur_token, next_token} =
      if lexeme == "time" do
        case String.slice(program, current_index, 7) do
          " offset" ->
            current_token =
              Map.merge(current_token, %{
                lexeme: lexeme <> " offset",
                current_index: current_index + 7,
                lexeme_length: lexeme_length + 7
              })

            {Token.new(Map.delete(current_token,:lexeme_length)),
             next_token(program, current_index + 7, current_line_number)}

          _ ->
            {Token.new(current_token), next_token(program, current_index, current_line_number)}
        end
      else
        {Token.new(Map.delete(current_token,:lexeme_length)), next_token(program, current_index, current_line_number)}
      end

    [cur_token | do_get_tokens(program, next_token)]
  end

  defp rollback_to_final_state(%{
         current_state: current_state,
         lexeme: lexeme,
         current_line_number: current_line_number
       })
       when current_state == @bad_state do
    raise ArgumentError,
      message: "Unrecognised lexeme #{inspect(lexeme)} in line #{inspect(current_line_number)}"
  end

  defp rollback_to_final_state(%{
         current_state: current_state,
         current_index: current_index,
         lexeme: lexeme,
         lexeme_length: lexeme_length,
         current_line_number: current_line_number
       })
       when current_state in @final_states do
    %{
      current_state: current_state,
      current_index: current_index,
      lexeme: lexeme,
      lexeme_length: lexeme_length,
      current_line_number: current_line_number
    }
  end

  defp rollback_to_final_state(%{
         lexeme: lexeme,
         current_states: [],
         current_line_number: _current_line_number
       }) do
    raise ArgumentError, message: "Invalid lexeme #{inspect(lexeme)}"
  end

  defp rollback_to_final_state(%{
         current_index: current_index,
         lexeme: lexeme,
         current_states: current_states,
         lexeme_length: lexeme_length,
         current_line_number: current_line_number
       }) do
    rollback_to_final_state(%{
      current_state: hd(current_states),
      current_index: current_index - 1,
      lexeme: String.slice(lexeme, 0..-2//1),
      current_states: tl(current_states),
      lexeme_length: lexeme_length,
      current_line_number: current_line_number
    })
  end

  defp increment_line_number_with_line_feed("\n", line_number) when is_integer(line_number) do
    line_number + 1
  end

  defp increment_line_number_with_line_feed(_, line_number) when is_integer(line_number) do
    line_number
  end

  defp get_transition_type(<<x::utf8>>) do
    cond do
      x == 10 -> :line_feed
      x == 32 -> :space
      x == 33 -> :exclamation
      x == 34 -> :quote
      x == 40 -> :left_parenthesis
      x == 41 -> :right_parenthesis
      x == 42 -> :asterisk
      x == 43 -> :plus
      x == 44 -> :comma
      x == 45 -> :minus
      x == 46 -> :dot
      x == 47 -> :forward_slash
      x in 48..57 -> :digit
      x == 58 -> :colon
      x == 60 -> :less_than
      x == 61 -> :equal
      x == 62 -> :greater_than
      x == 63 -> :question_mark
      x == 64 -> :at
      x in 65..90 -> :capital_a_to_z
      x == 91 -> :left_square_bracket
      x == 92 -> :back_slash
      x == 93 -> :right_square_bracket
      x == 95 -> :underscore
      x in 97..122 -> :small_a_to_z
      x == 123 -> :opening_brace
      x == 125 -> :closing_brace
    end
  end
end
