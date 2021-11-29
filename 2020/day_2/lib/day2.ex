defmodule Day2 do
  import NimbleParsec

  rule =
    integer(min: 1, max: 3)
    |> ignore(string("-"))
    |> integer(min: 1, max: 3)
    |> ignore(string(" "))
    |> ascii_char([?a..?z])
    |> ignore(string(": "))

  defparsec(:pw_parse, rule)

  def pw_check(file, fun) do
    File.stream!(file)
    |> Enum.map(&pw_parse(&1))
    |> Enum.count(&fun.(&1))
  end
end

valid? = fn parsed ->
  case parsed do
    {:ok, [a, b, c], pw, _, _, _} ->
      a..b
      |> Enum.member?(String.to_charlist(pw) |> Enum.count(fn x -> x == c end))

    _ ->
      false
  end
end

valid2? = fn parsed ->
  case parsed do
    {:ok, [a, b, c], pw, _, _, _} ->
      [a - 1, b - 1]
      |> Enum.count(&(Enum.at(String.to_charlist(pw), &1) == c))
      |> Kernel.==(1)

    _ ->
      false
  end
end

IO.inspect(Day2.pw_check("lib/input.txt", valid?))

IO.inspect(Day2.pw_check("lib/input.txt", valid2?))
