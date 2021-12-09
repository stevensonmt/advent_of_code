defmodule Day9 do
  @moduledoc false

  @input "input.txt"
         |> File.stream!()

  @row_max Enum.count(@input) - 1

  @col_max Enum.take(@input, 1) |> Enum.count() |> Kernel.-(1)

  @processed Stream.with_index(@input)
             |> Stream.flat_map(fn {l, r} ->
               String.trim(l)
               |> String.graphemes()
               |> Enum.with_index()
               |> Enum.map(fn {n, c} -> {{r, c}, String.to_integer(n)} end)
             end)
             |> Enum.into(%{})

  def find_low_pts() do
    for r <- 0..@row_max,
        c <- 0..@col_max do
          {r, c}
        end 
        |> Enum.filter(fn {r, c} -> 
      for m <- [(r - 1),(r + 1)],
          n <- [(c - 1),(c + 1)] do
        {m, n}
      end
      |> Enum.all(fn {m, n} -> Map.get(@processed, {m, n}) > Map.get(@processed, {r, c})
      
    end
    |> IO.inspect()
  end
end

Day9.find_low_pts()
