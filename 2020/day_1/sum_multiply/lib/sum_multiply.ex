defmodule SumMultiply do
  @moduledoc """
  Documentation for `SumMultiply`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SumMultiply.hello()
      :world

  """
  def parse_input() do
    {:ok, expenses} = File.read("lib/input.txt")

    expenses
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  def find_two([h | t], sum) do
    case Enum.find(t, fn x -> sum - h == x end) do
      nil ->
        find_two(t, sum)

      y ->
        h * y
    end
  end

  def find_two([], _sum) do
    nil
  end

  def find_two(sum) do
    parse_input()
    |> find_two(sum)
  end

  def find_three([], _sum) do
    nil
  end

  def find_three([h | t], sum) do
    case find_two(t, sum - h) do
      nil -> find_three(t, sum)
      y -> h * y
    end
  end

  def find_three(sum) do
    parse_input()
    |> find_three(sum)
  end
end

IO.puts(SumMultiply.find_two(2020))
IO.puts(SumMultiply.find_three(2020))
