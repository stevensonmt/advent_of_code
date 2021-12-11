defmodule Day11 do
  @moduledoc false

  @neighbors (for i <- -1..1,
                  j <- -1..1 do
                {i, j}
              end)

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
    |> flash()
    |> reset_flashed()

    # |> count_flashed()
  end

  def increment(map, coord) do
    case Map.fetch(map, coord) do
      {:ok, 9} -> flash(Map.put(map, coord, 10))
      {:ok, v} -> Map.put(map, coord, n + 1)
      _ -> map
    end
  end

  def increment_all(map) do
    map
    |> Enum.reduce(map, fn {coord, _v}, acc -> increment(acc, coord) end)
  end

  def flash(map) do
    map
    |> Enum.filter(&Kernel.==(elem(&1, 1), 10))
    |> Enum.flat_map(fn {{x, y}, _} ->
      @neighbors |> Enum.map(fn {m, n} -> {m + x, n + y} end)
    end)
    |> Enum.reduce(map, fn coord, acc ->
      case Map.fetch(acc, coord) do
        {:ok, 9} -> flash(Map.put(acc, coord, 10))
        {:ok, v} -> Map.put(acc, coord, v + 1)
        _ -> acc
      end
    end)
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
    |> Enum.reduce({data, 0}, fn i, {map, c} ->
      updated = map |> step()
      count = updated |> Enum.count(fn {_, v} -> v == 0 end)
      {updated, c + count}
    end)
    |> elem(1)
  end
end

Day11.pt_1("test.txt") |> IO.inspect()
