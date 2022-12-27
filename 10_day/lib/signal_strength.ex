
defmodule SignalStrength do
  defp add_cycle(state), do: %{ state | cycle: state.cycle + 1 }

  defp increase_register(state, "noop"), do: state
  defp increase_register(state, "addx " <> value), do: %{
    state |
    register: state.register + String.to_integer(value)
  }

  defp sync_strength(state) when state.cycle == 20 or rem(state.cycle - 20, 40) == 0 do
    %{
      state |
      strength: state.strength + state.register * state.cycle
    }
  end
  defp sync_strength(state), do: state

  defp compute_strength("addx " <> _ = command, state) do
    state |> add_cycle() |> sync_strength() |> add_cycle() |> sync_strength() |> increase_register(command)
  end

  defp compute_strength(_, state) do
    state |> add_cycle() |> sync_strength()
  end

  def part_one do
    state = %{
      register: 1,
      cycle: 0,
      strength: 0
    }

    File.stream!("data.txt")
    |> Enum.map(&String.trim(&1))
    |> Enum.reduce(state, &compute_strength(&1, &2))
  end

  defp replace_pixel(true, row, pos) when is_list(row), do: List.replace_at(row, pos, "#")
  defp replace_pixel(_, row, _), do: row

   def place_pixel(state) do
    y = state.cycle / 40 |> :math.floor() |> round()
    x = state.cycle - (y * 40) |> max(0)

    cursor = state.cursor..state.cursor+2

    is_lit = x in cursor

    row = state.display
    |> Enum.at(y)
    |> (&replace_pixel(is_lit, &1, x)).()

    %{
      state |
      display: state.display |> List.replace_at(y, row)
    }
  end

  def move_cursor(state) do
    %{
      state |
      cursor: state.register
    }
  end

  defp render_crt("addx " <> _ = command, state) do
    state
    |> add_cycle()
    |> place_pixel()
    |> add_cycle()
    |> place_pixel()
    |> increase_register(command)
    |> move_cursor()
  end

  defp render_crt("noop", state) do
    state
    |> add_cycle()
    |> place_pixel()
  end

  def part_two do
    display =  1..6 |> Enum.map(fn _ ->
      1..40 |> Enum.map(fn _ -> " " end)
    end)

    state = %{
      register: 1,
      cycle: 0,
      display: display,
      cursor: 0
    }

    File.stream!("data.txt")
    |> Enum.map(&String.trim(&1))
    |> Enum.reduce(state, &render_crt(&1, &2))
    |> (& &1.display).()
    |> Enum.map(&Enum.join(&1, ""))
    |> Enum.join("\n")
    |> IO.puts
  end
end
