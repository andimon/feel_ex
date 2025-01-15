# FeelEx [![Build Status](https://github.com/ExSemantic/feel_ex/actions/workflows/tests.yml/badge.svg)](https://github.com/ExSemantic/feel_ex/actions)  [![Coverage Status](https://coveralls.io/repos/github/ExSemantic/feel_ex/badge.svg?branch=master)](https://coveralls.io/github/ExSemantic/feel_ex?branch=master) [![Hex.pm](https://img.shields.io/hexpm/v/feel_ex.svg)](https://hex.pm/packages/feel_ex) [![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/feel_ex/)

# Introduction
A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the FEEL(Friendly Enough Expression Language). For more information regarding FEEL, please take a look at the official OMG specification at [https://www.omg.org/dmn/](https://www.omg.org/dmn/).
# Data types
## Null
A null value is represented simply by `null`.

```elixir
iex(1)> FeelEx.evaluate("null")
%FeelEx.Value{value: nil, type: :null}
```
## Number

Allows for integers and decimal numbers. The numbers can be negative, and leading zero may be omitted.
```elixir
iex(1)> FeelEx.evaluate("1")
%FeelEx.Value{value: 1, type: :number}

iex(2)> %FeelEx.Value{value: 2.4, type: :number}
FeelEx.evaluate("2.4")

iex(3)> FeelEx.evaluate(".4")
%FeelEx.Value{value: 0.4, type: :number}

iex(4)> FeelEx.evaluate("-5")
%FeelEx.Value{value: -5, type: :number}
```

## Strings
Strings are wrapped around in `"`.

```elixir
iex(1)> FeelEx.evaluate("\"Aw dinja\"")
%FeelEx.Value{value: "Aw dinja", type: :string} 
```
## Boolean
Either `true` or `false`.

```elixir
iex(1)> FeelEx.evaluate("true")
%FeelEx.Value{value: true, type: :boolean}
iex(2)> FeelEx.evaluate("false")
%FeelEx.Value{value: false, type: :boolean}
```
## Date
Format: `yyyy-MM-dd`.

```elixir
iex(1)> FeelEx.evaluate("date(\"2017-03-10\")")
%FeelEx.Value{value: ~D[2017-03-10], type: :date}
iex(2)> FeelEx.evaluate("@\"2017-03-10\"")
%FeelEx.Value{value: ~D[2017-03-10], type: :date}
```
## Time
Format: `HH:mm:ss` / `HH:mm:ss+/-HH:mm` / `HH:mm:ss@ZoneId`.

```elixir
iex(1)> FeelEx.evaluate("time(\"11:45:30\")")
%FeelEx.Value{value: ~T[11:45:30], type: :time}
iex(2)> FeelEx.evaluate("time(\"13:30\")")
%FeelEx.Value{value: ~T[13:30:00], type: :time}
iex(3)> FeelEx.evaluate("time(\"11:45:30+02:00\")")
%FeelEx.Value{value: {~T[11:45:30], "+02:00"}, type: :time}
iex(4)> FeelEx.evaluate("time(\"10:31:10@Europe/Paris\")")
%FeelEx.Value{value: {~T[10:31:10], "+01:00", "Europe/Paris"}, type: :time}
iex(5)> FeelEx.evaluate("@\"11:45:30\"")
%FeelEx.Value{value: ~T[11:45:30], type: :time}
iex(6)> FeelEx.evaluate("@\"13:30\"")
%FeelEx.Value{value: ~T[13:30:00], type: :time}
iex(7)> FeelEx.evaluate("@\"11:45:30+02:00\"")
%FeelEx.Value{value: {~T[11:45:30], "+02:00"}, type: :time}
iex(8)> FeelEx.evaluate("@\"10:31:10@Europe/Paris\"")
%FeelEx.Value{value: {~T[10:31:10], "+01:00", "Europe/Paris"}, type: :time}
iex(9)> FeelEx.evaluate("@\"10:31:10@Europe/Paris\"")
%FeelEx.Value{value: {~T[10:31:10], "+01:00", "Europe/Paris"}, type: :time}
```
## Date-time
Format: `yyyy-MM-dd'T'HH:mm:ss` / `yyyy-MM-dd'T'HH:mm:ss+/-HH:mm` / `yyyy-MM-dd'T'HH:mm:ss@ZoneId`.

```elixir
iex(1)> FeelEx.evaluate("date and time(\"2015-09-18T10:31:10\")")
%FeelEx.Value{value: ~N[2015-09-18 10:31:10], type: :date_time}
iex(2)> FeelEx.evaluate("date and time(\"2015-09-18T10:31:10+01:00\")")
%FeelEx.Value{value: {~N[2015-09-18 10:31:10], "+01:00"}, type: :date_time}
iex(3)> FeelEx.evaluate("date and time(\"2015-09-18T10:31:10@Europe/Paris\")")
%FeelEx.Value{
  value: {~N[2015-09-18 10:31:10], "+01:00", "Europe/Paris"},
  type: :date_time
}
iex(4)> FeelEx.evaluate("@\"2015-09-18T10:31:10\"")
%FeelEx.Value{value: ~N[2015-09-18 10:31:10], type: :date_time}
iex(5)> FeelEx.evaluate("@\"2015-09-18T10:31:10+01:00\"")
%FeelEx.Value{value: {~N[2015-09-18 10:31:10], "+01:00"}, type: :date_time}
iex(6)> FeelEx.evaluate("@\"2015-09-18T10:31:10@Europe/Paris\"")
%FeelEx.Value{
  value: {~N[2015-09-18 10:31:10], "+01:00", "Europe/Paris"},
  type: :date_time
}
```
## Days-time-duration
Format: `PxDTxHxMxS`.
```elixir
iex(1)> FeelEx.evaluate("duration(\"P4D\")")
%FeelEx.Value{value: %Duration{day: 4}, type: :days_time_duration}
iex(2)> FeelEx.evaluate("duration(\"PT2H\")")
%FeelEx.Value{value: %Duration{hour: 2}, type: :days_time_duration}
iex(3)> FeelEx.evaluate("duration(\"PT30M\")")
%FeelEx.Value{value: %Duration{minute: 30}, type: :days_time_duration}
iex(4)> FeelEx.evaluate("duration(\"P1DT6H\")")
%FeelEx.Value{value: %Duration{day: 1, hour: 6}, type: :days_time_duration}
iex(5)> FeelEx.evaluate("@\"P4D\"")
%FeelEx.Value{value: %Duration{day: 4}, type: :days_time_duration}
iex(6)> FeelEx.evaluate("@\"PT2H\"")
%FeelEx.Value{value: %Duration{hour: 2}, type: :days_time_duration}
iex(7)> FeelEx.evaluate("@\"PT30M\"")
%FeelEx.Value{value: %Duration{minute: 30}, type: :days_time_duration}
iex(8)> FeelEx.evaluate("@\"P1DT6H\"")
%FeelEx.Value{value: %Duration{day: 1, hour: 6}, type: :days_time_duration}
```
## Years-months-duration
Format: `PxYxM`.
```elixir
iex(1)> FeelEx.evaluate("duration(\"P2Y\")")
%FeelEx.Value{value: %Duration{year: 2}, type: :years_months_duration}
iex(2)> FeelEx.evaluate("duration(\"P6M\")")
%FeelEx.Value{value: %Duration{month: 6}, type: :years_months_duration}
iex(3)> FeelEx.evaluate("duration(\"P1Y6M\")")
%FeelEx.Value{value: %Duration{year: 1, month: 6}, type: :years_months_duration}
iex(4)> FeelEx.evaluate("@\"P2Y\"")
%FeelEx.Value{value: %Duration{year: 2}, type: :years_months_duration}
iex(5)> FeelEx.evaluate("@\"P6M\"")
%FeelEx.Value{value: %Duration{month: 6}, type: :years_months_duration}
iex(6)> FeelEx.evaluate("@\"P1Y6M\"")
%FeelEx.Value{value: %Duration{year: 1, month: 6}, type: :years_months_duration}
```
## List
A list of elements. Lists may contain lists or may be empty.
```elixir
iex(1)> FeelEx.evaluate("[]")
[]
iex(2)> FeelEx.evaluate("[1,2,3]")
[
  %FeelEx.Value{value: 1, type: :number},
  %FeelEx.Value{value: 2, type: :number},
  %FeelEx.Value{value: 3, type: :number}
]
iex(3)> FeelEx.evaluate("[\"a\",\"b\"]")
[
  %FeelEx.Value{value: "a", type: :string},
  %FeelEx.Value{value: "b", type: :string}
]
```
## Context
Key-value data structure. It may be empty or nested (value being a context). The key may be a name or a string. 
```elixir
iex(1)> FeelEx.evaluate("{}")
%FeelEx.Value{value: %{}, type: :context}
iex(2)> FeelEx.evaluate("{a:1}")
%FeelEx.Value{
  value: %{a: %FeelEx.Value{value: 1, type: :number}},
  type: :context
}
iex(3)> FeelEx.evaluate("{b:1, c: \"wow\"}")
%FeelEx.Value{
  value: %{
    c: %FeelEx.Value{value: "wow", type: :string},
    b: %FeelEx.Value{value: 1, type: :number}
  },
  type: :context
}
iex(4)> FeelEx.evaluate("{nested: {d: 3}}")
%FeelEx.Value{
  value: %{
    nested: %FeelEx.Value{
      value: %{d: %FeelEx.Value{value: 3, type: :number}},
      type: :context
    }
  },
  type: :context
}
iex(5)> FeelEx.evaluate("{\"a\": 1}")
%FeelEx.Value{
  value: %{a: %FeelEx.Value{value: 1, type: :number}},
  type: :context
}
iex(6)> FeelEx.evaluate("{\"b\": 2, \"c\": \"valid\"}")
%FeelEx.Value{
  value: %{
    c: %FeelEx.Value{value: "valid", type: :string},
    b: %FeelEx.Value{value: 2, type: :number}
  },
  type: :context
}
```
# Strings

## Creating a new string value.
```elixir
iex(1)> FeelEx.evaluate("\"Aw dinja\"")
%FeelEx.Value{value: "Aw dinja", type: :string}
```
## String concatenation
```elixir
iex(1)> FeelEx.evaluate("\"Aw\"+\" Dinja\"")
%FeelEx.Value{value: "Aw Dinja", type: :string}
```
## `string()`
Converting datatypes to string
### Examples
#### null
```elixir
iex(1)> FeelEx.evaluate("string(null)")
%FeelEx.Value{value: "null", type: :string}
```
#### string (idempotent)
```elixir
iex(1)> FeelEx.evaluate("string(\"Aw Dinja\")")
%FeelEx.Value{value: "Aw Dinja", type: :string}
```
#### number
```elixir
iex(1)> FeelEx.evaluate("string(12)")
%FeelEx.Value{value: "12", type: :string}

iex(2)> FeelEx.evaluate("string(.22)")
%FeelEx.Value{value: "0.22", type: :string}

iex(3)> FeelEx.evaluate("string(-2.22)")
%FeelEx.Value{value: "-2.22", type: :string}

iex(4)> FeelEx.evaluate("string(-.22)")
%FeelEx.Value{value: "-0.22", type: :string}
```
#### boolean
```elixir
iex(1)> FeelEx.evaluate("string(true)")
%FeelEx.Value{value: "true", type: :string}

iex(2)> FeelEx.evaluate("string(false)")
%FeelEx.Value{value: "false", type: :string}
```
#### date
```elixir
iex(1)> FeelEx.evaluate("string(@\"2024-01-01\")")
%FeelEx.Value{value: "2024-01-01", type: :string}
iex(2)> FeelEx.evaluate("string(date(\"2024-01-01\"))")
%FeelEx.Value{value: "2024-01-01", type: :string}
```
#### time
```elixir
iex(1)> FeelEx.evaluate("string(time(\"11:45:30\"))")
%FeelEx.Value{value: "11:45:30", type: :string}

iex(2)> FeelEx.evaluate("string(time(\"11:45\"))")
%FeelEx.Value{value: "11:45:00", type: :string}

iex(3)> FeelEx.evaluate("string(time(\"11:45:30+02:00\"))")
%FeelEx.Value{value: "11:45:30+02:00", type: :string}

iex(4)> FeelEx.evaluate("string(time(\"11:45:30+02:00\"))")
%FeelEx.Value{value: "11:45:30+02:00", type: :string}

iex(5)> FeelEx.evaluate("string(time(\"10:31:10@Europe/Paris\"))") %FeelEx.Value{value: "10:31:10@Europe/Paris", type: :string}

iex(6)> FeelEx.evaluate("string(@\"11:45:30\")")
%FeelEx.Value{value: "11:45:30",type: :string}

iex(7)> FeelEx.evaluate("string(@\"13:30\")")
%FeelEx.Value{value: "13:30:00", type: :string}

iex(8)> FeelEx.evaluate("string(@\"10:45:30+02:00\")")
%FeelEx.Value{value: "10:45:30+02:00", type: :string}

iex(9)> FeelEx.evaluate("string(@\"10:31:10@Europe/Paris\")")
%FeelEx.Value{value: "10:31:10@Europe/Paris", type: :string}
```
#### date-time
```elixir
iex(1)> FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10\"))") %FeelEx.Value{value: "2015-09-18T10:31:10", type: :string}

iex(2)> FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10+01:00\"))") %FeelEx.Value{value: "2015-09-18T10:31:10+01:00", type: :string}

iex(3)> FeelEx.evaluate("string(date and time(\"2015-09-18T10:31:10@Europe/Paris\"))")
%FeelEx.Value{value: "2015-09-18T10:31:10@Europe/Paris", type: :string}

iex(3)> FeelEx.evaluate("string(@\"2015-09-18T10:31:10\")")
%FeelEx.Value{value: "2015-09-18T10:31:10", type: :string}

iex(4)> FeelEx.evaluate("string(@\"2015-09-18T10:31:10+01:00\")")
%FeelEx.Value{value: "2015-09-18T10:31:10+01:00", type: :string}

iex(5)> FeelEx.evaluate("string(@\"2015-09-18T10:31:10@Europe/Paris\")") %FeelEx.Value{value: "2015-09-18T10:31:10@Europe/Paris", type: :string}
```
#### days-time duration
```elixir
iex(1)> FeelEx.evaluate("string(duration(\"P4D\"))")
%FeelEx.Value{value: "P4D", type: :string}

iex(2)> FeelEx.evaluate("string(duration(\"PT2H\"))")
%FeelEx.Value{value: "PT2H", type: :string}

iex(3)> FeelEx.evaluate("string(duration(\"PT30M\"))")\
%FeelEx.Value{value: "PT30M", type: :string}

iex(4)> FeelEx.evaluate("string(duration(\"P1DT6H\"))")
%FeelEx.Value{value: "P1DT6H", type: :string}

iex(5)> FeelEx.evaluate("string(@\"P4D\")")
%FeelEx.Value{value: "P4D",type: :string}

iex(6)> FeelEx.evaluate("string(@\"PT2H\")")
%FeelEx.Value{value: "PT2H", type: :string}

iex(7)> FeelEx.evaluate("string(@\"PT30M\")")
%FeelEx.Value{value: "PT30M", type: :string}

iex(8)> FeelEx.evaluate("string(@\"P1DT6H\")")
%FeelEx.Value{value: "P1DT6H", type: :string}
```

#### years-month-duration
```elixir
iex(1)> FeelEx.evaluate("string(duration(\"P2Y\"))")
%FeelEx.Value{value: "P2Y", type: :string}

iex(2)>  FeelEx.evaluate("string(duration(\"P6M\"))")
%FeelEx.Value{value: "P6M", type: :string}

iex(3)> FeelEx.evaluate("string(duration(\"P1Y6M\"))")
%FeelEx.Value{value: "P1Y6M", type: :string}

iex(4)> FeelEx.evaluate("string(@\"P2Y\")")
%FeelEx.Value{value: "P2Y", type: :string}

iex(5)> FeelEx.evaluate("string(@\"P6M\")")
%FeelEx.Value{value: "P6M", type: :string}

iex(6)> FeelEx.evaluate("string(@\"P1Y6M\")")
%FeelEx.Value{value: "P1Y6M", type: :string}
```
#### context
(To fix) order of keys not preserved.
```elixir
context =
"""
string(
{
	a: 1,
	"b": date and time("2021-01-01T01:00:00"),
	c: @\"P2Y\"
}
)
"""

  
iex(1)> FeelEx.evaluate(context)
%FeelEx.Value{value: "{a:1, b:2021-01-01T01:00:00, c: P2Y}", type: :string}
```
#### list 

```elixir
iex(1)< FeelEx.evaluate("string([1,2+4])")
%FeelEx.Value{value: "[1, 6]", type: :string}
```

### Note!
Please note that string concatenation is only available for string values. However one may use the `string()` function to convert a value in some datatype to string and use the 

```elixir
iex(1)> FeelEx.evaluate("\"You are number \"+string(1)")
%FeelEx.Value{value: "You are number 1", type: :string}
```
Take a look at these tests: https://github.com/ExSemantic/feel_ex/blob/master/test/expression_tests/string_test.exs  for more examples.

# Numbers

## Leading 0's are valid

```elixir
iex(1)> FeelEx.evaluate("-000002")
%FeelEx.Value{value: -2, type: :number}
iex(2)> FeelEx.evaluate("0001.5")
%FeelEx.Value{value: 1.5, type: :number}
```
## Addition, Subtraction, Multiplication, Division, Exponentiation

We can carry out the usual arithmetic operators with exponentiation having the highest precedence, division and multiplication the second highest and addition and subtraction the least precedence.

### Examples:

`2+3*2` is not `10` but `8` since the multiplicative operator `*` has more precedence than `+`

```elixir
iex(1)> FeelEx.evaluate("2+3*2")
%FeelEx.Value{value: 8, type: :number}
iex(2)> FeelEx.evaluate("2/3")
%FeelEx.Value{value: 0.6666666666666666, type: :number}
```
`16/4**2` is not `16` but `1` since the multiplicative operator `**` has more precedence than `/`

```elixir
iex(1)> FeelEx.evaluate("2+3*2")
%FeelEx.Value{value: 1.0, type: :number}
```


Take a look at these tests: https://github.com/ExSemantic/feel_ex/blob/master/test/expression_tests/number_test.exs  for more examples.

# Lists

## Getting element `list[i]`

Access element using **1-based indexing**. When index is out of bounds, null is returned.

```elixir
iex(1)> FeelEx.evaluate("[1, \"a\", 3][1]")
%FeelEx.Value{value: 1, type: :number}
iex(2)> FeelEx.evaluate("[1, \"a\", 3][2]")
%FeelEx.Value{value: "a", type: :string}
iex(3)> FeelEx.evaluate("[1, \"a\", 3][3]")
%FeelEx.Value{value: 3, type: :number}
iex(4)> FeelEx.evaluate("[1, \"a\", 3][4]")
%FeelEx.Value{value: nil, type: :null}
iex(5)> FeelEx.evaluate("[1, \"a\", 3][5]")
%FeelEx.Value{value: nil, type: :null}
```
Using negative indexing we can access elements from the back of the list. The last element of the list is at index `-1`.

```elixir
iex(1)> FeelEx.evaluate("[1, \"a\", 3][-1]")
%FeelEx.Value{value: 3, type: :number}
iex(2)> FeelEx.evaluate("[1, \"a\", 3][-2]")
%FeelEx.Value{value: "a", type: :string}
iex(3)> FeelEx.evaluate("[1, \"a\", 3][-3]")
%FeelEx.Value{value: 1, type: :number}
iex(4)> FeelEx.evaluate("[1, \"a\", 3][-4]")
%FeelEx.Value{value: nil, type: :null}
```
## Filtering

We can filter a list by a condition. The current element of the list is assigned to variable `item`.

```elixir
iex(1)> FeelEx.evaluate("[1,2,4, 3][even(item)]")
[%FeelEx.Value{value: 2, type: :number}, %FeelEx.Value{value: 4, type: :number}]

iex(2)> FeelEx.evaluate("[1,2,4, 3][item>2]")
[%FeelEx.Value{value: 4, type: :number}, %FeelEx.Value{value: 3, type: :number}]
```

## Quantified expression
`some a in b satisfies c`: iterates over list `b`, assigning current element in list to `a`, and evaluating `c`. If some of the elements evaluates to `true` then the statement is `true` else it is false.

`every a in b satisfies c`: iterates over list `b`, assigning current element in list to `a`, and evaluating `c`. If all of the elements evaluates to `true` then the statement is `true` else it is false.

```elixir
iex(1)> FeelEx.evaluate("some x in [1,2,3] satisfies x > 2")
%FeelEx.Value{value: true, type: :boolean}
iex(2)> FeelEx.evaluate("some x in [1,2,3] satisfies x > 5")
%FeelEx.Value{value: false, type: :boolean}
iex(3)> FeelEx.evaluate("some x in [1,2,3] satisfies even(x)")
%FeelEx.Value{value: true, type: :boolean}
iex(4)> FeelEx.evaluate("every x in [1,2,3] satisfies x >= 1")
%FeelEx.Value{value: true, type: :boolean}
iex(5)> FeelEx.evaluate("every x in [1,2,3] satisfies x >= 2")
%FeelEx.Value{value: false, type: :boolean}
```

We can also apply this statement to cartesian product of more than one lists.

```elixir
iex(6)> FeelEx.evaluate("every x in [1,2], y in [2,3] satisfies x < y")
%FeelEx.Value{value: false, type: :boolean}
iex(7)> FeelEx.evaluate("some x in [1,2], y in [2,3] satisfies x < y")
%FeelEx.Value{value: true, type: :boolean}
```

Take a look at these tests: https://github.com/ExSemantic/feel_ex/blob/master/test/expression_tests/list_test.exs  for more examples.


# Contexts

## Allows for previous element access

```elixir
iex(1)> FeelEx.evaluate("{a: 2, b: a*2}.a")
%FeelEx.Value{
  value: %{
    a: %FeelEx.Value{value: 2, type: :number},
    b: %FeelEx.Value{value: 4, type: :number}
  },
  type: :context
}
```
## Nested contexts

Values of contexts can be contexts themselves.

```elixir
iex(1)> program = """
...(2)> {
...(2)>   a: 1,
...(2)>   b: {
...(2)>     c: 2
...(2)>   }
...(2)> }
...(2)> """
"{\n  a: 1,\n  b: {\n    c: 2\n  }\n}\n"
iex(3)> FeelEx.evaluate(program)
%FeelEx.Value{
  value: %{
    a: %FeelEx.Value{value: 1, type: :number},
    b: %FeelEx.Value{
      value: %{c: %FeelEx.Value{value: 2, type: :number}},
      type: :context
    }
  },
  type: :context
}
```
## Get entry path `a.b`
We may use dot notation to access elements of a context.
```elixir
iex(1)> FeelEx.evaluate("{a: 2}.a")
%FeelEx.Value{value: 2, type: :number}
iex(2)> FeelEx.evaluate("{a: 2, b: {b: 3}}.b")
%FeelEx.Value{
  value: %{b: %FeelEx.Value{value: 3, type: :number}},
  type: :context
}
```

If the name we are accessing does not exist in the context than we simply return null.

```elixir
iex(1)> FeelEx.evaluate("{}.a")
%FeelEx.Value{value: nil, type: :null}
iex(2)> FeelEx.evaluate("{b: 1}.a")
%FeelEx.Value{value: nil, type: :null}
iex(3)> FeelEx.evaluate("{a: {c: 2}}.a.b")
%FeelEx.Value{value: nil, type: :null}
```

## Filter `a[c]`

Given a list of context element `a` we may filter elements using a filter `c`.

Examples:

```elixir
iex(1)> program = 
...(1)> """
...(1)> [
...(1)>   {
...(1)>     a: "p1",
...(1)>     b: 5
...(1)>   },
...(1)>   {
...(1)>     a: "p2",
...(1)>     b: 10
...(1)>   }
...(1)> ][b > 7]
...(1)> """
"[\n  {\n    a: \"p1\",\n    b: 5\n  },\n  {\n    a: \"p2\",\n    b: 10\n  }\n][b > 7]\n"
iex(2)> FeelEx.evaluate(program)
[
  %FeelEx.Value{
    value: %{
      b: %FeelEx.Value{value: 10, type: :number},
      a: %FeelEx.Value{value: "p2", type: :string}
    },
    type: :context
  }
]
```

## Projection
The dot notation may be used over a list to access multiple context at once.

Example:

```elixir
iex(1)> program1 =
...(1)> """
...(1)> [
...(1)>   {
...(1)>     a: "p1",
...(1)>     b: 5
...(1)>   },
...(1)>   {
...(1)>     a: "p2",
...(1)>     b: 10
...(1)>   }
...(1)> ].a
...(1)> """
"[\n  {\n    a: \"p1\",\n    b: 5\n  },\n  {\n    a: \"p2\",\n    b: 10\n  }\n].a\n"
iex(2)> FeelEx.evaluate(program1)
[
  %FeelEx.Value{value: "p1", type: :string},
  %FeelEx.Value{value: "p2", type: :string}
]
iex(3)> program2 =
...(3)> """
...(3)> [
...(3)>   {
...(3)>     a: "p1",
...(3)>     b: 5
...(3)>   },
...(3)>   {
...(3)>     a: "p2",
...(3)>     c: 20
...(3)>   }
...(3)> ].b
...(3)> """
"[\n  {\n    a: \"p1\",\n    b: 5\n  },\n  {\n    a: \"p2\",\n    c: 20\n  }\n].b\n"
iex(4)> FeelEx.evaluate(program2)
[%FeelEx.Value{value: 5, type: :number}, %FeelEx.Value{value: nil, type: :null}]
```

Take a look at these tests: https://github.com/ExSemantic/feel_ex/blob/master/test/expression_tests/context_test.exs  for more examples.


# Functions

## Numerical Functions

#### Decimal
```elixir
iex(1)> FeelEx.evaluate("1/3")
%FeelEx.Value{value: 0.3333333333333333, type: :number}
iex(2)> FeelEx.evaluate("decimal(1/3,2)")
%FeelEx.Value{value: 0.33, type: :number}
```
### floor

```elixir
iex(1)> FeelEx.evaluate("floor(1)")
%FeelEx.Value{value: 1, type: :number}
```
### floor with scale

```elixir
iex(1)> FeelEx.evaluate("floor(1.56,1)")
%FeelEx.Value{value: 1.5, type: :number}
```

### ceiling

```elixir
iex(1)> FeelEx.evaluate("ceiling(1.54)")
%FeelEx.Value{value: 2, type: :number}
```
### ceiling with scale

```elixir
iex(1)> FeelEx.evaluate("ceiling(1.5432,2)")
%FeelEx.Value{value: 1.55, type: :number}
```

### round up 
Rounds to given scale.
```elixir
iex(1)> FeelEx.evaluate("round up(1.123,3)")
%FeelEx.Value{value: 1.123, type: :number}
iex(2)> FeelEx.evaluate("round up(1.1234,3)")
%FeelEx.Value{value: 1.124, type: :number}
iex(3)> FeelEx.evaluate("round up(-1.1234,3)")
%FeelEx.Value{value: -1.124, type: :number}
iex(4)> FeelEx.evaluate("round up(-1.1234,1)")
%FeelEx.Value{value: -1.2, type: :number}
iex(5)> FeelEx.evaluate("round up(-1.121,2)")
%FeelEx.Value{value: -1.13, type: :number}
```

### round down
```elixir
iex(1)> FeelEx.evaluate("round down(-5.5,0)")
%FeelEx.Value{value: -5, type: :number}
iex(2)> FeelEx.evaluate("round down(-5.5,1)")
%FeelEx.Value{value: -5.5, type: :number}
iex(3)> FeelEx.evaluate("round down(1.121,2)")
%FeelEx.Value{value: 1.12, type: :number}
iex(4)> FeelEx.evaluate("round down(-1.126,2)")
%FeelEx.Value{value: -1.12, type: :number}
```

### round half up 
```elixir
iex(1)> FeelEx.evaluate("round half up(1.126,2)")
%FeelEx.Value{value: 1.13, type: :number}
iex(2)> FeelEx.evaluate("round half up(1.125,2)")
%FeelEx.Value{value: 1.13, type: :number}
iex(3)> FeelEx.evaluate("round half up(1.124,2)")
%FeelEx.Value{value: 1.12, type: :number}
iex(4)> FeelEx.evaluate("round half up(1.124,0)")
%FeelEx.Value{value: 1.0, type: :number}
iex(5)> FeelEx.evaluate("round half up(1.124,0)")
%FeelEx.Value{value: 1.0, type: :number}
iex(6)> recompile
iex(7)> FeelEx.evaluate("round half up(1.124,0)")
%FeelEx.Value{value: 1, type: :number}
iex(8)> FeelEx.evaluate("round half up(-1.124,2)")
%FeelEx.Value{value: -1.12, type: :number}
iex(9)> FeelEx.evaluate("round half up(-1.125,2)")
%FeelEx.Value{value: -1.13, type: :number}
```
# Temporal Expressions
## Addition
### `<date>+<duration>=<duration>`
```elixir
iex(1)> FeelEx.evaluate("date(\"2020-04-06\") + duration(\"P1D\")")
%FeelEx.Value{value: ~D[2020-04-07], type: :date}
```

### `<duration>+<date>=<duration>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"P1D\")+ date(\"2020-04-06\")")
```
### `<time>+<duration>=<time>`
```elixir
iex(1)> FeelEx.evaluate("time(\"08:00:00\") + duration(\"PT1H\")")
%FeelEx.Value{value: ~T[09:00:00], type: :time}
iex(2)> FeelEx.evaluate("time(\"08:00:00@Europe/Paris\") + duration(\"PT1H\")")
%FeelEx.Value{value: {~T[09:00:00], "Europe/Paris"}, type: :context}
iex(3)> FeelEx.evaluate("time(\"08:00:00+01:00\") + duration(\"PT1H\")")
%FeelEx.Value{value: {~T[09:00:00], "+01:00"}, type: :time}
```

### `<duration>+<time>=<time>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00\")")
%FeelEx.Value{value: ~T[09:00:00], type: :time}
iex(2)> FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00@Europe/Paris\")")
%FeelEx.Value{value: {~T[09:00:00], "Europe/Paris"}, type: :context}
iex(3)> FeelEx.evaluate("duration(\"PT1H\") + time(\"08:00:00+01:00\")")
%FeelEx.Value{value: {~T[09:00:00], "+01:00"}, type: :time}
```

### `<date-time>+<duration>=<duration>`

```elixir
iex(1)> FeelEx.evaluate("date and time(\"2020-04-06T08:00:00\") + duration(\"P7D\")")
%FeelEx.Value{value: ~N[2020-04-13 08:00:00], type: :date_time}
iex(2)> FeelEx.evaluate("date and time(\"2020-04-06T08:00:00+01:00\") + duration(\"P7D\")")
%FeelEx.Value{value: {~N[2020-04-13 08:00:00], "+01:00"}, type: :date_time}
iex(3)> FeelEx.evaluate("date and time(\"2020-04-06T08:00:00@Europe/Malta\") + duration(\"P7D\")")
%FeelEx.Value{
  value: {~N[2020-04-13 08:00:00], "+01:00", "Europe/Malta"},
  type: :date_time
}
```

### `<duration>+<date-time>=<duration>`

```elixir
iex(1)> FeelEx.evaluate("duration(\"P7D\")+date and time(\"2020-04-06T08:00:00\")")
%FeelEx.Value{value: ~N[2020-04-13 08:00:00], type: :date_time}
iex(2)> FeelEx.evaluate("duration(\"P7D\") + date and time(\"2020-04-06T08:00:00+01:00\")")
%FeelEx.Value{value: {~N[2020-04-13 08:00:00], "+01:00"}, type: :date_time}
iex(3)> FeelEx.evaluate("duration(\"P7D\")+date and time(\"2020-04-06T08:00:00@Europe/Malta\")")
%FeelEx.Value{
  value: {~N[2020-04-13 08:00:00], "+01:00", "Europe/Malta"},
  type: :date_time
}
```

### `<duration>+<duration>=<duration>`

```elixir
iex(1)> FeelEx.evaluate("duration(\"P1D\") + duration(\"PT1H\")")
%FeelEx.Value{value: %Duration{day: 1, hour: 1}, type: :days_time_duration}
iex(2)> FeelEx.evaluate("duration(\"P1DT2H\") + duration(\"P1DT3H\")")
%FeelEx.Value{value: %Duration{day: 2, hour: 5}, type: :days_time_duration}
```
Take a look at these tests: https://github.com/ExSemantic/feel_ex/blob/master/test/expression_tests/temporal_expressions_test.exs  for more examples.


## Subtraction

### `<date>-<date>=<duration>`

```elixir
iex(1)> FeelEx.evaluate("date(\"2020-04-06\") - date(\"2020-04-01\")")
%FeelEx.Value{value: %Duration{day: 5}, type: :days_time_duration}
iex(2)> FeelEx.evaluate("date(\"2023-10-01\") - date(\"2023-07-01\")")
%FeelEx.Value{value: %Duration{day: 92}, type: :days_time_duration}
iex(3)> FeelEx.evaluate("date(\"2023-01-01\") - date(\"2022-12-31\")")
%FeelEx.Value{value: %Duration{day: 1}, type: :days_time_duration}
```
### `<date>-<duration>=<date>`

```elixir
iex(1)> FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P5D\")")
%FeelEx.Value{value: ~D[2020-04-01], type: :date}
iex(2)> FeelEx.evaluate("date(\"2021-08-15\") - duration(\"P5D\")")
%FeelEx.Value{value: ~D[2021-08-10], type: :date}
iex(3)> FeelEx.evaluate("date(\"2020-04-06\") - duration(\"P-5D\")")
%FeelEx.Value{value: ~D[2020-04-11], type: :date} 
```
### `<time>-<time>=<days-time-duration>`
 
 ```elixir
 iex(1)> FeelEx.evaluate("time(\"08:00:00\") - time(\"06:00:01\")")
