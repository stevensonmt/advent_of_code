defmodule Day18 do
  @moduledoc """
  Solution for AoC `Day18`.
  """

  defmodule Tree do
    defstruct [:left, :right]

    @type t :: %__MODULE__{
            left: nil | integer() | t(),
            right: nil | integer() | t()
          }
  end

  defmodule ForestRanger do
    defstruct [:previous, :steps, :current]

    @type step :: :left | :right

    @type t :: %__MODULE__{
            previous: [Tree.t()],
            steps: [step],
            current: Tree.t()
          }

    def up(%__MODULE__{} = ranger) do
      [last | prev] = ranger.previous
      [s | steps] = ranger.steps
      curr = Map.update!(last.current, s, ranger.current)
      %ForestRanger{previous: prev, steps: steps, current: curr}
    end

    def down(%__MODULE__{} = ranger, step) do
      prev = [ranger | ranger.previous]
      steps = [step | ranger.steps]
      curr = Map.get(ranger.current, step)
    end
  end

  @type tree :: Tree.t()

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(Code.eval_string(&1) |> elem(0) |> new()))
  end

  def add_lines(forest) do
    forest
    |> Enum.reduce(new(), fn tree, acc -> add(acc, tree) |> reduce() end)
  end

  def do_pt_1(input) do
    input
    |> parse()
    |> add_lines()
    |> magnitude()
  end

  def new() do
    %Tree{}
  end

  def new(n, tree \\ %Tree{})

  def new([a, b], tree) do
    case {is_integer(a), is_integer(b)} do
      {true, true} ->
        %Tree{tree | left: a, right: b}

      {true, false} ->
        %Tree{tree | left: a, right: new(b)}

      {false, true} ->
        %Tree{tree | left: new(a), right: b}

      {false, false} ->
        %Tree{tree | left: new(a), right: new(b)}
    end
  end

  def new(a, _tree) when is_integer(a), do: a

  def add(root, tree) do
    %Tree{left: root, right: tree}
  end

  def split(n) when is_integer(n), do: [div(n, 2), ceil(n / 2)] |> new()

  def split(tree = %Tree{left: left}) when is_integer(left) and left > 9,
    do: Map.update!(tree, :left, fn _ -> split(left) end)

  def split(tree = %Tree{right: right}) when is_integer(right) and right > 9,
    do: Map.update!(tree, :right, fn _ -> split(right) end)

  def split(tree = %Tree{}), do: tree

  def explode(tree = %Tree{left: left, right: right}) do
    IO.inspect(binding(), label: "explode")

    tree
    |> Map.update!(:left, fn
      p_l when is_integer(p_l) -> [left + p_l, 0] |> new()
      nil -> 0
      p_l -> update_first_val(:right, p_l, left)
    end)
    |> Map.update!(:right, fn
      p_r when is_integer(p_r) ->
        right + p_r

      nil ->
        0

      p_r ->
        update_first_val(:left, p_r, right)
    end)
  end

  def update_first_val(_, n, val) when is_integer(n), do: n + val

  def update_first_val(_, nil, _), do: nil

  def update_first_val(side, tree, val) do
    Map.update!(tree, side, update_first_val(side, Map.get(tree, side), val))
  end

  def reduce(tree) do
    IO.inspect(binding())

    tree
    |> explosions()
    |> moar?(tree)
    |> splits()
    |> moar?(tree)
  end

  def explosions(tree) do
    case dfs(tree, 4) do
      {:explode, t} -> explode(t)
      _ -> tree
    end
  end

  def splits(tree) do
    case dfs(tree, :split) do
      {:split, t} -> split(t)
      t -> t
    end
  end

  def dfs(nil, n) when is_integer(n), do: :no_uhsploade
  def dfs(tree = %Tree{}, 0), do: {:explode, tree}
  def dfs(_, 0), do: :no_uhsploade
  def dfs(n, _) when is_integer(n), do: :no_uhsploade

  def dfs(tree = %Tree{}, n) when is_integer(n) do
    case dfs(tree.left, n - 1) do
      {:explode, t} ->
        {:explode, t}

      :no_uhsploade ->
        case dfs(tree.right, n - 1) do
          {:explode, t} -> {:explode, t}
          _ -> :no_uhsploade
        end
    end
  end

  def dfs(x, :split) when is_integer(x) or x == nil, do: :no_split

  def dfs(tree = %Tree{left: left}, :split) when is_integer(left) and left > 9,
    do: {:split, split(tree)}

  def dfs(tree = %Tree{right: right}, :split) when is_integer(right) and right > 9,
    do: {:split, split(tree)}

  def dfs(tree = %Tree{}, :split) do
    case dfs(tree.left, :split) do
      {:split, t} ->
        t

      :no_split ->
        case dfs(tree.right, :split) do
          {:split, t} -> t
          :no_split -> :no_split
        end
    end
  end

  def moar?(new, old) do
    if new == old do
      new
    else
      reduce(new)
    end
  end

  def magnitude(nil), do: 0
  def magnitude(n) when is_integer(n), do: n
  def magnitude(%Tree{left: left, right: right}), do: 3 * magnitude(left) + 2 * magnitude(right)
end

sample = "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"

Day18.do_pt_1(sample) |> IO.inspect(label: "part 1")
