defmodule Day9 do
  @moduledoc false

  @input "input.txt"
         |> File.read!()
         |> String.trim()
         |> String.split()

  @processed Stream.with_index(@input)
             |> Stream.flat_map(fn {l, r} ->
               String.trim(l)
               |> String.graphemes()
               |> Enum.with_index()
               |> Enum.map(fn {n, c} -> {c, String.to_integer(n)} end)
               |> Enum.map(fn {c, n} -> {{r, c}, n} end)
             end)
             |> Enum.into(%{})

  @neighbors [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  def find_low_pts() do
    @processed
    |> Enum.filter(fn {{r, c}, h} ->
      h < min_neighbor_heights({r, c})
    end)
  end

  def do_pt_1() do
    find_low_pts()
    |> Enum.map(fn {_, h} -> h + 1 end)
    |> Enum.sum()
  end

  def min_neighbor_heights({r, c}) do
    @neighbors
    |> Enum.map(fn {x, y} -> {x + r, y + c} end)
    |> Enum.map(fn {xx, yy} ->
      case Map.fetch(@processed, {xx, yy}) do
        {:ok, ht} ->
          ht

        _ ->
          :infinity
      end
    end)
    |> Enum.min()
  end

  def do_pt_2() do
    find_low_pts()
    |> find_basin_sizes()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp find_basin_sizes(low_pts) do
    low_pts
    |> Enum.map(fn {{r, c}, h} ->
      map_basin({r, c}, h, MapSet.new([{{r, c}, h}]))
    end)
    |> Enum.map(&map_basin(&1))
    |> Enum.map(&MapSet.size(&1))
  end

  defp map_basin({r, c}, h, basin) do
    @neighbors
    |> Enum.map(fn {x, y} -> {x + r, y + c} end)
    |> Enum.map(fn coord ->
      case Map.fetch(@processed, coord) do
        {:ok, ht} ->
          {coord, ht}

        _ ->
          {coord, -1}
      end
    end)
    |> Enum.filter(fn {_coord, hh} -> hh > h and hh < 9 end)
    |> Enum.reduce(basin, fn {coord, hh}, acc -> MapSet.put(acc, {coord, hh}) end)
  end

  defp map_basin(basin) do
    new =
      basin
      |> Enum.reduce(basin, fn {coord, ht}, acc -> map_basin(coord, ht, acc) end)

    if MapSet.equal?(new, basin) do
      basin
    else
      map_basin(new)
    end
  end
end

Day9.do_pt_1() |> IO.inspect()
Day9.do_pt_2() |> IO.inspect()
