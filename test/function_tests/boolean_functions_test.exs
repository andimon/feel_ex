defmodule FeelEx.BooleanFunctionTests do
  use ExUnit.Case
  alias FeelEx.Value

  describe "not(boolean)" do
    test "not true" do
      assert FeelEx.evaluate("not(true)") == %Value{value: false, type: :boolean}
    end

    test "not false" do
      assert FeelEx.evaluate("not(false)") == %Value{value: true, type: :boolean}
    end

    test "negate a non boolean value" do
      assert FeelEx.evaluate("not(1)") == %Value{value: nil, type: :null}
    end
  end
end
