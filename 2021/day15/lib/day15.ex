defmodule Day15 do
  @moduledoc """
  My solution for AoC 2021 `Day15`.
  """

  @neighbors [{0, -1}, {0, 1}, {1, 0}, {-1, 0}]

  def do_pt_1(input) do
    input
    |> solve()
  end

  def do_pt_2(input) do
    {map, {max_row, max_col}} = init(input)
    width = max_row + 1
    height = max_col + 1

    new_map = expand_map(map, width, height)
    new_endpoint = {max_row(new_map), max_col(new_map)}
    solve(new_map, new_endpoint)
  end

  def increment_risk(risk, increment) when risk + increment <= 9, do: risk + increment
  def increment_risk(risk, increment) when risk + increment > 9, do: risk + increment - 9

  defp expand_map(map, width, height) do
    map
    |> Enum.reduce(map, fn {{r, c}, risk}, map ->
      1..4
      |> Enum.reduce(map, fn i, map ->
        Map.put(map, {r + i * width, c}, increment_risk(risk, i))
      end)
    end)
    |> Enum.reduce(map, fn {{r, c}, risk}, map ->
      1..4
      |> Enum.reduce(map, fn i, map ->
        Map.put(map, {r, c + i * height}, increment_risk(risk, i))
      end)
    end)
  end

  def parse(input) do
    input
    |> String.split()
    |> Enum.with_index()
    |> Enum.flat_map(fn {s, row} ->
      s
      |> String.graphemes()
      |> Enum.map(&String.to_integer(&1))
      |> Enum.with_index()
      |> Enum.map(fn {i, col} -> {{row, col}, i} end)
    end)
    |> Enum.into(%{})
  end

  defp max_row(map), do: map |> Enum.map(&elem(elem(&1, 0), 0)) |> Enum.max()
  defp max_col(map), do: map |> Enum.map(&elem(elem(&1, 0), 1)) |> Enum.max()

  def init(input) do
    map = parse(input)
    max_row = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_col = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    {map, {max_row, max_col}}
  end

  def solve(input) do
    {map, endpoint} = input |> init()
    solve(:gb_sets.singleton({0, {0, 0}}), map, :infinity, endpoint, MapSet.new())
  end

  def solve(map, {x, y}) do
    start = {0, 0}
    q = :gb_sets.singleton({0, start})
    best = :infinity
    seen = MapSet.new()
    solve(q, map, best, {x, y}, seen)
  end

  def solve(queue, map, min_risk, endpoint, seen) do
    cond do
      :gb_sets.is_empty(queue) ->
        min_risk

      true ->
        {{risk, position}, queue} = :gb_sets.take_smallest(queue)

        cond do
          risk >= min_risk ->
            solve(queue, map, min_risk, endpoint, seen)

          true ->
            seen = MapSet.put(seen, position)

            case position do
              ^endpoint ->
                solve(queue, map, risk, endpoint, seen)

              _ ->
                position
                |> get_neighbors(queue, map, seen, risk)
                |> solve(map, min_risk, endpoint, seen)
            end
        end
    end
  end

  defp get_neighbors({row, col}, queue, map, seen, risk) do
    @neighbors
    |> Enum.map(fn {r, c} -> {r + row, c + col} end)
    |> Enum.reduce(queue, fn pos, q ->
      case Map.fetch(map, pos) do
        {:ok, d} ->
          if MapSet.member?(seen, pos) do
            q
          else
            :gb_sets.add({risk + d, pos}, q)
          end

        :error ->
          q
      end
    end)
  end
end

# "sample.txt"
# |> File.read!()
# |> Day15.do_pt_1()
# |> IO.inspect(label: "sample, pt 1")

"input.txt"
|> File.read!()
|> Day15.do_pt_2()
|> IO.inspect(label: "sample, pt 2")

# "input.txt"
# |> File.read!()
# |> Day15.do_pt_1()
# |> IO.inspect(label: "input, pt 1")