%FeelEx.Value{
  value: %Duration{hour: 1, minute: 59, second: 59},
  type: :days_time_duration
}
iex(2)> FeelEx.evaluate("time(\"08:00:00+01:00\") - time(\"06:00:01+01:00\")")
%FeelEx.Value{
  value: %Duration{hour: 1, minute: 59, second: 59},
  type: :days_time_duration
}
iex(3)> FeelEx.evaluate("time(\"08:00:00+01:00\") - time(\"06:00:01-01:00\")")
[warning] [Elixir.FeelEx.Expression][do_subtract/2] Cannot subtract %FeelEx.Value{value: {~T[08:00:00], "+01:00"}, type: :time} with %FeelEx.Value{value: {~T[06:00:01], "-01:00"}, type: :time}.
%FeelEx.Value{value: nil, type: :null}
iex(4)> FeelEx.evaluate("time(\"08:00:00@Europe/Malta\") - time(\"06:00:01@Europe/Malta\")")
%FeelEx.Value{
  value: %Duration{hour: 1, minute: 59, second: 59},
  type: :days_time_duration
}
iex(5)> FeelEx.evaluate("time(\"08:00:00@Europe/Malta\") - time(\"06:00:01@Europe/Paris\")") 
[warning] [Elixir.FeelEx.Expression][do_subtract/2] Cannot subtract %FeelEx.Value{value: {~T[08:00:00], "+01:00", "Europe/Malta"}, type: :time} with %FeelEx.Value{value: {~T[06:00:01], "+01:00", "Europe/Paris"}, type: :time}.
%FeelEx.Value{value: nil, type: :null}
```

**Note!**: Time difference for times with different time zones and offsets is currently not supported.

### `<date-time>-<date-time>=<days-time-duration>

