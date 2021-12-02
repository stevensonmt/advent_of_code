defmodule Day2 do
  @moduledoc false

  @input "../input.txt"
  @init_sub %{x: 0, d: 0, aim: 0}

  defp parse(input) do
    input
    |> File.stream!()
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&String.split(&1))
    |> Enum.map(fn [a, b] -> {a, String.to_integer(b)} end)
  end

  defp travel([], sub, _) do
    sub
  end

  defp travel([command | rest], sub = %{x: lat, d: depth, aim: _aim}, true) do
    case command do
      {"forward", x} -> travel(rest, %{sub | x: lat + x}, true)
      {"down", d} -> travel(rest, %{sub | d: depth + d}, true)
      {"up", d} -> travel(rest, %{sub | d: depth - d}, true)
    end
  end

  defp travel([command | rest], sub = %{x: lat, d: depth, aim: aim}, false) do
    case command do
      {"forward", x} -> travel(rest, %{sub | x: lat + x, d: depth + aim * x}, false)
      {"down", d} -> travel(rest, %{sub | aim: aim + d}, false)
      {"up", d} -> travel(rest, %{sub | aim: aim - d}, false)
    end
  end

  defp solve(%{x: lat, d: depth}) do
    lat * depth
  end

  def do_pt_1() do
    do_day2(true)
  end

  def do_pt_2() do
    do_day2(false)
  end

  defp do_day2(first_part?) do
    @input
    |> parse()
    |> travel(@init_sub, first_part?)
    |> solve()
    |> IO.puts()
  end
end

IO.puts("do_pt_1")
Day2.do_pt_1()

IO.puts("do_pt_2")
Day2.do_pt_2()
