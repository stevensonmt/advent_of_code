defmodule Day14 do
  @moduledoc """
  My solution to AoC day 14 2021
  """
  def parse(input) do
    input
    |> File.read!()
    |> String.split("\n\n", trim: true, parts: 2)
    |> parse_rules()
  end

  defp parse_rules([start, rules]) do
    {start,
     start
     |> String.to_charlist()
     |> Enum.chunk_every(2, 1, :discard),
     rules
     |> String.split("\n", trim: true)
     |> Enum.map(fn <<a, b>> <> " -> " <> <<c>> -> {[a, b], [c], [a, c], [c, b]} end)}
  end

  defp apply_rules({pair_counts = %{}, lttr_counts = %{}}, rules, limit, current)
       when limit > current do
    rules
    |> Enum.reduce({pair_counts, lttr_counts}, fn {rule_key_pair, insert, result_pair_1,
                                                   result_pair_2},
                                                  {pairs, lttrs} ->
      pair_counts
      |> Enum.filter(fn {k, v} -> k == rule_key_pair and v > 0 end)
      |> Enum.reduce({pairs, lttrs}, fn {k, count}, {prs, ltrs} ->
        {Map.update!(pairs, rule_key_pair, &Kernel.-(&1, count))
         |> Map.update(result_pair_1, count, &Kernel.+(&1, count))
         |> Map.update(result_pair_2, count, &Kernel.+(&1, count)),
         Map.update(lttrs, insert, count, &Kernel.+(&1, count))}
      end)
    end)
    |> apply_rules(rules, limit, current + 1)
  end

  defp apply_rules({%{}, lttr_counts = %{}}, _, limit, current) when limit <= current,
    do: lttr_counts

  defp apply_rules({source, src_prs, rules}, limit, current \\ 0) do
    pair_counts =
      src_prs
      |> Enum.reduce(%{}, fn pair, counts -> Map.update(counts, pair, 1, fn i -> i + 1 end) end)

    letter_counts =
      source |> String.graphemes() |> Enum.map(&String.to_charlist(&1)) |> Enum.frequencies()

    tracker = {pair_counts, letter_counts}

    rules
    |> Enum.reduce(tracker, fn
      {rule_key_pair, insert, result_pair_1, result_pair_2}, {pairs, lttrs} ->
        src_prs
        |> Enum.filter(fn pair -> pair == rule_key_pair end)
        |> Enum.reduce({pairs, lttrs}, fn pair, {prs, ltrs} ->
          {prs
           |> Map.update(rule_key_pair, 1, &Kernel.-(&1, 1))
           |> Map.update(result_pair_1, 1, &Kernel.+(&1, 1))
           |> Map.update(result_pair_2, 1, &Kernel.+(&1, 1)),
           Map.update(ltrs, insert, 1, &Kernel.+(&1, 1))}
        end)
    end)
    |> apply_rules(rules, limit, current + 1)
  end

  defp get_difference({min, max}), do: max - min

  def do_pt_1(input, limit) do
    input
    |> parse()
    |> apply_rules(limit)
    |> Map.values()
    |> Enum.min_max()
    |> get_difference()
  end

  def do_pt_2(input), do: do_pt_1(input, 40)
end

"sample.txt"
|> Day14.do_pt_1(10)
|> IO.inspect()

"sample.txt"
|> Day14.do_pt_2()
|> IO.inspect()

"input.txt"
|> Day14.do_pt_1(10)
|> IO.inspect()

"input.txt"
|> Day14.do_pt_2()
|> IO.inspect()