```elixir
iex(1)> FeelEx.evaluate("date and time(\"2025-01-01T08:00:00\") - date and time(\"2024-01-01T06:00:01\")")
%FeelEx.Value{
  value: %Duration{hour: 8785, minute: 59, second: 59},
  type: :days_time_duration
}
iex(2)> FeelEx.evaluate("date and time(\"2025-01-01T08:00:00+01:00\") - date and time(\"2024-01-01T06:00:01+01:00\")")
%FeelEx.Value{
  value: %Duration{hour: 8785, minute: 59, second: 59},
  type: :days_time_duration
}
iex(3)> FeelEx.evaluate("date and time(\"2025-01-01T08:00:00+01:00\") - date and time(\"2024-01-01T06:00:01-01:00\")")
[warning] [Elixir.FeelEx.Expression][do_subtract/2] Cannot subtract %FeelEx.Value{value: {~N[2025-01-01 08:00:00], "+01:00"}, type: :date_time} with %FeelEx.Value{value: {~N[2024-01-01 06:00:01], "-01:00"}, type: :date_time}.
%FeelEx.Value{value: nil, type: :null}
iex(4)> FeelEx.evaluate("date and time(\"2025-01-01T08:00:00@Europe/Malta\") - date and time(\"2024-01-01T06:00:01@Europe/Malta\")")
%FeelEx.Value{
  value: %Duration{hour: 8785, minute: 59, second: 59},
  type: :days_time_duration
}
iex(5)> FeelEx.evaluate("date and time(\"2025-01-01T08:00:00@Europe/Malta\") - date and time(\"2024-01-01T06:00:01@Europe/Paris\")")
[warning] [Elixir.FeelEx.Expression][do_subtract/2] Cannot subtract %FeelEx.Value{value: {~N[2025-01-01 08:00:00], "+01:00", "Europe/Malta"}, type: :date_time} with %FeelEx.Value{value: {~N[2024-01-01 06:00:01], "+01:00", "Europe/Paris"}, type: :date_time}.
%FeelEx.Value{value: nil, type: :null}
```
**Note!**: DateTime difference for times with different time zones and offsets is currently not supported.

