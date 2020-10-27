defmodule MnogobotTelegramTest do
  use ExUnit.Case
  doctest MnogobotTelegram

  test "greets the world" do
    assert MnogobotTelegram.hello() == :world
  end
end
