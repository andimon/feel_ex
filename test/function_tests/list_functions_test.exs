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

  describe "sublist(list, start)" do
    test "starting at a valid index" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 3)") == [Value.new(43), Value.new(2)]
    end

    test "starting at index 0" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 1)") == [
               Value.new(1),
               Value.new(23),
               Value.new(43),
               Value.new(2)
             ]
    end

    test "starting at an out-of-bounds index" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 10)") == []
    end

    test "empty list" do
      assert FeelEx.evaluate("sublist([], 0)") == Value.new(nil)
    end

    test "starting from a negative index" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], -2)") == [Value.new(43), Value.new(2)]
    end

    test "sublist  with negative start index exceeding list length" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], -5)") == [
               Value.new(1),
               Value.new(23),
               Value.new(43),
               Value.new(2)
             ]
    end

    test "sublist of a single element" do
      assert FeelEx.evaluate("sublist([10], 1)") == [Value.new(10)]
    end
  end

  describe "sublist(list, start, length)" do
    test "starting at a valid index with a specified length" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 3, 2)") == [
               Value.new(43),
               Value.new(2)
             ]
    end

    test "starting at index 0 with a specified length" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 1, 3)") == [
               Value.new(1),
               Value.new(23),
               Value.new(43)
             ]
    end

    test "starting at an out-of-bounds index with a specified length" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 10, 2)") == []
    end

    test "starting at a valid index but requesting more elements than available" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 3, 5)") == [
               Value.new(43),
               Value.new(2)
             ]
    end

    test "empty list with non-zero start and length" do
      assert FeelEx.evaluate("sublist([], 1, 1)") == []
    end

    test "starting from a negative index with a specified length" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], -3, 2)") == [
               Value.new(23),
               Value.new(43)
             ]
    end

    test "sublist starting at the beginning with length 0" do
      assert FeelEx.evaluate("sublist([1, 23, 43, 2], 1, 0)") == []
    end

    test "0 index is error" do
      assert FeelEx.evaluate("sublist([10], 0, 1)") == Value.new(nil)
    end
  end

  describe "any(list)" do
    test "contains a number and true" do
      assert FeelEx.evaluate("any([1,1,2,true,1])") == Value.new(true)
    end

    test "any of empty list is false" do
      assert FeelEx.evaluate("any([])") == Value.new(false)
    end

    test "contains a numbers and false is error" do
      assert FeelEx.evaluate("any([1,1,2,false,1])") == Value.new(nil)
    end

    test "just false" do
      assert FeelEx.evaluate("any([false])") == Value.new(false)
    end
  end

  describe "all(list)" do
    test "all elements are true" do
      assert FeelEx.evaluate("all([true, true, true])") == Value.new(true)
    end

    test "contains false" do
      assert FeelEx.evaluate("all([true, false, true])") == Value.new(false)
    end

    test "empty list is true" do
      assert FeelEx.evaluate("all([])") == Value.new(true)
    end

    test "contains a number and true is error" do
      assert FeelEx.evaluate("all([1, true, 2])") == Value.new(nil)
    end

    test "contains false and true is false" do
      assert FeelEx.evaluate("all([true, false])") == Value.new(false)
    end

    test "contains just false" do
      assert FeelEx.evaluate("all([false, false, false])") == Value.new(false)
    end

    test "contains just true" do
      assert FeelEx.evaluate("all([true, true, true])") == Value.new(true)
    end
  end

  describe "append(list,items)" do
    test "appending list of numbers" do
      assert FeelEx.evaluate("append([31,321],[1])") == [
               Value.new(31),
               Value.new(321),
               Value.new(1)
             ]
    end
  end

  describe "concatenate(list,items)" do
    test "list of numbers" do
      assert FeelEx.evaluate("concatenate([[1,2],[3]])") ==
               [Value.new(1), Value.new(2), Value.new(3)]
    end

    test "sequential parameters" do
      assert FeelEx.evaluate("concatenate([1,2],[3])") ==
               [Value.new(1), Value.new(2), Value.new(3)]
    end
  end

  describe "insert before(list, position, new_item)" do
    test "insert number before list of numbers" do
      assert FeelEx.evaluate("insert before([1, 32, 42], 2, 3)") == [
               Value.new(1),
               Value.new(3),
               Value.new(32),
               Value.new(42)
             ]
    end

    test "insert at the beginning of the list" do
      assert FeelEx.evaluate("insert before([1, 32, 42], 1, 0)") == [
               Value.new(0),
               Value.new(1),
               Value.new(32),
               Value.new(42)
             ]
    end

    test "insert at the end of the list" do
      assert FeelEx.evaluate("insert before([1, 32, 42], 4, 100)") == [
               Value.new(1),
               Value.new(32),
               Value.new(42),
               Value.new(100)
             ]
    end

    test "insert at a position greater than the list length" do
      assert FeelEx.evaluate("insert before([1, 32, 42], 5, 99)") == [
               Value.new(1),
               Value.new(32),
               Value.new(42),
               Value.new(99)
             ]
    end

    test "insert before empty list" do
      assert FeelEx.evaluate("insert before([], 0, 10)") == Value.new(nil)
    end

    test "insert at negative position" do
      assert FeelEx.evaluate("insert before([1, 32, 42], -1, 99)") == [
               Value.new(1),
               Value.new(32),
               Value.new(99),
               Value.new(42)
             ]
    end

    test "insert at first position with empty list" do
      assert FeelEx.evaluate("insert before([], 1, 100)") == [Value.new(100)]
    end

    test "insert at position 0 in a single-element list" do
      assert FeelEx.evaluate("insert before([5], 1, 0)") == [
               Value.new(0),
               Value.new(5)
             ]
    end

    test "position must be non zero" do
      assert FeelEx.evaluate("insert before([5], 0, 0)") == Value.new(nil)
    end
  end

  describe "remove(list, index)" do
    test "remove second element" do
      assert FeelEx.evaluate("remove([1, 3, 4], 2)") == [Value.new(1), Value.new(4)]
    end

    test "remove last element" do
      assert FeelEx.evaluate("remove([1, 3, 4], -1)") == [Value.new(1), Value.new(3)]
    end

    test "remove first element" do
      assert FeelEx.evaluate("remove([1, 3, 4], 1)") == [Value.new(3), Value.new(4)]
    end

    test "remove element at invalid index" do
      assert FeelEx.evaluate("remove([1, 3, 4], 5)") == [Value.new(1), Value.new(3), Value.new(4)]
    end

    test "remove element from empty list" do
      assert FeelEx.evaluate("remove([], 1)") == []
    end

    test "remove element at negative index out of bounds" do
      assert FeelEx.evaluate("remove([1, 3, 4], -5)") == [
               Value.new(1),
               Value.new(3),
               Value.new(4)
             ]
    end

    test "remove element from single-element list" do
      assert FeelEx.evaluate("remove([5], 1)") == []
    end

    test "remove from list with mixed data types" do
      assert FeelEx.evaluate("remove([1, true, false, 4], 2)") == [
               Value.new(1),
               Value.new(false),
               Value.new(4)
             ]
    end

    test "remove when list has only one element" do
      assert FeelEx.evaluate("remove([10], 1)") == []
    end

    test "remove at the last valid index" do
      assert FeelEx.evaluate("remove([1, 3, 4], 3)") == [Value.new(1), Value.new(3)]
    end
  end

  describe "string join(list)" do
    test "join list of strings" do
      assert FeelEx.evaluate("string join([\"a\",\"b\",\"c\"])") == Value.new("abc")
    end
  end

  describe "product(list)" do
    test "list of ones" do
      assert FeelEx.evaluate("product([1,1,1,1])") == Value.new(1)
    end

    test "list of zeros" do
      assert FeelEx.evaluate("product([0,0,0,0])") == Value.new(0)
    end

    test "product of positive and negative numbers" do
      assert FeelEx.evaluate("product([2,-3,4,-5])") == Value.new(120)
    end

    test "product with a single element" do
      assert FeelEx.evaluate("product([7])") == Value.new(7)
    end

    test "product of empty list" do
      assert FeelEx.evaluate("product([])") == Value.new(1)
    end

    test "product of large numbers" do
      assert FeelEx.evaluate("product([1000000, 1000000])") == Value.new(1_000_000_000_000)
    end

    test "product with floats" do
      assert FeelEx.evaluate("product([1.5, 2.5, 4.0])") == Value.new(15.0)
    end

    test "product with mixed types" do
      assert FeelEx.evaluate("product([2, 3, 1.5, 4])") == Value.new(36.0)
    end

    test "product with invalid value" do
      assert FeelEx.evaluate("product([\"a\", 3, 1.5, 4])") == Value.new(nil)
    end
  end

  describe "mean(list)" do
    test "list of ones" do
      assert FeelEx.evaluate("mean([1,1,1,1])") == Value.new(1.0)
    end

    test "list of zeros" do
      assert FeelEx.evaluate("mean([0,0,0,0])") == Value.new(0.0)
    end

    test "mean of positive and negative numbers" do
      assert FeelEx.evaluate("mean([2,-3,4,-5])") == Value.new(-0.5)
    end

    test "mean with a single element" do
      assert FeelEx.evaluate("mean([7])") == Value.new(7.0)
    end

    test "mean of empty list" do
      assert FeelEx.evaluate("mean([])") == Value.new(nil)
    end

    test "mean of large numbers" do
      assert FeelEx.evaluate("mean([1000000, 1000000])") == Value.new(1_000_000.0)
    end

    test "mean with floats" do
      assert FeelEx.evaluate("mean([1.5, 2.5, 4.0])") == Value.new(2.6666666666666665)
    end

    test "mean with mixed types" do
      assert FeelEx.evaluate("mean([2, 3, 1.5, 4])") == Value.new(2.625)
    end

    test "mean with invalid value" do
      assert FeelEx.evaluate("mean([\"a\", 3, 1.5, 4])") == Value.new(nil)
    end
  end

  describe "stddev(list)" do
    test "list of ones" do
      assert FeelEx.evaluate("stddev([1,1,1,1])") == Value.new(0.0)
    end

    test "list of zeros" do
      assert FeelEx.evaluate("stddev([0,0,0,0])") == Value.new(0.0)
    end

    test "stddev of positive and negative numbers" do
      assert FeelEx.evaluate("stddev([2,-3,4,-5])") == Value.new(4.203173404306164)
    end

    test "stddev with a single element" do
      assert FeelEx.evaluate("stddev([7])") == Value.new(nil)
    end

    test "stddev of empty list" do
      assert FeelEx.evaluate("stddev([])") == Value.new(nil)
    end

    test "stddev of large numbers" do
      assert FeelEx.evaluate("stddev([1000000, 1000000])") == Value.new(0.0)
    end

    test "stddev with floats" do
      assert FeelEx.evaluate("stddev([1.5, 2.5, 4.0])") == Value.new(1.2583057392117916)
    end

    test "stddev with mixed types" do
      assert FeelEx.evaluate("stddev([2, 3, 1.5, 4])") == Value.new(1.1086778913041726)
    end

    test "stddev with invalid value" do
      assert FeelEx.evaluate("stddev([\"a\", 3, 1.5, 4])") == Value.new(nil)
    end
  end

  describe "median(list)" do
    test "list with odd number of elements" do
      assert FeelEx.evaluate("median([3, 1, 4, 1, 5])") == Value.new(3.0)
    end

    test "list with even number of elements" do
      assert FeelEx.evaluate("median([3, 1, 4, 1])") == Value.new(2)
    end

    test "list of ones" do
      assert FeelEx.evaluate("median([1,1,1,1,1])") == Value.new(1.0)
    end

    test "list of zeros" do
      assert FeelEx.evaluate("median([0,0,0,0])") == Value.new(0.0)
    end

    test "median of negative numbers" do
      assert FeelEx.evaluate("median([-1, -3, -5, -2])") == Value.new(-2.5)
    end

    test "median with a single element" do
      assert FeelEx.evaluate("median([7])") == Value.new(7.0)
    end

    test "median of empty list" do
      assert FeelEx.evaluate("median([])") == Value.new(nil)
    end

    test "median with floats" do
      assert FeelEx.evaluate("median([1.5, 2.5, 4.0])") == Value.new(2.5)
    end

    test "median with mixed types" do
      assert FeelEx.evaluate("median([2, 3, 1.5, 4])") == Value.new(2.5)
    end

    test "median with invalid value" do
      assert FeelEx.evaluate("median([\"a\", 3, 1.5, 4])") == Value.new(nil)
    end
  end

  describe "mode(list)" do
    test "list with a single mode" do
      assert FeelEx.evaluate("mode([3, 1, 4, 1, 5])") == [Value.new(1)]
    end

    test "list with multiple modes" do
      assert FeelEx.evaluate("mode([1, 1, 2, 2, 3])") == Value.new([1, 2])
    end

    test "list with only one element" do
      assert FeelEx.evaluate("mode([7])") == [Value.new(7)]
    end

    test "list of ones" do
      assert FeelEx.evaluate("mode([1, 1, 1, 1])") == [Value.new(1)]
    end

    test "list of zeros" do
      assert FeelEx.evaluate("mode([0, 0, 0, 0])") == [Value.new(0)]
    end

    test "list with no mode" do
      # Each element occurs once, so all are modes
      assert FeelEx.evaluate("mode([3, 1, 4, 5])") == Value.new([1, 3, 4, 5])
    end

    test "mode with negative numbers" do
      assert FeelEx.evaluate("mode([-1, -3, -5, -3])") == [Value.new(-3)]
    end

    test "mode with floats" do
      assert FeelEx.evaluate("mode([1.5, 2.5, 1.5, 4.0])") == [Value.new(1.5)]
    end

    test "mode with mixed types" do
      assert FeelEx.evaluate("mode([2, 3, 1.5, 4, 3])") == Value.new([3])
    end

    test "mode with invalid value" do
      assert FeelEx.evaluate("mode([\"a\", 3, 1.5, 4])") == Value.new(nil)
    end
  end
end
