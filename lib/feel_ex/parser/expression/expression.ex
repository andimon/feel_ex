defmodule FeelEx.Expression do
  @moduledoc """
  AST representation of a FeelEx's program.
  """
  require Logger

  defstruct [:child]

  @type t(e) :: %__MODULE__{child: e}
  @type t() :: %__MODULE__{child: struct()}

  defmodule Access do
    @moduledoc """
    AST representation for dot operator.
    """
    @type t :: %__MODULE__{name: atom(), operand: struct()}
    defstruct [:name, :operand]

    @doc """
    Create new Access Expression AST.
    """
    @spec new(atom(), FeelEx.Expression.t()) :: FeelEx.Expression.t(t())
    def new(name, %FeelEx.Expression{} = operand) when is_atom(name) do
      %FeelEx.Expression{child: %__MODULE__{name: name, operand: operand}}
    end

    @spec new(atom(), atom()) :: FeelEx.Expression.t(t())
    def new(name, operand) when is_atom(name) and is_atom(operand) do
      %FeelEx.Expression{child: %__MODULE__{name: name, operand: operand}}
    end
  end

  defmodule Between do
    @moduledoc """
    AST representation for between operator.
    """
    @type t :: %__MODULE__{
            operand: FeelEx.Expression.t(),
            min: FeelEx.Expression.t(),
            max: FeelEx.Expression.t()
          }
    defstruct [:operand, :min, :max]

    @doc """
    Create new Between Operation AST.
    """
    @spec new(FeelEx.Expression.t(), FeelEx.Expression.t(), FeelEx.Expression.t()) ::
            FeelEx.Expression.t(t())
    def new(
          %FeelEx.Expression{} = operand,
          %FeelEx.Expression{} = min,
          %FeelEx.Expression{} = max
        ) do
      %FeelEx.Expression{child: %__MODULE__{operand: operand, min: min, max: max}}
    end
  end

  defmodule BinaryOp do
    @moduledoc """
    AST representation for a binary operator.
    """
    @type t :: %__MODULE__{
            type: atom(),
            left_tree: FeelEx.Expression.t(),
            right_tree: FeelEx.Expression.t()
          }
    defstruct [:type, :left_tree, :right_tree]

    @doc """
    Create new Binary Operation AST.
    """
    @spec new(atom(), FeelEx.Expression.t(), FeelEx.Expression.t()) :: FeelEx.Expression.t(t())
    def new(type, %FeelEx.Expression{} = left_tree, %FeelEx.Expression{} = right_tree)
        when is_atom(type) do
      %FeelEx.Expression{
        child: %__MODULE__{type: type, left_tree: left_tree, right_tree: right_tree}
      }
    end
  end

  defmodule Boolean do
    @moduledoc """
    AST representation for a boolean.
    """
    @type t :: %__MODULE__{value: boolean()}
    defstruct [:value]

    @doc """
    Create new Boolean Expression AST.
    """
    @spec new(boolean()) :: FeelEx.Expression.t(t())
    def new(value) when is_boolean(value) do
      %FeelEx.Expression{child: %__MODULE__{value: value}}
    end
  end

  defmodule Context do
    @moduledoc """
    AST representation for a context.
    """
    @type t() :: %__MODULE__{keys_with_values: [{atom(), FeelEx.Expression.t()}]}
    defstruct [:keys_with_values]

    @doc """
    Create new Context Expression AST.
    """
    @spec new([{atom(), FeelEx.Expression.t()}]) :: FeelEx.Expression.t(t())
    def new(keys_with_values) when is_list(keys_with_values) do
      %FeelEx.Expression{child: %__MODULE__{keys_with_values: keys_with_values}}
    end
  end

  defmodule FilterList do
    @moduledoc """
    AST representation for a filter list.
    """
    @type t() :: %__MODULE__{list: FeelEx.Expression.t(), filter: FeelEx.Expression.t()}
    defstruct [:list, :filter]

    @doc """
    Create new Filter Expression AST.
    """
    @spec new(FeelEx.Expression.t(), FeelEx.Expression.t()) :: FeelEx.Expression.t(t())
    def new(%FeelEx.Expression{} = list, %FeelEx.Expression{} = filter) do
      %FeelEx.Expression{child: %__MODULE__{list: list, filter: filter}}
    end
  end

  defmodule For do
    @moduledoc """
    AST representation for a for expression.
    """
    @type t() :: %__MODULE__{
            iteration_contexts: [{FeelEx.Expression.t(), FeelEx.Expression.t()}],
            return_expression: FeelEx.Expression.t()
          }
    defstruct [:iteration_contexts, :return_expression]

    @doc """
    Create new FOr Expression AST.
    """
    @spec new([{FeelEx.Expression.t(), FeelEx.Expression.t()}], struct()) ::
            FeelEx.Expression.t(t())
    def new(iteration_contexts, %FeelEx.Expression{} = return_expression)
        when is_list(iteration_contexts) do
      %FeelEx.Expression{
        child: %__MODULE__{
          iteration_contexts: iteration_contexts,
          return_expression: return_expression
        }
      }
    end
  end

  defmodule Function do
    @moduledoc """
    AST representation for a function call.
    """
    @type t() :: %__MODULE__{
            name: FeelEx.Expression.t() | [FeelEx.Expression.t()],
            arguments: [FeelEx.Expression.t()]
          }
    defstruct [:name, :arguments]

    @doc """
    Create new Funcation Call Expression AST.
    """
    @spec new(FeelEx.Expression.t(), [FeelEx.Expression.t()]) :: FeelEx.Expression.t(t())
    def new(%FeelEx.Expression{} = name, arguments) when is_list(arguments) do
      %FeelEx.Expression{child: %__MODULE__{name: name, arguments: arguments}}
    end

    @spec new([FeelEx.Expression.t()], [FeelEx.Expression.t()]) :: FeelEx.Expression.t(t())
    def new(name, arguments) when is_list(name) and is_list(arguments) do
      %FeelEx.Expression{child: %__MODULE__{name: name, arguments: arguments}}
    end
  end

  defmodule If do
    @moduledoc """
    AST representation for an if statement.
    """
    @type t() :: %__MODULE__{
            condition: FeelEx.Expression.t(),
            conditional_statement: FeelEx.Expression.t(),
            else_statement: FeelEx.Expression.t()
          }
    defstruct [:condition, :conditional_statement, :else_statement]

    @doc """
    Create new IF Expression AST.
    """
    @spec new(FeelEx.Expression.t(), FeelEx.Expression.t(), FeelEx.Expression.t()) ::
            FeelEx.Expression.t(t())
    def new(
          %FeelEx.Expression{} = condition,
          %FeelEx.Expression{} = conditional_statement,
          %FeelEx.Expression{} = else_statement
        ) do
      %FeelEx.Expression{
        child: %__MODULE__{
          condition: condition,
          conditional_statement: conditional_statement,
          else_statement: else_statement
        }
      }
    end
  end

  defmodule List do
    @moduledoc """
    AST repesentation for a list.
    """
    @type t() :: %__MODULE__{elements: [FeelEx.Expression.t()]}
    defstruct [:elements]

    @doc """
    Create new List Expression AST.
    """
    @spec new([FeelEx.Expression.t()]) :: FeelEx.Expression.t(t())
    def new(elements) when is_list(elements) do
      %FeelEx.Expression{child: %__MODULE__{elements: elements}}
    end
  end

  defmodule Name do
    @moduledoc """
    AST representation for a name.
    """
    @type t() :: %__MODULE__{value: String.t()}

    @doc """
    Create new Name Value Expression AST.
    """
    defstruct [:value]
    @spec new(String.t()) :: FeelEx.Expression.t(t())
    def new(value), do: %FeelEx.Expression{child: %__MODULE__{value: value}}
  end

  defmodule Negation do
    @moduledoc """
    AST representation for negation operation.
    """
    @type t() :: %__MODULE__{operand: FeelEx.Expression.t()}
    defstruct [:operand]

    @doc """
    Create new Negation Expression AST.
    """
    @spec new(FeelEx.Expression.t()) :: FeelEx.Expression.t(t())
    def new(%FeelEx.Expression{} = operand),
      do: %FeelEx.Expression{child: %__MODULE__{operand: operand}}
  end

  defmodule Number do
    @moduledoc """
    AST representation for a number.
    """
    @type t() :: %__MODULE__{value: number()}
    defstruct [:value]

    @doc """
    Create new Number Expression AST.
    """
    @spec new(number()) :: FeelEx.Expression.t(t())
    def new(value) when is_number(value) do
      %FeelEx.Expression{child: %__MODULE__{value: value}}
    end
  end

  defmodule Quantified do
    @moduledoc """
    AST representation for a quantified expression.
    """
    @type t() :: %__MODULE__{
            quantifier: :some | :every,
            list: [{FeelEx.Expression.t(), FeelEx.Expression.t()}],
            condition: FeelEx.Expression.t()
          }
    defstruct [:quantifier, :list, :condition]

    @doc """
    Create new Quantified Expression AST.
    """
    @spec new(
            :some | :every,
            [{FeelEx.Expression.t(), FeelEx.Expression.t()}],
            FeelEx.Expression.t()
          ) :: FeelEx.Expression.t(t())
    def new(quantifier, list, %FeelEx.Expression{} = condition)
        when quantifier in [:some, :every] and is_list(list) do
      %FeelEx.Expression{
        child: %__MODULE__{quantifier: quantifier, list: list, condition: condition}
      }
    end
  end

  defmodule Range do
    @moduledoc """
    AST representation for a range expression.
    """
    @type t() :: %__MODULE__{
            first_bound: FeelEx.Expression.t(),
            second_bound: FeelEx.Expression.t()
          }
    defstruct [:first_bound, :second_bound]

    @doc """
    Create new Range Expression AST.
    """
    @spec new(FeelEx.Expression.t(), FeelEx.Expression.t()) :: FeelEx.Expression.t(t())
    def new(%FeelEx.Expression{} = first_bound, %FeelEx.Expression{} = second_bound) do
      %FeelEx.Expression{child: %__MODULE__{first_bound: first_bound, second_bound: second_bound}}
    end
  end

  defmodule String_ do
    @moduledoc """
    AST representation for a string.
    """
    @type t :: %__MODULE__{value: String.t()}
    defstruct [:value]

    @doc """
    Create new String Expression AST.
    """
    @spec new(String.t()) :: FeelEx.Expression.t(t())
    def new(value) when is_binary(value) do
      %FeelEx.Expression{child: %__MODULE__{value: value}}
    end
  end
end
