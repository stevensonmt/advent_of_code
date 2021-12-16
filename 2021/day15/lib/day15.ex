defmodule Day15 do
  @moduledoc """
  My solution for AoC 2021 `Day15`.
  """

  @neighbors [{0, -1}, {0, 1}, {1, 0}, {-1, 0}]

  def do_pt_1(input) do
    input
    |> solve()
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

  def init(input) do
    map = parse(input)
    max_row = Map.keys(map) |> Enum.map(&elem(&1, 0)) |> Enum.max()
    max_col = Map.keys(map) |> Enum.map(&elem(&1, 1)) |> Enum.max()

    {map, {max_row, max_col}}
  end

  def solve(input) when is_binary(input) do
    {map, endpoint} = input |> init()
    solve([:gb_sets.singleton({0, {0, 0}}), map, :infinity, endpoint, MapSet.new()])
  end

  def solve([queue, map, min_risk, endpoint, seen]) do
    with {:continue, args} <- solver([queue, map, min_risk, endpoint, seen]),
         {:ok, updated_args} <- update_args([args, queue, map, min_risk, endpoint, seen]) do
      solve(updated_args)
    else
      {:stop, min_risk} -> min_risk
    end
  end

  defp solver([queue, map, min_risk, endpoint, seen]) do
    if :gb_sets.is_empty(queue) do
      {:stop, min_risk}
    else
      {{risk, position}, queue} = :gb_sets.take_smallest(queue)

      cond do
        risk >= min_risk ->
          {:continue, :none}

        position == endpoint ->
          {:continue, [{:seen, position}, {:min_risk, risk}]}

        true ->
          {:continue, [{:seen, position}, {:queue, position}, {:risk, risk}]}
      end
    end
  end

  defp update_args([:none | args]), do: args

  defp update_args([[{:seen, pos}, {:min_risk, risk}] | args]) do
    {:ok,
     args
     |> List.update_at(4, &MapSet.put(&1, pos))
     |> List.replace_at(2, risk)}
  end

  defp update_args([[{:seen, pos}, {:queue, pos}, {:risk, risk}] | args]) do
    args = List.update_at(args, 4, &MapSet.put(&1, pos))

    {:ok,
     args
     |> List.update_at(0, fn _ -> get_neighbors(pos, risk, args) end)}
  end

  # cond do
  # :gb_sets.is_empty(queue) ->
  # min_risk

  # true ->
  # {{risk, position}, queue} = :gb_sets.take_smallest(queue)

  # cond do
  # risk >= min_risk ->
  # solve(queue, map, min_risk, endpoint, seen)

  # true ->
  # seen = MapSet.put(seen, position)

  # case position do
  # ^endpoint ->
  # solve(queue, map, risk, endpoint, seen)

  # _ ->
  # position
  # |> get_neighbors(queue, map, seen, risk)
  # |> solve(map, min_risk, endpoint, seen)
  # end
  # end
  # end
  # end

  defp get_neighbors(position = {row, col}, risk, [queue, map, min_risk, endpoint, seen]) do
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

"sample.txt"
|> File.read!()
|> Day15.do_pt_1()
|> IO.inspect(label: "sample, pt 1")

# "input.txt"
# |> File.read!()
# |> Day15.do_pt_1()
# |> IO.inspect(label: "input, pt 1")
