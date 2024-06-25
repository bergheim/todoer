defmodule Todo do
  defstruct [:id, :date, :title]
end

defmodule Todoer do
  def hello do
    :world
  end

  defstruct next_id: 1, entries: %{}
  def new(), do: %Todoer{}

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %Todoer{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def entries(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
end
