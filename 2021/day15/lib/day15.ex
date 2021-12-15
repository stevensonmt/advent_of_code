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

  def build_path(
        {_, max_row, max_col},
        [{max_row, max_col} | _rest],
        current_distance,
        min_complete_distance
      ) do
    if current_distance < min_complete_distance do
      current_distance |> IO.inspect(label: "distance travelled")
    else
      :too_long
    end
  end

  def build_path(
        {map, _max_row, _max_col} = init_args,
        [{row, col} = _last | _rest] = path,
        current_distance,
        min_complete_distance
      ) do
    candidates =
      @neighbors
      |> Enum.map(fn {r, c} -> {r + row, c + col} end)
      |> Enum.reduce([], fn {rr, cc}, candidates ->
        case Map.fetch(map, {rr, cc}) do
          {:ok, l} -> [{{rr, cc}, l} | candidates]
          :error -> candidates
        end
      end)
      |> Enum.reject(fn {coord, d} ->
        coord in path or d + current_distance > min_complete_distance
      end)

    case candidates do
      [] ->
        :deadend

      _ ->
        Enum.reduce(candidates, min_complete_distance, fn {c, d}, distance ->
          case build_path(init_args, [c | path], current_distance + d, distance) do
            :deadend -> distance
            :too_long -> distance
            i -> i
          end
        end)
    end
  end
end

"sample.txt"
|> File.read!()
|> Day15.init()
|> Day15.build_path([{0, 0}], 0, :infinity)
|> IO.inspect()

# "input.txt"
# |> File.read!()
# |> Day15.init()
# |> Day15.build_path([{0, 0}], 0, :infinity)
# |> IO.inspect()

# :timer.kill_after(:timer.seconds(10000), pid)
