defmodule Todo do
  defstruct [:id, :date, :title]
end

defmodule Todoer do
  def hello do
    :world
  end

  defstruct next_id: 1, entries: %{}

  def new(), do: %Todoer{}

  def new(entries) do
    Enum.reduce(entries, %Todoer{}, fn entry, acc ->
      add_entry(acc, entry)
    end)
  end

  def add_entry(todo_list, entry) do
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(todo_list.entries, todo_list.next_id, entry)

    %Todoer{todo_list | entries: new_entries, next_id: todo_list.next_id + 1}
  end

  def update_entry(todo_list, entry) do
    updated_entries =
      Map.update(todo_list.entries, entry.id, todo_list.entries, fn e ->
        Map.merge(e, entry, fn _key, v1, v2 -> if v2 == nil, do: v1, else: v2 end)
      end)

    %{todo_list | entries: updated_entries}
  end

  def update_entry(todo_list, todo_id, updater) do
    case Map.fetch(todo_list.entries, todo_id) do
      :error ->
        todo_list

      {:ok, old_entry} ->
        new_entry = updater.(old_entry)
        updated_entries = Map.put(todo_list.entries, todo_id, new_entry)
        %{todo_list | entries: updated_entries}
    end
  end

  def entries(todo_list, date \\ nil) do
    entries = Map.values(todo_list.entries)

    case date do
      nil -> entries
      _ -> Enum.filter(entries, fn entry -> entry.date == date end)
    end
  end

  def get_for_date(todo_list, date) do
    todo_list.entries
    |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end
end

defimpl String.Chars, for: Todoer do
  def to_string(todo_list) do
    Enum.map(Todoer.entries(todo_list), fn entry ->
      String.Chars.to_string(entry) <> "\n"
    end)
  end
end

defimpl String.Chars, for: Todo do
  def to_string(todo) do
    Date.to_string(todo.date) <> ": " <> todo.title
  end
end
