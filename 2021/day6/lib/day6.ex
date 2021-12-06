defmodule Day6 do
  @moduledoc """
  Documentation for `Day6`.
  """

  @input "input.txt"
         |> File.read!()
         |> String.trim()
         |> String.split(",", trim: true)
         |> Enum.map(&String.to_integer/1)

  def pt_1() do
    do_pt_1(@input, 0, 80)
  end

  defp do_pt_1(school, day, day) do
    length(school)
  end

  defp do_pt_1(school, day, limit) do
    new_fishies = List.duplicate(8, Enum.count(school, &Kernel.==(&1, 0)))

    school
    |> Enum.map(fn x ->
      case x do
        0 -> 6
        _ -> x - 1
      end
    end)
    |> Kernel.++(new_fishies)
    |> do_pt_1(day + 1, limit)
  end

  def pt_2() do
    do_pt_1(@input, 0, 256)
  end
end

Day6.pt_1() |> IO.inspect(label: "part 1")
Day6.pt_2() |> IO.inspect(label: "part 2")
