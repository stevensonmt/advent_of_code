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

  @ns hd(@input) |> String.split(",") |> Enum.map(&String.to_integer(&1)) |> IO.inspect()

  @drawpool hd(@input) |> String.split(",")

  @boards tl(@input)
          |> Enum.chunk_every(5)
          |> Enum.chunk_every(5)

  @boards2 (for board <- @boards do
              for {row, ri} <- Enum.with_index(board) do
                for {col, ci} <- Enum.with_index(row) do
                  {col, {ri, ci}}
                end
              end
              |> List.flatten()
              |> Map.new()
              |> then(&{&1, MapSet.new(), MapSet.new()})
            end)

  def do_pt_1() do
    bingo(@drawpool, @boards, 1)
  end

  def bingo([n | rest], boards, pt) do
    new_boards =
      boards
      |> Enum.map(&mark_cells(n, &1))

    winner = check_boards(new_boards)

    if winner == nil do
      bingo(rest, new_boards, pt)
    else
      sum_board(winner) * String.to_integer(n)
    end
  end

  defp mark_cells(n, board) do
    board
    |> Enum.map(
      &Enum.map(&1, fn y ->
        if y == n do
          nil
        else
          y
        end
      end)
    )
  end

  defp check_boards(boards) do
    winning_row =
      boards
      |> Enum.find(&empty_rows(&1))

    if winning_row == nil do
      winning_col =
        boards
        |> cols_transform()
        |> Enum.find(&empty_cols(&1))

      if winning_col == nil do
        nil
      else
        winning_col
      end
    else
      winning_row
    end
  end

  defp empty_rows(board) do
    board
    |> Enum.find(&Enum.all?(&1, fn c -> c == nil end))
  end

  defp cols_transform(boards) do
    boards
    |> Enum.map(&Enum.zip(&1))
    |> Enum.map(&Enum.map(&1, fn r -> Tuple.to_list(r) end))
  end

  defp empty_cols(board) do
    board
    |> empty_rows()
  end

  defp sum_board(board) do
    board
    |> List.flatten()
    |> Enum.reject(fn i -> i == nil end)
    |> Enum.map(&String.to_integer(&1))
    |> Enum.sum()
  end

  def do_pt_2() do
    calc(@boards2, @drawpool)
  end

  def calc(boards, [n | numbers]) do
    boards =
      Enum.map(boards, fn {map, coords, ns} = original ->
        if coord = Map.get(map, n) do
          # if n is a key in the board map, mark the cell and its value off
          # by placing them in the "marked" coord and value map sets respectively.
          {map, MapSet.put(coords, coord), MapSet.put(ns, n)}
        else
          original
        end
      end)

    winners =
      Enum.filter(boards, fn {_map, coords, _} ->
        [Enum.group_by(coords, &elem(&1, 0)), Enum.group_by(coords, &elem(&1, 1))]
        |> Enum.any?(fn map ->
          Enum.any?(map, fn {_, v} -> length(v) == 5 end)
        end)
      end)

    if match?(^winners, boards) do
      {map, _, ns} = List.first(boards) |> IO.inspect(label: "list.first")

      map
      |> Map.keys()
      |> Kernel.--(ns |> Enum.to_list() |> IO.inspect(label: "ns"))
      |> Enum.map(&String.to_integer(&1))
      |> Enum.sum()
      |> IO.inspect(label: "sum")
      |> Kernel.*(String.to_integer(n))
    else
      calc(boards -- winners, numbers)
    end
  end
end

Day4.boards()
