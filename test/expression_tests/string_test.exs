defmodule FeelEx.StringTest do
  use ExUnit.Case
  import TestHelpers

  doctest FeelEx

  describe "string literals" do
    test "creates string from literal" do
      assert_feel_result("\"Aw dinja\"", "Aw dinja", :string)
    end

    test "handles empty string" do
      assert_feel_result("\"\"", "", :string)
    end
  end

  describe "string concatenation" do
    test "concatenates two strings" do
      assert_feel_result("\"Aw\"+\" Dinja\"", "Aw Dinja", :string)
    end

    test "concatenates multiple strings" do
      assert_feel_result("\"Hello\" + \", \" + \"World!\"", "Hello, World!", :string)
    end
  end

  describe "string() function - type conversion" do
    test "converts numbers to strings" do
      assert_feel_result("string(12)", "12", :string)
      assert_feel_result("string(.22)", "0.22", :string)
      assert_feel_result("string(-2.22)", "-2.22", :string)
      assert_feel_result("string(-.22)", "-0.22", :string)
    end

    test "converts booleans to strings" do
      assert_feel_result("string(true)", "true", :string)
      assert_feel_result("string(false)", "false", :string)
    end

    test "returns string unchanged" do
      assert_feel_result("string(\"Aw Dinja\")", "Aw Dinja", :string)
    end
  end

  describe "string() function - temporal types" do
    test "converts dates to strings" do
      assert_feel_result("string(@\"2024-01-01\")", "2024-01-01", :string)
      assert_feel_result("string(date(\"2024-01-01\"))", "2024-01-01", :string)
    end

    test "converts times to strings" do
      assert_feel_result("string(time(\"11:45:30\"))", "11:45:30", :string)
      assert_feel_result("string(time(\"11:45\"))", "11:45:00", :string)
      assert_feel_result("string(time(\"11:45:30+02:00\"))", "11:45:30+02:00", :string)

      assert_feel_result(
        "string(time(\"10:31:10@Europe/Paris\"))",
        "10:31:10@Europe/Paris",
        :string
      )

      assert_feel_result("string(@\"11:45:30\")", "11:45:30", :string)
      assert_feel_result("string(@\"13:30\")", "13:30:00", :string)
      assert_feel_result("string(@\"10:45:30+02:00\")", "10:45:30+02:00", :string)
      assert_feel_result("string(@\"10:31:10@Europe/Paris\")", "10:31:10@Europe/Paris", :string)
    end

    test "converts date-times to strings" do
      assert_feel_result(
        "string(date and time(\"2015-09-18T10:31:10\"))",
        "2015-09-18T10:31:10",
        :string
      )

      assert_feel_result(
        "string(date and time(\"2015-09-18T10:31:10+01:00\"))",
        "2015-09-18T10:31:10+01:00",
        :string
      )

      assert_feel_result(
        "string(date and time(\"2015-09-18T10:31:10@Europe/Paris\"))",
        "2015-09-18T10:31:10@Europe/Paris",
        :string
      )

      assert_feel_result("string(@\"2015-09-18T10:31:10\")", "2015-09-18T10:31:10", :string)

      assert_feel_result(
        "string(@\"2015-09-18T10:31:10+01:00\")",
        "2015-09-18T10:31:10+01:00",
        :string
      )

      assert_feel_result(
        "string(@\"2015-09-18T10:31:10@Europe/Paris\")",
        "2015-09-18T10:31:10@Europe/Paris",
        :string
      )
    end

    test "converts days-time durations to strings" do
      assert_feel_result("string(duration(\"P4D\"))", "P4D", :string)
      assert_feel_result("string(duration(\"PT2H\"))", "PT2H", :string)
      assert_feel_result("string(duration(\"PT30M\"))", "PT30M", :string)
      assert_feel_result("string(duration(\"P1DT6H\"))", "P1DT6H", :string)
      assert_feel_result("string(@\"P4D\")", "P4D", :string)
      assert_feel_result("string(@\"PT2H\")", "PT2H", :string)
      assert_feel_result("string(@\"PT30M\")", "PT30M", :string)
      assert_feel_result("string(@\"P1DT6H\")", "P1DT6H", :string)
    end

    test "converts years-month durations to strings" do
      assert_feel_result("string(duration(\"P2Y\"))", "P2Y", :string)
      assert_feel_result("string(duration(\"P6M\"))", "P6M", :string)
      assert_feel_result("string(duration(\"P1Y6M\"))", "P1Y6M", :string)
      assert_feel_result("string(@\"P2Y\")", "P2Y", :string)
      assert_feel_result("string(@\"P6M\")", "P6M", :string)
      assert_feel_result("string(@\"P1Y6M\")", "P1Y6M", :string)
    end

    test "converts lists to strings" do
      assert_feel_result("string([1,2+4])", "[1, 6]", :string)
    end
  end

  describe "string concatenation with conversion" do
    test "concatenates string with converted number" do
      assert_feel_result("\"You are number \"+string(1)", "You are number 1", :string)
    end
  end
end
