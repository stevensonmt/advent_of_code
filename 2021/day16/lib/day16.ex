defmodule Day16 do
  @moduledoc """
  My solution for `Day16`.
  """

  @type literal :: integer
  @type op :: %{version: integer, type: integer, length_type: integer, sub_packets: [packet]}
  @type payload :: literal | op
  @type packet :: %{version: integer, type: integer, payload: [payload]}

  def parse(input) do
    input
    |> Base.decode16!()
    |> decode()
  end

  @spec decode_packet(binary) :: packet
  defp decode_packet(<<version::3, type::3, rest::bits>>) do
    IO.inspect(binding(), label: "decode packet")
    %{version: version, type: type, payload: unpack(type, rest, [])}
  end

  defp decode_packet(_n), do: <<>>

  @spec decode_packets(integer, binary, [packet]) :: [packet]
  defp decode_packets(0, rest, packets), do: {packets, rest}

  defp decode_packets(n, bin, packets) do
    {packet, rest} = decode_packet(bin)
    decode_packets(n - 1, rest, [packet | packets])
  end

  @spec decode_op(binary, [packet]) :: [packet]
  defp decode_op(<<i::1, rest::bits>>, acc) do
    case i do
      0 ->
        IO.inspect(rest)
        <<len::15, bs::bits>> = rest
        <<subs::bitstring-size(len), other::bits>> = bs
        [decode_packets(subs) | acc]

      # <<sub::len, other::bits>> = bs
      # decode_packet(<<sub::len>>)

      1 ->
        <<total_packets::11, other::bits>> = rest
        decode_packets(total_packets, other, []) ++ acc
    end
  end

  defp unpack(4, bin, acc) do
    {literal, rest} = decode_literal(bin, <<>>)
    [decode_packet(rest) | [literal | acc]]
  end

  defp decode_literal(<<a::1, b::4, rest::bits>>, acc) do
    case a do
      0 -> {acc <> <<b>>, rest}
      1 -> decode_literal(rest, acc <> <<b>>)
    end
  end

  defp unpack(_, <<v::3, t::3, rest::bits>>, acc) do
    IO.inspect(binding(), label: "unpack")
    {payload, rem} = decode_op(rest, [])
    [decode_packet(rem) | [%{version: v, type: t, payload: payload} | acc]]
  end
end

# "input.txt"
# |> File.read!()
# |> String.trim()
# "D2FE28"
"38006F45291200"
|> Day16.parse()
|> IO.inspect()
