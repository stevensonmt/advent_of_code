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
    |> count_and_reset_flashed()

    # |> reset_flashed()
    # |> count_flashed()
  end

  def increment_all(map) do
    map
    |> Enum.map(fn {coord, v} -> {coord, v + 1} end)
    |> Enum.into(%{})
    |> flash()
  end

  def flash(map) do
    map
    |> Enum.reduce({map, false}, fn {{i, j}, v}, {acc, flashed?} ->
      if v == 10 do
        IO.puts("not step 1")
        {increment_neighbors(acc, {i, j}), true}
      else
        {acc, flashed?}
      end
    end)
    |> recurse?()

    # |> zero_flashed()
  end

  def increment_neighbors(map, {i, j}) do
    @neighbors
    |> Enum.reduce(map, fn {m, n}, acc ->
      case Map.get(acc, {m + i, n + j}) do
        nil ->
          acc

        # 9 ->
        # flash(Map.put(acc, {m + i, n + j}, 10))

        x ->
          Map.put(acc, {m + i, n + j}, x + 1)
      end
    end)
  end

  def recurse?({map, false}), do: map
  def recurse?({map, true}), do: flash(map)

  def count_and_reset_flashed(map) do
    map
    |> Enum.reject(fn {_, v} -> v < 10 end)
    |> Enum.reduce({map, 0}, fn {coord, v}, {m, count} ->
      if v > 9 do
        # IO.inspect(coord, label: "this flashed")
        {Map.put(m, coord, 0), count + 1}
      else
        {m, count}
      end
    end)
  end

  def update_count({_, c} = t, count), do: put_elem(t, 1, c + count)

  def pt_1(input) do
    data =
      input
      |> parse_input()

    1..2
    |> Enum.reduce({data, 0}, fn i, {map, count} ->
      IO.inspect(i, label: "STEP:")

      t =
        map
        |> step()
        # |> IO.inspect(label: "map, count")
        |> update_count(count)

      # Enum.sort_by(fn {coord, v} -> coord end) |> IO.inspect()
      # elem(t, 0) |> Map.get({7, 3}) |> IO.inspect()

      t
    end)
    |> elem(1)
  end
end

Day11.pt_1("test.txt") |> IO.inspect()
