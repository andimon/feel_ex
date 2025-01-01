defmodule FeelEx.HelperTests do
  use ExUnit.Case

  test "cartesian product []" do
    assert [] = FeelEx.Helper.cartesian([])
  end

  test "cartesian product [[:a1,:a2]]" do
    assert [[:a1], [:a2]] = FeelEx.Helper.cartesian([[:a1, :a2]])
  end

  test "cartesian product [[:a1,:a2],[:b1]]" do
    assert [[:a1, :b1], [:a2, :b1]] = FeelEx.Helper.cartesian([[:a1, :a2], [:b1]])
  end

  test "cartesian product FeelEx.Helper.cartesian([[:a1,:a2],[:b1],[:c1,:c2]])" do
   expected =  MapSet.new([
      [:a1, :b1, :c1],
      [:a1, :b1, :c2],
      [:a1, :b1, :c3],
      [:a1, :b2, :c1],
      [:a1, :b2, :c2],
      [:a1, :b2, :c3],
      [:a2, :b1, :c1],
      [:a2, :b1, :c2],
      [:a2, :b1, :c3],
      [:a2, :b2, :c1],
      [:a2, :b2, :c2],
      [:a2, :b2, :c3],
      [:a3, :b1, :c1],
      [:a3, :b1, :c2],
      [:a3, :b1, :c3],
      [:a3, :b2, :c1],
      [:a3, :b2, :c2],
      [:a3, :b2, :c3]
    ])
    assert expected == MapSet.new(FeelEx.Helper.cartesian([[:a1, :a2,:a3], [:b1, :b2], [:c1, :c2, :c3]]))
  end
end
