defmodule TreeHouse do

  # Can't solve by myself. So take more understandable solution from:
  # https://gist.github.com/zolrath/aef819016583d494c3f9023db63f3794#file-day-8-ex-L1


  defp visible(checking, tree) do
    checking
    |> Enum.all?(&(&1 < tree))
  end

  defp visible?({rows, cols}, {x, y}) do
    row = Enum.at(rows, y)
    col = Enum.at(cols, x)
    tree = Enum.at(row, x)

    visible(Enum.take(row, x), tree) ||
      visible(Enum.drop(row, x + 1), tree) ||
      visible(Enum.take(col, y), tree) ||
      visible(Enum.drop(col, y + 1), tree)
  end

  defp visible_count(checking, tree) do
    checking
    |> Enum.reduce_while(0, fn val, acc ->
      if val < tree, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

  def visible_count?({rows, cols}, {x, y}) do
    row = Enum.at(rows, y)
    col = Enum.at(cols, x)
    tree = Enum.at(row, x)

    visible_count(Enum.take(row, x) |> Enum.reverse(), tree) *
      visible_count(Enum.drop(row, x + 1), tree) *
      visible_count(Enum.take(col, y) |> Enum.reverse(), tree) *
      visible_count(Enum.drop(col, y + 1), tree)
  end

  defp parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&(String.split(&1, "", trim: true)))
    |> Enum.map(fn line -> Enum.map(line, &String.to_integer/1) end)
  end

  def part_one do
    grid = File.read!("tree-grid.txt")

    rows = parse_input(grid)
    cols = Enum.zip_with(rows, & &1)

    for x <- 0..(Enum.count(rows) - 1), y <- 0..(Enum.count(cols) - 1) do
      visible?({rows, cols}, {x, y})
    end
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  def part_two do
    grid = File.read!("tree-grid.txt")

    rows = parse_input(grid)
    cols = Enum.zip_with(rows, & &1)

    for x <- 0..(Enum.count(rows) - 1), y <- 0..(Enum.count(cols) - 1) do
      visible_count?({rows, cols}, {x, y})
    end
    |> Enum.max()
  end
end
