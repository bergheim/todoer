defmodule Todoer.CsvImporter do
  def import(filename) do
    File.stream!(filename)
    |> Stream.map(fn line ->
      [date, title] =
        String.trim(line)
        |> String.split(",", trim: true)

      %Todo{date: Date.from_iso8601!(date), title: title}
    end)

    # |> Map.to
  end
end
