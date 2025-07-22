defmodule FeelEx.BooleanFunctionTests do
  use ExUnit.Case
  import TestHelpers

  doctest FeelEx

  describe "not(boolean)" do
    test "returns false when negating true" do
      assert_feel_result("not(true)", false, :boolean)
    end

    test "returns true when negating false" do
      assert_feel_result("not(false)", true, :boolean)
    end

    test "returns null when negating a non-boolean value" do
      assert_feel_result("not(1)", nil, :null)
    end

    test "returns null when negating null" do
      assert_feel_result("not(null)", nil, :null)
    end
  end
end
