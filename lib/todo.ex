defmodule Todoer.Todo do
  use GenServer
  require Logger

  defstruct [:id, :date, :title, :status, :pid]

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  def start_link(initial_todo \\ %__MODULE__{}, id) do
    GenServer.start_link(__MODULE__, initial_todo, name: {:via, Registry, {Todoer.Registry, id}})
  end

  def new(%__MODULE__{} = entry \\ %__MODULE__{}) do
    unique_id = :erlang.unique_integer([:positive, :monotonic])
    unique_name = {:via, Registry, {Todoer.Registry, {:todo, unique_id}}}

    # Logger.info("Creating __MODULE__ with unique id: #{unique_id}")
    {:ok, pid} = start_link(entry, unique_name)

    %__MODULE__{
      pid: pid,
      id: unique_id,
      date: entry.date,
      title: entry.title,
      status: Map.get(entry, :status, nil)
    }
  end

  def postpone(%__MODULE__{} = todo, days \\ Enum.random(1..10)) do
    state = GenServer.call(todo.pid, {:postpone, days})
    %__MODULE__{todo | date: state.date}
  end

  # TODO what about update??
  def update(todo, updater) do
    GenServer.call(todo.pid, {:update, updater})
  end

  @impl true
  def handle_call({:postpone, days}, _from, %__MODULE__{} = state) do
    date = Date.add(state.date, days)
    todo = %__MODULE__{state | date: date}
    {:reply, todo, todo}
  end

  @impl true
  def handle_call(:done, _from, state) do
    new_state = Map.put(state, :status, :done)
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call({:update, updater}, _from, state) do
    new_entry = updater.(state)
    new_state = Map.merge(state, new_entry)
    {:reply, new_state, new_state}
  end
end