### `<date-time>-<duration>=<date-time>

```elixir
iex(1)> FeelEx.evaluate("date and time(\"2021-01-01T08:00:00\") - duration(\"PT2H\")")
%FeelEx.Value{value: ~N[2021-01-01 06:00:00], type: :date_time}
iex(2)> FeelEx.evaluate("date and time(\"2021-01-01T08:00:00+01:00\") - duration(\"PT2H\")")
%FeelEx.Value{value: {~N[2021-01-01 06:00:00], "+01:00"}, type: :date_time}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:00:00@Europe/Malta\") - duration(\"PT2H\")")
%FeelEx.Value{
  value: {~N[2021-01-01 06:00:00], "+01:00", "Europe/Malta"},
  type: :date_time
}
```

### `<days-time-duration>-<days-time-duration>=<days-time-duration>

```iex
iex(1)> FeelEx.evaluate("duration(\"P7D\") - duration(\"P2D\")")
%FeelEx.Value{value: %Duration{hour: 120}, type: :days_time_duration}
iex(2)> FeelEx.evaluate("duration(\"P7D\") - duration(\"P8DT1S\")")
%FeelEx.Value{
  value: %Duration{hour: -24, second: -1},
  type: :days_time_duration
}
```
### `<years-months-duration>-<years-months-duration>=<years-months-duration>

