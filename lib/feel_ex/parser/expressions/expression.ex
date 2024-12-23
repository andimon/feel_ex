defmodule FeelEx.Expression do
  alias FeelEx.Expression.If

  alias FeelEx.Expression.{
    Name,
    Number,
    Negation,
    OpAdd,
    OpSubtract,
    OpMultiply,
    OpDivide,
    OpLeq,
    OpGeq,
    OpEq,
    OpNeq,
    OpLt,
    OpGt,
    Boolean,
    String_
  }

  alias FeelEx.Value
  require Logger
  defstruct [:child]
  # create negation treee
  def new(:negation, operand) do
    %__MODULE__{child: %Negation{operand: operand}}
  end

  # evaluate a string
  def new(:string, string) do
    %__MODULE__{child: %String_{value: string}}
  end

  # evaluate a name
  def new(:name, name) do
    %__MODULE__{child: %Name{value: name}}
  end

  # evaluate boolean values true and false
  def new(:boolean, true) do
    %__MODULE__{child: %Boolean{value: true}}
  end

  def new(:boolean, false) do
    %__MODULE__{child: %Boolean{value: false}}
  end

  def new(:int, int) do
    %__MODULE__{child: %Number{value: String.to_integer(int)}}
  end

  def new(:float, float) do
    %__MODULE__{child: %Number{value: String.to_float(float)}}
  end

  def new(:if, condition_tree, conditional_statement_tree, else_statement_tree) do
    %__MODULE__{
      child: %If{
        condition: condition_tree,
        conditional_statetement: conditional_statement_tree,
        else_statement: else_statement_tree
      }
    }
  end

  # arithmetic operations
  def new(:op_add, left_tree, right_tree) do
    %__MODULE__{child: %OpAdd{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_subtract, left_tree, right_tree) do
    %__MODULE__{child: %OpSubtract{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_multiply, left_tree, right_tree) do
    %__MODULE__{child: %OpMultiply{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_divide, left_tree, right_tree) do
    %__MODULE__{child: %OpDivide{left_tree: left_tree, right_tree: right_tree}}
  end

  # comparisons

  def new(:op_geq, left_tree, right_tree) do
    %__MODULE__{child: %OpGeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_leq, left_tree, right_tree) do
    %__MODULE__{child: %OpLeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_lt, left_tree, right_tree) do
    %__MODULE__{child: %OpLt{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_gt, left_tree, right_tree) do
    %__MODULE__{child: %OpGt{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_eq, left_tree, right_tree) do
    %__MODULE__{child: %OpEq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:op_neq, left_tree, right_tree) do
    %__MODULE__{child: %OpNeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def evaluate(%__MODULE__{child: %String_{value: string}}, _context) do
    Value.new(string)
  end

  def evaluate(%__MODULE__{child: %Boolean{value: bool}}, _context) do
    Value.new(bool)
  end

  def evaluate(%__MODULE__{child: %Name{value: name}}, context) do
    result = context[String.to_atom(name)]

    if is_nil(result) do
    else
      Value.new(result)
    end
  end

  def evaluate(%__MODULE__{child: %Number{value: number}}, _context) do
    Value.new(number)
  end

  def evaluate(%__MODULE__{child: %OpAdd{left_tree: left_tree, right_tree: right_tree}}, context) do
    do_add(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpMultiply{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_multiply(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpDivide{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_divide(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpSubtract{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_subtract(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpLeq{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_leq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpGt{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_gt(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpGeq{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_geq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpLt{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_lt(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpEq{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_eq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %OpNeq{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_neq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %Negation{operand: operand}},
        context
      ) do
    do_negation(evaluate(operand, context))
  end

  def evaluate(
        %__MODULE__{
          child: %If{
            condition: condition,
            conditional_statetement: conditional_statement,
            else_statement: else_statement
          }
        },
        context
      ) do
    result = evaluate(condition, context)
    do_if(result, conditional_statement, else_statement, context)
  end

  defp do_add(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 + val2)
  end

  defp do_add(
         %FeelEx.Value{value: val1, type: :string},
         %FeelEx.Value{value: val2, type: :string}
       ) do
    Value.new(val1 <> val2)
  end

  defp do_multiply(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 * val2)
  end

  defp do_subtract(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 - val2)
  end

  defp do_divide(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 / val2)
  end

  defp do_gt(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 > val2)
  end

  defp do_lt(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 < val2)
  end

  defp do_leq(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 <= val2)
  end

  defp do_geq(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 >= val2)
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 == val2)
  end

  defp do_neq(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 != val2)
  end

  defp do_negation(%FeelEx.Value{value: val1, type: :number}) do
    Value.new(-val1)
  end

  defp do_if(
         %FeelEx.Value{value: true, type: :boolean},
         conditional_statement,
         _else_statement,
         context
       ) do
    evaluate(conditional_statement, context)
  end

  defp do_if(
         %FeelEx.Value{value: false, type: :boolean},
         _conditional_statement,
         else_statement,
         context
       ) do
    evaluate(else_statement, context)
  end
end
