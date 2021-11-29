defmodule Day15 do
  @moduledoc false

  @input [0, 13, 16, 17, 1, 10, 6]

  def turn(n) when n < 8 do
    Enum.at(@input, n - 1)
  end

  def turn(n) do
    @input
    |> Enum.with_index()
    |> Enum.map(fn {x, ndx} -> {x, [ndx + 1, 0]} end)
    |> Enum.into(%{})
    |> turn(n, length(@input) + 1, List.last(@input))
  end

  def turn(_map, finish, current_round, last_said) when finish == current_round - 1 do
    last_said
  end

  def turn(map, finish, current_round, last_said) do
    previously_said = Map.get(map, last_said)

    say =
      case previously_said do
        [_a, 0] -> 0
        [a, b | _rest] -> a - b
      end

    new_map =
      Map.update(map, say, [current_round, 0], fn prev ->
        [current_round | prev]
      end)

    turn(new_map, finish, current_round + 1, say)
  end
end

IO.inspect(Day15.turn(30_000_000))
