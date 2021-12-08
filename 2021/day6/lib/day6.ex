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

  def pt_2(limit) do
    # initial value(1+growth rate as decimal)^x or (initial value * (1+growth rate)^x
    @input
    |> Enum.frequencies()
    |> do_pt_2(limit)
    |> Map.values()
    |> Enum.sum()
  end

  defp do_pt_2(school, 0), do: school

  defp do_pt_2(school, limit) do
    school
    |> Map.pop(0)
    |> then(fn {spawning, schl} ->
      schl
      |> Enum.map(fn {timer, count} -> {timer - 1, count} end)
      |> Enum.into(%{})
      |> Map.merge(%{6 => spawning, 8 => spawning}, fn
        _, nil, v -> v
        _, v, nil -> v
        _, v, v2 -> v + v2
      end)
      |> do_pt_2(limit - 1)
    end)
  end

  def alt_2() do
    @input
    |> Enum.frequencies()
    |> Task.async_stream(fn {k, v} -> v * Float.pow(2.0, (256 - k) / 7) end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end
end

Day6.pt_1() |> IO.inspect(label: "part 1")
Day6.pt_2(256) |> IO.inspect(label: "part 2")
Day6.alt_2() |> IO.inspect(label: "alt 2")
