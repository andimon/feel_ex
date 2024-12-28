# FeelEx

[![Documentation](https://img.shields.io/badge/documentation-gray)](https://hexdocs.pm/feel_ex/)

A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the FEEL(Friendly Enough Expression Language). For more information regarding FEEL, please take a look at the official OMG specification at https://www.omg.org/dmn/.

# Example Usage

## Resolving names

```elixir
iex(1)> FeelEx.evaluate(%{new_var: 1}, "new_var")
%FeelEx.Value{value: 1, type: :number}

iex(2)> FeelEx.evaluate(%{a: [1,[2,true]]}, "a")
[
  %FeelEx.Value{value: 1, type: :number},
  [
    %FeelEx.Value{value: 2, type: :number},
    %FeelEx.Value{value: true, type: :boolean}
  ]
]
```

## Binary Operations

Supported binary operations: `+,-,/,*,**,>,>=,<=,>=,=,.`.

### Arithmetic Expressions

#### Addition

`<expression>+<expression>`

##### Examples 
- Adding two numbers

```elixir
iex(1)> FeelEx.evaluate("1+2.2")
%FeelEx.Value{value: 3.2, type: :number}
```
* Adding two strings (concatenates two strings)

```elixir
iex(1)> FeelEx.evaluate("\"Aw\"+\" Dinja\"")
%FeelEx.Value{value: "Aw Dinja", type: :sting}
```

#### Subtraction

`<expression>-<expression>`


##### Examples

* Subtracting two numbers


```elixir
iex(1)> FeelEx.evaluate("2-3")
%FeelEx.Value{value: -1, type: :number}
```

#### Multiplication

`<expression>*<expression>`


##### Examples

* Multiplying two numbers

```elixir
iex(1)> FeelEx.evaluate("2*3")
%FeelEx.Value{value: 6, type: :number}
```

#### Division

`<expression>/<expression>`

##### Examples

* Dividing two numbers

```elixir
iex(1)> FeelEx.evaluate("2/3")
%FeelEx.Value{value: 0.6666666666666666, type: :number}
```

#### Exponentiation

`<expression>**<expression>`


##### Examples

* A number raised to the power of another number

```elixir
iex(1)> FeelEx.evaluate("2**3")
%FeelEx.Value{value: 8, type: :number}
```

#### Arithmetic Negation
`-<expression>`


##### Examples

* Negating a number

```elixir
iex(1)> FeelEx.evaluate("-5.5")
%FeelEx.Value{value: -5.5, type: :number}
```
### Comparison Expressions

#### Equality

`<expression>=<expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1=6")
%FeelEx.Value{value: true, type: :boolean}

iex(2)> FeelEx.evaluate("5+1=2+3+1+1")
%FeelEx.Value{value: false, type: :boolean}

iex(3)> FeelEx.evaluate("5>1=true")
%FeelEx.Value{value: true, type: :boolean}
```

#### Inequality

`<expression>!=<expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1!=6")
%FeelEx.Value{value: true, type: :boolean}

iex(2)> FeelEx.evaluate("5+1!=2+3+1+1")
%FeelEx.Value{value: false, type: :boolean}

iex(3)> FeelEx.evaluate("5>1!=true")
%FeelEx.Value{value: true, type: :boolean}
```

#### Less Than

`<expression> < <expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1<6")
%FeelEx.Value{value: false, type: :boolean}

iex(2)> FeelEx.evaluate("5+1<2+3+1+1")
%FeelEx.Value{value: true, type: :boolean}

iex(3)> FeelEx.evaluate("5+1<7")
%FeelEx.Value{value: true, type: :boolean}
```

#### Greater Than

`<expression> > <expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1>6")
%FeelEx.Value{value: false, type: :boolean}

iex(2)> FeelEx.evaluate("5+1>2+3+1+1")
%FeelEx.Value{value: false, type: :boolean}

iex(3)> FeelEx.evaluate("5+1>7")
%FeelEx.Value{value: false, type: :boolean}
```
#### Less Than or Equal

`<expression> <= <expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1<=6")
%FeelEx.Value{value: true, type: :boolean}

iex(2)> FeelEx.evaluate("5+1<=2+3+1+1")
%FeelEx.Value{value: true, type: :boolean}

iex(3)> FeelEx.evaluate("5+1<=7")
%FeelEx.Value{value: true, type: :boolean}
```

#### Greater Than or Equal

`<expression> >= <expression>`

##### Examples

```elixir
iex(1)> FeelEx.evaluate("5+1>=6")
%FeelEx.Value{value: true, type: :boolean}

iex(2)> FeelEx.evaluate("5+1>=2+3+1+1")
%FeelEx.Value{value: false, type: :boolean}

iex(3)> FeelEx.evaluate("5+1>=7")
%FeelEx.Value{value: false, type: :boolean}
```

## If Statement

`if <expression> then <expression> else expression>`

### Examples

```elixir
iex(1)> FeelEx.evaluate(%{language: "mt"}, "if language=\"mt\" then \"Aw Dinja\" else \"Hello World\"")
%FeelEx.Value{value: "Aw Dinja", type: :string}

iex(2)> FeelEx.evaluate(%{a: true},"if a then 1 else 2")
%FeelEx.Value{value: 1, type: :number}

iex(3)> FeelEx.evaluate(%{a: 1, b: 0.5}, "if a<b then 1 else \"one\"")
%FeelEx.Value{value: "one", type: :string}

iex(4)> FeelEx.evaluate("if 1=2-1 then 1 else 2")
%FeelEx.Value{value: 1, type: :number}
```