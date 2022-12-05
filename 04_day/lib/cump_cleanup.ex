defmodule CumpCleanup do

  defp assignment_to_range(assignment) do
    assignment
    |> String.split("-", trim: true)
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(&elem(&1, 0))
  end

  defp normalize(row) do
    row
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> Enum.map(&assignment_to_range(&1))
  end

  defp is_covered([first, second]) do
    [first_start, first_end] = first
    [second_start, second_end] = second

    first_cover_second = first_start <= second_start and first_end >= second_end
    second_cover_first = first_start >= second_start and first_end <= second_end

    first_cover_second or second_cover_first
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

  defp is_overlap([first, second]) do
    [first_start, first_end] = first
    [second_start, second_end] = second

    !Range.disjoint?(
      first_start..first_end,
      second_start..second_end
    )
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
