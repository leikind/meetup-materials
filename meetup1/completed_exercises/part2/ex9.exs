# Write a function which returns true if a string has the same number of
# opening and closing parentheses:


defmodule Parentheses do

  def balanced? (string) do
    characters = String.codepoints(string)

    count(characters) == 0
  end

  defp count([]), do: 0

  defp count(["(" | tail]), do: 1 + count(tail)

  defp count([")" | tail]), do: count(tail) - 1

  defp count([_ | tail]), do: count(tail)

end


ExUnit.start

defmodule ParenthesesTest do
  use ExUnit.Case

  test "opening parentheses and closing parentheses are calculated correctly" do

    assert  Parentheses.balanced?("weih((rwkdfn)sle)rh")

    assert  ! Parentheses.balanced?("weih((rwkdfn)sle)r)h")

    assert  ! Parentheses.balanced?("w((eih((rwkdfn)sle)r)h")

  end

end


