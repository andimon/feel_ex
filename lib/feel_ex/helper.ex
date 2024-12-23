defmodule FeelEx.Helper do
  @doc """
    Checks if the keys of the inputted map are all atoms or are all binaries.
    Also checks that the keys of nested maps have the same type.
  """
  def input_map_checker(input_map) when is_map(input_map) do
    case Enum.at(input_map, 0) do
      {key, _val} when is_atom(key) ->
        handle_result(are_all_keys_atoms?(input_map), input_map)

      {key, _val} when is_binary(key) ->
        handle_result(are_all_keys_binaries?(input_map), input_map)
        true

      nil ->
        map_valid_message()
    end
  end

  def filter_out_comments(list) when is_list(list) do
    Enum.reject(list, fn x -> Map.get(x, :type) == :comment end)
  end

  defp are_all_keys_atoms?(map) when is_map(map) do
    Enum.all?(map, fn {key, value} ->
      is_atom(key) and
        (is_map(value) == false or are_all_keys_atoms?(value))
    end)
  end

  defp are_all_keys_binaries?(map) when is_map(map) do
    Enum.all?(map, fn {key, value} ->
      is_binary(key) and
        (is_map(value) == false or are_all_keys_binaries?(value))
    end)
  end

  defp handle_result(true, _map), do: map_valid_message()
  defp handle_result(false, map), do: map_error_key_mismatch_message(map)

  defp map_valid_message(), do: {:ok, "Map is valid"}

  defp map_error_key_mismatch_message(map) when is_map(map),
    do:
      {:error,
       "Map #{inspect(map)} is invalid. Please ensure that all keys are atoms or that all keys are binaries."}
end
