defmodule Day3 do
  use Bitwise

  @moduledoc false

  @input "input.txt"
         |> File.stream!()
         |> Enum.map(&String.trim(&1))
         |> Enum.map(&String.graphemes(&1))

  def input, do: @input

  @limit Enum.at(@input, 0) |> length()

  def frequencies(input) do
    input
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list(&1))
    |> Enum.map(&Enum.frequencies(&1))
  end

  def gamma() do
    frequencies(@input)
    |> Enum.map(&Enum.max_by(&1, fn {_, v} -> v end))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&String.to_integer(&1))
    |> Integer.undigits(2)
  end

  def epsilon() do
    ~~~gamma() &&& 0b111111111111
  end

  def do_pt_1() do
    gamma() * epsilon()
  end

  def ohtoo() do
    ohtoo(0, @input)
    |> Enum.map(&String.to_integer(&1))
    |> Integer.undigits(2)
  end

  def ohtoo(column, input) when column < @limit do
    max_bit =
      frequencies(input)
      |> Enum.at(column)
      |> Enum.max_by(&elem(&1, 1), &>/2)
      |> elem(0)

    new_input =
      input
      |> Enum.filter(fn n -> Enum.at(n, column) == max_bit end)

    ohtoo(column + 1, new_input)
  end

  def ohtoo(_, [input]), do: input

  def seeohtoo() do
    seeohtoo(0, @input)
    |> Enum.map(&String.to_integer(&1))
    |> Integer.undigits(2)
  end

  def seeohtoo(column, input) when column < @limit do
    min_bit =
      frequencies(input)
      |> Enum.at(column)
      |> Enum.min_by(&elem(&1, 1), &<=/2)
      |> elem(0)

    new_input =
      input
      |> Enum.filter(fn n -> Enum.at(n, column) == min_bit end)

    seeohtoo(column + 1, new_input)
  end

  def seeohtoo(_, [input]), do: input

  def do_pt_2() do
    ohtoo() * seeohtoo()
  end
end

Day3.do_pt_2() |> IO.inspect()
