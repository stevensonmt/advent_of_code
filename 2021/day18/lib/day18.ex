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
            previous: t(),
            steps: [step],
            current: Tree.t()
          }

    def new(tree = %Tree{}) do
      %ForestRanger{current: tree, steps: [], previous: nil}
    end

    def up(%__MODULE__{previous: nil} = ranger), do: {:top, ranger}

    def up(%__MODULE__{} = ranger) do
      # last = ranger.previous
      # [s | steps] = ranger.steps
      # curr = Map.put(last.current, s, ranger.current)
      # prev = last.previous

      # {:ok, %ForestRanger{previous: prev, steps: steps, current: curr}}
      {:ok,
       ranger.previous
       |> Map.update!(:current, fn new_curr ->
         Map.update!(new_curr, hd(ranger.steps), fn _ -> ranger.current end)
       end)}
    end

    def down(%__MODULE__{current: curr} = ranger, _step) when curr == nil, do: {:bottom, ranger}

    def down(%__MODULE__{} = ranger, step) do
      prev = ranger
      steps = [step | ranger.steps]
      curr = Map.get(ranger.current, step)
      {:ok, %ForestRanger{previous: prev, steps: steps, current: curr}}
    end

    def extract_tree(%__MODULE__{} = ranger) do
      # Map.update!(hd(ranger.previous), hd(ranger.steps), ranger.current)
      case up(ranger) do
        {:top, r} -> r.current
        {:ok, r} -> extract_tree(r)
      end
    end
  end

  @type tree :: Tree.t()

  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(Code.eval_string(&1) |> elem(0) |> new()))
  end

  def add_lines([tree | forest]) do
    forest
    |> Enum.reduce(tree, fn t, acc -> add(acc, t) |> reduce() end)
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

  def explode(ranger = %ForestRanger{current: curr}) do
    meh =
      ranger
      |> set_current_zero()
      |> ForestRanger.up()

    {:ok, meh2} =
      meh
      |> update_first_left(curr.left)

    meh3 =
      meh2
      |> ForestRanger.extract_tree()
      |> ForestRanger.new()

    {:ok,
     ranger.steps
     |> Enum.take(length(ranger.steps) - 1)
     |> Enum.reduce_while(meh3, fn step, r ->
       case ForestRanger.down(r, step) do
         {:ok, rr} -> {:cont, rr}
         {:bottom, rr} -> {:halt, rr}
       end
     end)}
    |> update_first_right(curr.right)
  end

  def set_current_zero(ranger) do
    extracted =
      Map.put(ranger, :current, 0)
      |> ForestRanger.extract_tree()

    ranger.steps
    |> Enum.take(length(ranger.steps) - 1)
    |> Enum.reduce_while(ForestRanger.new(extracted), fn step, r ->
      case ForestRanger.down(r, step) do
        {:ok, rr} -> {:cont, rr}
        {:bottom, rr} -> {:halt, rr}
      end
    end)
  end

  def update_first_right({:top, ranger}, _), do: ranger

  def update_first_right({:ok, ranger = %ForestRanger{current: curr}}, val) do
    cond do
      is_integer(curr.right) ->
        Map.update!(ranger, :current, &Map.put(&1, :right, curr.right + val))

      curr.right == nil ->
        ranger

      true ->
        update_first_right(ForestRanger.up(ranger), val)
    end
  end

  def update_first_left({:top, ranger}, _), do: {:ok, ranger}

  def update_first_left({:ok, ranger = %ForestRanger{current: curr}}, val) do
    cond do
      is_integer(curr.left) ->
        {:ok, Map.update!(ranger, :current, &Map.put(&1, :left, curr.left + val))}

      curr.left == nil ->
        {:ok, ranger}

      true ->
        update_first_left(ForestRanger.up(ranger), val)
    end
  end

  def reduce(tree) do
    tree
    |> explosions()
    |> IO.inspect(label: "THIS")
    |> moar?(tree)
    |> splits()
    |> moar?(tree)
  end

  def explosions(tree) do
    case dfs(ForestRanger.new(tree), :explode) do
      {:exploded, r} ->
        ForestRanger.extract_tree(r)

      _ ->
        tree
    end
  end

  def splits(tree) do
    case dfs(ForestRanger.new(tree), :split) do
      {:split, r} -> ForestRanger.extract_tree(r)
      _ -> tree
    end
  end

  def dfs(tree = %Tree{}, op), do: dfs(ForestRanger.new(tree), op)

  def dfs(ranger = %ForestRanger{current: nil}, :explode), do: :no_uhsploade
  def dfs(ranger = %ForestRanger{current: n}, :explode) when is_integer(n), do: :no_uhsploade
  def dfs(n, :explode) when is_integer(n), do: :no_uhsploade

  def dfs(ranger = %ForestRanger{steps: steps, current: current}, :explode)
      when length(steps) == 4 and is_integer(current.left) and is_integer(current.right) do
    new = explode(ranger)
    {:exploded, new}
  end

  def dfs(ranger = %ForestRanger{}, :explode) do
    case ForestRanger.down(ranger, :left) do
      {:ok, rngr} ->
        case dfs(rngr, :explode) do
          {:exploded, r} ->
            {:exploded, r}

          _ ->
            case ForestRanger.down(ranger, :right) do
              {:ok, rngr} ->
                case dfs(rngr, :explode) do
                  {:exploded, rngr} ->
                    {:exploded, rngr}

                  _ ->
                    ranger
                end

              _ ->
                ranger
            end
        end

      _ ->
        case ForestRanger.down(ranger, :right) do
          {:ok, rngr} ->
            case dfs(rngr, :explode) do
              {:exploded, rngr} ->
                {:exploded, rngr}

              _ ->
                ranger
            end

          _ ->
            ranger
        end
    end
  end

  def dfs(ranger = %ForestRanger{current: n}, :split) when is_integer(n) and n > 10 do
    new = new([div(n, 2), ceil(n / 2)])
    Map.update!(ranger, :current, new)
  end

  def dfs(ranger = %ForestRanger{current: n}, :split) when is_integer(n) or n == nil,
    do: :no_split

  def dfs(ranger = %ForestRanger{}, :split) do
    case ForestRanger.down(ranger, :left) do
      {:ok, rngr} ->
        case dfs(rngr, :split) do
          {:split, r} ->
            r

          _ ->
            case ForestRanger.down(ranger, :right) do
              {:ok, rngr} ->
                case dfs(rngr, :split) do
                  {:split, r} -> r
                  _ -> ranger
                end
            end
        end

      _ ->
        case ForestRanger.down(ranger, :right) do
          {:ok, rngr} ->
            case dfs(rngr, :split) do
              {:split, r} -> r
              _ -> ranger
            end
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

addition_sample = "[[[[4,3],4],4],[7,[[8,4],9]]]\n[1,1]"
smol = "[[1,2],[[3,4],5]]"
med = "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
med2 = "[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
[[[[4,2],2],6],[8,7]]"
explode = "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"

Day18.parse(explode)
|> Day18.add_lines()
|> Day18.reduce()
|> IO.inspect()

# Day18.do_pt_1(addition_sample) |> IO.inspect(label: "part 1")
