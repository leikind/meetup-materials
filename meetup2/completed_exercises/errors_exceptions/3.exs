
ExUnit.start

defmodule SomeTest do
  use ExUnit.Case

  test "how do I test exits" do

    Process.flag(:trap_exit, true)

    pid = spawn_link fn() ->
      :timer.sleep(100)
      exit :some_exit_reason
    end


    assert_receive {:EXIT, ^pid, :some_exit_reason}, 20_000

  end

end
