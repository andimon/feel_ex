defmodule FeelEx.FunctionDefinitions do
  alias FeelEx.FunctionDefinitions.{Numeric, String}
  alias FeelEx.Value

  def floor(%Value{value: number, type: :number}) do
    Numeric.floor(%Value{value: number, type: :number})
  end

  def ceiling(%Value{value: number, type: :number}) do
    Numeric.ceiling(%Value{value: number, type: :number})
  end

  def decimal(%Value{value: number, type: :number}, %Value{
        value: precision,
        type: :number
      }) do
    Numeric.decimal(%Value{value: number, type: :number}, %Value{
      value: precision,
      type: :number
    })
  end

  def abs(%Value{value: number, type: :number}) do
    Numeric.abs(%Value{value: number, type: :number})
  end

  def modulo(%Value{value: divedend, type: :number}, %Value{
        value: divisor,
        type: :number
      }) do
    Numeric.modulo(%Value{value: divedend, type: :number}, %Value{
      value: divisor,
      type: :number
    })
  end

  def sqrt(%Value{value: number, type: :number}) do
    Numeric.sqrt(%Value{value: number, type: :number})
  end

  def log(%Value{value: number, type: :number}) do
    Numeric.log(%Value{value: number, type: :number})
  end

  def exp(%Value{value: number, type: :number}) do
    Numeric.exp(%Value{value: number, type: :number})
  end

  def odd(%Value{value: number, type: :number}) do
    Numeric.odd(%Value{value: number, type: :number})
  end

  def even(%Value{value: number, type: :number}) do
    Numeric.even(%Value{value: number, type: :number})
  end

  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: number}) do
    String.substring(%Value{type: :string, value: string}, %Value{type: :number, value: number})
  end

  def substring(%Value{type: :string, value: string}, %Value{type: :number, value: index}, %Value{
        type: :number,
        value: length
      }) do
    String.substring(
      %Value{type: :string, value: string},
      %Value{type: :number, value: index},
      %Value{
        type: :number,
        value: length
      }
    )
  end

  def length(%Value{type: :string, value: string}) do
    String.length(%Value{type: :string, value: string})
  end
end
