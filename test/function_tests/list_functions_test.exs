defmodule FeelEx.ListFunctionTests do
  use ExUnit.Case
  alias FeelEx.Value

  describe "max(list)" do
    test "max(list of numbers)" do
      assert FeelEx.evaluate("max([1,2,3])") == %Value{value: 3, type: :number}
    end

    test "max(_,_,..,_)" do
      assert FeelEx.evaluate("max(1,2,3)") == %Value{value: 3, type: :number}
    end

    test "max(list of dates)" do
      assert FeelEx.evaluate("max(date(2021,1,1),date(2020,1,1))") == %Value{
               value: ~D[2021-01-01],
               type: :date
             }
    end
  end
end
