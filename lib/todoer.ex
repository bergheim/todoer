defmodule Todo do
  defstruct [:id, :date, :title, :status]
end

# TODO should this be moved to application.ex or todoer_app.. or todoer/app..?
defmodule Todoer.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: Todoer.Registry},
      {Todoer, []}
    ]

    opts = [strategy: :one_for_one, name: Todoer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Todoer do
  use GenServer
  require Logger
  alias Todoer.CsvHelper
  defstruct next_id: 1, entries: %{}, pid: nil

  # GenServer setup
  def start_link(initial_entries \\ %Todoer{}, name) do
    GenServer.start_link(__MODULE__, initial_entries,
      name: {:via, Registry, {Todoer.Registry, name}}
    )
  end

  def add_entry(todo_list, entry) do
    updated_entries = GenServer.call(todo_list.pid, {:add_entry, entry})
    %Todoer{todo_list | entries: updated_entries, next_id: map_size(updated_entries) + 1}
  end

  def list_entries(pid) do
    GenServer.call(pid, :list_entries)
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  @impl true
  def handle_call(:list_entries, _from, state), do: {:reply, state.entries, state}

  @impl true
  def handle_call({:add_entry, entry}, _from, state) do
    entry = Map.put(entry, :id, state.next_id)
    new_entries = Map.put(state.entries, state.next_id, entry)
    new_state = %Todoer{state | entries: new_entries, next_id: state.next_id + 1}

    {:reply, new_state.entries, new_state}
  end

  def start() do
    todo_list = CsvHelper.import("todos.csv")
    IO.puts(todo_list)
  end

  def new() do
    unique_id = :erlang.unique_integer([:positive, :monotonic])
    unique_name = {:via, Registry, {Neowellwise.Registry, {:todoer, unique_id}}}
    # Logger.info("Creating Todoer with unique id: #{unique_id}")

    {:ok, pid} = start_link(%Todoer{}, unique_name)
    %Todoer{pid: pid}
  end

  def new(entries) do
    todo_list = Todoer.new()

    todo_list =
      Enum.reduce(entries, %Todoer{pid: todo_list.pid, next_id: 1, entries: %Todo{}}, fn entry,
                                                                                         acc ->
        add_entry(acc, entry)
      end)

    %Todoer{entries: todo_list.entries, pid: todo_list.pid, next_id: todo_list.next_id + 1}
  end

  def update_entry(todo_list, entry) do
    updated_entries =
      Map.update(todo_list.entries, entry.id, todo_list.entries, fn e ->
        # if the new entry does not have a key (ie it is nil), keep the existing one
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

  def remove(todo_list, id) when is_integer(id) do
    todo_list.entries
    |> Map.delete(id)
    |> Map.values()
  end

  def remove(todo_list, %Todo{} = todo) do
    remove(todo_list, todo.id)
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

  def postpone(todo, days \\ Enum.random(1..10)) do
    date = Date.add(todo.date, days)
    %Todo{todo | date: date}
  end
end

defimpl String.Chars, for: Todoer do
  def to_string(todo_list) do
    Todoer.entries(todo_list)
    |> Enum.map(fn entry -> String.Chars.to_string(entry) end)
    |> Enum.join("\n")
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
