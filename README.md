# FeelEx

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