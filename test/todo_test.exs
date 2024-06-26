defmodule TodoTest do
  use ExUnit.Case
  doctest Todo

  def equal_todo?(%Todo{date: date, title: title, status: status}, %Todo{
        date: date2,
        title: title2,
        status: status2
      }) do
    date == date2 and title == title2 and status == status2
  end

  test "can postpone a TODO" do
    todo = Todo.new(%Todo{date: ~D[2024-11-01], title: "of", id: 3})
    # TODO if we set the seed for the rng we should be able to use that as well
    todo = Todo.postpone(todo, 8)

    assert equal_todo?(todo, %Todo{date: ~D[2024-11-09], title: "of"})
  end
end
