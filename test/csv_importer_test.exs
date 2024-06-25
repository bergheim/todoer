defmodule CsvImporterTest do
  use ExUnit.Case
  doctest Todoer

  test "can load todos from a file" do
    todo_list = Todoer.CsvImporter.import("todos.csv")
    todo_list = Todoer.new(todo_list)

    assert Todoer.entries(todo_list) == [
             %Todo{date: ~D[2024-09-09], title: "Jump", id: 1},
             %Todo{date: ~D[2024-09-10], title: "Sit", id: 2},
             %Todo{date: ~D[2024-09-11], title: "Walk", id: 3}
           ]
  end
end
