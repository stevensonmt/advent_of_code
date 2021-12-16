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

    map = expand_map(map, max_row + 1, max_col + 1)
    new_endpoint = {max_row(map), max_col(map)}
    # solve(:gb_sets.singleton({0, {0, 0}}), map, :infinity, new_endpoint, MapSet.new())
  end

  defp expand_map(map, width, height) do
    for rr <- 1..4,
      cc <- 1..4 do 
        {rr,cc}
      end
    map
    |> Enum.reduce(map, fn {{r, c}, risk}, acc ->
      1..4
      |> Enum.reduce(acc, fn i, nmap ->
        nrow = r + i * width
        ncol = c + i * height
        nrisk = rem(risk + i, 10)

        [{nrow, c}, {r, ncol}]
        |> Enum.reduce(nmap, fn pos, nnmap ->
          IO.inspect({pos, nrisk, risk})
          Map.put(nnmap, pos, nrisk)
        end)
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

  defp max_row(map), do: Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
  defp max_col(map), do: Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

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

  def solve(queue, map, min_risk, endpoint, seen) do
    IO.inspect(binding())

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

  defp get_neighbors(position = {row, col}, queue, map, seen, risk) do
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

"sample.txt"
|> File.read!()
|> Day15.do_pt_2()
|> IO.inspect(label: "sample, pt 2")

# "input.txt"
# |> File.read!()
# |> Day15.do_pt_1()
# |> IO.inspect(label: "input, pt 1")
