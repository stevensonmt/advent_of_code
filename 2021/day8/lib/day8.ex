defmodule Day8 do
  @moduledoc false

  def input do
    "input.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split(&1, " | "))
    |> Stream.map(&Enum.map(&1, fn s -> String.split(s) end))
  end

  @uniqdigitsegments [2, 3, 4, 7]

  def do_pt_1() do
    input()
    |> Stream.map(&count_uniq_digits/1)
    |> Enum.sum()
  end

  def count_uniq_digits([_digits, coded_vals]) do
    coded_vals
    |> Enum.count(&Enum.any?(@uniqdigitsegments, fn i -> String.length(&1) == i end))
  end

  def do_pt_2() do
    input()
    |> Stream.map(fn [digits, vals] ->
      [
        digits
        |> Enum.map(fn d -> String.graphemes(d) |> Enum.sort() end)
        |> Enum.uniq(),
        vals |> Enum.map(fn d -> String.graphemes(d) |> Enum.sort() end)
      ]
    end)
    |> Stream.map(&decipher/1)
    |> Enum.sum()
  end

  def decipher([digits, coded_vals]) do
    digits
    |> decode_uniq_digits()
    |> decode_six_seg_digits(digits)
    |> decode_five_seg_digits(digits)
    |> Enum.reduce(%{}, fn {k, v}, acc -> Map.put(acc, v, k) end)
    |> decode_vals(coded_vals)
  end

  defp decode_uniq_digits(digits) do
    [1, 7, 4, 8]
    |> Stream.zip(@uniqdigitsegments)
    |> Stream.map(fn {n, segs} ->
      {n, Enum.find(digits, fn s -> length(s) == segs end)}
    end)
    |> Enum.into(%{})
  end

  defp decode_six_seg_digits(map, digits) do
    digits
    |> Enum.filter(fn d -> length(d) == 6 end)
    |> decode_six(map)
    |> decode_zero_nine(digits)
  end

  defp decode_five_seg_digits(map, digits) do
    digits
    |> Enum.filter(fn d -> length(d) == 5 end)
    |> decode_three(map)
    |> decode_two_five(digits)
  end

  defp decode_six(candidates, map) do
    Map.put(
      map,
      6,
      candidates
      |> Enum.find(fn d -> not MapSet.subset?(MapSet.new(Map.get(map, 1)), MapSet.new(d)) end)
    )
  end

  defp decode_zero_nine(map, digits) do
    digits
    |> Enum.filter(fn d -> length(d) == 6 and Map.get(map, 6) != d end)
    |> Enum.sort_by(fn d -> MapSet.subset?(MapSet.new(Map.get(map, 4)), MapSet.new(d)) end)
    |> Enum.zip([0, 9])
    |> Enum.reduce(map, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  defp decode_three(candidates, map) do
    Map.put(
      map,
      3,
      candidates
      |> Enum.find(fn d -> MapSet.subset?(MapSet.new(Map.get(map, 1)), MapSet.new(d)) end)
    )
  end

  defp decode_two_five(map, digits) do
    digits
    |> Enum.filter(fn d -> length(d) == 5 and Map.get(map, 3) != d end)
    |> Enum.sort_by(fn d ->
      MapSet.subset?(
        MapSet.new(MapSet.difference(MapSet.new(Map.get(map, 8)), MapSet.new(Map.get(map, 9)))),
        MapSet.new(d)
      )
    end)
    |> Enum.zip([5, 2])
    |> Enum.reduce(map, fn {v, k}, acc -> Map.put(acc, k, v) end)
  end

  defp decode_vals(map, coded_vals) do
    coded_vals
    |> Enum.map(fn c ->
      Map.get(map, c)
    end)
    |> Integer.undigits()
  end
end

Day8.do_pt_1() |> IO.inspect()
Day8.do_pt_2() |> IO.inspect()
