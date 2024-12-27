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
    OpAnd,
    OpOr,
    OpLt,
    OpGt,
    Boolean,
    String_,
    List,
    OpExponentiation
  }

  alias FeelEx.Value
  require Logger
  defstruct [:child]

  def new(:list, expression_list) do
    expression_list =
      Enum.map(expression_list, fn expression_list ->
        case expression_list do
          {exp, _tokens} -> exp
          exp -> exp
        end
      end)

    %__MODULE__{child: %List{elements: expression_list}}
  end

  def new(:negation, operand) do
    %__MODULE__{child: %Negation{operand: operand}}
  end

  def new(:string, string) do
    %__MODULE__{child: %String_{value: string}}
  end

  def new(:name, name) do
    %__MODULE__{child: %Name{value: name}}
  end

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

  def new(:if, {condition_tree, []}, {conditional_statement_tree, []}, {else_statement_tree, []}) do
    %__MODULE__{
      child: %If{
        condition: condition_tree,
        conditional_statetement: conditional_statement_tree,
        else_statement: else_statement_tree
      }
    }
  end

  def new(:arithmetic_op_add, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpAdd{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:arithmetic_op_sub, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpSubtract{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:arithmetic_op_mul, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpMultiply{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:exponentiation, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpExponentiation{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:arithmetic_op_div, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpDivide{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:geq, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpGeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:leq, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpLeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:lt, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpLt{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:gt, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpGt{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:eq, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpEq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:neq, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpNeq{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:and, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpAnd{left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:or, left_tree, right_tree) do
    left_tree =
      case left_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    right_tree =
      case right_tree do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %OpOr{left_tree: left_tree, right_tree: right_tree}}
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
        %__MODULE__{child: %OpExponentiation{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_exponentiation(evaluate(left_tree, context), evaluate(right_tree, context))
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
        %__MODULE__{child: %OpAnd{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_and(evaluate(left_tree, context), right_tree, context)
  end

  def evaluate(
        %__MODULE__{child: %OpOr{left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_or(evaluate(left_tree, context), right_tree, context)
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

  def evaluate(
        %__MODULE__{
          child: %List{
            elements: elements
          }
        },
        context
      ) do
    Enum.map(elements, fn expression -> evaluate(expression, context) end)
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

  defp do_exponentiation(
         %FeelEx.Value{value: val1, type: :number},
         %FeelEx.Value{value: val2, type: :number}
       ) do
    Value.new(val1 ** val2)
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

  defp do_and(%FeelEx.Value{value: true, type: :boolean}, right_tree, context) do
    do_and(evaluate(right_tree, context))
  end

  defp do_and(%FeelEx.Value{value: false, type: :boolean}, _right_tree, _context) do
    %FeelEx.Value{value: false, type: :boolean}
  end

  defp do_and(%FeelEx.Value{value: value, type: :boolean}) when is_boolean(value) do
    %FeelEx.Value{value: value, type: :boolean}
  end

  defp do_or(%FeelEx.Value{value: true, type: :boolean}, _right_tree, _context) do
    %FeelEx.Value{value: true, type: :boolean}
  end

  defp do_or(%FeelEx.Value{value: false, type: :boolean}, right_tree, context) do
    do_or(evaluate(right_tree, context))
  end

  defp do_or(%FeelEx.Value{value: value, type: :boolean}) when is_boolean(value) do
    %FeelEx.Value{value: value, type: :boolean}
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
