defmodule Day4 do
  @moduledoc false

  @input "input.txt" |> File.read!() |> String.split()

  @type board :: {%{required(integer) => {integer, integer}}, MapSet.t(), MapSet.t()}

  @spec boards() :: [board]
  def boards() do
    @input
    |> tl()
    |> Enum.chunk_every(5)
    |> Enum.chunk_every(5)
    |> Enum.map(&Enum.with_index(&1))
    |> Enum.map(&Enum.map(&1, fn {r, i} -> {Enum.with_index(r), i} end))
    |> Enum.map(
      &Enum.map(&1, fn {cells, row_ndx} ->
        cells
        |> Enum.map(fn {val, col_ndx} -> {String.to_integer(val), {row_ndx, col_ndx}} end)
      end)
    )
    |> Enum.map(&List.flatten(&1))
    |> Enum.map(&Enum.into(&1, %{}))
    |> Enum.map(fn map -> {map, MapSet.new(), MapSet.new()} end)
  end

  @ns hd(@input) |> String.split(",") |> Enum.map(&String.to_integer(&1))

  @spec do_pt_1() :: integer
  def do_pt_1() do
    bingo(boards(), @ns)
    |> score_winner()
    |> IO.inspect(label: "score")
  end

  @spec bingo([board], [integer]) :: board
  def bingo(boards, []), do: boards

  def bingo(boards, [n | ns]) do
    marked =
      boards
      |> Enum.map(&mark(&1, n))

    case bingo?(marked) do
      {%{}, _, _} = board -> {board, n}
      nil -> bingo(marked, ns)
    end
  end

  @spec mark(board, integer) :: board
  defp mark({map, marked_coords, marked_vals} = board, n) do
    case Map.get(map, n) do
      nil -> board
      coords -> {map, MapSet.put(marked_coords, coords), MapSet.put(marked_vals, n)}
    end
  end

  @spec bingo?([board]) :: board | nil
  defp bingo?(boards) do
    boards
    |> Enum.find(fn {_, marked, _} ->
      [Enum.group_by(marked, &elem(&1, 0)), Enum.group_by(marked, &elem(&1, 1))]
      |> Enum.any?(fn map -> Map.values(map) |> Enum.any?(&(length(&1) == 5)) end)
    end)
  end

  @spec score_winner({board, integer}) :: integer
  defp score_winner({{map, _coords, vals}, n}) do
    map
    |> Map.keys()
    |> Kernel.--(Enum.to_list(vals))
    |> Enum.sum()
    |> Kernel.*(n)
  end

  @spec pt_2() :: integer
  def pt_2() do
    do_pt_2(boards(), @ns)
    |> score_winner()
    |> IO.inspect(label: "score 2")
  end

  @spec do_pt_2([board], [integer]) :: {board, integer}
  def do_pt_2(boards, [n | ns]) do
    marked = boards |> Enum.map(&mark(&1, n))

    {winners, n} = bingo2(marked, n)

    if winners == marked do
      {hd(winners), n}
    else
      updated_boards =
        marked
        |> Enum.reject(fn {map, _, _} ->
          Enum.any?(winners, fn {m, _, _} ->
            m == map
          end)
        end)

      do_pt_2(updated_boards, ns)
    end
  end

  def bingo2(boards, n) do
    {bingo2?(boards), n}
  end

  @spec bingo2?([board]) :: board
  defp bingo2?(boards) do
    boards
    |> Enum.filter(fn {_, marked, _} ->
      [Enum.group_by(marked, &elem(&1, 0)), Enum.group_by(marked, &elem(&1, 1))]
      |> Enum.any?(fn map -> Map.values(map) |> Enum.any?(&(length(&1) == 5)) end)
    end)
  end
end

Day4.do_pt_1()
Day4.pt_2()
