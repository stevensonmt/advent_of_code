defmodule Day9 do
  @input File.stream!("lib/input", [:trim_bom])
         |> Stream.map(&String.trim(&1))
         |> Enum.map(&String.to_integer(&1))

  def first_invalid() do
    last_valid =
      @input
      |> Stream.with_index()
      |> Stream.chunk_every(26, 1, :discard)
      |> Stream.map(fn list -> Enum.reverse(list) end)
      |> Stream.map(fn [head | rest] -> {head, combinations(rest)} end)
      |> Stream.take_while(fn {{val, _ndx}, pairs} ->
        Enum.any?(pairs, fn pair ->
          Enum.reduce(pair, 0, fn {item, _i}, acc -> acc + item end) == val
        end)
      end)
      |> Stream.map(fn {{_val, ndx}, _} -> ndx end)
      |> Enum.reverse()
      |> List.first()

    {Enum.at(@input, last_valid + 1), last_valid + 1}
  end

  def combinations(list) do
    for a <- list, b <- list, uniq: true do
      [a, b] |> Enum.sort()
    end
  end

  def combinations(list, k) do
    len = Enum.count(list)

    if k > len do
      :error
    else
      combine(list, len, k, [], [])
    end
  end

  def combine(_, _, 0, _, _) do
    [[]]
  end

  def combine(list, _, 1, _, _) do
    list
    |> Enum.map(&[[&1]])
  end

  def combine(list, len, k, current_combo, all_combos) do
    list
    |> Stream.unfold(fn [h | t] -> {{h, t}, t} end)
    |> Stream.take(len)
    |> Enum.reduce(all_combos, fn {x, sublist}, acc ->
      sublist_len = Enum.count(sublist)
      current_combo_len = Enum.count(current_combo)

      if k > sublist_len + current_combo_len + 1 do
        # current combo not k-sized but not enough elements to produce another full combo
        acc
      else
        new_curr_combo = [x | current_combo]
        new_curr_combo_len = current_combo_len + 1

        case new_curr_combo_len do
          # k-sized combo found, add it to the list
          ^k -> [new_curr_combo | acc]
          # curr combo not k-sized so try with sub list
          _ -> combine(sublist, sublist_len, k, new_curr_combo, acc)
        end
      end
    end)
  end

  def valid_slice(list, start, stop, target) do
    slice =
      list
      |> Enum.slice(start, stop - start)

    sum = Enum.sum(slice)

    cond do
      sum == target -> Enum.sum([Enum.min(slice), Enum.max(slice)])
      sum > target -> valid_slice(list, start + 1, start + 2, target)
      sum < target -> valid_slice(list, start, stop + 1, target)
    end
  end

  def part1() do
    elem(first_invalid(), 0)
  end

  def part2() do
    {target, max} = first_invalid()

    sublist = Enum.slice(@input, 0..(max - 1))

    valid_slice(sublist, 0, 1, target)
  end
end

IO.inspect(Day9.part1())
IO.inspect(Day9.part2())
