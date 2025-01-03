defmodule FeelEx.LexerTest do
use ExUnit.Case
doctest FeelEx

test "lexer - \"11 1.2\"" do
  expected = [
    %FeelEx.Token{type: :int, value: "11", line_number: 1},
    %FeelEx.Token{type: :float, value: "1.2", line_number: 1},
    %FeelEx.Token{type: :eof, value: nil, line_number: nil}
  ]

  assert FeelEx.Lexer.tokens("11 1.2") == expected
end

test "lexer - \"1.2 11\"" do
  expected = [
    %FeelEx.Token{type: :float, value: "1.2", line_number: 1},
    %FeelEx.Token{type: :int, value: "11", line_number: 1},
    %FeelEx.Token{type: :eof, value: nil, line_number: nil}
  ]

  assert FeelEx.Lexer.tokens("1.2 11") == expected
end

test "lexer - \"1.2 11 \n 13.213\"" do
  expected = [
    %FeelEx.Token{type: :float, value: "1.2", line_number: 1},
    %FeelEx.Token{type: :int, value: "11", line_number: 1},
    %FeelEx.Token{type: :float, value: "13.213", line_number: 2},
    %FeelEx.Token{type: :eof, value: nil, line_number: nil}
  ]

  assert FeelEx.Lexer.tokens("1.2 11 \n 13.213") == expected
end

test "lexer - \"1.2 11//wow\n 11\"" do
  expected = [
    %FeelEx.Token{type: :float, value: "1.2", line_number: 1},
    %FeelEx.Token{type: :int, value: "11", line_number: 1},
    %FeelEx.Token{type: :comment, value: "//wow\n", line_number: 1},
    %FeelEx.Token{type: :int, value: "11", line_number: 2},
    %FeelEx.Token{type: :eof, value: nil, line_number: nil}
  ]

  assert FeelEx.Lexer.tokens("1.2 11//wow\n 11") == expected
end

test "lexer - \"..\"" do
  assert [
            %FeelEx.Token{type: :double_dot, value: ".."},
            %FeelEx.Token{type: :eof, value: nil}
          ] = FeelEx.Lexer.tokens("..")
end

test "lexer - \"//.\n\"" do
  expected = [
    %FeelEx.Token{type: :comment, value: "//.\n", line_number: 1},
    %FeelEx.Token{type: :eof, value: nil, line_number: nil}
  ]

  assert FeelEx.Lexer.tokens("//.\n") == expected
end
end
