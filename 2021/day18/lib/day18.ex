defmodule Day18 do
  @moduledoc """
  Solution for AoC `Day18`.
  """

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(Code.eval_string(&1) |> elem(0)))
  end

  def add_lines(a, b) do
    reduce([a, b])
  end

  def reduce(num) do
    num
    |> try_explode()
    |> again?()
    |> IO.inspect(label: "exploded")
    |> try_split()
    |> again?()
    |> IO.inspect(label: "splitted")
  end

  def try_explode(n) do
    case explode(n, 0) do
      {_, l, _} ->
        {:exploded, l}

      false ->
        {:none, n}
    end
  end

  def try_split([a, b] = n) do
    case split(a) do
      false ->
        case split(b) do
          false -> {:none, n}
          x -> {:split, x}
        end

      x ->
        {:split, x}
    end
  end

  def split([a, b]) do
    cond do
      x = split(a) -> [x, b]
      x = split(b) -> [a, x]
      true -> false
    end
  end

  def split(n) when n > 9, do: [div(n, 2), ceil(n / 2)]
  def split(_n), do: false

  def merge([a, b], n) do
    [a, merge(b, n)]
  end

  def merge(n, [a, b]) do
    [merge(n, a), b]
  end

  def merge(a, b) do
    a + b
  end

  def explode(n), do: explode(n, 0)

  def explode([a, b], 4) do
    {a, 0, b}
  end

  def explode([a, b], level) do
    IO.inspect(binding(), label: "explode args")

    case explode(a, level + 1) do
      {aa, n, ab} ->
        {aa, [n, merge(ab, b)], 0} |> IO.inspect(label: "exploded a")

      _ ->
        case explode(b, level + 1) do
          {ba, n, bb} ->
            {0, [merge(a, ba), n], bb} |> IO.inspect(label: "exploded b")

          _ ->
            IO.puts("k")
            false
        end
    end
  end

  def explode(_n, _level) do
    false
  end

  def again?({:none, l}), do: l
  def again?({_, l}), do: reduce(l)

  def magnitude(n) when is_integer(n), do: n
  def magnitude([a, b]), do: 3 * magnitude(a) + 2 * magnitude(b)

  def do_pt_1(input) do
    input
    |> parse()
    |> IO.inspect(label: "parsed")
    |> Enum.reduce(&add_lines(&2, &1))
    |> IO.inspect(label: "added")
    |> magnitude()
    |> IO.inspect(label: "PART 1")
  end
end

# "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
# [[[5,[2,8]],4],[5,[[9,9],0]]]
# [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
# [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
# [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
# [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
# [[[[5,4],[7,7]],8],[[8,3],8]]
# [[9,3],[[9,9],[6,[4,9]]]]
# [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
# [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"
"[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]"
|> Day18.do_pt_1()
