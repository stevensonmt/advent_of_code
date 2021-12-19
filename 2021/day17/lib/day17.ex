defmodule Day17 do
  @moduledoc """
  Solution for AoC `Day17`.
  """

  def apogee(y_vel) do
    div(y_vel * y_vel + y_vel, 2)
  end

  def step({x, y}, {dx, dy}, apogee, target_x, target_y) do
    case in_target({x, y}, target_x, target_y) do
      :nailedit ->
        {:ok, apogee}

      :undershot ->
        new_dx =
          if dx == 0 do
            0
          else
            dx - 1
          end

        step({x + dx, y + dy}, {new_dx, dy - 1}, apogee, target_x, target_y)

      :overshot ->
        :fail
    end
  end

  def in_target({x, y}, target_x, target_y) do
    cond do
      x in target_x && y in target_y ->
        :nailedit

      x > Enum.max(target_x) ->
        :overshot

      y < Enum.min(target_y) ->
        :overshot

      true ->
        :undershot
    end
  end

  def valid_firing_params(target_x, target_y) do
    for v_x <- 0..Enum.max(target_x),
        v_y <- Enum.min(target_y)..abs(Enum.min(target_y)) do
      {v_x, v_y}
    end
    |> Enum.map(fn {dx, dy} -> {{dx, dy}, apogee(dy)} end)
    |> Enum.filter(fn {{dx, dy}, apogee} ->
      step({0, 0}, {dx, dy}, apogee, target_x, target_y) == {:ok, apogee}
    end)
  end

  def max_ht(target_x, target_y) do
    valid_firing_params(target_x, target_y)
    |> Enum.max_by(&elem(&1, 1))
  end

  def total_valid_firing_params(target_x, target_y) do
    valid_firing_params(target_x, target_y)
    |> Enum.uniq()
    |> Enum.count()
  end
end

Day17.max_ht(20..30, -10..-5)
|> IO.inspect()

Day17.max_ht(124..174, -123..-86)
|> IO.inspect()

Day17.total_valid_firing_params(20..30, -10..-5)
|> IO.inspect()

Day17.total_valid_firing_params(124..174, -123..-86)
|> IO.inspect()
