defmodule FeelEx.Lexer.States do
  require Logger

  def start_state do
    Logger.info("Setting start state")
    :state_0
  end

  def bad_state do
    Logger.info("Setting bad state")
    :state_bad
  end

  def error_state do
    Logger.info("Setting error state")
    :state_error
  end

  def states do
    Logger.info("Setting states")

    [
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
  end

  def final_states do
    Logger.info("Setting final states")

    [
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
  end

  def states_excluding_error_state do
    Logger.info("Setting states excluding error state")
    states() -- [error_state()]
  end

  def transition_table do
    Logger.info("Setting transition table")

    %{
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
  end
end
