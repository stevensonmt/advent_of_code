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

    def up({:ok, r}), do: up(r)
    def up(%__MODULE__{previous: nil} = ranger), do: {:top, ranger}

    def up(%__MODULE__{} = ranger) do
      {:ok,
       ranger.previous
       |> Map.update!(:current, fn new_curr ->
         Map.update!(new_curr, hd(ranger.steps), fn _ -> ranger.current end)
       end)}
    end

    def down({:ok, r}, s), do: down(r, s)

    def down(%__MODULE__{current: curr} = ranger, _step) when is_integer(curr) or curr == nil,
      do: {:bottom, ranger}

    def down(%__MODULE__{} = ranger, step) do
      prev = ranger
      steps = [step | ranger.steps]
      curr = Map.get(ranger.current, step)
      {:ok, %ForestRanger{previous: prev, steps: steps, current: curr}}
    end

    def extract_tree(%__MODULE__{} = ranger) do
      case up(ranger) do
        {:top, r} -> r.current
        {:ok, r} -> extract_tree(r)
      end
    end
  end

  @type tree :: Tree.t()
  @type ranger :: ForestRanger.t()

  @spec parse(String.t()) :: [tree()]
  def parse(input) do
    input
    |> String.split()
    |> Enum.map(&(Code.eval_string(&1) |> elem(0) |> Tree.new()))
  end

  @spec add_lines([tree()]) :: tree()
  def add_lines([tree | forest]) do
    forest
    |> Enum.reduce(tree, fn t, acc ->
      acc = Tree.add(acc, t) |> reduce()
      acc
    end)
  end

  @spec do_pt_1(String.t()) :: integer
  def do_pt_1(input) do
    input
    |> parse()
    |> add_lines()
    |> magnitude()
  end

  @spec do_pt_2(String.t()) :: integer
  def do_pt_2(input) do
    lines = parse(input)

    for n <- lines,
        m <- lines,
        n != m do
      add_lines([n, m])
      |> magnitude()
    end
    |> Enum.max()
  end

  @spec explode(ranger()) :: ranger()
  def explode(ranger = %ForestRanger{current: curr}) do
    {:ok,
     ranger
     |> set_current_zero()
     |> update_nearest_left_int(curr.left)
     |> reset(ranger.steps)
     |> update_nearest_right_int(curr.right)}
  end

  def reset(ranger, steps) do
    ranger =
      ranger
      |> ForestRanger.extract_tree()
      |> ForestRanger.new()

    steps
    |> Enum.reverse()
    |> Enum.reduce_while(ranger, fn s, r ->
      case ForestRanger.down(r, s) do
        {:bottom, rr} -> {:halt, rr}
        {:ok, rr} -> {:cont, rr}
      end
    end)
  end

  def update_nearest_left_int(ranger, val) do
    # if it's lefts all the way to the top, there is no nearest right
    if ranger.steps |> Enum.all?(fn s -> s == :left end) do
      ranger
    else
      # otherwise, reverse all the lefts and then reverse the first right and go left instead
      rev_rights =
        ranger.steps
        |> Enum.reduce_while(ranger, fn step, acc ->
          case {step, ForestRanger.up(acc)} do
            {:left, {:ok, r}} -> {:cont, r}
            {_, {_, r}} -> {:halt, r}
          end
        end)
        |> ForestRanger.down(:left)

      # then find the nearest left int
      {:ok, found} = closest_left_int(rev_rights)

      Map.update!(found, :current, fn c ->
        c + val
      end)
    end
  end

  def closest_left_int({:ok, r}), do: closest_left_int(r)

  def closest_left_int(ranger) do
    cond do
      is_integer(ranger.current) ->
        {:ok, ranger}

      true ->
        closest_left_int(ForestRanger.down(ranger, :right))
    end
  end

  def update_nearest_right_int(ranger, val) do
    # if it's rights all the way to the top, there is no nearest right
    if ranger.steps |> Enum.all?(fn s -> s == :right end) do
      ranger
    else
      # otherwise, reverse all the rights and then reverse the first left and go right instead
      rev_rights =
        ranger.steps
        |> Enum.reduce_while(ranger, fn step, acc ->
          case {step, ForestRanger.up(acc)} do
            {:right, {:ok, r}} -> {:cont, r}
            {_, {_, r}} -> {:halt, r}
          end
        end)
        |> ForestRanger.down(:right)

      # then find the nearest left int
      {:ok, found} = closest_right_int(rev_rights)

      Map.update!(found, :current, fn c ->
        c + val
      end)
    end
  end

  def closest_right_int({:ok, r}), do: closest_right_int(r)

  def closest_right_int(ranger) do
    case ranger.current |> is_integer() do
      true ->
        {:ok, ranger}

      false ->
        closest_right_int(ForestRanger.down(ranger, :left))
    end
  end

  def set_current_zero(ranger) do
    Map.put(ranger, :current, 0)
  end

  def reduce(tree) do
    tree
    |> try_explode()
    |> moar?(tree)
    |> try_split()
    |> moar?(tree)
  end

  def try_explode(tree) do
    case dfs(ForestRanger.new(tree), :explode) do
      {:exploded, r} ->
        ForestRanger.extract_tree(r)

      _ ->
        tree
    end
  end

  def try_split(tree) do
    case dfs(ForestRanger.new(tree), :split) do
      {:split, r} -> ForestRanger.extract_tree(r)
      _ -> tree
    end
  end

  def dfs(tree = %Tree{}, op), do: dfs(ForestRanger.new(tree), op)

  def dfs(_ranger = %ForestRanger{current: nil}, :explode), do: :no_uhsploade
  def dfs(_ranger = %ForestRanger{current: n}, :explode) when is_integer(n), do: :no_uhsploade
  def dfs(n, :explode) when is_integer(n), do: :no_uhsploade

  def dfs(ranger = %ForestRanger{steps: steps, current: current}, :explode)
      when length(steps) >= 4 and is_integer(current.left) and is_integer(current.right) do
    {:ok, new} = explode(ranger)
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

  def dfs(n, :split) when is_integer(n) and n >= 10 do
    new = Tree.new([div(n, 2), ceil(n / 2)])
    {:split, new}
  end

  def dfs(n, :split) when is_integer(n), do: :no_split

  def dfs(ranger = %ForestRanger{current: n}, :split) when is_integer(n) and n >= 10 do
    new = Tree.new([div(n, 2), ceil(n / 2)])
    {:split, Map.put(ranger, :current, new)}
  end

  def dfs(_ranger = %ForestRanger{current: n}, :split) when is_integer(n) or n == nil,
    do: :no_split

  def dfs(ranger = %ForestRanger{}, :split) do
    case ForestRanger.down(ranger, :left) do
      {:ok, rngr} ->
        case dfs(rngr, :split) do
          {:split, r} ->
            {:split, r}

          _ ->
            case ForestRanger.down(ranger, :right) do
              {:ok, rngr} ->
                case dfs(rngr, :split) do
                  {:split, r} -> {:split, r}
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
