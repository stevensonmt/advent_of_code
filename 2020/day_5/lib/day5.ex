defmodule Day5 do
  @input File.stream!("lib/input.txt")

  @process_input @input
                 |> Stream.map(&String.trim(&1))
                 |> Stream.map(
                   &String.replace(&1, ["F", "B", "L", "R"], fn c ->
                     case c do
                       "F" -> "0"
                       "B" -> "1"
                       "L" -> "0"
                       "R" -> "1"
                     end
                   end)
                 )
                 |> Enum.map(&String.to_integer(&1, 2))

  def highest_seat do
    @process_input
    |> Enum.max()
  end

  def sort_tickets do
    @process_input
    |> Enum.sort()
  end

  def find_gap do
    sort_tickets()
    |> Stream.chunk_every(2, 1, :discard)
    |> Enum.find(fn [a, b] -> b - a == 2 end)
    |> Enum.take(1)
    |> Enum.reduce(1, fn x, acc -> x + acc end)
  end
end

IO.inspect(Day5.highest_seat())
IO.inspect(Day5.find_gap())
