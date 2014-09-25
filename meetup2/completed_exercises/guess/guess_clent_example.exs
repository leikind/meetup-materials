# elixir --cookie devspace --name client  guess_clent_example.exs

defmodule GuessClientExample do

  @remote_node      :'guess@192.168.1.37'
  @remote_pid_name  :guess_number_server

  @my_name  "Yuri"

  @initial_step 100

  def guess(initial_number) do
    case request_response(initial_number) do
      :correct              -> won(initial_number)
      {:too_late, message}  -> lost(message)
      more_or_less          -> guess(more_or_less, initial_number, @initial_step)
    end
  end

  defp guess(:your_guess_is_less_than_the_number, than, step) do
    number = than + step
    case request_response(number) do
      :correct                             -> won(number)
      {:too_late, message}                 -> lost(message)
      :your_guess_is_less_than_the_number  -> guess(:your_guess_is_less_than_the_number, number,  step)
      :your_guess_is_more_than_the_number  -> guess(:your_guess_is_more_than_the_number, number, div(step, 2))
    end
  end

  defp guess(:your_guess_is_more_than_the_number, than, step) do
    number = than - step
    case request_response(number) do
      :correct                             -> won(number)
      {:too_late, message}                 -> lost(message)
      :your_guess_is_less_than_the_number  -> guess(:your_guess_is_less_than_the_number, number, div(step, 2))
      :your_guess_is_more_than_the_number  -> guess(:your_guess_is_more_than_the_number, number, step)
    end
  end

  defp won(number), do: IO.puts "I have won: #{number}"

  defp lost(message), do: IO.puts message


  defp request_response(number) do
    send {@remote_pid_name, @remote_node}, {self, @my_name, number}
    IO.write  "#{number} -> "
    receive do
      response ->
        IO.inspect response
        response
    end
  end
end

GuessClientExample.guess(2)
