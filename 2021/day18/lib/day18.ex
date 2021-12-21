defmodule Day18 do
  @moduledoc """
  Solution for AoC `Day18`.
  """

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(Code.eval_string(&1) |> elem(0) |> new()))
  end

  def add_lines([a | rest]) do
    rest
    |> Enum.reduce(a, fn t, acc -> (acc ++ t) |> reduce() end)
  end

  def reduce(num) do
    num
    |> try_explode?()
    |> again?()
    |> try_split?()
    |> again?()
  end

  def try_explode(n, path \\ []) do
    cond do
      is_integer(n) ->
        {:none, n}

      Enum.all?(n, &is_integer(&1)) and length(path) >= 4 ->
        {:exploded, 0, hd(n), hd(tl(n)), path}

      try_explode(n, [:left | path]) = {:exploded, nn, left, right, path} ->
        update_list(n, nn, left, right, path)

      try_explode(n, [:right | path]) = {:exploded, nn, left, right, path} ->
        update_list(n, nn, left, right, path)

      true ->
        {:none, n}
    end
  end

  def update_list([a, b], val, left, right, [step | path] = full_path) do
    case step do
      :left ->
        [update_list(a, val, path) | b]
        |> update_left(left, full_path)
        |> update_right(right, full_path)

      :right ->
        [a | update_list(b, val, path)]
        |> update_left(left, full_path)
        |> update_right(right, full_path)
    end
  end

  def update_list(_, val, []), do: val

  def update_list([a, b], val, [step | path]) do
    case step do
      :left -> [update_list(a, val, path) | b]
      :right -> [a | update_list(b, val, path)]
    end
  end

  def update_left([a, b], val, [p])

  def update_left([a, b], val, [step | path]) do
    case step do
      :left -> [update_left(a, val, path) | b]
      :right -> [a | update_left(b, val, path)]
    end
  end

  def do_pt_1(input) do
    input
    |> parse()
    |> add_lines()
    |> magnitude()
  end
end
