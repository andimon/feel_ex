defmodule FeelEx.Expression do
  @moduledoc false
  require Logger

  alias FeelEx.{Helper, Value, Functions}

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
    operand =
      if is_atom(operand) do
        Value.new(context[operand])
      else
        evaluate(operand, context)
      end

    case operand do
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

    func_name = String.to_atom(name)

    arguments =
      Enum.map(arguments, fn expression -> evaluate(expression, context) end)
      |> Helper.argument_wrapper(func_name)

    try do
      case func_name do
        :not -> :negate
        func_name -> func_name
      end
      |> (&apply(Functions, &1, arguments)).()
    rescue
      _e in FunctionClauseError ->
        Logger.warning(
          "[FUNCTION_INVOCATION_FAILURE] Failed to invoke function '#{func_name}': Illegal arguments: #{inspect(arguments)}"
        )

        Value.new(nil)

      _e in UndefinedFunctionError ->
        Logger.warning(
          "[NO_FUNCTION_FOUND] No function found with name '#{func_name}' and #{length(arguments)} parameters"
        )

        Value.new(nil)
    end
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

  defp do_add(%Value{value: d1, type: dt1}, %Value{
         value: d2,
         type: dt2
       })
       when dt1 in [:days_time_duration, :years_months_duration] and
              dt2 in [:days_time_duration, :years_months_duration] do
    Value.new(Duration.add(d1, d2))
  end

  defp do_add(%Value{value: datetime, type: :date_time}, %Value{
         value: duration,
         type: duration_type
       })
       when duration_type in [:days_time_duration, :years_months_duration] do
    case datetime do
      %NaiveDateTime{} -> Value.new(NaiveDateTime.shift(datetime, duration))
      {datetime, offset} -> Value.new(NaiveDateTime.shift(datetime, duration), offset)
      {datetime, _offset, zone_id} -> Value.new(NaiveDateTime.shift(datetime, duration), zone_id)
    end
  end

  defp do_add(
         %Value{value: duration, type: duration_type},
         %Value{value: datetime, type: :date_time}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    case datetime do
      %NaiveDateTime{} -> Value.new(NaiveDateTime.shift(datetime, duration))
      {datetime, offset} -> Value.new(NaiveDateTime.shift(datetime, duration), offset)
      {datetime, _offset, zone_id} -> Value.new(NaiveDateTime.shift(datetime, duration), zone_id)
    end
  end

  defp do_add(
         %Value{value: time, type: :time},
         %Value{value: duration, type: duration_type}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    case time do
      %Time{} -> Value.new(Time.shift(time, duration))
      {time, offset} -> Value.new(Time.shift(time, duration), offset)
      {time, _offset, zone_id} -> Value.new(Time.shift(time, duration), zone_id)
    end
  end

  defp do_add(
         %Value{value: duration, type: duration_type},
         %Value{value: time, type: :time}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    case time do
      %Time{} -> Value.new(Time.shift(time, duration))
      {time, offset} -> Value.new(Time.shift(time, duration), offset)
      {time, _offset, zone_id} -> Value.new(Time.shift(time, duration), zone_id)
    end
  end

  defp do_add(
         %Value{value: date, type: :date},
         %Value{value: duration, type: duration_type}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    Value.new(Date.shift(date, duration))
  end

  defp do_add(
         %Value{value: duration, type: duration_type},
         %Value{value: date, type: :date}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    Value.new(Date.shift(date, duration))
  end

  defp do_add(
         %Value{value: val1, type: :number},
         %Value{value: val2, type: :number}
       ) do
    Value.new(val1 + val2)
  end

  defp do_add(
         %Value{value: val1, type: :string},
         %Value{value: val2, type: :string}
       ) do
    Value.new(val1 <> val2)
  end

  defp do_multiply(
         %Value{value: %Duration{} = d, type: :years_months_duration},
         %Value{value: n, type: :number}
       ) do
    {y, m} = {d.year * trunc(n), d.month * trunc(n)}

    {y, m} =
      Helper.normalise(y, m)

    Value.new(Duration.new!(year: y, month: m))
  end

  defp do_multiply(
         %Value{value: n, type: :number},
         %Value{value: %Duration{} = d, type: :years_months_duration}
       ) do
    {y, m} = {d.year * trunc(n), d.month * trunc(n)}
    {y, m} = Helper.normalise(y, m)
    Value.new(Duration.new!(year: y, month: m))
  end

  defp do_multiply(
         %Value{value: n, type: :number},
         %Value{value: %Duration{} = d, type: :days_time_duration}
       ) do
    {day, hour, minute, second} =
      {d.day * trunc(n), d.hour * trunc(n), d.second * trunc(n), d.second * trunc(n)}

    {day, hour, minute, second} = Helper.normalise(day, hour, minute, second)

    Value.new(Duration.new!(day: day, month: hour, minute: minute, second: second))
  end

  defp do_multiply(
         %Value{value: %Duration{} = d, type: :days_time_duration},
         %Value{value: n, type: :number}
       ) do
    {day, hour, minute, second} =
      {d.day * trunc(n), d.hour * trunc(n), d.second * trunc(n), d.second * trunc(n)}

    {day, hour, minute, second} = Helper.normalise(day, hour, minute, second)
    Value.new(Duration.new!(day: day, month: hour, minute: minute, second: second))
  end

  defp do_multiply(
         %Value{value: val1, type: :number},
         %Value{value: val2, type: :number}
       ) do
    Value.new(val1 * val2)
  end

  defp do_exponentiation(
         %Value{value: val1, type: :number},
         %Value{value: val2, type: :number}
       ) do
    Value.new(val1 ** val2)
  end

  defp do_subtract(
         %Value{value: val1, type: :number},
         %Value{value: val2, type: :number}
       ) do
    Value.new(val1 - val2)
  end

  defp do_subtract(
         %Value{value: %Time{} = t1, type: :time},
         %Value{value: %Time{} = t2, type: :time}
       ) do
    diff_seconds = Time.diff(t1, t2)

    hours = div(diff_seconds, 3600)
    minutes = div(rem(diff_seconds, 3600), 60)
    seconds = rem(diff_seconds, 60)
    Value.new(%Duration{hour: hours, minute: minutes, second: seconds})
  end

  defp do_subtract(
         %Value{value: {%Time{} = t1, offset}, type: :time},
         %Value{value: {%Time{} = t2, offset}, type: :time}
       ) do
    diff_seconds = Time.diff(t1, t2)

    hours = div(diff_seconds, 3600)
    minutes = div(rem(diff_seconds, 3600), 60)
    seconds = rem(diff_seconds, 60)
    Value.new(%Duration{hour: hours, minute: minutes, second: seconds})
  end

  defp do_subtract(
         %Value{value: {%Time{} = t1, offset, zoneid}, type: :time},
         %Value{value: {%Time{} = t2, offset, zoneid}, type: :time}
       ) do
    Time.diff(t1, t2)
    |> Helper.duration_from_seconds()
    |> Value.new()
  end

  defp do_subtract(
         %Value{value: d1, type: :date},
         %Value{value: d2, type: duration_type}
       )
       when duration_type in [:days_time_duration, :years_months_duration] do
    Value.new(Date.shift(d1, Duration.multiply(d2, -1)))
  end

  defp do_subtract(%Value{value: d1, type: :date}, %Value{value: d2, type: :date}) do
    Value.new(%Duration{day: Date.diff(d1, d2)})
  end

  defp do_subtract(%Value{value: %NaiveDateTime{} = d1, type: :date_time}, %Value{
         value:
           %NaiveDateTime{} =
             d2,
         type: :date_time
       }) do
    NaiveDateTime.diff(d1, d2)
    |> Helper.duration_from_seconds()
    |> Value.new()
  end

  defp do_subtract(%Value{value: {%NaiveDateTime{} = d1, offset}, type: :date_time}, %Value{
         value:
           {%NaiveDateTime{} =
              d2, offset},
         type: :date_time
       }) do
    NaiveDateTime.diff(d1, d2)
    |> Helper.duration_from_seconds()
    |> Value.new()
  end

  defp do_subtract(
         %Value{value: {%NaiveDateTime{} = d1, offset, zoneid}, type: :date_time},
         %Value{
           value:
             {%NaiveDateTime{} =
                d2, offset, zoneid},
           type: :date_time
         }
       ) do
    NaiveDateTime.diff(d1, d2)
    |> Helper.duration_from_seconds()
    |> Value.new()
  end

  defp do_subtract(
         %Value{value: %NaiveDateTime{} = dt, type: :date_time},
         %Value{
           value: %Duration{} = dur,
           type: dtt
         }
       )
       when dtt in [:days_time_duration, :years_months_duration] do
    dur = trunc(to_timeout(dur) / 1000)

    NaiveDateTime.add(dt, -dur)
    |> Value.new()
  end

  defp do_subtract(
         %Value{value: {%NaiveDateTime{} = dt, offset}, type: :date_time},
         %Value{
           value: %Duration{} = dur,
           type: dtt
         }
       )
       when dtt in [:days_time_duration, :years_months_duration] do
    dur = trunc(to_timeout(dur) / 1000)

    NaiveDateTime.add(dt, -dur)
    |> Value.new(offset)
  end

  defp do_subtract(
         %Value{value: {%NaiveDateTime{} = dt, _offset, zoneid}, type: :date_time},
         %Value{
           value: %Duration{} = dur,
           type: dtt
         }
       )
       when dtt in [:days_time_duration, :years_months_duration] do
    dur = trunc(to_timeout(dur) / 1000)

    NaiveDateTime.add(dt, -dur)
    |> Value.new(zoneid)
  end

  defp do_subtract(
         %Value{value: %Duration{} = dur1, type: :days_time_duration},
         %Value{value: %Duration{} = dur2, type: :days_time_duration}
       ) do
    (trunc(to_timeout(dur1) / 1000) - trunc(to_timeout(dur2) / 1000))
    |> Helper.duration_from_seconds()
    |> Value.new()
  end

  defp do_subtract(
         %Value{value: %Duration{} = dur1, type: :years_months_duration},
         %Value{value: %Duration{} = dur2, type: :years_months_duration}
       ) do
    m1 = dur1.month + dur1.year * 12
    m2 = dur2.month + dur2.year * 12

    case {div(m1 - m2, 12), rem(m1 - m2, 12)} do
      {0, m} -> Value.new(%Duration{month: m})
      {y, 0} -> Value.new(%Duration{year: y})
      {y, m} -> Value.new(%Duration{year: y, month: m})
    end
  end

  defp do_subtract(v1, v2) do
    Logger.warning("Cannot subtract #{inspect(v1)} with #{inspect(v2)}.")
    Value.new(nil)
  end

  defp do_divide(%Value{value: val1, type: :days_time_duration}, %Value{
         value: val2,
         type: :days_time_duration
       }) do
    Value.new(div(to_timeout(val1), to_timeout(val2)))
  end

  defp do_divide(%Value{value: %Duration{} = d1, type: :years_months_duration}, %Value{
         value: %Duration{} = d2,
         type: :years_months_duration
       }) do
    m1 = d1.year * 12 + d1.month
    m2 = d2.year * 12 + d2.month
    Value.new(div(m1, m2))
  end

  defp do_divide(%Value{value: %Duration{} = d, type: :years_months_duration}, %Value{
         value: n,
         type: :number
       }) do
    months = div(d.year * 12 + d.month, trunc(n))
    year = div(months, 12)
    month = rem(months, 12)
    Value.new(Duration.new!(year: year, month: month))
  end

  defp do_divide(%Value{value: %Duration{} = d, type: :days_time_duration}, %Value{
         value: n,
         type: :number
       }) do
    seconds = d.day * 86400 + d.hour * 3600 + d.minute * 60 + d.second
    seconds = div(seconds, trunc(n))
    days_in_seconds = div(seconds, 86400)
    seconds = rem(seconds, 86400)

    hour_in_seconds = div(seconds, 3600)
    seconds = rem(seconds, 3600)

    minutes_in_seconds = div(seconds, 60)
    seconds = rem(seconds, 60)

    Value.new(
      Duration.new!(
        day: days_in_seconds,
        hour: hour_in_seconds,
        minute: minutes_in_seconds,
        day: days_in_seconds,
        second: seconds
      )
    )
  end

  defp do_divide(%Value{value: val1, type: :number}, %Value{value: val2, type: :number}) do
    Value.new(val1 / val2)
  end

  defp do_gt(
         %Value{value: val1, type: type1},
         %Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) > to_timeout(val2))
  end

  defp do_gt(
         %Value{value: val1, type: type},
         %Value{value: val2, type: type}
       ) do
    Value.new(val1 > val2)
  end

  defp do_lt(
         %Value{value: val1, type: type1},
         %Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) < to_timeout(val2))
  end

  defp do_lt(
         %Value{value: val1, type: type},
         %Value{value: val2, type: type}
       ) do
    Value.new(val1 < val2)
  end

  defp do_leq(
         %Value{value: val1, type: type1},
         %Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) <= to_timeout(val2))
  end

  defp do_leq(
         %Value{value: val1, type: type},
         %Value{value: val2, type: type}
       ) do
    Value.new(val1 <= val2)
  end

  defp do_geq(
         %Value{value: val1, type: type},
         %Value{value: val2, type: type}
       ) do
    Value.new(val1 >= val2)
  end

  defp do_eq(
         %Value{value: val1, type: :time},
         %Value{value: val2, type: :time}
       )
       when is_struct(val1) and is_tuple(val2) do
    Logger.warning("Cannot compare #{inspect(val1)} with #{inspect(val2)}")
    Value.new(nil)
  end

  defp do_eq(
         %Value{value: val1, type: :time},
         %Value{value: val2, type: :time}
       )
       when is_struct(val2) and is_tuple(val1) do
    Logger.warning("Cannot compare #{inspect(val1)} with #{inspect(val2)}")
    Value.new(nil)
  end

  defp do_eq(
         %Value{value: val1, type: type1},
         %Value{value: val2, type: type2}
       )
       when type1 == :null or type2 == :null do
    Value.new(val1 == val2)
  end

  defp do_eq(
         %Value{value: val1, type: type1},
         %Value{value: val2, type: type2}
       )
       when type1 in [:days_time_duration, :years_months_duration] and
              type2 in [:days_time_duration, :years_months_duration] do
    Value.new(to_timeout(val1) == to_timeout(val2))
  end

  defp do_eq(
         %Value{value: val1, type: type},
         %Value{value: val2, type: type}
       ) do
    Value.new(val1 == val2)
  end

  defp do_eq(l1, l2) when is_list(l1) and is_list(l2) do
    Value.new(l1 == l2)
  end

  defp do_eq(
         %Value{value: val1},
         %Value{value: val2}
       ) do
    Logger.warning("Cannot compare #{inspect(val1)} with #{inspect(val2)}")
    Value.new(nil)
  end

  defp do_neq(val1, val2) do
    case do_eq(val1, val2) do
      %Value{value: value, type: :boolean} ->
        %Value{value: not value, type: :boolean}

      val ->
        val
    end
  end

  defp do_and(%Value{value: true, type: :boolean}, right_tree, context) do
    do_and(evaluate(right_tree, context))
  end

  defp do_and(%Value{}, _right_tree, _context) do
    %Value{value: false, type: :boolean}
  end

  defp do_and(%Value{value: true, type: :boolean}) do
    Value.new(true)
  end

  defp do_and(%Value{}) do
    Value.new(false)
  end

  defp do_or(%Value{value: true, type: :boolean}, _right_tree, _context) do
    %Value{value: true, type: :boolean}
  end

  defp do_or(%Value{value: false, type: :boolean}, right_tree, context) do
    do_or(evaluate(right_tree, context))
  end

  defp do_or(%Value{value: value, type: :boolean}) when is_boolean(value) do
    %Value{value: value, type: :boolean}
  end

  defp do_negation(%Value{value: val1, type: :number}) do
    Value.new(-val1)
  end

  defp do_if(
         %Value{value: true, type: :boolean},
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
         %Value{value: first_bound, type: :number},
         %Value{value: second_bound, type: :number}
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

  defp do_access(name, %Duration{} = d, :days_time_duration, _context)
       when name in [:days, :hours, :minutes, :seconds] do
    {day, hour, minute, second} = Helper.normalise(d.day, d.hour, d.minute, d.second)

    case name do
      :days -> day
      :hours -> hour
      :minutes -> minute
      :seconds -> second
    end
    |> Value.new()
  end

  defp do_access(name, %Duration{} = d, :years_months_duration, _context)
       when name in [:years, :months] do
    {years, months} = Helper.normalise(d.year, d.month)

    case name do
      :years -> years
      :months -> months
    end
    |> Value.new()
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

  defp do_access(name, operand, :date, _context) when name in [:year, :month, :day] do
    Value.new(Map.get(operand, name))
  end

  defp do_access(name, {operand, _}, :date_time, _context)
       when name in [:year, :month, :day] do
    Value.new(Map.get(operand, name))
  end

  defp do_access(name, {operand, _, _}, :date_time, _context)
       when name in [:year, :month, :day] do
    Value.new(Map.get(operand, name))
  end

  defp do_access(name, %NaiveDateTime{} = dt, :date_time, _context)
       when name in [:year, :month, :day] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%NaiveDateTime{} = dt, _}, :date_time, _context)
       when name in [:year, :month, :day] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%NaiveDateTime{} = dt, _, _}, :date_time, _context)
       when name in [:year, :month, :day] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, %NaiveDateTime{} = dt, :date_time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%NaiveDateTime{} = dt, _}, :date_time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%NaiveDateTime{} = dt, _, _}, :date_time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, %Time{} = dt, :time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%Time{} = dt, _}, :time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(name, {%Time{} = dt, _, _}, :time, _context)
       when name in [:hour, :minute, :second] do
    Value.new(Map.get(dt, name))
  end

  defp do_access(:"time offset", {_, to}, type, _context) when type in [:time, :date_time] do
    Value.new(Helper.offset_to_duration(to))
  end

  defp do_access(:"time offset", {_, to, _}, type, _context) when type in [:time, :date_time] do
    Value.new(Helper.offset_to_duration(to))
  end

  defp do_access(:timezone, {_, _, zoneid}, type, _context) when type in [:time, :date_time] do
    Value.new(zoneid)
  end

  defp do_access(:weekday, operand, :date, _context) do
    Value.new(Date.day_of_week(operand))
  end

  defp do_access(:weekday, %NaiveDateTime{} = dt, :date_time, _context) do
    Value.new(Date.day_of_week(dt))
  end

  defp do_access(:weekday, {%NaiveDateTime{} = dt, _offset}, :date_time, _context) do
    Value.new(Date.day_of_week(dt))
  end

  defp do_access(:weekday, {%NaiveDateTime{} = dt, _offset, _zoneid}, :date_time, _context) do
    Value.new(Date.day_of_week(dt))
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
