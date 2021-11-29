defmodule Day6 do
  @input File.read!("lib/input.txt") |> String.split("\n\n")

  def total_affirmative_answers() do
    @input
    |> Stream.map(&unique_affirmatives(&1))
    |> Stream.map(&MapSet.size(&1))
    |> Enum.sum()
  end

  defp unique_affirmatives(lines) do
    lines
    |> String.split("\n", trim: true)
    |> Enum.map(&String.codepoints(&1))
    |> Enum.map(&MapSet.new(&1))
    |> Enum.reduce(MapSet.new(), fn set, acc -> MapSet.union(acc, set) end)
  end

  defp inclusive_affirmatives() do
    @input
    |> Enum.map(&get_set_for_group(&1))
  end

  defp get_set_for_group(group) do
    group =
      group
      |> String.split("\n", trim: true)
      |> Enum.map(&String.codepoints(&1))
      |> Enum.map(&MapSet.new(&1))

    group
    |> Enum.reduce(List.first(group), fn individual, acc ->
      MapSet.intersection(acc, individual)
    end)
  end

  def total_inclusive_affirmatives() do
    inclusive_affirmatives()
    |> Enum.map(&MapSet.size(&1))
    |> Enum.sum()
  end
end

IO.inspect(Day6.total_affirmative_answers())
IO.inspect(Day6.total_inclusive_affirmatives())
