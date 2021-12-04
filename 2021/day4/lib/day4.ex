defmodule Day4 do
  @moduledoc false

  @input "input.txt" |> File.read!() |> String.split()

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
            sum_board(winner) * String.to_integer(n)
        end

      true ->
        sum_board(winner) * String.to_integer(n)
    end
  end

  def loser_bingo([n | rest], boards) do
    marked_boards = boards |> Enum.map(&mark_cells(n, &1))

    checked = check_boards2(marked_boards)

    case {length(marked_boards), length(checked)} do
      {2, 1} ->
        loser = marked_boards |> Enum.reject(&Enum.any?(checked, fn b -> b == &1 end))
        IO.inspect(loser)
        IO.puts("$$$$")
        IO.inspect(marked_boards)
        IO.puts("%%%%")
        IO.inspect(checked)
        sum_board(loser) |> Kernel.*(String.to_integer(n))

      _ ->
        loser_bingo(rest, checked)
    end
  end

  defp check_boards2(boards) do
    tmp =
      boards
      |> Enum.reject(&empty_rows(&1))

    IO.inspect(length(tmp))

    tmp2 =
      tmp
      |> cols_transform()
      |> Enum.reject(&empty_cols(&1))

    IO.inspect(length(tmp2))

    tmp2
    |> cols_transform()
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
    loser_bingo(@drawpool, @boards)
  end
end

Day4.do_pt_1() |> IO.inspect()
Day4.do_pt_2() |> IO.inspect()
