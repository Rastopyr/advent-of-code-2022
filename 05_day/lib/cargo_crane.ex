defmodule CargoCrane do
  def initial_state do
    File.stream!("crates.txt")
    |> Enum.map(&String.replace(&1, "    ", "[-]"))
    |> Enum.map(&String.replace(&1, " ", ""))
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&String.split(&1, ~r/\]\[|\[|\]/i, trim: true))
    |> Enum.map(&Enum.with_index(&1))
    |> Enum.with_index()
    |> Enum.reduce([], fn row_data, blocks ->
      {row, _} = row_data

      Enum.reduce(row, blocks, fn crate_data, blocks ->
        {crate, crate_index} = crate_data

        row_to_add = Enum.at(blocks, crate_index)

        case row_to_add do
          nil -> blocks ++ [[crate]]
          row -> List.replace_at(blocks, crate_index, row ++ [crate])
        end
      end)
    end)
    |> Enum.map(&Enum.filter(&1, fn r -> r != "-"  end))
  end

  defp parse_move(move) do
    ~r/move (\d*) from (\d*) to (\d*)/im
    |> Regex.run(move)
    |> Enum.drop(1)
    |> Enum.map(&String.to_integer(&1))
    |> List.to_tuple()
  end

  def arrange_crates(is_reverse) do
    File.stream!("moves.txt")
    |> Enum.reduce(initial_state(), fn move, blocks ->
      {count, source, target} = parse_move(move)

      source_row = blocks |> Enum.at(source-1)
      target_row = blocks |> Enum.at(target-1)

      {moved_crates, left_source} = source_row |> Enum.split(count)

      ordered_crates = case is_reverse do
        true -> Enum.reverse(moved_crates)
        false -> moved_crates
      end

      blocks
      |> List.replace_at(source-1, left_source)
      |> List.replace_at(target-1, ordered_crates ++ target_row)
    end)
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.join("")
  end

  def part_one() do
    arrange_crates(true)
  end

  def part_two() do
    arrange_crates(false)
  end
end
