defmodule RuckSack do
  @score_table "abcdefghijklmnopqrstuvwxyz" |> String.split("", trim: true)

  defp find_items(left, right) do
    left |> Enum.filter(fn elem -> elem in right end)
  end

  defp get_score(char) do
    lower_char = String.downcase(char)
    pos = Enum.find_index(@score_table, fn e -> e == lower_char end) + 1

    case lower_char == char do
      true -> pos
      false -> pos + 26
    end
  end

  defp normalize_rucksack(rucksack) do
    rucksack
    |> String.replace("\n", "")
    |> String.split("", trim: true)
  end

  defp split_rucksack(rucksack) do
    rucksack_size = length(rucksack)
    comparent_size = trunc(rucksack_size / 2)

    Enum.split(rucksack, comparent_size ) |> Tuple.to_list()
  end

  defp find_in_rucksack(rucksack) do
    [left, right]  = rucksack
    |> normalize_rucksack
    |> split_rucksack

    find_items(left, right)
  end

  defp find_unique_items(rucksack_entry) do
    rucksack_entry
    |> find_in_rucksack
    |> Enum.at(0)
    |> get_score
  end

  def part_one do
    File.stream!("rucksacks.txt")
    |> Enum.reduce(0, fn entry, acc ->
      find_unique_items(entry) + acc
    end)
  end

  def part_two do
    File.stream!("rucksacks.txt")
    |> Enum.chunk_every(3)
    |> Enum.reduce(0, fn chunk, score ->
      chunk
      |> Enum.reduce([], fn entry, acc ->
        case acc do
          [] -> entry |> normalize_rucksack
          chars -> entry |> normalize_rucksack |> find_items(chars)
        end
      end)
      |> Enum.at(0)
      |> get_score
      |> Kernel.+(score)
    end)
  end
end
