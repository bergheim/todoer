defmodule TodoerTest do
  use ExUnit.Case
  doctest Todoer

  test "greets the world" do
    assert Todoer.hello() == :world
  end
end
