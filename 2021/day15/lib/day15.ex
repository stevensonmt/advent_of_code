defmodule Day15 do
  @moduledoc """
  My solution for AoC 2021 `Day15`.
  """

  @neighbors [{0, -1}, {0, 1}, {1, 0}, {-1, 0}]

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

  def init(input) do
    map = parse(input)
    max_row = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_col = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()
    {map, max_row, max_col}
  end

  def build_path({_, max_row, max_col}, [{max_row, max_col} | _rest], distance),
    do: distance |> IO.inspect(label: "distance travelled")

  def build_path(
        {map, _max_row, _max_col} = init_args,
        [{row, col} = _last | _rest] = path,
        distance
      ) do
    IO.inspect(path, label: "path")

    candidates =
      @neighbors
      |> Enum.map(fn {r, c} -> {r + row, c + col} end)
      |> Enum.reduce([], fn {rr, cc}, candidates ->
        case Map.fetch(map, {rr, cc}) do
          {:ok, l} -> [{{rr, cc}, l} | candidates]
          :error -> candidates
        end
      end)
      |> Enum.reject(fn {coord, _d} -> coord in path end)
      |> IO.inspect(label: "neighbors")

    case candidates do
      [] ->
        :deadend

      _ ->
        Enum.min_by(candidates, fn {c, d} -> build_path(init_args, [c | path], distance + d) end)
    end
  end
end

"sample.txt"
|> File.read!()
|> Day15.init()
|> Day15.build_path([{0, 0}], 0)
|> IO.inspect()
