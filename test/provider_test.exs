defmodule ProviderTest do
  use ExUnit.Case
  doctest Provider

  test "greets the world" do
    assert Provider.hello() == :world
  end
end
