defmodule RopePath.Knot do
  alias RopePath.Knot

  @enforce_keys [:position, :passed]
  defstruct position: nil, passed: nil

  def new() do
    %Knot{
      passed: MapSet.new([]),
      position: %{x: 0, y: 0}
    }
  end

  defp put_passed(passed, knot), do: Map.put(knot, :passed, passed)
  defp put_position(position, knot), do: Map.put(knot, :position, position)


  def mark_passed(%Knot{} = knot), do: knot.passed |> MapSet.put(knot.position) |> put_passed(knot)

  defp put_x(x, knot), do: knot.position |> Map.put(:x, x) |> put_position(knot)
  defp put_y(y, knot), do: knot.position |> Map.put(:y, y) |> put_position(knot)

  def move(knot, "U"), do: knot.position.y + 1 |> put_y(knot)
  def move(knot, "D"), do: knot.position.y - 1 |> put_y(knot)

  def move(knot, "R"), do: knot.position.x + 1 |> put_x(knot)
  def move(knot, "L"), do: knot.position.x - 1 |> put_x(knot)

  def move(knot, _), do: knot
end

defmodule RopePath.Rope do
  alias RopePath.{
    Knot,
    Rope
  }

  defstruct knots: []

  def new(knots_count) do
    1..knots_count |> Enum.map(fn _ -> Knot.new() end) |> (& %Rope{ knots: &1 }).()
  end

  defp put_knots(knots, rope), do: Map.put(rope, :knots, knots)

  def follow_diagonal?(x, y, knot) when abs(x - knot.position.x) > 0 and abs(y - knot.position.y) > 1, do: true
  def follow_diagonal?(x, y, knot) when abs(x - knot.position.x) > 1 and abs(y - knot.position.y) > 0, do: true
  def follow_diagonal?(_, _, _), do: false

  def follow_x?(x, knot), do: abs(x - knot.position.x) > 1
  def follow_y?(y, knot), do: abs(y - knot.position.y) > 1

  def follow_x(x, knot) when x > knot.position.x, do: Knot.move(knot, "R")
  def follow_x(_, knot), do: Knot.move(knot, "L")

  def follow_y(y, knot) when y > knot.position.y, do: Knot.move(knot, "U")
  def follow_y(_, knot), do: Knot.move(knot, "D")

  defp follow_head(head, tail) do
    %{ x: x, y: y } = head.position

    with  should_move_diagonal <- follow_diagonal?(x, y, tail),
          should_move_x <- follow_x?(x, tail),
          should_move_y <- follow_y?(y, tail) do

      cond do
        should_move_diagonal -> follow_x(x, tail) |> (&follow_y(y, &1)).()
        should_move_x -> follow_x(x, tail)
        should_move_y -> follow_y(y, tail)
        true -> tail
      end
    end
  end

  defp move_tail(tail, list) do
    List.last(list)
    |> follow_head(tail)
    |> Knot.mark_passed()
    |> (&list ++ [&1]).()
  end

  def move(direction, %Rope{} = rope) do
    head = rope.knots |> Enum.at(0) |> Knot.move(direction)

    rope.knots
    |> Enum.drop(1)
    |> Enum.reduce([head], &move_tail(&1, &2))
    |> put_knots(rope)
  end
end

defmodule RopePath do
  alias RopePath.Rope

  defp parse_line(line), do:
    line
    |> String.replace("\n", "")
    |> String.split(" ", trim: true)
    |> (fn [d, s] -> {d, String.to_integer(s)} end).()
    |> (fn {d, s} -> 1..s |> Enum.map(fn _ -> d end) end).()


  def part_one do
    File.stream!("data.txt")
    |> Enum.flat_map(&parse_line(&1))
    |> Enum.reduce(Rope.new(2), &Rope.move(&1, &2))
    |> (&List.last(&1.knots)).()
    |> (&MapSet.size(&1.passed)).()
  end

  def part_two do
    File.stream!("data.txt")
    |> Enum.flat_map(&parse_line(&1))
    |> Enum.reduce(Rope.new(10), &Rope.move(&1, &2))
    |> (&List.last(&1.knots)).()
    |> (&MapSet.size(&1.passed)).()
  end
end
