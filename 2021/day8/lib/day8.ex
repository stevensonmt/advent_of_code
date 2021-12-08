defmodule Day8 do
  @moduledoc false

  @input "input.txt"
         |> File.stream!()
         |> Stream.map(&String.trim/1)
         |> Stream.map(&String.split(&1, " | "))
         |> Stream.map(&Enum.map(&1, fn s -> String.split(s) end))
         |> Enum.to_list()
         |> IO.inspect()

  @segments [:top, :northeast, :southeast, :bottom, :southwest, :northwest, :median]

  @uniqdigitsegments [2, 3, 4, 7]

  def do_pt_1() do
    @input
    |> Enum.map(&decode_uniq_digits/1)
    |> Enum.sum()
  end

  def decode_uniq_digits([digits, coded_vals]) do
    coded_vals
    |> Enum.count(&Enum.any?(@uniqdigitsegments, fn i -> String.length(&1) == i end))
  end

  def do_pt_2() do
    @input
    # |> Enum.take(3)
    |> Enum.map(fn [digits, vals] ->
      [
        digits
        |> Enum.map(fn d -> String.graphemes(d) |> Enum.sort() end)
        |> Enum.uniq(),
        vals |> Enum.map(fn d -> String.graphemes(d) |> Enum.sort() end)
      ]
    end)
    |> Enum.map(&decipher/1)
    |> Enum.sum()
  end

  def decipher([digits, coded_vals]) do
    cipher =
      [{1, 2}, {7, 3}, {4, 4}, {8, 7}]
      |> Enum.map(fn {n, segs} ->
        {n, Enum.find(digits, fn s -> length(s) == segs end)}
      end)
      |> Enum.into(%{})

    find_nine_six_and_zero(cipher, digits)
    |> find_two_three_and_five(digits)
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Enum.into(%{})
    |> decode_vals(coded_vals)
  end

  defp find_nine_six_and_zero(map, digits) do
    one = Map.get(map, 1)

    four = Map.get(map, 4)

    nine_six_or_zero = digits |> Enum.filter(fn d -> length(d) == 6 end)

    [six] =
      nine_six_or_zero
      |> Enum.reject(fn d ->
        Enum.all?(one, fn c -> Enum.find(d, fn e -> c == e end) end)
      end)

    [zero, nine] =
      (nine_six_or_zero -- [six])
      |> Enum.sort_by(fn d -> Enum.all?(four, fn e -> Enum.find(d, fn f -> f == e end) end) end)

    [zero, six, nine]
    |> Enum.zip([0, 6, 9])
    |> Enum.reduce(map, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  defp find_two_three_and_five(map, digits) do
    one = Map.get(map, 1)
    eight = Map.get(map, 8)
    nine = Map.get(map, 9)
    [southwest] = eight -- nine

    candidates = digits |> Enum.filter(fn d -> length(d) == 5 end)

    three =
      candidates
      |> Enum.find(fn d -> Enum.all?(one, fn c -> Enum.find(d, fn e -> c == e end) end) end)

    [five, two] =
      (candidates -- [three])
      |> Enum.sort_by(fn d -> Enum.find(d, fn e -> e == southwest end) end)

    [two, three, five]
    |> Enum.zip([2, 3, 5])
    |> Enum.reduce(map, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  defp decode_vals(map, coded_vals) do
    IO.inspect(map)

    coded_vals
    |> Enum.map(fn c ->
      Map.get(map, c)
    end)
    |> Integer.undigits()
  end
end

# Day8.do_pt_1() |> IO.inspect()
Day8.do_pt_2() |> IO.inspect()
