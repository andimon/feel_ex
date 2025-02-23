defmodule FeelEx.Expression do
  @moduledoc """
  AST representation of a FeelEx's program.
  """
  require Logger

  alias FeelEx.Helper

  defstruct [:child]

  defmodule Access do
    @moduledoc """
    AST representation for dot operator.
    """
    @opaque t :: %__MODULE__{name: atom(), operand: struct()}
    defstruct [:name, :operand]

    @doc """
    Create new Access Expression AST.
    """
    @spec new(atom(), struct()) :: t()
    def new(name, operand) when is_atom(name) and is_struct(operand) do
      %FeelEx.Expression{child: %__MODULE__{name: name, operand: operand}}
    end
  end

  defmodule Between do
    @moduledoc """
    AST representation for between operator.
    """
    @opaque t :: %__MODULE__{operand: struct(), min: struct(), max: struct()}
    defstruct [:operand, :min, :max]

    @doc """
    Create new Between Operation AST.
    """
    @spec new(struct(), struct(), struct()) :: t()
    def new(operand, min, max) when is_struct(operand) and is_struct(min) and is_struct(max) do
      %FeelEx.Expression{child: %__MODULE__{operand: operand, min: min, max: max}}
    end
  end

  defmodule BinaryOp do
    @moduledoc """
    AST representation for a binary operator.
    """
    @opaque t :: %__MODULE__{type: atom(), left_tree: struct(), right_tree: struct()}
    defstruct [:type, :left_tree, :right_tree]

    @doc """
    Create new Binary Operation AST.
    """
    @spec new(atom(), struct(), struct()) :: t()
    def new(type, left_tree, right_tree)
        when is_atom(type) and is_struct(left_tree) and is_struct(right_tree) do
      %FeelEx.Expression{
        child: %__MODULE__{type: type, left_tree: left_tree, right_tree: right_tree}
      }
    end
  end

  defmodule Boolean do
    @moduledoc """
    AST representation for a boolean.
    """
    @opaque t :: %__MODULE__{value: boolean()}
    defstruct [:value]

    @doc """
    Create new Boolean Expression AST.
    """
    @spec new(boolean()) :: t()
    def new(value) when is_boolean(value) do
      %FeelEx.Expression{child: %__MODULE__{value: value}}
    end
  end

  defmodule Context do
    @moduledoc """
    AST representation for a context.
    """
    @opaque t() :: %__MODULE__{keys_with_values: [{atom(), struct()}]}
    defstruct [:keys_with_values]

    @doc """
    Create new Context Expression AST.
    """
    @spec new([{atom(), struct()}]) :: t()
    def new(keys_with_values) when is_list(keys_with_values) do
      %FeelEx.Expression{child: %__MODULE__{keys_with_values: keys_with_values}}
    end
  end

  defmodule FilterList do
    @moduledoc """
    AST representation for a filter list.
    """
    @opaque t() :: %__MODULE__{list: struct(), filter: struct()}
    defstruct [:list, :filter]

    @doc """
    Create new Filter Expression AST.
    """
    @spec new(struct(), struct()) :: t()
    def new(list, filter) when is_struct(list) and is_struct(filter) do
      %FeelEx.Expression{child: %__MODULE__{list: list, filter: filter}}
    end
  end

  defmodule For do
    @moduledoc """
    AST representation for a for expression.
    """
    @opaque t() :: %__MODULE__{
              iteration_contexts: [{struct(), struct()}],
              return_expression: struct()
            }
    defstruct [:iteration_contexts, :return_expression]

    @doc """
    Create new FOr Expression AST.
    """
    @spec new([{struct(), struct()}], struct()) :: t()
    def new(iteration_contexts, return_expression) do
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
    @opaque t() :: %__MODULE__{name: struct(), arguments: [struct()]}
    defstruct [:name, :arguments]

    @doc """
    Create new Funcation Call Expression AST.
    """
    @spec new(struct(), [struct()]) :: t()
    def new(name, arguments) do
      %FeelEx.Expression{child: %__MODULE__{name: name, arguments: arguments}}
    end
  end

  defmodule If do
    @moduledoc """
    AST representation for an if statement.
    """
    @opaque t() :: %__MODULE__{
              condition: struct(),
              conditional_statement: struct(),
              else_statement: struct()
            }
    defstruct [:condition, :conditional_statement, :else_statement]

    @doc """
    Create new IF Expression AST.
    """
    @spec new(struct(), struct(), struct()) :: t()
    def new(condition, conditional_statement, else_statement) do
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
    @opaque t() :: %__MODULE__{elements: [struct()]}
    defstruct [:elements]

    @doc """
    Create new List Expression AST.
    """
    @spec new([struct()]) :: t()
    def new(elements), do: %FeelEx.Expression{child: %__MODULE__{elements: elements}}
  end

  defmodule Name do
    @moduledoc """
    AST representation for a name.
    """
    @opaque t() :: %__MODULE__{value: String.t()}

    @doc """
    Create new Name Value Expression AST.
    """
    defstruct [:value]
    @spec new(String.t()) :: t()
    def new(value), do: %FeelEx.Expression{child: %__MODULE__{value: value}}
  end

  defmodule Negation do
    @moduledoc """
    AST representation for negation operation.
    """
    @opaque t() :: %__MODULE__{operand: struct()}
    defstruct [:operand]

    @doc """
    Create new Negation Expression AST.
    """
    @spec new(struct()) :: t()
    def new(operand), do: %FeelEx.Expression{child: %__MODULE__{operand: operand}}
  end

  defmodule Number do
    @moduledoc """
    AST representation for a number.
    """
    @opaque t() :: %__MODULE__{value: number()}
    defstruct [:value]

    @doc """
    Create new Number Expression AST.
    """
    @spec new(number()) :: t()
    def new(value), do: %FeelEx.Expression{child: %__MODULE__{value: value}}
  end

  defmodule Quantified do
    @moduledoc """
    AST representation for a quantified expression.
    """
    @opaque t() :: %__MODULE__{
              quantifier: :some | :every,
              list: [{struct(), struct()}],
              condition: struct()
            }
    defstruct [:quantifier, :list, :condition]

    @doc """
    Create new Quantified Expression AST.
    """
    @spec new(:some | :every, [{struct(), struct()}], struct()) :: t()
    def new(quantifier, list, condition),
      do: %FeelEx.Expression{
        child: %__MODULE__{quantifier: quantifier, list: list, condition: condition}
      }
  end

  defmodule Range do
    @moduledoc """
    AST representation for a range expression.
    """
    @opaque t() :: %__MODULE__{first_bound: struct(), second_bound: struct()}
    defstruct [:first_bound, :second_bound]

    @doc """
    Create new Range Expression AST.
    """
    @spec new(struct(), struct()) :: t()
    def new(first_bound, second_bound) do
      %FeelEx.Expression{child: %__MODULE__{first_bound: first_bound, second_bound: second_bound}}
    end
  end

  defmodule String_ do
    @moduledoc """
    AST representation for a string.
    """
    @opaque t :: %__MODULE__{value: String.t()}
    defstruct [:value]

    @doc """
    Create new String Expression AST.
    """
    @spec new(String.t()) :: t()
    def new(value), do: %FeelEx.Expression{child: %__MODULE__{value: value}}
  end
end
