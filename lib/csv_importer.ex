defmodule Todoer.CsvImporter do
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
end
