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

  test "greets the world" do
    assert Todoer.hello() == :world
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
end
