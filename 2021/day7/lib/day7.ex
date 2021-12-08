defmodule Day7 do
  @moduledoc false

  @input "input.txt"
         |> File.read!()
         |> String.trim()
         |> String.split(",")
         |> Enum.map(&String.to_integer(&1))
         |> Enum.sort()
         |> IO.inspect()

  # @ref_pts List.to_tuple(Enum.uniq(@input))

  # @max Kernel.tuple_size(@ref_pts) - 1

  def fuel_cost(n) do
    div(n * (n + 1), 2)
  end

  def pt_1() do
    calc(fn {k, v}, n -> abs(k - n) * v end)
  end

  def pt_2() do
    calc(fn {k, v}, n -> fuel_cost(abs(k - n)) * v end)
  end

  def calc(fun) do
    {min, max} = @input |> Enum.min_max()

    min..max
    |> Enum.map(fn i ->
      @input
      |> Enum.frequencies()
      |> Enum.map(fn {k, v} ->
        fun.({k, v}, i)
      end)
      |> Enum.sum()
    end)
    |> Enum.min()
  end
end

Day7.pt_1() |> IO.inspect()
Day7.pt_2() |> IO.inspect()
