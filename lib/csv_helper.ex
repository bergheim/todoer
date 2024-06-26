defmodule Todoer.CsvHelper do
  def import(filename) do
    entries =
      File.stream!(filename)
      |> Stream.map(fn line ->
        [date, title] =
          String.trim(line)
          |> String.split(",", trim: true)

        %Todo{date: Date.from_iso8601!(date), title: title}
      end)

    Todoer.new(entries)
  end

  def export(todo_list, filename) do
    File.write!(
      filename,
      Todoer.entries(todo_list)
      |> Enum.map(fn %Todo{date: date, title: title} ->
        "#{date},#{title}"
      end)
      |> Enum.join("\n")
    )
  end
end