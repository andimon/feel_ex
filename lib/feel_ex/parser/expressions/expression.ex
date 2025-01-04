defmodule FeelEx.Expression do
  @moduledoc false
  alias FeelEx.{Helper, Value}

  alias FeelEx.Expression.{
    Name,
    Number,
    Negation,
    BinaryOp,
    Boolean,
    String_,
    List,
    For,
    Range,
    If,
    Function,
    FilterList
  }

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

  def new(:filter_list, expression_list, expression) do
    expression_list =
      case expression_list do
        {exp, _tokens} -> exp
        exp -> exp
      end

    expression =
      case expression do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{child: %FilterList{list: expression_list, filter: expression}}
  end

  def new(:function, name, expression_list) do
    arguments =
      Enum.map(expression_list, fn expression_list ->
        case expression_list do
          {exp, _tokens} -> exp
          exp -> exp
        end
      end)

    %__MODULE__{child: %Function{name: name, arguments: arguments}}
  end

  def new(:range, first_bound, second_bound) do
    %__MODULE__{child: %Range{first_bound: first_bound, second_bound: second_bound}}
  end

  def new(:for, iteration_context, return_expression) do
    return_expression =
      case return_expression do
        {exp, _tokens} -> exp
        exp -> exp
      end

    %__MODULE__{
      child: %For{
        iteration_contexts: iteration_context,
        return_expression: return_expression
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

    %__MODULE__{child: %BinaryOp{type: :add, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :subtract, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :multiply, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{
      child: %BinaryOp{type: :exponentiation, left_tree: left_tree, right_tree: right_tree}
    }
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

    %__MODULE__{child: %BinaryOp{type: :divide, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :geq, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :leq, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :lt, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :gt, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :eq, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :neq, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :and, left_tree: left_tree, right_tree: right_tree}}
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

    %__MODULE__{child: %BinaryOp{type: :or, left_tree: left_tree, right_tree: right_tree}}
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

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :add, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_add(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{
          child: %BinaryOp{type: :multiply, left_tree: left_tree, right_tree: right_tree}
        },
        context
      ) do
    do_multiply(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{
          child: %BinaryOp{type: :exponentiation, left_tree: left_tree, right_tree: right_tree}
        },
        context
      ) do
    do_exponentiation(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{
          child: %BinaryOp{type: :divide, left_tree: left_tree, right_tree: right_tree}
        },
        context
      ) do
    do_divide(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{
          child: %BinaryOp{type: :subtract, left_tree: left_tree, right_tree: right_tree}
        },
        context
      ) do
    do_subtract(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :leq, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_leq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :gt, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_gt(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :geq, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_geq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :lt, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_lt(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :eq, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_eq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :neq, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_neq(evaluate(left_tree, context), evaluate(right_tree, context))
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :and, left_tree: left_tree, right_tree: right_tree}},
        context
      ) do
    do_and(evaluate(left_tree, context), right_tree, context)
  end

  def evaluate(
        %__MODULE__{child: %BinaryOp{type: :or, left_tree: left_tree, right_tree: right_tree}},
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
          child: %For{
            iteration_contexts: iteration_contexts,
            return_expression: return_expression
          }
        },
        context
      ) do
    iteration_contexts
    |> Enum.map(fn {%FeelEx.Expression{child: %FeelEx.Expression.Name{value: name}},
                    list_expression} ->
      list_expression =
        case list_expression do
          {exp, _tokens} -> exp
          exp -> exp
        end

      Enum.map(evaluate(list_expression, context), fn %Value{value: value} ->
        {String.to_atom(name), value}
      end)
    end)
    |> Helper.cartesian()
    |> Enum.map(fn new_assignments ->
      new_context = Enum.into(new_assignments, context)
      evaluate(return_expression, new_context)
    end)
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

  def evaluate(
        %__MODULE__{
          child: %FilterList{
            list: list,
            filter: %FeelEx.Expression{child: %FeelEx.Expression.Number{}} = number
          }
        },
        context
      ) do
    list = evaluate(list, context)
    filter = evaluate(number, context)
    get_elem(list, filter)
  end

  def evaluate(
        %__MODULE__{
          child: %FilterList{
            list: list,
            filter:
              %FeelEx.Expression{
                child: %FeelEx.Expression.Negation{
                  operand: %FeelEx.Expression{child: %FeelEx.Expression.Number{}}
                }
              } = number
          }
        },
        context
      ) do
    list = evaluate(list, context)
    filter = evaluate(number, context)
    get_elem(list, filter)
  end

  def evaluate(
        %__MODULE__{
          child: %FilterList{
            list: list,
            filter: filter
          }
        },
        context
      ) do
    list = evaluate(list, context)
    apply_filter(list, filter, context)
  end

  def evaluate(
        %__MODULE__{
          child: %Function{
            name: %__MODULE__{child: %Name{value: name}},
            arguments: arguments
          }
        },
        context
      ) do
    arguments = Enum.map(arguments, fn expression -> evaluate(expression, context) end)
    apply(FeelEx.FunctionDefinitions, String.to_atom(name), arguments)
  end

  def evaluate(
        %__MODULE__{
          child: %Range{
            first_bound: first_bound,
            second_bound: second_bound
          }
        },
        context
      ) do
    get_range_list(evaluate(first_bound, context), evaluate(second_bound, context))
  end

  def filter_iteration_context(list) when is_list(list) do
    Enum.map(list, fn %Value{value: value} ->
      value
    end)
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
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 == val2)
  end

  defp do_neq(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
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

  # on false or anything else
  defp do_if(
         _,
         _conditional_statement,
         else_statement,
         context
       ) do
    evaluate(else_statement, context)
  end

  defp get_range_list(
         %FeelEx.Value{value: first_bound, type: :number},
         %FeelEx.Value{value: second_bound, type: :number}
       ) do
    Helper.gen_list_from_range(first_bound, second_bound)
    |> Enum.map(fn x -> Value.new(x) end)
  end

  defp get_elem(list, %Value{value: 0})
       when is_list(list) do
    Value.new(nil)
  end

  defp get_elem(list, %Value{value: number})
       when is_list(list) and number > 0 do
    value = Enum.at(list, number - 1)
    if is_nil(value), do: Value.new(nil), else: value
  end

  defp get_elem(list, %Value{value: number})
       when is_list(list) and number < 0 do
    value = Enum.at(list, number)
    if is_nil(value), do: Value.new(nil), else: value
  end

  defp apply_filter(list, filter, context) do
    Enum.filter(list, fn %Value{value: value} ->
      new_context = Map.put(context, :item, value)
      evaluate(filter, new_context) == %Value{value: true, type: :boolean}
    end)
  end
end
