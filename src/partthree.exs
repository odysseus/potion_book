# Lists and Recursion

defmodule Listy do
  def len([ _ | [] ]), do: 1
  def len([ _ | t ]), do: 1 + len(t)

  def second_to_last([ a, _ | [] ]), do: a
  def second_to_last([ _, _ | t ]), do: second_to_last(t)

  def map([], _), do: []
  def map([ head | tail ], fun), do: [ fun.(head) | map(tail, fun) ]

  def sum([]), do: 0
  def sum([ head | tail ]), do: head + sum(tail)

  def product([]), do: 1
  def product([ head | tail ]), do: head * product(tail)

  def tail_sum(list), do: _tail_sum(list, 0)
  defp _tail_sum([], total), do: total
  defp _tail_sum([ head | tail ], total), do: _tail_sum(tail, head+total)

  def fold([head | tail], fun), do: _fold(tail, fun, head)
  defp _fold([], _fun, acc), do: acc
  defp _fold([head | tail], fun, acc), do: _fold(tail, fun, fun.(acc, head))
end

l = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
IO.inspect Listy.fold(l, &max/2)
