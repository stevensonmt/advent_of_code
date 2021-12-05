defmodule Day5 do
  @moduledoc false

  # input file processed to list of list of tuple pairs
  @input "input.txt"
         |> File.read!()
         |> String.split(["\n", ",", " -> "], trim: true)
         |> Enum.map(&String.to_integer(&1))
         |> Enum.chunk_every(4)
         |> Enum.map(fn [a, b, c, d] -> [{a, b}, {c, d}] end)

  @spec count_overlaps(bool) :: %{{integer, integer} => integer}
  def count_overlaps(part1?) do
    @input
    |> Enum.reduce(%{}, fn [{x1, y1}, {x2, y2}], acc ->
      case {x1 == x2, y1 == y2} do
        {true, true} ->
          acc

        {true, false} ->
          Stream.cycle([x1])
          |> Enum.zip(y1..y2)
          |> Enum.reduce(acc, fn c, a ->
            Map.update(a, c, 1, fn current -> current + 1 end)
          end)

        {false, true} ->
          x1..x2
          |> Enum.zip(Stream.cycle([y1]))
          |> Enum.reduce(acc, fn c, a ->
            Map.update(a, c, 1, fn current -> current + 1 end)
          end)

        {false, false} ->
          if part1? do
            acc
          else
            x1..x2
            |> Enum.zip(y1..y2)
            |> Enum.reduce(acc, fn c, a ->
              Map.update(a, c, 1, fn current -> current + 1 end)
            end)
          end
      end
    end)
  end

  def do_pt_1() do
    count_overlaps(true)
    |> Enum.count(fn {_, v} -> v > 1 end)
  end

  def do_pt_2() do
    count_overlaps(false)
    |> Enum.count(fn {_, v} -> v > 1 end)
  end
end

Day5.do_pt_1() |> IO.inspect()
Day5.do_pt_2() |> IO.inspect()
