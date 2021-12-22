defmodule Day18 do
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(&1 |> Code.eval_string() |> elem(0)))
  end

  def add_lines(lines) do
    tl(lines)
    |> Enum.reduce(hd(lines), fn l, acc -> add(acc, l) end)
  end

  def add(a, b) do
    reduce([a, b])
  end

  def reduce(l) do
    l
    |> try_explode()
    |> continue?()
    |> try_split()
    |> continue?()
  end

  def continue?({:none, l}), do: l
  def continue?({_, l}), do: reduce(l)

  def merge([a, b], n) do
    [a, merge(b, n)]
  end

  def merge(n, [a, b]) do
    [merge(n, a), b]
  end

  def merge(a, b) do
    a + b
  end

  def try_explode(l) do
    case explode(l, 1) do
      {_, n, _} -> {:exploded, n}
      _ -> {:none, l}
    end
  end

  def explode([a, b], 5) do
    {a, 0, b}
  end

  def explode([a, b], level) do
    case explode(a, level + 1) do
      {aa, n, ab} ->
        {aa, [n, merge(ab, b)], 0}

      _ ->
        case explode(b, level + 1) do
          {ba, n, bb} ->
            {0, [merge(a, ba), n], bb}

          _ ->
            false
        end
    end
  end

  def explode(_n, _level) do
    false
  end

  def try_split(l) do
    case split(l) do
      false -> {:none, l}
      n -> {:split, n}
    end
  end

  def split([a, b]) do
    case split(a) do
      false ->
        case split(b) do
          false -> false
          bb -> [a, bb]
        end

      aa ->
        [aa, b]
    end
  end

  def split(n) when n >= 10, do: [div(n, 2), ceil(n / 2)]

  def split(n) do
    false
  end

  def magnitude(n) when is_integer(n), do: n
  def magnitude([a, b]), do: 3 * magnitude(a) + 2 * magnitude(b)

  def do_pt_1(input) do
    input
    |> parse()
    |> add_lines()
    |> magnitude()
  end

  def do_pt_2(input) do
    for n <- parse(input),
        m <- parse(input),
        n != m do
      add_lines([n, m]) |> magnitude()
    end
    |> Enum.max()
  end
end

data =
  "input.txt"
  |> File.read!()

data
|> Day18.do_pt_1()
|> IO.inspect(label: "part 1")

data
|> Day18.do_pt_2()
|> IO.inspect(label: "part 2")
