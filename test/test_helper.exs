ExUnit.start()

defmodule TodoerTestHelper do
  alias Todoer.TodoList

  defp strip_dynamic_fields(%Todo{date: date, title: title, status: status}) do
    %Todo{date: date, title: title, status: status}
  end

  def equal_todoers?(todos1, todos2) when is_list(todos1) and is_list(todos2) do
    stripped_todos1 = Enum.map(todos1, &strip_dynamic_fields/1)
    stripped_todos2 = Enum.map(todos2, &strip_dynamic_fields/1)

    stripped_todos1 == stripped_todos2
  end

  def equal_todoers?(
        %TodoList{entries: entries1, next_id: next_id1},
        %TodoList{entries: entries2, next_id: next_id2}
      ) do
    equal_todoers?(
      Map.values(entries1),
      Map.values(entries2)
    ) and
      next_id1 == next_id2
  end

  def equal_todoers?(
        %Todo{date: date, title: title, status: status},
        %Todo{date: date2, title: title2, status: status2}
      ) do
    date == date2 and title == title2 and status == status2
  end
end
