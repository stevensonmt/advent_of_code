defmodule Day11 do
  @moduledoc false

  def parse_input(input) do
    input
    |> File.read!()
    |> String.trim()
    |> String.split()
    |> Enum.with_index()
    |> Enum.flat_map(fn {s, i} ->
      s
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, j} -> {{i, j}, String.to_integer(c)} end)
    end)
    |> Enum.into(%{})
  end

  def step(map) do
    map
    |> increment_all()
    |> reset_flashed()
  end

  def increment(map, coord) do
    case Map.fetch(map, coord) do
      {:ok, 9} -> flash(Map.put(map, coord, 10), coord)
      {:ok, v} -> Map.put(map, coord, v + 1)
      _ -> map
    end
  end

  def increment_all(map) do
    map
    |> Enum.reduce(map, fn {coord, _v}, acc -> increment(acc, coord) end)
  end

  def flash(map, {x, y}) do
    map
    |> increment({x + 1, y})
    |> increment({x - 1, y})
    |> increment({x + 1, y + 1})
    |> increment({x - 1, y + 1})
    |> increment({x + 1, y - 1})
    |> increment({x - 1, y - 1})
    |> increment({x, y + 1})
    |> increment({x, y - 1})
  end

  def reset_flashed(map) do
    map
    |> Enum.reduce(map, fn {coord, v}, acc ->
      if v > 9 do
        Map.put(acc, coord, 0)
      else
        acc
      end
    end)
  end

  def pt_1(input) do
    data =
      input
      |> parse_input()

    1..100
    |> Enum.reduce({data, 0}, fn _i, {map, c} ->
      updated = map |> step()
      count = updated |> Enum.count(fn {_, v} -> v == 0 end)
      {updated, c + count}
    end)
    |> elem(1)
  end

  def pt_2(input) do
    data = input |> parse_input()

    Stream.iterate(0, fn i -> i + 1 end)
    |> Enum.reduce_while({data, 0}, fn _i, {map, c} ->
      stepped = step(map)

      cond do
        Map.values(stepped) |> Enum.all?(&Kernel.==(&1, 0)) -> {:halt, c + 1}
        true -> {:cont, {stepped, c + 1}}
      end
    end)
  end
end

Day11.pt_1("input.txt") |> IO.inspect()
Day11.pt_2("input.txt") |> IO.inspect()
