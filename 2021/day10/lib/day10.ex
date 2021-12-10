defmodule Day10 do
  @moduledoc false

  def prep_input(input) do
    input
    |> File.stream!()
    |> Stream.map(&String.trim(&1))
    |> Stream.map(&String.graphemes(&1))
  end

  def do_pt_1(input) do
    input
    |> prep_input()
    |> Stream.map(fn line -> check_line(line, []) end)
    |> Stream.filter(&corrupt?(&1))
    |> Stream.map(fn {:corrupt, b} -> syntax_score(b) end)
    |> Enum.sum()
    |> IO.inspect()
  end

  def do_pt_2(input) do
    input
    |> prep_input()
    |> Stream.map(&check_line(&1, []))
    |> Stream.reject(&corrupt?(&1))
    |> Stream.map(fn {_, bs} ->
      Stream.map(bs, &syntax_score(&1))
      |> Enum.reduce(0, fn i, acc -> acc * 5 + i end)
    end)
    |> Enum.sort()
    |> get_mid()
    |> IO.inspect()
  end

  defp get_mid(scores) do
    # floor b/c zero index derpp
    mid = floor(length(scores) / 2)
    Enum.at(scores, mid)
  end

  defp corrupt?({:corrupt, b}), do: true
  defp corrupt?(_), do: false

  defp check_line([], []), do: :ok
  defp check_line([], stack), do: {:incomplete, stack}

  defp check_line([hd | rest], []), do: check_line(rest, [hd])

  defp check_line([hd | rest], [recent | old] = stack) do
    cond do
      close_it?(hd, recent) ->
        check_line(rest, old)

      closer?(hd) ->
        {:corrupt, hd}

      true ->
        check_line(rest, [hd | stack])
    end
  end

  defp close_it?(")", "("), do: true
  defp close_it?("]", "["), do: true
  defp close_it?("}", "{"), do: true
  defp close_it?(">", "<"), do: true
  defp close_it?(_, _), do: false

  defp closer?(a), do: a in [")", "]", "}", ">"]

  defp syntax_score(")"), do: 3
  defp syntax_score("]"), do: 57
  defp syntax_score("}"), do: 1197
  defp syntax_score(">"), do: 25137

  defp syntax_score("("), do: 1
  defp syntax_score("["), do: 2
  defp syntax_score("{"), do: 3
  defp syntax_score("<"), do: 4
end

Day10.do_pt_1("input.txt")
Day10.do_pt_2("input.txt")
