# FeelEx

A friendly expression language helps users define decision logic without needing deep technical expertise. This language is based on the Friendly Enough Expression Language. For more information regarding FEEL, please take a look at the official OMG specification at https://www.omg.org/dmn/.

# Example Usage

```elixir
iex(1)> FeelEx.evaluate("if true then \"hello\" else 2")
%FeelEx.Value{value: "hello", type: :string}
iex(2)> FeelEx.evaluate(%{a: 1},"a+2")
%FeelEx.Value{value: 3, type: :number}
```