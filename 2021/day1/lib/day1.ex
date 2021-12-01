defmodule Day1 do
  @moduledoc false

  def parse(path) do
    File.stream!(path)
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.to_integer(&1))
  end

  def depth_increment_count(input, step \\ 1) do
    Enum.zip_reduce([input, Enum.drop(input, step)], 0, fn [a, b], acc ->
      if b > a do
        acc + 1
      else
        acc
      end
    end)
  end

  def trios_increment(input) do
    depth_increment_count(input, 3)
  end
end

input = Day1.parse("lib/input.txt")
IO.puts(Day1.depth_increment_count(input))
IO.puts(Day1.trios_increment(input))
