defmodule CargoCraneTest do
  use ExUnit.Case
  doctest CargoCrane

  test "greets the world" do
    assert CargoCrane.hello() == :world
  end
end
