defmodule TodoerTest do
  use ExUnit.Case
  import TodoerTestHelper
  alias Todoer.TodoList
  alias Todoer.Todo
  doctest Todoer.TodoList

  def generate_todos() do
    TodoList.new()
    |> TodoList.add_entry(%Todo{date: ~D[2024-01-01], title: "Some"})
    |> TodoList.add_entry(%Todo{date: ~D[2024-10-01], title: "kind"})
    |> TodoList.add_entry(%Todo{date: ~D[2024-11-01], title: "of"})
    |> TodoList.add_entry(%Todo{date: ~D[2024-11-01], title: "blue"})
  end

  test "a new todo list is empty" do
    todo_list = TodoList.new()
    assert %TodoList{todo_list | pid: nil} == %TodoList{}
    assert todo_list.pid != nil
  end

  test "can add a new entry" do
    todo_list = generate_todos()

    assert equal_todoers?(TodoList.entries(todo_list, ~D[2024-01-01]), [
             %Todo{
               date: ~D[2024-01-01],
               title: "Some",
               id: 1
             }
           ])
  end

  test "can add multiple new entries" do
    todo_list =
      TodoList.new([
        %Todo{date: ~D[2024-01-01], title: "Some"},
        %Todo{date: ~D[2024-11-01], title: "blue"}
      ])

    assert equal_todoers?(TodoList.entries(todo_list), [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 2}
           ])
  end

  test "can add new entries using comprehension" do
    todo_list = generate_todos()
    duplicate_todo_list = Enum.into(todo_list, TodoList.new())

    assert equal_todoers?(duplicate_todo_list, todo_list)
  end

  test "can find an entry for a date" do
    todo_list = generate_todos()

    assert equal_todoers?(TodoList.get_for_date(todo_list, ~D[2024-01-01]), [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1}
           ])
  end

  test "can find multiple entries for a date" do
    todo_list = generate_todos()

    assert equal_todoers?(TodoList.get_for_date(todo_list, ~D[2024-11-01]), [
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ])
  end

  test "can update an existing entry by struct" do
    todo_list = generate_todos()

    new_entry = %Todo{
      date: ~D[2024-11-01],
      title: "of other",
      id: 3
    }

    assert equal_todoers?(
             TodoList.update_entry(todo_list, new_entry)
             |> TodoList.entries(),
             [
               %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
               %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
               %Todo{date: ~D[2024-11-01], title: "of other", id: 3},
               %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
             ]
           )
  end

  test "can update an existing entry with a partial struct" do
    todo_list = generate_todos()

    new_entry = %Todo{
      title: "of other",
      id: 3
    }

    assert equal_todoers?(
             TodoList.update_entry(todo_list, new_entry)
             |> TodoList.entries(),
             [
               %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
               %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
               %Todo{date: ~D[2024-11-01], title: "of other", id: 3},
               %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
             ]
           )
  end

  test "can update an existing entry by id" do
    todo_list = generate_todos()

    assert equal_todoers?(
             TodoList.update_entry(todo_list, 1, &Map.put(&1, :title, "Some other"))
             |> TodoList.entries(),
             [
               %Todo{date: ~D[2024-01-01], title: "Some other", id: 1},
               %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
               %Todo{date: ~D[2024-11-01], title: "of", id: 3},
               %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
             ]
           )
  end

  test "can delete a TODO" do
    todo_list = generate_todos()
    todo = %Todo{date: ~D[2024-11-01], title: "of", id: 3}
    todo_list = TodoList.remove(todo_list, todo)

    assert equal_todoers?(todo_list, [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ])
  end

  test "can delete a TODO by id" do
    todo_list = generate_todos()
    todo_list = TodoList.remove(todo_list, 2)

    assert equal_todoers?(todo_list, [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ])
  end

  test "can set a TODO as done" do
    todo_list = [
      %Todo{date: ~D[2024-01-01], title: "Some", id: 1}
    ]

    assert TodoList.done(List.first(todo_list)) == %Todo{
             date: ~D[2024-01-01],
             title: "Some",
             id: 1,
             status: :done
           }
  end

  test "can get all DONE TODOs" do
    todo_list =
      generate_todos()
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-01], title: "We", status: :done})
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-02], title: "Are", status: nil})
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-02], title: "Done", status: :done})

    assert Enum.count(todo_list) == 7

    assert equal_todoers?(TodoList.get_done(todo_list), [
             %Todo{date: ~D[2024-02-01], title: "We", status: :done, id: 5},
             %Todo{date: ~D[2024-02-02], title: "Done", status: :done, id: 7}
           ])
  end

  test "can get all pending TODOs" do
    todo_list =
      generate_todos()
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-01], title: "We", status: :done})
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-02], title: "Are", status: nil})
      |> TodoList.add_entry(%Todo{date: ~D[2024-02-02], title: "Done", status: :done})

    assert equal_todoers?(TodoList.get_active(todo_list), [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4},
             %Todo{date: ~D[2024-02-02], title: "Are", status: nil, id: 6}
           ])
  end

  test "updating an invalid entry returns the original list" do
    todo_list = generate_todos()

    assert equal_todoers?(
             TodoList.update_entry(todo_list, 10, &Map.put(&1, :title, "Some other"))
             |> TodoList.entries(),
             [
               %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
               %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
               %Todo{date: ~D[2024-11-01], title: "of", id: 3},
               %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
             ]
           )
  end

  test "can call to_string to get TODOs" do
    todo_list =
      generate_todos()
      |> String.Chars.to_string()

    assert todo_list ==
             """
             2024-01-01: Some
             2024-10-01: kind
             2024-11-01: of
             2024-11-01: blue\
             """
  end

  test "can create many TODO lists (as unique processes)" do
    todo_list = generate_todos()
    todo_list2 = generate_todos()
    todo_list3 = generate_todos()

    assert equal_todoers?(todo_list, todo_list2)
    assert equal_todoers?(todo_list2, todo_list3)
  end
end
