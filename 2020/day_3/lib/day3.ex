defmodule Day3 do
  @input File.stream!("lib/input") |> Enum.into([])
  @finish Kernel.length(@input)

  def progress(_, y, _, _, trees) when y >= @finish do
    trees
  end

  def progress(x, y, run, rise, trees) do
    case @input
         |> Enum.at(y)
         |> String.at(rem(x, 31)) do
      "#" -> progress(x + run, y + rise, run, rise, trees + 1)
      _ -> progress(x + run, y + rise, run, rise, trees)
    end
  end
end

(Day3.progress(0, 0, 1, 1, 0) * Day3.progress(0, 0, 3, 1, 0) * Day3.progress(0, 0, 5, 1, 0) *
   Day3.progress(0, 0, 7, 1, 0) * Day3.progress(0, 0, 1, 2, 0))
|> IO.inspect()
