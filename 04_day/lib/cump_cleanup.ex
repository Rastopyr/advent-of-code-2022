defmodule CumpCleanup do
  defp to_map_set([a, b]) do
    MapSet.new(a..b)
  end

  defp assignment_to_range(assignment) do
    assignment
    |> String.split("-", trim: true)
    |> Enum.map(&String.to_integer(&1))
    |> to_map_set
  end

  defp normalize(row) do
    row
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(&assignment_to_range(&1))
  end

  defp is_covered([a, b]) do
    MapSet.subset?(a, b) or MapSet.subset?(b, a)
  end

  defp match_cover(row) do
    row
    |> normalize
    |> is_covered
  end

  def part_one do
    File.stream!("assignments.txt")
    |> Enum.reduce(0, fn row, acc ->
      is_cover = match_cover(row)
      case is_cover do
        true -> acc + 1
        false -> acc
      end
    end)
  end

  defp is_overlap([a, b]) do
    !MapSet.disjoint?(a, b)
  end

   defp match_overlap(row) do
    row
    |> normalize
    |> is_overlap
  end

  def part_two do
    File.stream!("assignments.txt")
    |> Enum.reduce(0, fn row, acc ->
      is_cover = match_overlap(row)
      case is_cover do
        true -> acc + 1
        false -> acc
      end
    end)
  end
end
