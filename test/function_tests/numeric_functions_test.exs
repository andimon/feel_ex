defmodule FeelEx.NumericFunctionTests do
  use ExUnit.Case

  alias FeelEx.Value

  describe "decimal(number,precision)" do
    test "integer number" do
      assert FeelEx.evaluate("decimal(1,2)") == %Value{value: 1, type: :number}
    end

    test "0 precision" do
      assert FeelEx.evaluate("decimal(1.21,0)") == %Value{value: 1, type: :number}
    end

    test "2 precision" do
      assert FeelEx.evaluate("decimal(1.123,2)") == %Value{value: 1.12, type: :number}
    end

    test "float precision" do
      assert FeelEx.evaluate("decimal(1.123,2.21)") == %Value{value: 1.12, type: :number}
    end

    test "more precision than fractional part" do
      assert FeelEx.evaluate("decimal(1.123,15)") == %Value{value: 1.123, type: :number}
    end
  end

  describe "floor(number)" do
    test "floor(integer)" do
      assert FeelEx.evaluate("floor(11)") == %Value{value: 11, type: :number}
    end

    test "floor(float)  " do
      assert FeelEx.evaluate("floor(11.911)") == %Value{value: 11, type: :number}
    end

    test "floor(nan)" do
      assert FeelEx.evaluate("floor(\"a\")") == %Value{value: nil, type: :null}
    end
  end

  describe "floor(number,number)" do
    test "floor(integer,integer)" do
      assert FeelEx.evaluate("floor(11,1)") == %Value{value: 11, type: :number}
    end

    test "floor(float)  " do
      assert FeelEx.evaluate("floor(11.911,1)") == %Value{value: 11.9, type: :number}
    end

    test "floor(nan)" do
      assert FeelEx.evaluate("floor(\"a\",1)") == %Value{value: nil, type: :null}
    end
  end

  describe "ceiling(number)" do
    test "ceiling(integer)" do
      assert FeelEx.evaluate("ceiling(11)") == %Value{value: 11, type: :number}
    end

    test "ceiling(float)  " do
      assert FeelEx.evaluate("ceiling(11.111)") == %Value{value: 12, type: :number}
    end

    test "ceiling(nan)" do
      assert FeelEx.evaluate("ceiling(\"a\")") == %Value{value: nil, type: :null}
    end
  end

  describe "ceiling(number,number)" do
    test "ceiling(integer,integer)" do
      assert FeelEx.evaluate("ceiling(11,1)") == %Value{value: 11, type: :number}
    end

    test "ceiling(float)  " do
      assert FeelEx.evaluate("ceiling(11.911,1)") == %Value{value: 12, type: :number}
    end

    test "ceiling(nan,1)" do
      assert FeelEx.evaluate("ceiling(\"a\",1)") == %Value{value: nil, type: :null}
    end
  end

  describe "round_up(number,number)" do
    test "round_up(integer)" do
      assert FeelEx.evaluate("round up(11,0)") == %Value{value: 11, type: :number}
    end

    test "scale greater than fractional part" do
      assert FeelEx.evaluate("round up(11.1234,6)") == %Value{value: 11.1234, type: :number}
    end

    test "round_up(float)  " do
      assert FeelEx.evaluate("round up(11.111,0)") == %Value{value: 12, type: :number}
    end

    test "round_up(nan,0)" do
      assert FeelEx.evaluate("round up(\"a\",0)") == %Value{value: nil, type: :null}
    end

    test "round_up negative float" do
      assert FeelEx.evaluate("round up(-11.1234,2)") == %Value{value: -11.13, type: :number}
    end
  end

  describe "round down(number,number)" do
    test "round down(integer)" do
      assert FeelEx.evaluate("round down(11,0)") == %Value{value: 11, type: :number}
    end

    test "scale greater than fractional part" do
      assert FeelEx.evaluate("round down(11.1234,6)") == %Value{value: 11.1234, type: :number}
    end

    test "round down(float)  " do
      assert FeelEx.evaluate("round down(11.111,0)") == %Value{value: 11, type: :number}
    end

    test "round down(nan,0)" do
      assert FeelEx.evaluate("round down(\"a\",0)") == %Value{value: nil, type: :null}
    end

    test "round down negative float" do
      assert FeelEx.evaluate("round down(-11.1234,2)") == %Value{value: -11.12, type: :number}
    end
  end

  describe "round half up" do
    test "round half up integer" do
      assert FeelEx.evaluate("round half up(11,2)") == %Value{value: 11, type: :number}
    end

    test "round half up with 5 beginning of fractional part" do
      assert FeelEx.evaluate("round half up(11.5, 0)") == %Value{value: 12, type: :number}
    end

    test "round half up with fractional part less than 5" do
      assert FeelEx.evaluate("round half up(11.3, 0)") == %Value{value: 11, type: :number}
    end

    test "round half up with multiple decimal places" do
      assert FeelEx.evaluate("round half up(11.567, 2)") == %Value{value: 11.57, type: :number}
    end

    test "round half up exactly at 5" do
      assert FeelEx.evaluate("round half up(11.5, 1)") == %Value{value: 11.5, type: :number}
    end

    test "round half up with negative number" do
      assert FeelEx.evaluate("round half up(-11.5, 0)") == %Value{value: -12, type: :number}
    end

    test "round half up with small decimal" do
      assert FeelEx.evaluate("round half up(11.04, 1)") == %Value{value: 11, type: :number}
    end
  end

  describe "round half down" do
    test "round half down integer" do
      assert FeelEx.evaluate("round half down(11, 2)") == %Value{value: 11, type: :number}
    end

    test "round half down with 5 beginning of fractional part" do
      assert FeelEx.evaluate("round half down(11.5, 0)") == %Value{value: 11, type: :number}
    end

    test "round half down with fractional part less than 5" do
      assert FeelEx.evaluate("round half down(11.3, 0)") == %Value{value: 11, type: :number}
    end

    test "round half down with multiple decimal places" do
      assert FeelEx.evaluate("round half down(11.567, 2)") == %Value{value: 11.57, type: :number}
    end

    test "round half down exactly at 5" do
      assert FeelEx.evaluate("round half down(11.5, 1)") == %Value{value: 11.5, type: :number}
    end

    test "round half down with negative number" do
      assert FeelEx.evaluate("round half down(-11.5, 0)") == %Value{value: -11, type: :number}
    end

    test "round half down with small decimal" do
      assert FeelEx.evaluate("round half down(11.04, 1)") == %Value{value: 11.0, type: :number}
    end
  end

  describe "abs(number)" do
    test "absolute value of a positive number" do
      assert FeelEx.evaluate("abs(10)") == %Value{value: 10, type: :number}
    end

    test "absolute value of zero" do
      assert FeelEx.evaluate("abs(0)") == %Value{value: 0, type: :number}
    end

    test "absolute value of a negative number" do
      assert FeelEx.evaluate("abs(-10)") == %Value{value: 10, type: :number}
    end

    test "absolute value of a decimal number" do
      assert FeelEx.evaluate("abs(-10.5)") == %Value{value: 10.5, type: :number}
    end

    test "absolute value of a small decimal number" do
      assert FeelEx.evaluate("abs(-0.5)") == %Value{value: 0.5, type: :number}
    end

    test "absolute value of a large negative number" do
      assert FeelEx.evaluate("abs(-1000000)") == %Value{value: 1_000_000, type: :number}
    end

    test "absolute value of a large positive number" do
      assert FeelEx.evaluate("abs(1000000)") == %Value{value: 1_000_000, type: :number}
    end
  end

  describe "modulo(number, divisor)" do
    test "modulo of positive numbers" do
      assert FeelEx.evaluate("modulo(10, 3)") == %Value{value: 1, type: :number}
    end

    test "modulo with zero divisor" do
      assert_raise ArithmeticError, "bad argument in arithmetic expression", fn ->
        FeelEx.evaluate("modulo(10, 0)")
      end
    end

    test "modulo of a negative number" do
      assert FeelEx.evaluate("modulo(-10, 3)") == %Value{value: -1, type: :number}
    end

    test "modulo with negative divisor" do
      assert FeelEx.evaluate("modulo(10, -3)") == %Value{value: 1, type: :number}
    end

    test "modulo of zero" do
      assert FeelEx.evaluate("modulo(0, 3)") == %Value{value: 0, type: :number}
    end

    test "modulo with negative dividend and divisor" do
      assert FeelEx.evaluate("modulo(-10, -3)") == %Value{value: -1, type: :number}
    end

    test "modulo of large numbers" do
      assert FeelEx.evaluate("modulo(1000000, 7)") == %Value{value: 1, type: :number}
    end

    test "modulo with float numbers" do
      assert FeelEx.evaluate("modulo(10.5, 3)") == %Value{value: 1.5, type: :number}
    end

    test "modulo of negative float numbers" do
      assert FeelEx.evaluate("modulo(-10.5, 3)") == %Value{value: -1.5, type: :number}
    end
  end

  describe "sqrt(number)" do
    test "sqrt of a positive integer" do
      assert FeelEx.evaluate("sqrt(16)") == %Value{value: 4, type: :number}
    end

    test "sqrt of a positive float" do
      assert FeelEx.evaluate("sqrt(20.25)") == %Value{value: 4.5, type: :number}
    end

    test "sqrt of zero" do
      assert FeelEx.evaluate("sqrt(0)") == %Value{value: 0, type: :number}
    end

    test "sqrt of a negative number should return a nil" do
      assert FeelEx.evaluate("sqrt(-9)") == %Value{value: nil, type: :null}
    end

    test "sqrt of a negative float should return a nil" do
      assert FeelEx.evaluate("sqrt(-4.5)") == %Value{value: nil, type: :null}
    end

    test "sqrt of a very large number" do
      assert FeelEx.evaluate("sqrt(1000000000)") == %Value{
               value: 31622.776601683792,
               type: :number
             }
    end

    test "sqrt of a very small positive number" do
      assert FeelEx.evaluate("sqrt(0.0000001)") == %Value{
               value: 3.1622776601683794e-4,
               type: :number
             }
    end

    test "sqrt of a negative non-integer" do
      assert FeelEx.evaluate("sqrt(-5)") == %Value{value: nil, type: :null}
    end
  end

  describe "log(number)" do
    test "log of a positive number" do
      assert FeelEx.evaluate("log(10)") == %Value{value: 2.302585092994046, type: :number}
    end

    test "log of a positive float" do
      assert FeelEx.evaluate("log(2.718)") == %Value{value: 0.999896315728952, type: :number}
    end

    test "log of 1 (should return 0)" do
      assert FeelEx.evaluate("log(1)") == %Value{value: 0, type: :number}
    end

    test "log of a very small positive number" do
      assert FeelEx.evaluate("log(0.0001)") == %Value{value: -9.210340371976182, type: :number}
    end

    test "log of a very large number" do
      assert FeelEx.evaluate("log(1000000000)") == %Value{value: 20.72326583694641, type: :number}
    end

    test "log of 0 should be an error (undefined)" do
      assert FeelEx.evaluate("log(0)") == %Value{value: nil, type: :null}
    end

    test "log of a negative number should return an error (undefined)" do
      assert FeelEx.evaluate("log(-10)") == %Value{value: nil, type: :null}
    end
  end

  describe "exp(number)" do
    test "exp of negative number" do
      assert FeelEx.evaluate("exp(-5)") == %Value{value: 0.006737946999085467, type: :number}
    end
  end

  describe "odd(number)" do
    test "odd(negative odd)" do
      assert FeelEx.evaluate("odd(-5)") == Value.new(true)
    end

    test "odd(positive odd)" do
      assert FeelEx.evaluate("odd(3)") == Value.new(true)
    end

    test "odd(negative even)" do
      assert FeelEx.evaluate("odd(-4)") == Value.new(false)
    end

    test "odd(positive even)" do
      assert FeelEx.evaluate("odd(6)") == Value.new(false)
    end

    test "odd(negative float)" do
      assert FeelEx.evaluate("odd(-5.5)") == Value.new(false)
    end

    test "odd(positive float)" do
      assert FeelEx.evaluate("odd(3.2)") == Value.new(false)
    end
  end

  describe "even(number)" do
    test "even(negative even)" do
      assert FeelEx.evaluate("even(-4)") == Value.new(true)
    end

    test "even(positive even)" do
      assert FeelEx.evaluate("even(8)") == Value.new(true)
    end

    test "even(negative odd)" do
      assert FeelEx.evaluate("even(-5)") == Value.new(false)
    end

    test "even(positive odd)" do
      assert FeelEx.evaluate("even(3)") == Value.new(false)
    end

    test "even(negative float)" do
      assert FeelEx.evaluate("even(-4.7)") == Value.new(false)
    end

    test "even(positive float)" do
      assert FeelEx.evaluate("even(2.1)") == Value.new(false)
    end
  end

  describe "random" do
    test "random number generation" do
      result = FeelEx.evaluate("random()")
      assert result >= Value.new(0) && result <= Value.new(1)
    end
  end
end
