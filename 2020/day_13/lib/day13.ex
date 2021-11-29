defmodule Day13 do
  @moduledoc false

  @input "1001287
  13,x,x,x,x,x,x,37,x,x,x,x,x,461,x,x,x,x,x,x,x,x,x,x,x,x,x,17,x,x,x,x,19,x,x,x,x,x,x,x,x,x,29,x,739,x,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,x,x,x,23"

  def process() do
    @input
    |> String.split("\n", parts: 2, trim: true)
    |> Enum.with_index()
    |> Enum.reduce({}, fn {sub, ndx}, acc ->
      case ndx do
        0 ->
          Tuple.append(acc, String.to_integer(sub))

        _ ->
          Tuple.append(
            acc,
            sub
            |> String.trim_leading()
            |> String.split(",")
            |> Enum.filter(&Kernel.!=("x", &1))
            |> Enum.map(&String.to_integer(&1))
          )
      end
    end)
  end

  def shortest_wait(timestamp, bus_list) do
    {bus, wait} =
      bus_list
      |> Enum.map(fn x -> {x, x - rem(timestamp, x)} end)
      |> Enum.min_by(fn {_x, wait} -> wait end)

    bus * wait
  end

  def part_1 do
    {timestamp, bus_list} = process()
    shortest_wait(timestamp, bus_list)
  end

  def process_2 do
    @input
    |> String.split("\n", parts: 2, trim: true)
    |> List.last()
    |> String.trim_leading()
    |> String.split(",")
    |> Enum.with_index()
    |> Enum.reject(fn {c, _ndx} -> c == "x" end)
    |> Enum.map(fn {c, ndx} -> {ndx, String.to_integer(c)} end)
  end

  def timestamp_search([{_ndx, first_bus} | _rest] = buses) do
    min_time = 100_000_000_000_000 + rem(100_000_000_000, first_bus)
    timestamp_search(buses, {min_time, 1})
  end

  def timestamp_search([], {timestamp, _}) do
    timestamp
  end

  def timestamp_search([{ndx, bus} | rest] = buses, {timestamp, step}) do
    if valid_timestamp?(timestamp, bus, ndx) do
      timestamp_search(rest, {timestamp, Day13.MathHelpers.lcm(step, bus)})
    else
      timestamp_search(buses, {timestamp + step, step})
    end
  end

  def valid_timestamp?(timestamp, bus, ndx) do
    rem(timestamp + ndx, bus) == 0
  end

  def part_2 do
    process_2()
    |> timestamp_search()
  end

  defmodule MathHelpers do
    @moduledoc false
    def gcd(a, 0), do: a
    def gcd(0, b), do: b
    def gcd(a, b), do: gcd(b, rem(a, b))

    def lcm(0, 0), do: 0
    def lcm(a, b), do: div(a * b, gcd(a, b))
  end
end

IO.puts(Day13.part_1())
IO.puts(Day13.part_2())
