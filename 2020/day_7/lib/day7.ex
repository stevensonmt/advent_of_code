defmodule Day7 do
  @input File.read!("lib/input.txt")
         |> String.split(".\n", trim: true)

  def child_to_parents_map() do
    @input
    |> Enum.map(
      &List.flatten(
        Regex.scan(~r/(\w+ \w+)(?= bags contain )|(?<=\d )(\w+ \w+)/, &1, capture: :first)
      )
    )
    |> Enum.map(fn [h | t] -> {h, t} end)
    |> Enum.reduce(Map.new(), fn {parent, children}, map ->
      Enum.reduce(children, map, fn child, acc ->
        Map.update(acc, child, [parent], fn x -> [parent | x] end)
      end)
    end)
  end

  def count_parents(map, bag) do
    count_parents(map, [bag], MapSet.new())
  end

  def count_parents(_map, [], parents) do
    Enum.count(parents)
  end

  def count_parents(map, [bag | rest], parents) do
    case Map.fetch(map, bag) do
      :error -> count_parents(map, rest, parents)
      {:ok, rents} -> count_parents(map, rents ++ rest, MapSet.union(parents, MapSet.new(rents)))
    end
  end

  def parent_to_children_map() do
    @input
    |> Enum.map(
      &List.flatten(
        Regex.scan(~r/(\w+ \w+)(?= bags contain )|((\d) (\w+ \w+))/, &1, capture: :first)
      )
    )
    |> Enum.map(fn [h | t] -> {h, parse_children(t)} end)
    |> Enum.reduce(Map.new(), fn {parent, children}, acc -> Map.put(acc, parent, children) end)
  end

  def parse_children(children) do
    children
    |> Enum.map(&String.split(&1, " ", parts: 2))
    |> Enum.reduce(Map.new(), fn [num, bag], acc ->
      Map.put(acc, bag, String.to_integer(num))
    end)
  end

  def count_children(map, bag) do
    Enum.reduce(map[bag], 0, fn {child, size}, count ->
      count + size + size * count_children(map, child)
    end)
  end

  def part1() do
    child_to_parents_map()
    |> count_parents("shiny gold")
    |> IO.inspect()
  end

  def part2() do
    parent_to_children_map()
    |> count_children("shiny gold")
    |> IO.inspect()
  end
end

Day7.part1()
Day7.part2()
