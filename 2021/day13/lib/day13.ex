defmodule Day13 do
  @moduledoc """
  Day 13 of AoC 2021
  """

  def parse(input) do
    [coords, folds] = String.split(input, "\n\n")

    proccessed_coords =
      coords
      |> String.split()
      |> Enum.map(fn line ->
        String.split(line, ",") |> Enum.map(&String.to_integer(&1)) |> List.to_tuple()
      end)

    processed_folds =
      Regex.scan(~r/(x|y)=(\d+)/, folds, capture: :all_but_first)
      |> Enum.map(fn
        ["x", n] -> {String.to_integer(n), :nan}
        ["y", n] -> {:nan, String.to_integer(n)}
        _ -> :bad_input
      end)

    {proccessed_coords, processed_folds}
  end

  def fold({x_fold, y_fold}, coords) do
    coords
    |> Enum.map(fn {x, y} ->
      case {x_fold, y_fold} do
        {:nan, n} when y > n -> {x, 2 * n - y}
        {n, :nan} when x > n -> {2 * n - x, y}
        _ -> {x, y}
      end
    end)
  end

  def do_folds({coords, folds}), do: do_folds({coords, folds}, length(folds))

  def do_folds({coords, folds}, steps) do
    folds
    |> Enum.take(steps)
    |> Enum.reduce(coords, fn fold, acc ->
      fold(fold, acc)
    end)
  end

  defp count_visible(coords), do: Enum.uniq(coords) |> Enum.count()

  defp print_lines(coords) do
    coords
    |> Enum.sort()
    |> Enum.uniq()
    |> Enum.group_by(&elem(&1, 1))
    |> Map.values()
    |> Enum.map(&Enum.map(&1, fn e -> elem(e, 0) end))
    |> Enum.map(&Enum.chunk_every(&1, 2, 1))
    |> Enum.map(fn pairs ->
      Enum.reduce(pairs, "", fn
        [a], s ->
          s <> "&"

        [a, b], s ->
          if String.length(s) == 0 do
            String.duplicate(" ", a) <> "&" <> String.duplicate(" ", b - a - 1)
          else
            s <> "&" <> String.duplicate(" ", b - a - 1)
          end
      end)
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def do_pt_1(input) do
    input
    |> parse()
    |> do_folds(1)
    |> count_visible()
  end

  def do_pt_2(input) do
    input
    |> parse()
    |> do_folds()
    |> print_lines()
  end
end

input =
  "input.txt"
  |> File.read!()

input
|> Day13.do_pt_1()
|> IO.inspect()

input
|> Day13.do_pt_2()
