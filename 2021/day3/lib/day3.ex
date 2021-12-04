defmodule Day3 do
  use Bitwise

  @moduledoc false

  @input "input.txt"
         |> File.stream!()
         |> Enum.map(&String.trim(&1))

  def process_1() do
    @input
    |> Enum.map(&(String.graphemes(&1) |> Enum.with_index()))
    |> List.flatten()
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
    |> Enum.map(fn {k, v} -> Enum.frequencies(v) end)
  end

  def do_part_1() do
    gamma = process_1() |> gamma() |> Enum.map(fn d -> String.to_integer(d) end)
    epsilon = invert(gamma)

    [gamma, epsilon]
    |> Enum.map(&Integer.undigits(&1, 2))
    |> Enum.product()
  end

  def gamma(src) do
    src
    |> Enum.map(fn f -> Enum.max_by(f, &elem(&1, 1)) |> elem(0) end)
  end

  def invert(bits) do
    bits
    |> Enum.map(fn b ->
      if b == 1 do
        0
      else
        1
      end
    end)
  end

  def do_part_2() do
    l = bits_length() - 1
    oxygen(0, l, process_1() |> IO.inspect())
  end

  defp bits_length() do
    @input
    |> List.first()
    |> String.graphemes()
    |> length()
  end

  defp oxygen(current, limit, src) do
    if current < limit do
      gamma = gamma(src)
      mask = Enum.at(gamma, current)
      new = src |> Enum.filter(fn i -> Enum.at(i, current) == mask end)
      oxygen(current + 1, limit, new)
    else
      List.first(src)
    end
  end
end

Day3.do_part_1()
|> IO.inspect()

Day3.do_part_2()
|> IO.inspect()
