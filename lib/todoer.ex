defmodule Todo do
  defstruct [:id, :date, :title, :status]
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

  def done(todo), do: Map.put(todo, :status, :done)

  def get_done(todo_list) do
    Todoer.entries(todo_list)
    |> Enum.filter(fn todo -> todo.status == :done end)
  end

  def get_active(todo_list) do
    Todoer.entries(todo_list)
    |> Enum.filter(fn todo -> todo.status == nil end)
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

defimpl Collectable, for: Todoer do
  def into(original) do
    {original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    Todoer.add_entry(todo_list, entry)
  end

  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(_todo_list, :halt), do: :ok
end

defimpl Enumerable, for: Todoer do
  @impl true
  @spec count(Todoer.t()) :: {:ok, non_neg_integer()}
  def count(%Todoer{entries: entries}) do
    {:ok, map_size(entries)}
  end

  @impl true
  def member?(%Todoer{entries: entries}, item) do
    {:ok, Enum.any?(entries, fn {_id, value} -> value == item end)}
  end

  @impl true
  def slice(_todoer) do
    {:error, __MODULE__}
  end

  @impl true
  def reduce(%Todoer{entries: entries}, acc, fun) do
    enumerable = Map.values(entries)
    do_reduce(enumerable, acc, fun)
  end

  defp do_reduce(_, {:halt, acc}, _fun), do: {:halted, acc}
  defp do_reduce([], {:cont, acc}, _fun), do: {:done, acc}

  defp do_reduce([head | tail], {:cont, acc}, fun) do
    do_reduce(tail, fun.(head, acc), fun)
  end

  defp do_reduce(list, {:suspend, acc}, fun) do
    {:suspended, acc, &do_reduce(list, &1, fun)}
  end
end
