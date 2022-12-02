defmodule RPS do
  @left_rps %{
    "A" => :rock,
    "B" => :paper,
    "C" => :scissors
  }

  @right_rps %{
    "X" => :rock,
    "Y" => :paper,
    "Z" => :scissors
  }

  @endgame_rules %{
    "Y" => :draw,
    "X" => :lose,
    "Z" => :win
  }

  defp check(:rock, :paper), do: :lose
  defp check(:rock, :rock), do: :draw
  defp check(:rock, :scissors), do: :win

  defp check(:paper, :rock), do: :win
  defp check(:paper, :scissors), do: :lose
  defp check(:paper, :paper), do: :draw

  defp check(:scissors, :paper), do: :win
  defp check(:scissors, :rock), do: :lose
  defp check(:scissors, :scissors), do: :draw

  defp match_points(:win), do: 6
  defp match_points(:draw), do: 3
  defp match_points(:lose), do: 0

  defp rps_points(:rock), do: 1
  defp rps_points(:paper), do: 2
  defp rps_points(:scissors), do: 3

  defp map_match(<<left::binary-size(1), " ", right::binary-size(1)>>) do
    {
      Map.get(@left_rps, left),
      Map.get(@right_rps, right)
    }
  end

  defp compute_score(match, game) do
    {left_rps, right_rps} = match

    left_points = (left_rps |> rps_points) + (left_rps |> check(right_rps) |> match_points)
    right_points = (right_rps |> rps_points) + (right_rps |> check(left_rps) |> match_points)

    %{
      left: game.left + left_points,
      right: game.right + right_points
    }
  end

  def simple_match do
    File.stream!("rps.txt")
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&map_match(&1))
    |> Enum.reduce(%{ left: 0, right: 0}, &compute_score(&1, &2))
  end

  defp endgame_check(:rock, :draw), do: :rock
  defp endgame_check(:rock, :win), do: :paper
  defp endgame_check(:rock, :lose), do: :scissors

  defp endgame_check(:paper, :draw), do: :paper
  defp endgame_check(:paper, :win), do: :scissors
  defp endgame_check(:paper, :lose), do: :rock

  defp endgame_check(:scissors, :draw), do: :scissors
  defp endgame_check(:scissors, :win), do: :rock
  defp endgame_check(:scissors, :lose), do: :paper

  defp endgame_map_match(<<left::binary-size(1), " ", right::binary-size(1)>>) do
    {
      Map.get(@left_rps, left),
      Map.get(@left_rps, left) |> endgame_check(Map.get(@endgame_rules, right))
    }
  end

  def endgame_match do
    File.stream!("rps.txt")
    |> Enum.map(&String.replace(&1, "\n", ""))
    |> Enum.map(&endgame_map_match(&1))
    |> Enum.reduce(%{ left: 0, right: 0}, &compute_score(&1, &2))
  end
end
