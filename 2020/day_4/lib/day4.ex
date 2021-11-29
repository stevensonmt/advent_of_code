defmodule Day4 do
  import NimbleParsec

  @input File.read!("lib/input.txt") |> String.split("\n\n")

  defmodule ParsingHelper do
    byr =
      string("byr")
      |> ignore(string(":"))
      |> choice([
        string("1") |> string("9") |> ascii_char([?2..?9]) |> integer(1),
        string("2") |> string("0") |> string("0") |> ascii_char([?0..?2])
      ])

    # matches 5 entries

    iyr =
      string("iyr")
      |> ignore(string(":"))
      |> string("20")
      |> choice([
        string("1") |> ascii_char([?0..?9]),
        string("2") |> string("0")
      ])

    # matches 4 entries

    eyr =
      string("eyr")
      |> ignore(string(":"))
      |> string("20")
      |> choice([
        string("2") |> ascii_char([?0..?9]),
        string("3") |> string("0")
      ])

    # matches 4 entries

    hgt =
      string("hgt")
      |> ignore(string(":"))
      |> choice([integer(3) |> string("cm"), integer(2) |> string("in")])

    # matches 3 entries

    hcl =
      string("hcl")
      |> ignore(string(":"))
      |> string("#")
      |> ascii_string([?0..?9, ?a..?f], 6)

    # matches 3 entries

    ecl =
      string("ecl")
      |> ignore(string(":"))
      |> choice([
        string("amb"),
        string("blu"),
        string("brn"),
        string("gry"),
        string("grn"),
        string("hzl"),
        string("oth")
      ])

    # matches 2 entries

    pid = string("pid") |> ignore(string(":")) |> integer(9)
    # matches 2 entries

    cid = string("cid") |> ignore(string(":")) |> choice([integer(3), integer(2)])
    # matches 2 entries

    fields =
      repeat(
        choice([
          byr,
          iyr,
          eyr,
          hgt,
          hcl,
          ecl,
          pid,
          cid
        ])
        |> ignore(choice([string(" "), ascii_char([10..10]), empty()]))
      )

    defparsec(:fields, fields)
  end

  defp valid_fields?(fields, regex_match) do
    case length(fields) do
      8 -> true
      7 -> not Enum.member?(fields, regex_match)
      _ -> false
    end
  end

  def valid_number_of_fields() do
    @input
    |> Stream.map(&Regex.scan(~r/[a-z]{3}:/, &1))
    |> Stream.filter(&valid_fields?(&1, ["cid:"]))
    |> Enum.count()
  end

  def valid_number_of_fields_and_expected_names() do
    @input
    |> Stream.map(&Regex.scan(~r/(byr|iyr|eyr|hgt|hcl|ecl|pid|cid)(?=:)/, &1))
    |> Stream.filter(&valid_fields?(&1, ["cid", "cid"]))
    |> Enum.count()
  end

  def valid_fields_and_values() do
    @input
    |> Stream.map(&Day4.ParsingHelper.fields(&1))
    |> Stream.filter(fn {a, _, _, _, _, _} -> a == :ok end)
    |> Stream.filter(fn {_, b, _, _, _, _} ->
      length(b) == 25 or (length(b) == 23 and not Enum.member?(b, "cid"))
    end)
    |> Enum.count()
  end
end

IO.inspect(Day4.valid_number_of_fields())
IO.inspect(Day4.valid_number_of_fields_and_expected_names())
IO.inspect(Day4.valid_fields_and_values())
