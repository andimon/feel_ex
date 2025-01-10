defmodule FeelEx.Expression do
  @moduledoc false
  require Logger

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
    FilterList,
    Context,
    Access,
    Quantified,
    Between
  }

  require Logger

  defstruct [:child]

  def new(:context, expression_list) do
    expression_list =
      Enum.map(expression_list, fn {key, value} ->
        value = Helper.filter_expression(value)
        {key, value}
      end)

    %__MODULE__{child: %Context{keys_with_values: expression_list}}
  end

  def new(:list, expression_list) do
    expression_list =
      Enum.map(expression_list, fn expression_list ->
        Helper.filter_expression(expression_list)
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
    float = if String.starts_with?(float, "."), do: "0" <> float, else: float
    %__MODULE__{child: %Number{value: String.to_float(float)}}
  end

  def new(:access, name, operand) do
    name = Helper.filter_expression(name)
    operand = Helper.filter_expression(operand)
    %__MODULE__{child: %Access{name: name, operand: operand}}
  end

  def new(:filter_list, expression_list, expression) do
    expression_list = Helper.filter_expression(expression_list)

    expression = Helper.filter_expression(expression)

    %__MODULE__{child: %FilterList{list: expression_list, filter: expression}}
  end

  def new(:function, name, expression_list) do
    arguments =
      Enum.map(expression_list, fn expression_list ->
        Helper.filter_expression(expression_list)
      end)

    %__MODULE__{child: %Function{name: name, arguments: arguments}}
  end

  def new(:range, first_bound, second_bound) do
    %__MODULE__{child: %Range{first_bound: first_bound, second_bound: second_bound}}
  end

  def new(:for, iteration_context, return_expression) do
    return_expression = Helper.filter_expression(return_expression)

    %__MODULE__{
      child: %For{
        iteration_contexts: iteration_context,
        return_expression: return_expression
      }
    }
  end

  def new(:arithmetic_op_add, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)
    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :add, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:arithmetic_op_sub, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)
    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :subtract, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:arithmetic_op_mul, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :multiply, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:exponentiation, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)
    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{
      child: %BinaryOp{type: :exponentiation, left_tree: left_tree, right_tree: right_tree}
    }
  end

  def new(:arithmetic_op_div, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :divide, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:geq, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :geq, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:leq, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :leq, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:lt, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :lt, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:gt, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :gt, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:eq, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :eq, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:neq, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :neq, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:and, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :and, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:or, left_tree, right_tree) do
    left_tree = Helper.filter_expression(left_tree)

    right_tree = Helper.filter_expression(right_tree)

    %__MODULE__{child: %BinaryOp{type: :or, left_tree: left_tree, right_tree: right_tree}}
  end

  def new(:quantifier, quantifier, iteration_contexts, condition) do
    iteration_contexts = Helper.filter_expression(iteration_contexts)
    condition = Helper.filter_expression(condition)

    %__MODULE__{
      child: %Quantified{
        quantifier: quantifier,
        list: iteration_contexts,
        condition: condition
      }
    }
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

  def new(:between, operand, min, max) do
    operand = Helper.filter_expression(operand)
    min = Helper.filter_expression(min)
    max = Helper.filter_expression(max)

    %__MODULE__{
      child: %Between{
        operand: operand,
        min: min,
        max: max
      }
    }
  end

  def evaluate(
        %__MODULE__{
          child: %__MODULE__.Between{
            operand: operand,
            min: min,
            max: max
          }
        },
        context
      ) do
    left = new(:geq, operand, min)
    right = new(:leq, operand, max)
    evaluate(new(:and, left, right), context)
  end

  def evaluate(
        %__MODULE__{
          child: %Quantified{
            quantifier: quantifier,
            list: list,
            condition: condition
          }
        },
        context
      ) do
    do_apply_quantifier(quantifier, list, condition, context)
  end

  def evaluate(%__MODULE__{child: %String_{value: string}}, _context) do
    Value.new(string)
  end

  def evaluate(%__MODULE__{child: %Boolean{value: bool}}, _context) do
    Value.new(bool)
  end

  def evaluate(%__MODULE__{child: %Name{value: name}}, context) do
    Value.new(context[String.to_atom(name)])
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
    context = Map.put(context, :partial, [])

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
    |> Enum.map_reduce(context, fn new_assignments, context ->
      new_context = Enum.into(new_assignments, context)
      evaluation = evaluate(return_expression, new_context)
      current_partial = Map.get(context, :partial)
      list = [evaluation | Enum.reverse(current_partial)]
      new_partial = Enum.reverse(list)
      {evaluation, Map.put(context, :partial, new_partial)}
    end)
    |> elem(0)
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
          child: %Context{
            keys_with_values: keys_with_values
          }
        },
        context
      ) do
    {result, _current_context} =
      Enum.map_reduce(keys_with_values, context, fn {name, expression}, current_context ->
        value = evaluate(expression, current_context)
        new_context = Map.put_new(current_context, name, value)
        {{name, value}, new_context}
      end)

    result
    |> Enum.into(%{})
    |> Value.new()
  end

  def evaluate(
        %__MODULE__{
          child: %Access{
            name: name,
            operand: operand
          }
        },
        context
      ) do
    case evaluate(operand, context) do
      %Value{value: value, type: type} -> do_access(name, value, type, context)
      list when is_list(list) -> do_access(name, list, :list, context)
    end
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
            name: name,
            arguments: arguments
          }
        },
        context
      ) do
    name = Helper.filter_expression(name)

    name =
      case name do
        %__MODULE__{child: %Name{value: name}} ->
          name

        list when is_list(list) ->
          Enum.map_join(list, "_", fn val -> Helper.filter_expression(val).child.value end)
      end

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
         %FeelEx.Value{value: val1, type: type1},
         %FeelEx.Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) > to_timeout(val2))
  end

  defp do_gt(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 > val2)
  end

  defp do_lt(
         %FeelEx.Value{value: val1, type: type1},
         %FeelEx.Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) < to_timeout(val2))
  end

  defp do_lt(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 < val2)
  end

  defp do_leq(
         %FeelEx.Value{value: val1, type: type1},
         %FeelEx.Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) <= to_timeout(val2))
  end

  defp do_leq(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 <= val2)
  end

  defp do_geq(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 >= val2)
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: :time},
         %FeelEx.Value{value: val2, type: :time}
       )
       when is_struct(val1) and is_tuple(val2) do
    Logger.warning("Cannot compare #{inspect(val1)} with #{inspect(val2)}")
    Value.new(nil)
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: :time},
         %FeelEx.Value{value: val2, type: :time}
       )
       when is_struct(val2) and is_tuple(val1) do
    Logger.warning("Cannot compare #{inspect(val1)} with #{inspect(val2)}")
    Value.new(nil)
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: type1},
         %FeelEx.Value{value: val2, type: type2}
       )
       when type1 == :null or type2 == :null do
    Value.new(val1 == val2)
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: type1},
         %FeelEx.Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) == to_timeout(val2))
  end

  defp do_eq(
         %FeelEx.Value{value: val1, type: type},
         %FeelEx.Value{value: val2, type: type}
       ) do
    Value.new(val1 == val2)
  end

  defp do_eq(l1, l2) when is_list(l1) and is_list(l2) do
    Value.new(l1 == l2)
  end

  defp do_neq(val1, val2) do
    case do_eq(val1, val2) do
      %FeelEx.Value{value: value, type: :boolean} ->
        %FeelEx.Value{value: not value, type: :boolean}

      val ->
        val
    end
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
    Enum.filter(list, fn %Value{value: operand, type: type} = value ->
      new_context = Map.put(context, :item, value)

      new_context =
        if type == :context do
          Map.merge(new_context, operand)
        else
          new_context
        end

      evaluate(filter, new_context) == %Value{value: true, type: :boolean}
    end)
  end

  defp do_access(name, operand, :context, _context) do
    value = Map.get(operand, name)
    if is_nil(value), do: Value.new(nil), else: value
  end

  defp do_access(name, operand, :list, context) do
    Enum.map(operand, fn elem ->
      case elem do
        %Value{value: value, type: type} -> do_access(name, value, type, context)
        list when is_list(list) -> do_access(name, list, :list, context)
      end
    end)
  end

  defp do_access(name, operand, _type, _context) do
    Logger.warning("No property found with name #{inspect(name)} of value #{inspect(operand)}.")
    Value.new(nil)
  end

  defp do_apply_quantifier(:some, list, condition, context) do
    context = Map.put(context, :partial, [])

    list
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
    |> Enum.map_reduce(context, fn new_assignments, context ->
      new_context = Enum.into(new_assignments, context)
      evaluation = evaluate(condition, new_context)
      current_partial = Map.get(context, :partial)
      list = [evaluation | Enum.reverse(current_partial)]
      new_partial = Enum.reverse(list)
      {evaluation, Map.put(context, :partial, new_partial)}
    end)
    |> elem(0)
    |> Enum.any?(fn x -> x.value == true end)
    |> Value.new()
  end

  defp do_apply_quantifier(:every, list, condition, context) do
    context = Map.put(context, :partial, [])

    list
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
    |> Enum.map_reduce(context, fn new_assignments, context ->
      new_context = Enum.into(new_assignments, context)
      evaluation = evaluate(condition, new_context)
      current_partial = Map.get(context, :partial)
      list = [evaluation | Enum.reverse(current_partial)]
      new_partial = Enum.reverse(list)
      {evaluation, Map.put(context, :partial, new_partial)}
    end)
    |> elem(0)
    |> Enum.all?(fn x -> x.value == true end)
    |> Value.new()
  end
end
