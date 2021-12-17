defmodule Day16 do
  @moduledoc """
  My solution for `Day16`.
  """

  def parse(input) do
    input
    |> Integer.parse(16)
    |> elem(0)
    |> Integer.digits(2)
    |> unpack()
  end

  def unpack(bits) do
    bits
    |> Enum.split(3)
    |> packet_type()
  end

  def packet_type([version | bits]) do
    bits
    |> Enum.split(3)
    |> literal_or_operator(version)
  end

  def literal_or_operator([type | bits], version) do
    case Integer.undigits(type, 2) do
      4 -> process_literals(version, type, bits)
      _ -> process_operators(version, type, bits)
    end
  end

  def process_literals(version, type, bits) do
    {version, type,
     bits
     |> Enum.chunk_every(5, :discard)
     |> Enum.split_with(fn chnk -> hd(chnk) == 0 end)
     |> realign()
     |> decode_literals()}
  end

  def realign({literals, [last_lit | rest]}), do: {literals ++ [last_lit], List.flatten(rest)}

  def decode_literals({literals, bits}) do
    {literals
     |> Enum.map(&tl(&1))
     |> List.flatten()
     |> Integer.undigits(2), bits}
  end

  def process_operators(version, type, [length_type | bits]) do
    case length_type do 
      0 -> bits |> Enum.split(15) |> decode_length_and_sub_packets() 
      1 -> bits |> Enum.split(11) |> decode_num_sub_packets()
    end
  end
end

"input.txt"
|> File.read!()
|> Day16.parse()
|> IO.inspect()
