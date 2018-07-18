defmodule RecieveTestTest do
  use ExUnit.Case
  doctest RecieveTest

  test "greets the world" do
    assert RecieveTest.hello() == :world
  end
end
