defmodule Day12 do
  @moduledoc false

  # cave system represented by map of cave keys with connected caves in MapSet as vals
  #
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [k, v], acc ->
      IO.inspect({k, v})

      Map.update(acc, k, MapSet.new([v]), fn vs -> MapSet.put(vs, v) end)
      |> Map.update(v, MapSet.new([k]), fn vs -> MapSet.put(vs, k) end)
    end)
    |> IO.inspect(label: "parsed")
  end

  def build_paths(cave_system) do
    build_paths(cave_system, ["start"])
  end

  defp build_paths(cave_system, [current_cave | prior_caves] = path) do
    cave_system
    |> Map.get(current_cave)
    |> IO.inspect(label: "candidates")
    |> Enum.flat_map(fn cave ->
      cond do
        String.upcase(cave) == cave -> build_paths(cave_system, [cave | path])
        cave in prior_caves -> :dead_end
        cave == "end" -> [cave | path]
        true -> build_paths(cave_system, [cave | path])
      end
    end)
    |> Enum.reject(&Kernel.==(Function.identity(&1), :dead_end))
    |> Enum.count()
  end

  def do_pt_1(input) do
    input
    |> parse()
    |> IO.inspect()
    |> build_paths()
  end
end

sample = "start-A
start-b
A-c
A-b
b-d
A-end
b-end"

Day12.do_pt_1(sample)
