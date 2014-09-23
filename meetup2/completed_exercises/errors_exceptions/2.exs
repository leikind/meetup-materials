
defmodule WeAllDie do

  def run do
    IO.write "parent: "
    IO.inspect self

    Process.flag(:trap_exit, true)
    pid1 = spawn_link fn() ->
      :timer.sleep(1000)

      pid2 = spawn_link fn() ->
        :timer.sleep(1000)

        pid3 = spawn_link fn() ->
          :timer.sleep(1000)
          IO.write "I, "
          IO.inspect self
          IO.puts "will die now "

          # exit :some_exit_reason
          raise ArithmeticError
        end

        IO.write "pid3: "
        IO.inspect pid3


        :timer.sleep(7000)
      end

      IO.write "pid2: "
      IO.inspect pid2


      :timer.sleep(7000)
    end

    IO.write "pid1: "
    IO.inspect pid1

    listen_to_exits

  end


  def run2 do
    IO.write "parent: "
    IO.inspect self


    pid1 = spawn_link fn() ->
      :timer.sleep(1000)

      pid2 = spawn_link fn() ->
        :timer.sleep(1000)

        pid3 = spawn_link fn() ->
          :timer.sleep(1000)
          IO.write "I, "
          IO.inspect self
          IO.puts "will die now "

          exit :some_exit_reason
        end

        IO.write "pid3: "
        IO.inspect pid3


        :timer.sleep(7000)
      end

      IO.write "pid2: "
      IO.inspect pid2


      :timer.sleep(7000)
    end

    IO.write "pid1: "
    IO.inspect pid1


    pid_n = spawn_link fn() ->
      Process.flag(:trap_exit, true)
      listen_to_exits
    end

    IO.write "pid_n: "
    IO.inspect pid_n

    :timer.sleep(10000)

  end


  defp listen_to_exits do
    receive do
      something ->
        IO.puts "<caught message>"
        IO.inspect something
        IO.puts "</caught message>"
    after
      7000 -> :ok
    end
  end


end

WeAllDie.run
