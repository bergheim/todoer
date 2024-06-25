defmodule TodoerTest do
  use ExUnit.Case
  doctest Todoer

  test "greets the world" do
    assert Todoer.hello() == :world
  end

  test "a new todo list is empty" do
    assert Todoer.new() == %Todoer{}
  end

  test "can add a new entry" do
    todo_list =
      Todoer.new()
      |> Todoer.add_entry(%{date: ~D[2024-01-01], title: "Some"})
      |> Todoer.add_entry(%{date: ~D[2024-10-01], title: "kind"})
      |> Todoer.add_entry(%{date: ~D[2024-11-01], title: "of"})
      |> Todoer.add_entry(%{date: ~D[2024-12-01], title: "blue"})

    assert Todoer.entries(todo_list, ~D[2024-01-01]) == [
             %{
               date: ~D[2024-01-01],
               title: "Some",
               id: 1
             }
           ]
  end
end
