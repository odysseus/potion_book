# Lists and Recursion

defmodule ListOps do
  def len([]), do: 0
  def len([_h|t]), do: 1 + len(t)
  def square([]), do: []
  def square([ head | tail ]), do: [ head*head | square(tail) ]
end

l = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
IO.puts ListOps.square l