```elixir
iex(1)> FeelEx.evaluate("duration(\"P1Y\") - duration(\"P3M\")") 
%FeelEx.Value{value: %Duration{month: 9}, type: :years_months_duration}
iex(2)> FeelEx.evaluate("duration(\"P3Y1M\") - duration(\"P1Y12M\")")
%FeelEx.Value{value: %Duration{year: 1, month: 1}, type: :years_months_duration}
```
## Multiplication 
### `<number>*<days_time_duration>=<days_time_duration>`
```elixir
iex(1)> FeelEx.evaluate("5*duration(\"P1D\")")
%FeelEx.Value{value: %Duration{day: 5}, type: :days_time_duration}
```
### `<days_time_duration>*<number>=<days_time_duration>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"P1D\") * 5")
%FeelEx.Value{value: %Duration{day: 5}, type: :days_time_duration}
```
### `<number>*<years_months_duration>=<years_months_duration>
```elixir
iex(1)> FeelEx.evaluate("13 * duration(\"P1M\")")
%FeelEx.Value{value: %Duration{year: 1, month: 1}, type: :years_months_duration}
```
### `<years_months_duration>*<number>=<years_months_duration>`
```elixir
iex(15)> FeelEx.evaluate("duration(\"P1M\") * 13")
%FeelEx.Value{value: %Duration{year: 1, month: 1}, type: :years_months_duration}
```
## Division
### `<days-time-duration>/<days-time-duration>=<number>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"P5D\") / duration(\"P1D\")")
%FeelEx.Value{value: 5, type: :number}
```
### `<days-time-duration>/<number>=<days-time-duration>`
```elixir
FeelEx.evaluate("duration(\"P5D\")/5")
```
### `<years-months-duration>/<years-months-duration>=<number>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"P1Y\") / duration(\"P2M\")")
%FeelEx.Value{value: 6, type: :number}
```
### `<years-months-duration>/<number>=<years-months-duration>`
```elixir
iex(1)> FeelEx.evaluate("duration(\"P1Y\") / 12")
%FeelEx.Value{value: %Duration{month: 1}, type: :years_months_duration}
```


## Temporal Properties

### Accessing `year` 
```elixir
Interactive Elixir (1.17.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> FeelEx.evaluate("@\"2021-01-01\".year")
%FeelEx.Value{value: 2021, type: :number}
iex(2)> FeelEx.evaluate("date(\"2021-01-01\").year")
%FeelEx.Value{value: 2021, type: :number}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").year")
%FeelEx.Value{value: 2021, type: :number}
iex(3)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".year")
%FeelEx.Value{value: 2021, type: :number}
iex(4)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").year")
%FeelEx.Value{value: 2021, type: :number}
iex(5)> FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".year")
%FeelEx.Value{value: 2021, type: :number}
iex(6)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".year") 
%FeelEx.Value{value: 2021, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").year") 
%FeelEx.Value{value: 2021, type: :number}
```
### Accessing `month` in `[1-12]` where 1 is January.
```elixir
iex(1)> FeelEx.evaluate("@\"2021-01-01\".month")
%FeelEx.Value{value: 1, type: :number}
iex(2)> FeelEx.evaluate("date(\"2021-01-01\").month")
%FeelEx.Value{value: 1, type: :number}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").month")
%FeelEx.Value{value: 1, type: :number}
iex(4)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".month")
%FeelEx.Value{value: 1, type: :number}
iex(5)> FeelEx.evaluate("date and time(\"2021-05-01T08:01:05+01:00\").month")
%FeelEx.Value{value: 5, type: :number}
iex(6)> FeelEx.evaluate("@\"2021-01-01T08:05:05+01:00\".month")
%FeelEx.Value{value: 1, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-05-01T08:01:05@Europe/Malta\").month")
%FeelEx.Value{value: 5, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:05:05@Europe/Malta\".month")
%FeelEx.Value{value: 1, type: :number}
```
### Accessing `day` in `[1-31]`.
```elixir
iex(1)> FeelEx.evaluate("@\"2021-01-01\".day")
%FeelEx.Value{value: 1, type: :number}
iex(2)> FeelEx.evaluate("date(\"2021-01-01\").day")
%FeelEx.Value{value: 1, type: :number}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").day")
%FeelEx.Value{value: 1, type: :number}
iex(4)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".day")
%FeelEx.Value{value: 1, type: :number}
iex(5)> FeelEx.evaluate("date and time(\"2021-05-01T08:01:05+01:00\").day")
%FeelEx.Value{value: 1, type: :number}
iex(6)> FeelEx.evaluate("@\"2021-01-01T08:05:05+01:00\".day")
%FeelEx.Value{value: 1, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-05-01T08:01:05@Europe/Malta\").day")
%FeelEx.Value{value: 1, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:05:05@Europe/Malta\".day")
%FeelEx.Value{value: 1, type: :number}
```
### Accessing `weekday` in `[1-7]` where 1 is Monday.
```elixir
iex(1)> FeelEx.evaluate("@\"2021-01-01\".weekday")
%FeelEx.Value{value: 5, type: :number}
iex(2)> FeelEx.evaluate("date(\"2021-01-01\").weekday")
%FeelEx.Value{value: 5, type: :number}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").weekday")
%FeelEx.Value{value: 5, type: :number}
iex(4)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".weekday")
%FeelEx.Value{value: 5, type: :number}
iex(5)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").weekday")
%FeelEx.Value{value: 5, type: :number}
iex(6)> FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".weekday")
%FeelEx.Value{value: 5, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").weekday")
%FeelEx.Value{value: 5, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".weekday")
%FeelEx.Value{value: 5, type: :number}
```

### Accessing hour in `[0-23]`
```elixir
iex(1)> FeelEx.evaluate("time(\"08:01:05\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(2)> FeelEx.evaluate("@\"08:01:05\".hour")
%FeelEx.Value{value: 8, type: :number}
iex(3)> FeelEx.evaluate("time(\"08:01:05+01:00\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(4)> FeelEx.evaluate("@\"08:01:05+01:00\".hour")
%FeelEx.Value{value: 8, type: :number}
iex(5)> FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(6)> FeelEx.evaluate("@\"08:01:05@Europe/Malta\".hour")
%FeelEx.Value{value: 8, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".hour")
%FeelEx.Value{value: 8, type: :number}
iex(9)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(10)> FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".hour")
%FeelEx.Value{value: 8, type: :number}
iex(11)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").hour")
%FeelEx.Value{value: 8, type: :number}
iex(12)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".hour")
%FeelEx.Value{value: 8, type: :number}
```
### Accessing minute in `[0-59]`
```elixir
iex(1)> FeelEx.evaluate("time(\"08:01:05\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(2)> FeelEx.evaluate("@\"08:01:05\".minute")
%FeelEx.Value{value: 1, type: :number}
iex(3)> FeelEx.evaluate("time(\"08:01:05+01:00\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(4)> FeelEx.evaluate("@\"08:01:05+01:00\".minute")
%FeelEx.Value{value: 1, type: :number}
iex(5)> FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(6)> FeelEx.evaluate("@\"08:01:05@Europe/Malta\".minute")
%FeelEx.Value{value: 1, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".minute")
%FeelEx.Value{value: 1, type: :number}
iex(9)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(10)> FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".minute")
%FeelEx.Value{value: 1, type: :number}
iex(11)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").minute")
%FeelEx.Value{value: 1, type: :number}
iex(12)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".minute")
%FeelEx.Value{value: 1, type: :number}
```
### Accessing second in `[0-59]`

```elixir
iex(1)> FeelEx.evaluate("time(\"08:01:05\").second")
%FeelEx.Value{value: 5, type: :number}
iex(2)> FeelEx.evaluate("@\"08:01:05\".second")
%FeelEx.Value{value: 5, type: :number}
iex(3)> FeelEx.evaluate("time(\"08:01:05+01:00\").second")
%FeelEx.Value{value: 5, type: :number}
iex(4)> FeelEx.evaluate("@\"08:01:05+01:00\".second")
%FeelEx.Value{value: 5, type: :number}
iex(5)> FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").second")
%FeelEx.Value{value: 5, type: :number}
iex(6)> FeelEx.evaluate("@\"08:01:05@Europe/Malta\".second")
%FeelEx.Value{value: 5, type: :number}
iex(7)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05\").second")
%FeelEx.Value{value: 5, type: :number}
iex(8)> FeelEx.evaluate("@\"2021-01-01T08:01:05\".second")
%FeelEx.Value{value: 5, type: :number}
iex(9)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05+01:00\").second")
%FeelEx.Value{value: 5, type: :number}
iex(10)> FeelEx.evaluate("@\"2021-01-01T08:01:05+01:00\".second")
%FeelEx.Value{value: 5, type: :number}
iex(11)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").second")
%FeelEx.Value{value: 5, type: :number}
iex(12)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".second")
%FeelEx.Value{value: 5, type: :number}
```
### Accessing time offset
```elixir
iex(1)> FeelEx.evaluate("@\"08:01:05+01:32\".time offset")
%FeelEx.Value{value: %Duration{hour: 1, minute: 32}, type: :days_time_duration}
iex(2)> FeelEx.evaluate("time(\"08:01:05-02:21\").time offset")
%FeelEx.Value{value: %Duration{hour: -2, minute: -21}
iex(3)> FeelEx.evaluate("time(\"08:01:05-01@Europe/Malta\").time offset")
%FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}
iex(4)> FeelEx.evaluate("@\"08:01:05@Europe/Malta\".time offset")
%FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}
iex(5)> FeelEx.evaluate("@\"2021-01-03T08:01:05+01:02\".time offset")
%FeelEx.Value{value: %Duration{hour: 1, minute: 2}, type: :days_time_duration}
iex(6)> FeelEx.evaluate("date and time(\"2021-01-03T08:01:05-02:01\").time offset")
%FeelEx.Value{value: %Duration{hour: -2, minute: -1}, type: :days_time_duration}
iex(7)> FeelEx.evaluate("@\"2021-01-03T08:01:05+01:02\".time offset")
%FeelEx.Value{value: %Duration{hour: 1, minute: 2}, type: :days_time_duration}
iex(8)> FeelEx.evaluate("date and time(\"2021-01-03T08:01:05-02:01\").time offset")
%FeelEx.Value{value: %Duration{hour: -2, minute: -1}, type: :days_time_duration}
iex(9)> FeelEx.evaluate("@\"2021-01-03T08:01:05@Europe/Malta\".time offset")
%FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}
iex(10)> FeelEx.evaluate("date and time(\"2021-01-03T08:01:05@Europe/Malta\").time offset")
%FeelEx.Value{value: %Duration{hour: 1}, type: :days_time_duration}
```
### Accessing timezone
```elixir
iex(1)> FeelEx.evaluate("time(\"08:01:05@Europe/Malta\").timezone")
%FeelEx.Value{value: "Europe/Malta", type: :string}
iex(2)> FeelEx.evaluate("@\"08:01:05@Europe/Malta\".timezone")
%FeelEx.Value{value: "Europe/Malta", type: :string}
iex(3)> FeelEx.evaluate("date and time(\"2021-01-01T08:01:05@Europe/Malta\").timezone")
%FeelEx.Value{value: "Europe/Malta", type: :string}
iex(4)> FeelEx.evaluate("@\"2021-01-01T08:01:05@Europe/Malta\".timezone")
%FeelEx.Value{value: "Europe/Malta", type: :string}
```

### Access days, hours in `[0..23]`, minutes in `[0..59]`, seconds  in `[0..59]`for days-time-duration
```elixir
iex(1)> FeelEx.evaluate("@\"PT24H\".days")
%FeelEx.Value{value: 1, type: :number}
iex(2)> FeelEx.evaluate("@\"P2DT-24H\".days")
%FeelEx.Value{value: 1, type: :number}
iex(3)> FeelEx.evaluate("@\"P3DT-24H\".days")
%FeelEx.Value{value: 2, type: :number}
iex(4)> FeelEx.evaluate("@\"P3DT24H\".days")
%FeelEx.Value{value: 4, type: :number}
iex(5)> FeelEx.evaluate("@\"P3DT24H1440M\".days")
%FeelEx.Value{value: 5, type: :number}
iex(6)> FeelEx.evaluate("@\"P3DT24H1441M\".days")
%FeelEx.Value{value: 5, type: :number}
iex(7)> FeelEx.evaluate("@\"P3DT48H1441M\".days")
%FeelEx.Value{value: 6, type: :number}
iex(8)> FeelEx.evaluate("@\"PT25H63M\".minutes")
%FeelEx.Value{value: 3, type: :number}
iex(9)> FeelEx.evaluate("@\"PT25H63M119S\".seconds")
%FeelEx.Value{value: 59, type: :number}
```

### Access years, months in `[0..11]`
```elixir
iex(1)> FeelEx.evaluate("@\"P1Y13M\".years")
%FeelEx.Value{value: 2, type: :number}
iex(2)> FeelEx.evaluate("@\"P1Y13M\".months")
%FeelEx.Value{value: 1, type: :number}
iex(3)> FeelEx.evaluate("@\"P1Y13M\".months")
%FeelEx.Value{value: 1, type: :number}
```