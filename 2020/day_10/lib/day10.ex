defmodule Day10 do
  @input File.stream!("lib/input")
         |> Stream.map(&String.to_integer(String.trim(&1)))
         |> Enum.sort()

  def part1() do
    device = List.last(@input) + 3

    input = [0 | @input] ++ [device]

    counts =
      input
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [x, y] -> y - x end)
      |> Enum.reduce({0, 0}, fn diff, {ones, threes} ->
        case diff do
          1 -> {ones + 1, threes}
          3 -> {ones, threes + 1}
          x when x > 3 -> :error
          x when x < 1 -> :error
          _ -> {ones, threes}
        end
      end)

    elem(counts, 0) * elem(counts, 1)
  end

  def part2() do
    device = List.last(@input) + 3
    input = @input ++ [device]

    input
    |> Enum.reduce([[0]], fn x, [[h | t] | rest] = acc ->
      case x - h do
        1 -> [[x | [h | t]] | rest]
        _ -> [[x] | acc]
      end
    end)
    |> Enum.map(&length(&1))
    |> Enum.map(&tribonacci(&1))
    |> Enum.reduce(1, fn x, acc -> x * acc end)
  end

  def tribonacci(n) do
    case n do
      0 -> 0
      1 -> 1
      2 -> 1
      n -> tribonacci(n - 1) + tribonacci(n - 2) + tribonacci(n - 3)
    end
  end
end

IO.inspect(Day10.part1())
IO.inspect(Day10.part2())
