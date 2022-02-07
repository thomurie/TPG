defmodule TPGTest do
  use ExUnit.Case
  doctest TPG

  test "greets the world" do
    assert TPG.hello() == :world
  end
end
