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
Supported binary operations: +,-,/,*,**,>,>=,<=,>=,=
```elixir
iex(1)> FeelEx.evaluate("2+1>=3-2+2+1")
%FeelEx.Value{value: false, type: :boolean}
```
