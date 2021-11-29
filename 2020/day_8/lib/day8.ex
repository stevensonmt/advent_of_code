defmodule Day8 do
  import NimbleParsec

  @input File.read!("lib/input.txt")

  defmodule ParsingHelp do
    defparsec(
      :command_lexer,
      ascii_string([?a..?z], 3)
      |> ignore(string(" "))
      |> choice([
        string("+"),
        string("-")
      ])
      |> integer(min: 1, max: 4)
    )
  end

  def lex_input() do
    @input
    |> String.split("\n", trim: true)
    |> Enum.map(&ParsingHelp.command_lexer(&1))
    |> Enum.map(&elem(&1, 1))
    |> Enum.with_index()
  end

  def parse() do
    lex_input()
    |> parse()
    |> elem(1)
  end

  def parse([]) do
    0
  end

  def parse([h | _rest] = list) do
    parse(h, list, {0, []})
  end

  #handles case of last command progressing beyond last command
  def parse(nil, _, {acc, _}) do
    {:ok, acc}
  end

  def parse({[cmd, sign, val], curr_ndx}, list, {acc, visited}) do
    sign =
      case sign do
        "-" -> -1
        "+" -> 1
      end

    cond do
      Enum.member?(visited, curr_ndx) ->
        {:error, acc}

      curr_ndx >= Enum.count(list) ->
        {:ok, acc}

      cmd == "nop" ->
        parse(Enum.at(list, curr_ndx + 1), list, {acc, [curr_ndx | visited]})

      cmd == "jmp" ->
        parse(Enum.at(list, curr_ndx + sign * val), list, {acc, [curr_ndx | visited]})

      cmd == "acc" ->
        parse(
          Enum.at(list, curr_ndx + 1),
          list,
          {acc + sign * val, [curr_ndx | visited]}
        )
    end
  end

  def try_fix() do
    lexed = lex_input()
    try_fix(List.first(lexed), lexed, {0, []})
  end

  def try_fix([], _, {acc, _}) do
    acc
  end

  def try_fix({[cmd, sign, val], ndx}, list, {acc, visited}) do
    multiplier =
      case sign do
        "-" -> -1
        "+" -> 1
      end

    case cmd do
      "nop" ->
        case parse({["jmp", sign, val], ndx}, list, {acc, visited}) do
          {:error, _} ->
            try_fix(Enum.at(list, ndx + 1), list, {acc, [ndx | visited]})

          {:ok, n} ->
            n
        end

      "jmp" ->
        case parse({["nop", sign, val], ndx}, list, {acc, visited}) do
          {:error, _} ->
            try_fix(Enum.at(list, multiplier * val + ndx), list, {acc, [ndx | visited]})

          {:ok, n} ->
            n
        end

      "acc" ->
        try_fix(Enum.at(list, ndx + 1), list, {acc + multiplier * val, [ndx | visited]})
    end
  end
end

IO.inspect(Day8.parse())
IO.inspect(Day8.try_fix())
