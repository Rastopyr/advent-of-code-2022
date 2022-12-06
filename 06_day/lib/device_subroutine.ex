defmodule DeviceSubroutine do
  defp continue(acc), do: {:cont, acc}
  defp halt(acc), do: {:halt, acc}

  defp drop_til_char(chars, char) do
    case Enum.find_index(chars, &Kernel.==(&1, char)) do
      nil -> chars
      index -> chars |> Enum.drop(index + 1)
    end
  end

  defp find_unique_substring(message, substring_length) do
    Enum.reduce_while(message, {0, []}, fn char, {count, chars} ->
      next_chars = drop_til_char(chars, char) ++ [char]

      case length(next_chars) do
        ^substring_length -> halt({count + 1, next_chars})
        _ -> continue({count + 1, next_chars})
      end
    end)
  end

  def part_one do
    File.read!("message.txt")
    |> String.split("", trim: true)
    |> find_unique_substring(4)
  end

  def part_two do
    File.read!("message.txt")
    |> String.split("", trim: true)
    |> find_unique_substring(14)
  end
end
