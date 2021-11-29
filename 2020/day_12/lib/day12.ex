defmodule Day12 do
  @moduledoc false

  @input File.read!("lib/input")
         |> String.split("\n", trim: true)
         |> Enum.map(fn <<cmd::binary-size(1)>> <> dist -> {cmd, String.to_integer(dist)} end)

  defmodule Ship do
    @moduledoc false

    defstruct heading: {1, 0}, coord: {0, 0}

    use Agent

    def start_link do
      Agent.start_link(fn -> %Ship{} end, name: __MODULE__)
    end

    def start_link({x, y}) do
      Agent.start_link(fn -> %Ship{heading: {x, y}} end, name: __MODULE__)
    end

    def direction do
      Agent.get(__MODULE__, fn ship -> ship.heading end)
    end

    def manhattan_dist do
      Agent.get(__MODULE__, fn ship ->
        {x, y} = ship.coord
        abs(x) + abs(y)
      end)
    end

    def forward(dist) do
      Agent.update(__MODULE__, fn ship ->
        {x, y} = ship.coord
        {a, b} = ship.heading

        %{ship | coord: {x + dist * a, y + dist * b}}
      end)
    end

    def turn do
      Agent.update(__MODULE__, fn ship ->
        {x, y} = ship.heading

        %{ship | heading: {y, -x}}
      end)
    end

    def move(dir, dist) do
      Agent.update(__MODULE__, fn ship ->
        {x, y} = ship.coord

        case dir do
          :east -> %{ship | coord: {x + dist, y}}
          :south -> %{ship | coord: {x, y - dist}}
          :west -> %{ship | coord: {x - dist, y}}
          :north -> %{ship | coord: {x, y + dist}}
        end
      end)
    end

    def to_waypoint(count) do
      Agent.update(__MODULE__, fn ship ->
        {lat, long} = ship.coord
        {x, y} = ship.heading

        %{ship | coord: {lat + x * count, long + y * count}}
      end)
    end

    def move_waypoint(dir, dist) do
      Agent.update(__MODULE__, fn ship ->
        {x, y} = ship.heading

        case dir do
          :east -> %{ship | heading: {x + dist, y}}
          :south -> %{ship | heading: {x, y - dist}}
          :west -> %{ship | heading: {x - dist, y}}
          :north -> %{ship | heading: {x, y + dist}}
        end
      end)
    end

    def status do
      Agent.get(__MODULE__, & &1)
    end

    def stop do
      Agent.stop(__MODULE__)
    end
  end

  def part_1() do
    Ship.start_link()

    @input
    |> Enum.each(fn {cmd, dist} ->
      case cmd do
        "E" -> Ship.move(:east, dist)
        "S" -> Ship.move(:south, dist)
        "W" -> Ship.move(:west, dist)
        "N" -> Ship.move(:north, dist)
        "F" -> Ship.forward(dist)
        "R" -> 1..div(dist, 90) |> Enum.each(fn _ -> Ship.turn() end)
        "L" -> 1..div(360 - dist, 90) |> Enum.each(fn _ -> Ship.turn() end)
      end
    end)

    IO.puts(Ship.manhattan_dist())
    Ship.stop()
  end

  def part_2() do
    Ship.start_link({10, 1})

    @input
    |> Enum.each(fn {cmd, dist} ->
      case cmd do
        "E" -> Ship.move_waypoint(:east, dist)
        "S" -> Ship.move_waypoint(:south, dist)
        "W" -> Ship.move_waypoint(:west, dist)
        "N" -> Ship.move_waypoint(:north, dist)
        "F" -> Ship.to_waypoint(dist)
        "R" -> 1..div(dist, 90) |> Enum.each(fn _ -> Ship.turn() end)
        "L" -> 1..div(360 - dist, 90) |> Enum.each(fn _ -> Ship.turn() end)
      end
    end)

    IO.puts(Ship.manhattan_dist())
    Ship.stop()
  end
end

Day12.part_1()
Day12.part_2()
