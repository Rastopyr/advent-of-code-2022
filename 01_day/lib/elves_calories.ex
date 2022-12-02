defmodule ElvesCalories do
  @moduledoc """
  Documentation for `ElvesCalories`.
  """

  require Logger

  defp add_calories([], calories) do
    [calories]
  end

  defp add_calories(elves, calories) do
    List.update_at(elves, 0, fn count -> count + calories end)
  end

  defp parse_calories(calories) do
    case Integer.parse(calories) do
      :error -> Logger.error("Fail parse calories", %{c: calories})
      {calories, _} -> calories
    end
  end

  defp add_elve(elves) do
    [0 | elves]
  end

  @doc """
  Hello world.

  ## Examples

      iex> ElvesCalories.hello()
      :world

  """
  def count_calories(file_path \\ "calories.txt") do
    File.stream!(file_path)
    |> Enum.reduce([], fn str, acc ->
      is_empty_line = str == "\n"

      case is_empty_line do
        true ->
          acc |> add_elve

        false ->
          str |> parse_calories() |> (&add_calories(acc, &1)).()
      end
    end)
    |> Enum.sort(:desc)
  end

  def most_carrying_elf_calories(elves) do
    elves
    |> Enum.at(0)
  end

  def top_3_carrying_elf_calories(elves) do
    elves
    |> Enum.take(3)
    |> Enum.reduce(0, fn elem, acc -> acc + elem end)
  end
end
