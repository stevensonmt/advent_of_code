defmodule Day18Test do
  use ExUnit.Case
  doctest Day18
  alias Day18.Tree
  alias Day18.ForestRanger

  @sample "[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
 [[[5,[2,8]],4],[5,[[9,9],0]]]
 [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
 [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
 [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
 [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
 [[[[5,4],[7,7]],8],[[8,3],8]]
 [[9,3],[[9,9],[6,[4,9]]]]
 [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
 [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]"

  @addition_sample "[[[[4,3],4],4],[7,[[8,4],9]]]\n[1,1]"
  @smol "[[1,2],[[3,4],5]]"
  @med "[[[[0,7],4],[[7,8],[6,0]]],[8,1]]"
  @med2 "[[[[7,7],[7,7]],[[8,7],[8,7]]],[[[7,0],[7,7]],9]]
 [[[[4,2],2],6],[8,7]]"
  @explode "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]"
  @split "[[[[0,7],4],[15,[0,13]]],[1,1]]"

  test "parse smol sample" do
    assert Day18.parse(@smol) == [
             %Tree{
               left: %Tree{left: 1, right: 2},
               right: %Tree{left: %Tree{left: 3, right: 4}, right: 5}
             }
           ]
  end

  test "parse explode sample" do
    assert Day18.parse(@explode) == [
             %Tree{
               left: %Tree{
                 left: %Tree{
                   left: %Tree{
                     left: %Tree{
                       left: 4,
                       right: 3
                     },
                     right: 4
                   },
                   right: 4
                 },
                 right: %Tree{
                   left: 7,
                   right: %Tree{
                     left: %Tree{
                       left: 8,
                       right: 4
                     },
                     right: 9
                   }
                 }
               },
               right: %Tree{
                 left: 1,
                 right: 1
               }
             }
           ]
  end

  test "simple addition" do
    assert [Day18.parse("[1,2]\n[[3,4],5]") |> Day18.add_lines()] == Day18.parse(@smol)
  end

  test "extracting ranger == extracting up(ranger)" do
    ranger = Day18.parse(@smol) |> Day18.add_lines() |> ForestRanger.new()
    downl = ForestRanger.down(ranger, :left) |> elem(1)
    topped = ForestRanger.up(ranger) |> elem(1)
    upped = ForestRanger.up(downl) |> elem(1)

    assert ForestRanger.extract_tree(ranger) == ForestRanger.extract_tree(upped)
    assert ForestRanger.extract_tree(ranger) == ForestRanger.extract_tree(downl)
    assert ForestRanger.extract_tree(ranger) == ForestRanger.extract_tree(topped)
  end

  test "set ranger.current zero produces new tree when extracted" do
    ranger = Day18.parse(@smol) |> Day18.add_lines() |> ForestRanger.new()
    downl = ForestRanger.down(ranger, :left) |> elem(1)
    zeroed = Day18.set_current_zero(downl)
    up_zeroed = ForestRanger.up(zeroed) |> elem(1)
    assert Day18.parse("[0,[[3,4],5]]") |> Day18.add_lines() == ForestRanger.extract_tree(zeroed)
    assert ForestRanger.extract_tree(zeroed) == ForestRanger.extract_tree(up_zeroed)
  end

  @tag :ignore
  test "update_nearest_left_int" do
    ranger =
      Day18.parse("[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
      |> Day18.add_lines()
      |> ForestRanger.new()
      |> ForestRanger.down(:left)
      |> ForestRanger.down(:right)
      |> ForestRanger.down(:right)
      |> ForestRanger.down(:right)
      |> elem(1)

    assert ranger.current.left == 6

    update_nearest_left_int = Day18.update_nearest_left_int(ranger, 6)

    assert update_nearest_left_int.current.left == 6

    updated_tree = update_nearest_left_int |> ForestRanger.extract_tree()

    assert updated_tree ==
             Day18.parse("[[[[0,7],4],[[7,8],[6,[6,7]]]],[1,1]]") |> Day18.add_lines()
  end

  # @tag :ignore
  test "simple explode" do
    exploding =
      Day18.parse("[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]")
      |> Day18.add_lines()
      |> ForestRanger.new()
      |> ForestRanger.down(:left)
      |> ForestRanger.down(:right)
      |> ForestRanger.down(:right)
      |> ForestRanger.down(:right)
      |> elem(1)
      |> Day18.explode()

    assert exploding
           |> elem(1)
           |> ForestRanger.extract_tree() ==
             Day18.parse("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]") |> Day18.add_lines()
  end

  test "another simple explode" do
    exploding =
      Day18.parse("[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]")
      |> Day18.add_lines()
      |> ForestRanger.new()
      |> ForestRanger.down(:left)
      |> ForestRanger.down(:left)
      |> ForestRanger.down(:left)
      |> ForestRanger.down(:left)
      |> elem(1)
      |> Day18.explode()

    assert exploding |> elem(1) |> ForestRanger.extract_tree() ==
             Day18.parse("[[[[0,7],4],[7,[[8,4],9]]],[1,1]]") |> Day18.add_lines()
  end

  @tag :ignore
  test "try_explode finds first exploding node" do
    assert Day18.parse(@explode) |> Day18.add_lines() |> Day18.try_explode() ==
             Day18.parse("[[[[0,7],4],[7,[[8,4],9]]],[1,1]]") |> Day18.add_lines()
  end

  @tag :ignore
  test "simple split" do
    assert Day18.parse(@split) |> Day18.add_lines() |> Day18.split() ==
             Day18.parse("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
  end

  @tag :ignore
  test "try_split finds first splitting node" do
    assert Day18.parse(@split) |> Day18.add_lines() |> Day18.try_split() ==
             Day18.parse("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
  end
end