#
# Write a parallel map function which, given an enumerable and a function,
# will apply the function to all items *concurrently* and return a list with
# the results of the transformation.
#

defmodule Parallel do

  def map(enumerable, func) do
    enumerable
      |> spawn_mapping_processes(func)
      |> collect_results
  end

  defp spawn_mapping_processes(enumerable, func) do
    parent_pid = self
    Enum.map enumerable, fn (item) ->
      spawn_link(fn ->
        send parent_pid, {self, func.(item)}
      end)
    end
  end

  defp collect_results(pids) do
    Enum.map pids, fn (pid) ->
      receive do
        {^pid, mapped_item} -> mapped_item
      end
    end
  end

end



ExUnit.start

defmodule ParallelTest do
   use ExUnit.Case

  test "it maps empty enumerables" do
    assert [] == Parallel.map([], fn (x) -> x*x end)
  end

  test "it maps enumerables" do
    assert [0, 1, 4, 9, 16] == Parallel.map([0, 1, 2, 3, 4], fn (x) -> x*x end)
  end

  test "it maps large enumerables" do
    assert [0, 1, 4, 9, 16, 25, 36|_] = Parallel.map(0..99999, fn (x) -> x*x end)
  end

end