defmodule Day4 do
  @input "input.txt" |> File.read!() |> String.split()

  @drawpool hd(@input) |> String.split(",")

  @boards tl(@input)
          |> Enum.chunk_every(5)
          |> Enum.chunk_every(5)

  def do_pt_1() do
    bingo(@drawpool, @boards, 1)
  end

  def bingo([n | rest], boards, pt) do
    new_boards =
      boards
      |> Enum.map(&mark_cells(n, &1))

    winner = check_boards(new_boards)

    cond do
      winner == nil ->
        bingo(rest, new_boards, pt)

      pt == 2 and [winner] == new_boards ->
        sum_board(winner) * String.to_integer(n)

      pt == 2 ->
        newer_boards = new_boards |> Enum.reject(&Kernel.==(&1, winner))

        try do
          bingo(rest, newer_boards, pt)
        rescue
          _ ->
            IO.inspect({winner, n})
            sum_board(winner) * String.to_integer(n)
        end

      true ->
        sum_board(winner) * String.to_integer(n)
    end
  end

  def loser_bingo([n | rest], boards) do 

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
        |> Enum.map(&Enum.zip(&1))
        |> Enum.map(&Enum.map(&1, fn r -> Tuple.to_list(r) end))
        |> empty_rows()

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

  defp sum_board(board) do
    board
    |> List.flatten()
    |> Enum.reject(fn i -> i == nil end)
    |> Enum.map(&String.to_integer(&1))
    |> Enum.sum()
  end

  def do_pt_2() do
    bingo(@drawpool, @boards, 2)
  end
end

Day4.do_pt_1() |> IO.inspect()
Day4.do_pt_2() |> IO.inspect()
