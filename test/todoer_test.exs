defmodule TodoerTest do
  use ExUnit.Case
  doctest Todoer

  def generate_todos() do
    Todoer.new()
    |> Todoer.add_entry(%Todo{date: ~D[2024-01-01], title: "Some"})
    |> Todoer.add_entry(%Todo{date: ~D[2024-10-01], title: "kind"})
    |> Todoer.add_entry(%Todo{date: ~D[2024-11-01], title: "of"})
    |> Todoer.add_entry(%Todo{date: ~D[2024-11-01], title: "blue"})
  end

  test "a new todo list is empty" do
    assert Todoer.new() == %Todoer{}
  end

  test "can add a new entry" do
    todo_list = generate_todos()

    assert Todoer.entries(todo_list, ~D[2024-01-01]) == [
             %Todo{
               date: ~D[2024-01-01],
               title: "Some",
               id: 1
             }
           ]
  end

  test "can add multiple new entries" do
    todo_list =
      Todoer.new([
        %Todo{date: ~D[2024-01-01], title: "Some"},
        %Todo{date: ~D[2024-11-01], title: "blue"}
      ])

    assert Todoer.entries(todo_list) == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 2}
           ]
  end

  test "can add new entries using comprehension" do
    todo_list = generate_todos()
    assert Enum.into(todo_list, Todoer.new()) == todo_list
  end

  test "can find an entry for a date" do
    todo_list = generate_todos()

    assert Todoer.get_for_date(todo_list, ~D[2024-01-01]) == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1}
           ]
  end

  test "can find multiple entries for a date" do
    todo_list = generate_todos()

    assert Todoer.get_for_date(todo_list, ~D[2024-11-01]) == [
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ]
  end

  test "can update an existing entry by struct" do
    todo_list = generate_todos()

    new_entry = %Todo{
      date: ~D[2024-11-01],
      title: "of other",
      id: 3
    }

    assert Todoer.update_entry(todo_list, new_entry)
           |> Todoer.entries() == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of other", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ]
  end

  test "can update an existing entry with a partial struct" do
    todo_list = generate_todos()

    new_entry = %Todo{
      title: "of other",
      id: 3
    }

    assert Todoer.update_entry(todo_list, new_entry)
           |> Todoer.entries() == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of other", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ]
  end

  test "can update an existing entry by id" do
    todo_list = generate_todos()

    assert Todoer.update_entry(todo_list, 1, &Map.put(&1, :title, "Some other"))
           |> Todoer.entries() == [
             %Todo{date: ~D[2024-01-01], title: "Some other", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ]
  end

  test "can set a TODO as done" do
    todo_list = [
      %Todo{date: ~D[2024-01-01], title: "Some", id: 1}
    ]

    assert Todoer.done(List.first(todo_list)) == %Todo{
             date: ~D[2024-01-01],
             title: "Some",
             id: 1,
             status: :done
           }
  end

  test "can get all DONE TODOs" do
    todo_list =
      generate_todos()
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-01], title: "We", status: :done})
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-02], title: "Are", status: nil})
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-02], title: "Done", status: :done})

    assert Enum.count(todo_list) == 7

    assert Todoer.get_done(todo_list) == [
             %Todo{date: ~D[2024-02-01], title: "We", status: :done, id: 5},
             %Todo{date: ~D[2024-02-02], title: "Done", status: :done, id: 7}
           ]
  end

  test "can get all pending TODOs" do
    todo_list =
      generate_todos()
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-01], title: "We", status: :done})
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-02], title: "Are", status: nil})
      |> Todoer.add_entry(%Todo{date: ~D[2024-02-02], title: "Done", status: :done})

    assert Todoer.get_active(todo_list) == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4},
             %Todo{date: ~D[2024-02-02], title: "Are", status: nil, id: 6}
           ]
  end

  test "updating an invalid entry returns the original list" do
    todo_list = generate_todos()

    assert Todoer.update_entry(todo_list, 10, &Map.put(&1, :title, "Some other"))
           |> Todoer.entries() == [
             %Todo{date: ~D[2024-01-01], title: "Some", id: 1},
             %Todo{date: ~D[2024-10-01], title: "kind", id: 2},
             %Todo{date: ~D[2024-11-01], title: "of", id: 3},
             %Todo{date: ~D[2024-11-01], title: "blue", id: 4}
           ]
  end
end
