defmodule Day17 do
  @moduledoc false

  @input ".###.#.#\n####.#.#\n#.....#.\n####....\n#...##.#\n########\n..#####.\n######.#"

  def process_input() do
    @input
    |> String.split()
    |> Enum.with_index()
    |> Enum.map(fn {line, ndx} ->
      {ndx,
       line
       |> String.codepoints()
       |> Enum.with_index()
       |> Enum.filter(fn {char, _x} -> char == "#" end)
       |> Enum.map(&elem(&1, 1))}
    end)
    |> Enum.flat_map(fn {y, xs} -> xs |> Enum.map(fn x -> {x, y, 0} end) end)

    # |> IO.inspect()
  end

  # use an agent to hold the cube
  # each iteration 
  defmodule ConwayCube do
    @moduledoc false

    defstruct active_cubes: []

    use Agent

    def start_link do
      Agent.start_link(fn -> %ConwayCube{} end, name: __MODULE__)
    end

    def start_link(active_cubes) do
      Agent.start_link(fn -> %ConwayCube{active_cubes: active_cubes} end, name: __MODULE__)
    end

    def next_round do
      Agent.update(__MODULE__, fn cube ->
        %{
          cube
          | active_cubes:
              cube.active_cubes
              |> Enum.filter(fn {curr_x, curr_y, curr_z} ->
                cube.active_cubes
                |> Enum.filter(fn {x, y, z} ->
                  {x, y, z} != {curr_x, curr_y, curr_z} &&
                    (abs(curr_x - x) <= 1 && abs(curr_y - y) <= 1 && abs(curr_z - z) <= 1)
                end)
                |> Enum.count()
                |> (fn count -> count < 4 && count > 1 end).()
                |> IO.inspect()

                # |> (fn count -> count > 1 && count < 4 end).()
              end)
              |> IO.inspect()
        }
      end)
    end

    def active_cubes do
      Agent.get(__MODULE__, fn cube -> cube.active_cubes end)
    end
  end

  def part_1 do
    ConwayCube.start_link(Day17.process_input())
    ConwayCube.next_round()
    ConwayCube.active_cubes()
  end
end

Day17.part_1()
# |> IO.inspect()
