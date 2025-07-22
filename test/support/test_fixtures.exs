defmodule TestFixtures do
  @moduledoc """
  Common test data and fixtures for FEEL expression tests.
  """

  @doc """
  Sample dates for testing temporal expressions.
  """
  def sample_dates do
    %{
      date_2020_04_05: "2020-04-05",
      date_2020_04_06: "2020-04-06",
      date_2021_01_01: "2021-01-01",
      date_2021_12_31: "2021-12-31"
    }
  end

  @doc """
  Sample times for testing temporal expressions.
  """
  def sample_times do
    %{
      time_08_00_00: "08:00:00",
      time_23_59_59: "23:59:59",
      time_with_offset: "08:00:00+01:00"
    }
  end

  @doc """
  Sample numeric values for testing arithmetic operations.
  """
  def sample_numbers do
    %{
      positive_int: 42,
      negative_int: -17,
      zero: 0,
      positive_float: 3.14,
      negative_float: -2.718
    }
  end

  @doc """
  Sample string values for testing string operations.
  """
  def sample_strings do
    %{
      hello_world: "Hello World",
      empty_string: "",
      special_chars: "Hello, 世界! 123",
      whitespace: "  spaces  "
    }
  end

  @doc """
  Sample context data for testing context operations.
  """
  def sample_context do
    %{
      person: %{name: "John", age: 30, active: true},
      numbers: [1, 2, 3, 4, 5],
      mixed_list: [1, "two", true, nil]
    }
  end
end
