defmodule ExitDemo do

  ### EXITS ###

  # {:EXIT, #PID<0.53.0>, :normal}
  def normal_implicit_exit do
    Process.flag(:trap_exit, true)
    spawn_link fn() -> :timer.sleep(1000) end
    listen_to_exits
  end


  # {:EXIT, #PID<0.53.0>, :normal}
  def normal_explicit_exit do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      exit :normal
    end
    listen_to_exits
  end

  # {:EXIT, #PID<0.53.0>, :some_exit_reason}
  def abnormal_exit do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      exit :some_exit_reason
    end
    listen_to_exits
  end

  ### ERRORS


  # {:EXIT, #PID<0.56.0>,
  #  {:badarith,
  #   [{ExitDemo, :"-runtime_error/0-fun-0-", 0, [file: '1.exs', line: 42]}]}}
  def runtime_error do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      1 / 0
    end
    listen_to_exits
  end


  # {:EXIT, #PID<0.54.0>,
  #  {:undef,
  #   [{:badarith, :exception, [[]], []},
  #    {ExitDemo, :"-explicit_runtime_error/0-fun-0-", 0,
  #     [file: '1.exs', line: 59]}]}}
  def explicit_runtime_error_erlang_style do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      # in Erlang: erlang:error(:badarith)
      raise :badarith
    end
    listen_to_exits
  end

  # {:EXIT, #PID<0.54.0>,
  #  {%ArithmeticError{},
  #   [{ExitDemo, :"-explicit_runtime_error/0-fun-0-", 0,
  #     [file: '1.exs', line: 71]}]}}
  def explicit_runtime_error do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      raise ArithmeticError
    end
    listen_to_exits
  end

  # {:EXIT, #PID<0.53.0>,
  #  {{:nocatch, 42},
  #   [{ExitDemo, :"-throwing/0-fun-0-", 0, [file: '1.exs', line: 85]}]}}
  def throwing do
    Process.flag(:trap_exit, true)
    spawn_link fn() ->
      :timer.sleep(1000)
      throw 42
    end
    listen_to_exits
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

# ExitDemo.normal_implicit_exit
# ExitDemo.normal_explicit_exit
ExitDemo.abnormal_exit

# ExitDemo.runtime_error
# ExitDemo.explicit_runtime_error_erlang_style
# ExitDemo.explicit_runtime_error

# ExitDemo.throwing

