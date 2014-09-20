#
# Let's extend our little counter process example!
#
# Your tasks:
#  1) Implement an incrementable counter based on public API described below
#  2) Add a new Counter.dec/1 public function which decrements the counter, make sure your write a test case for it
#  3) A counter must always remain >= 0, make sure an exception is raised otherwise.
#
#     You can raise an exception with:
#
#       raise ArgumentError
#
#     Testing exceptions is straightforward:
#
#        assert_raise SomeException, fn ->
#          ... some code supposed to raise SomeException ...
#        end
#

defmodule Counter do

  @doc "A simple counter showing how to manage state using processes"

  @doc "Creates a new counter, initialized to 0"
  def start do
    spawn_link(fn -> loop(0) end)
  end

  @doc "Increments the given counter by 1"
  def inc(counter) do
    send counter, {self, :inc}
  end

  @doc "Decrements the given counter by 1"
  def dec(counter) do
    send counter, {self, :dec}
  end

  @doc "Returns the current value of the given counter"
  def value(counter) do
    send counter, {self, :val}
    get_value counter
  end

  @doc "Destroy the given counter and return its last value"
  def terminate(counter) do
    send counter, {self, :bye}
    get_value counter
  end

  defp get_value(counter) do
    receive do
      {^counter, :ok, val} ->
        val
    end
  end

  defp loop(counter) do
    receive do
      {_, :inc} ->
        loop(counter + 1)
      {_, :dec} ->
        loop(safe_decrement(counter))
      {sender, :val} ->
        send sender, {self, :ok, counter}
        loop(counter)
      {sender, :bye} ->
        send sender, {self, :ok, counter}
    end
  end

  defp safe_decrement(0),       do: raise(ArgumentError, "Counter cannot get negative")
  defp safe_decrement(counter), do: counter - 1

end

ExUnit.start

defmodule CounterTest do
  use ExUnit.Case

  test "counter starts at 0" do
    c = Counter.start
    assert 0 == Counter.value(c)
  end

  test "counter incrementation" do
    c = Counter.start
    Counter.inc(c)
    Counter.inc(c)
    Counter.inc(c)
    assert 3 == Counter.value(c)
  end

  test "counter decrementation" do
    c = Counter.start
    Counter.inc(c)
    Counter.dec(c)
    Counter.inc(c)
    assert 1 == Counter.value(c)
  end

  test "counter decrementation below zero" do
    c = Counter.start
    assert_raise ArgumentError, fn -> Counter.dec(c) end
  end

  test "multiple counters" do
    c1 = Counter.start
    c2 = Counter.start
    c3 = Counter.start
    Counter.inc(c1)
    Counter.inc(c2)
    Counter.inc(c2)
    assert 1 == Counter.value(c1)
    assert 2 == Counter.value(c2)
    assert 0 == Counter.value(c3)
  end

  test "terminate returns final value of counter" do
    c = Counter.start
    Counter.inc(c)
    assert 1 == Counter.terminate(c)
  end

end
