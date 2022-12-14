defmodule DirSize do
  defp normalize(line) do
    line
    |> String.replace("\n", "")
  end

  defp update_dir_size(nil, _, directories) do
    directories
  end

  defp update_dir_size(dirname, size, directories) do
    {dir_size, parent_dir} = directories[dirname]

    {dir_size + size, parent_dir}
    |> (&Map.put(directories, dirname, &1)).()
    |> (&update_dir_size(parent_dir, size, &1)).()
  end

  defp parse_line("$ cd /", _) do
    {
      %{
        "/root" => {0, nil}
      },
      "/root"
    }
  end

  defp parse_line("$ cd ..", {directories, current_dirname}) do
    {_, parent_dirname} = directories[current_dirname]

    {directories, parent_dirname}
  end

  defp parse_line("$ cd " <> dir, {directories, current_dirname}) do
    full_path = "#{current_dirname}/#{dir}"

    directories
    |> Map.put(full_path, {0, current_dirname})
    |> (&{&1, full_path}).()
  end

  defp parse_line("$ ls", state) do
    state
  end

  defp parse_line("dir " <> _, state) do
    state
  end

  defp parse_line(file, {directories, current_dirname}) do
    [filesize, _] = String.split(file, " ", trim: true)

    current_dirname
    |> update_dir_size(String.to_integer(filesize), directories)
    |> (&{&1, current_dirname}).()
  end

  def walk() do
    File.stream!("log.txt")
    |> Enum.reduce({%{}, nil}, fn line, state ->
      line
      |> normalize()
      |> parse_line(state)
    end)
  end

  def part_one() do
    walk()
    |> elem(0)
    |> Enum.reduce(0, fn {_, {size, _}}, all_size ->
      case size < 100000 do
        true -> all_size + size
        false -> all_size
      end
    end)
  end

  def part_two() do
    space = 70000000
    expected = 30000000

    {directories, _} = walk()
    {root_size, _} = directories["/root"]

    directories
    |> Enum.reduce(fn {_, {size, _}}, erased_space ->
      case space - root_size + size >= expected && size < erased_space do
        true -> size
        false -> erased_space
      end
    end)
  end
end
