defmodule FeelEx do
  @moduledoc """
  FeelEx. An implementation of the (Friendly Enough Expression Language) in Elixir.
  """
  require Logger
  alias FeelEx.{Helper, Lexer}

  @doc """
  """
  def execute(input_map, feel_expression) when is_map(input_map) and is_binary(feel_expression) do
    with {{:ok, "Map is valid"}, :input_map} <- {Helper.input_map_checker(input_map), :input_map},
         {{:ok, tokens}, :tokens} <- {Lexer.tokens(feel_expression), :tokens} do
      tokens
    else
      {err, :input_map} ->
        Logger.error("Please check the given input map #{inspect(input_map)}")
        err

      {err, :tokens} ->
        err
    end
  end

  @doc """
  """
  def execute(feel_expression) when is_binary(feel_expression) do
    :world
  end
end
