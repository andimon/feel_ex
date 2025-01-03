defmodule FeelEx.FunctionDefinitions do
  alias FeelEx.FunctionDefinitions.Numeric

  def floor(%FeelEx.Value{value: number, type: :number}) do
    Numeric.floor(%FeelEx.Value{value: number, type: :number})
  end

  def ceiling(%FeelEx.Value{value: number, type: :number}) do
    Numeric.ceiling(%FeelEx.Value{value: number, type: :number})
  end

  def decimal(%FeelEx.Value{value: number, type: :number}, %FeelEx.Value{
        value: precision,
        type: :number
      }) do
    Numeric.decimal(%FeelEx.Value{value: number, type: :number}, %FeelEx.Value{
      value: precision,
      type: :number
    })
  end

  def abs(%FeelEx.Value{value: number, type: :number}) do
    Numeric.abs(%FeelEx.Value{value: number, type: :number})
  end

  def modulo(%FeelEx.Value{value: divedend, type: :number}, %FeelEx.Value{
        value: divisor,
        type: :number
      }) do
    Numeric.modulo(%FeelEx.Value{value: divedend, type: :number}, %FeelEx.Value{
      value: divisor,
      type: :number
    })
  end

  def sqrt(%FeelEx.Value{value: number, type: :number}) do
    Numeric.sqrt(%FeelEx.Value{value: number, type: :number})
  end

  def log(%FeelEx.Value{value: number, type: :number}) do
    Numeric.log(%FeelEx.Value{value: number, type: :number})
  end

  def exp(%FeelEx.Value{value: number, type: :number}) do
    Numeric.exp(%FeelEx.Value{value: number, type: :number})
  end

  def odd(%FeelEx.Value{value: number, type: :number}) do
    Numeric.odd(%FeelEx.Value{value: number, type: :number})
  end

  def even(%FeelEx.Value{value: number, type: :number}) do
    Numeric.even(%FeelEx.Value{value: number, type: :number})
  end
end
