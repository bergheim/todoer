defmodule CsvHelperTest do
  use ExUnit.Case
  import TodoerTestHelper
  alias Todoer.TodoList
  alias Todoer.Todo
  doctest Todoer.CsvHelper

  # @tag :one
  test "can load todos from a file" do
    todo_list = Todoer.CsvHelper.import("todos.csv")

    assert equal_todoers?(TodoList.entries(todo_list), [
             %Todo{date: ~D[2024-09-09], title: "Jump", id: 1},
             %Todo{date: ~D[2024-09-10], title: "Sit", id: 2},
             %Todo{date: ~D[2024-09-11], title: "Walk", id: 3}
           ])
  end

  test "can save todos to a file" do
    todo_list =
      Todoer.CsvHelper.import("todos.csv")
      |> TodoList.add_entry(%Todo{date: ~D[2024-11-01], title: "of"})

    # art vandelay called
    Todoer.CsvHelper.export(todo_list, "test.csv")
    todo_list = Todoer.CsvHelper.import("test.csv")

    assert equal_todoers?(
             TodoList.entries(todo_list),
             [
               %Todo{date: ~D[2024-09-09], title: "Jump", id: 1},
               %Todo{date: ~D[2024-09-10], title: "Sit", id: 2},
               %Todo{date: ~D[2024-09-11], title: "Walk", id: 3},
               %Todo{date: ~D[2024-11-01], title: "of", id: 4}
             ]
           )
  end
end
