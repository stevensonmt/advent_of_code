defmodule Day16 do
  @moduledoc """
  My solution for `Day16`.
  """
  @type type :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
  @type version :: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
  @type literal() :: integer()
  @type op :: %{
          version: version(),
          type: type(),
          length_type: integer(),
          sub_packets: [packet()]
        }
  @type payload :: literal() | op()
  @type packet :: %{version: version(), type: type(), value: [payload()]}

  @spec parse(binary()) :: {packet(), binary()}
  def parse(input) do
    input
    |> Base.decode16!()
    |> decode_packet()
  end

  @spec decode_packet(binary()) :: {packet(), binary()}
  defp decode_packet(<<version::3, 4::3, rest::bits>>) do
    {val, rem} = decode_literal(rest, <<>>)
    value = calculate_value(val)

    {%{
       type: 4,
       version: version,
       value: value
     }, rem}
  end

  defp decode_packet(<<version::3, type::3, 0::1, len::15, rest::bits>>) do
    <<subs::bitstring-size(len), rem::bits>> = rest
    {%{type: type, version: version, value: decode_packets(subs)}, rem}
  end

  defp decode_packet(<<version::3, type::3, 1::1, packets::11, rest::bits>>) do
    {val, rem} =
      1..packets
      |> Enum.map_reduce(rest, fn _i, acc ->
        decode_packet(acc)
      end)

    {%{type: type, version: version, value: val}, rem}
  end

  @spec decode_packets(binary()) :: [packet()]
  defp decode_packets(bin) do
    case decode_packet(bin) do
      {packet, <<>>} -> [packet]
      {packet, rem} -> [packet | decode_packets(rem)]
    end
  end

  @spec decode_literal(binary(), binary()) :: {binary(), binary()}
  defp decode_literal(<<1::1, val::4, rest::bits>>, acc) do
    decode_literal(rest, acc <> <<val>>)
  end

  defp decode_literal(<<0::1, val::4, rest::bits>>, acc) do
    {acc <> <<val>>, rest}
  end

  @spec calculate_value(binary()) :: integer()
  defp calculate_value(bin) do
    bin
    |> :binary.bin_to_list()
    |> Enum.map(&Integer.digits(&1, 2))
    |> Enum.map(fn ds ->
      l = length(ds)

      if l == 4 do
        ds
      else
        l..3 |> Enum.reduce(ds, fn _, acc -> [0 | acc] end)
      end
    end)
    |> List.flatten()
    |> Integer.undigits(2)
  end

  @spec do_pt_1(String.t()) :: integer()
  def do_pt_1(input) do
    input
    |> parse()
    |> elem(0)
    |> sum_versions()
  end

  @spec sum_versions(packet()) :: integer()
  defp sum_versions(%{version: v, value: value}), do: sum_versions(value, v)
  @spec sum_versions(integer(), integer()) :: integer()
  defp sum_versions(n, acc) when is_integer(n), do: acc
  @spec sum_versions(packet, integer()) :: integer()
  defp sum_versions(%{version: v, value: val}, acc), do: acc + v + sum_versions(val)

  @spec sum_versions([packet], integer()) :: integer()
  defp sum_versions(packets, acc) do
    packets
    |> Enum.reduce(acc, fn p, sum -> sum_versions(p) + sum end)
  end

  @spec do_pt_2(String.t()) :: integer()
  def do_pt_2(input) do
    input
    |> parse()
    |> elem(0)
    |> sum_values()
  end

  @spec sum_values(packet) :: integer()
  defp sum_values(%{type: _, value: v}) when is_integer(v), do: v

  defp sum_values(%{type: 0, value: v}) when is_list(v),
    do: Enum.reduce(v, 0, fn sub, acc -> acc + sum_values(sub) end)

  defp sum_values(%{type: 1, value: v}) when is_list(v),
    do: Enum.reduce(v, 1, fn sub, acc -> acc * sum_values(sub) end)

  defp sum_values(%{type: 2, value: v}) when is_list(v) do
    v
    |> Enum.map(&sum_values(&1))
    |> Enum.min()
  end

  defp sum_values(%{type: 3, value: v}) when is_list(v) do
    v
    |> Enum.map(&sum_values(&1))
    |> Enum.max()
  end

  defp sum_values(%{type: 5, value: [a, b]}) do
    if(sum_values(a) > sum_values(b)) do
      1
    else
      0
    end
  end

  defp sum_values(%{type: 6, value: [a, b]}) do
    if(sum_values(a) < sum_values(b)) do
      1
    else
      0
    end
  end

  defp sum_values(%{type: 7, value: [a, b]}) do
    if(sum_values(a) == sum_values(b)) do
      1
    else
      0
    end
  end
end

input =
  "input.txt"
  |> File.read!()
  |> String.trim()

pt_1_samples = [
  "8A004A801A8002F478",
  "620080001611562C8802118E34",
  "C0015000016115A2E0802F182340",
  "A0016C880162017C3686B18A3D4780"
]

pt_1_samples
|> Enum.map(&Day16.do_pt_1(&1))
|> IO.inspect()

input
|> Day16.do_pt_1()
|> IO.inspect()

pt_2_samples = [
  "C200B40A82",
  "04005AC33890",
  "880086C3E88112",
  "CE00C43D881120",
  "D8005AC2A8F0",
  "F600BC2D8F",
  "9C005AC2F8F0",
  "9C0141080250320F1802104A08"
]

pt_2_samples
|> Enum.map(&Day16.do_pt_2(&1))
|> IO.inspect()

input
|> Day16.do_pt_2()
|> IO.inspect()
