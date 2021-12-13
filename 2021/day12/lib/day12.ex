defmodule Day12 do
  @moduledoc false

  # cave system represented by map of cave keys with connected caves in MapSet as vals
  #
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(%{}, fn [k, v], acc ->
      Map.update(acc, k, MapSet.new([v]), fn vs -> MapSet.put(vs, v) end)
      |> Map.update(v, MapSet.new([k]), fn vs -> MapSet.put(vs, k) end)
    end)
  end

  def build_paths(cave_system, part_2?) do
    build_paths(cave_system, ["start"], part_2?)
  end

  defp build_paths(cave_system, [current_cave | prior_caves] = path, part_2?) do
    cave_system
    |> Map.get(current_cave)
    |> Enum.reduce(MapSet.new(), fn cave, paths ->
      cond do
        String.upcase(cave) == cave ->
          # large caves are always valid next points
          MapSet.union(paths, build_paths(cave_system, [cave | path], part_2?))

        cave == "start" ->
          paths

        cave in prior_caves and small_only_once?(prior_caves, part_2?) ->
          # small caves already visited can be revisited if no other small cave has been revisited
          # IO.inspect({cave, prior_caves}, label: "why")
          MapSet.union(paths, build_paths(cave_system, [cave | path], part_2?))

        cave in prior_caves ->
          # [:dead_end]
          paths

        cave == "end" ->
          [cave | path] |> Enum.reverse() |> Enum.join(",") |> IO.inspect(label: "finished path")
          MapSet.put(paths, [cave | path])

        true ->
          MapSet.union(paths, build_paths(cave_system, [cave | path], part_2?))
      end
    end)
  end

  defp small_only_once?(_caves, false), do: false

  defp small_only_once?(caves, true) do
    caves
    |> Enum.reject(fn cave -> String.upcase(cave) == cave end)
    |> Enum.frequencies()
    # |> IO.inspect(label: "frequencies check")
    |> Enum.all?(fn {_, v} -> v == 1 end)

    # |> IO.inspect()
  end

  def do_pt_1(input), do: solve(input)
  def do_pt_2(input), do: solve(input, true)

  defp solve(input, part_2? \\ false) do
    input
    |> parse()
    |> build_paths(part_2?)
    |> MapSet.size()
    |> IO.inspect(label: "total paths")
  end
end

sample = "start-A
start-b
A-c
A-b
b-d
A-end
b-end"

# Day12.do_pt_1(sample)
# Day12.do_pt_2(sample)

sample2 = "dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc"

# Day12.do_pt_1(sample2)
Day12.do_pt_2(sample2)

sample3 = "fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW"

# Day12.do_pt_1(sample3)
# Day12.do_pt_2(sample3)

input = "input.txt" |> File.read!()

# Day12.do_pt_1(input)
# Day12.do_pt_2(input)
