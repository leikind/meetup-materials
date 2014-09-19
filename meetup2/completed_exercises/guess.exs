defmodule Guess do

  @name  :guess_number_server

  # client API

  def start_link(number) do
    pid = spawn_link(fn -> init(number) end)

    # :global.register_name(:guess_number_server, self() )
    Process.register(pid, @name)
  end

  # server code

  def init(number) do
    IO.inspect "init"
    state = %{
      number:        number,
      call_counter:  0,
      requests_log:  []
    }

    loop(state)
  end


  def loop(state = %{number: number}) do
    IO.inspect "loop"
    receive do

      {sender, :i_am_nsa} ->
        send(sender, state.requests_log)

      {sender, guess} when is_number(guess) ->

        result = cond do
          guess == number -> :winner
          guess < number  -> :less
          true            -> :more
        end

        IO.inspect 123
        send(sender, result)

        request = {sender, number, result}

        state = %{state | call_counter: state.call_counter + 1,  requests_log: [ request | state.requests_log] }


      {sender, _} ->
        send(sender, "我不會說這門語言。")

      _ ->
        IO.puts "Someone sent garbage. Shame on you."

    end

    loop(state)

  end
end

IO.inspect Guess.start_link(42)


defmodule Guesser do
  def guess(n) do
    IO.inspect 1
    # send { :guess_number_server, node() }, {self(), n}
    send  :guess_number_server, {self(), n}
    IO.inspect 2
    receive do

      response ->
        IO.inspect 3
        response
    end

  end

  def spy() do
    send :guess_number_server, {self(), :i_am_nsa}
    receive do
      response -> response
    end

  end
end

IO.inspect Guesser.guess(2)
IO.inspect Guesser.guess(60)
IO.inspect Guesser.guess(4)

IO.inspect Guesser.spy

receive do
  _ -> :ok
end


