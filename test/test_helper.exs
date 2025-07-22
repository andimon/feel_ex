ExUnit.start()

# Load support files
Code.require_file("support/test_fixtures.exs", __DIR__)

defmodule TestHelpers do
  import ExUnit.Assertions

  @doc """
  Helper function to evaluate FEEL expressions and assert the result type and value.
  Reduces boilerplate in tests.
  """
  def assert_feel_result(expression, expected_value, expected_type) do
    result = FeelEx.evaluate(expression)
    assert result.value == expected_value
    assert result.type == expected_type
    result
  end

  @doc """
  Helper function to evaluate FEEL expressions and assert only the result value.
  """
  def assert_feel_value(expression, expected_value) do
    result = FeelEx.evaluate(expression)
    assert result.value == expected_value
    result
  end

  @doc """
  Helper function to evaluate FEEL expressions and assert the result type.
  """
  def assert_feel_type(expression, expected_type) do
    result = FeelEx.evaluate(expression)
    assert result.type == expected_type
    result
  end

  @doc """
  Helper function to create a FeelEx.Value struct.
  """
  def feel_value(value, type) do
    %FeelEx.Value{value: value, type: type}
  end
end
