defmodule Times do
  def two(x), do: x * 2
  def two(x, y) do (x + y) * 2 end
  def quadruple(x), do: two(two(x))
end

defmodule Factorial do
  def of(0), do: 1
  def of(n), do: n * of(n-1)
end

defmodule Guard do
  def what_is(x) when is_number(x) do
    IO.puts "That's a number"
  end
  def what_is(x) when is_list(x) do
    IO.puts "It's a list"
  end
  def what_is(x) when is_atom(x) do
    IO.puts "Ooh look, an atom!"
  end
end

defmodule BadPat do
  def fun(p1 \\ :ok, p2, p3)
  def fun(:ok, _p2, _p3) do
    IO.puts "All is well"
  end
  def fun(:bad, _p2, _p3) do
    IO.puts "Panic and freak out"
  end
end

defmodule Chop do
  def midrange(range) do
    min..max = range
    rng = max - min
    div(rng, 2) + min
  end
  def guess(actual, range \\ 1..1000) do
    guess = midrange(range)
    guess(actual, range, guess)
  end
  def guess(actual, range, guess) when (guess > actual) do
    newrange = Enum.min(range)..guess
    newguess = midrange(newrange)
    IO.puts "Is it #{guess}?"
    guess(actual, newrange, newguess)
  end
  def guess(actual, range, guess) when (guess < actual) do
    newrange = guess..Enum.max(range)
    newguess = midrange(newrange)
    IO.puts "Is it #{guess}?"
    guess(actual, newrange, newguess)
  end
  def guess(actual, _range, guess) when (guess == actual) do
    IO.puts "Actual: #{actual} / Guess: #{guess}"
  end
end

defmodule Meta do
  @author "Dave Thomas"
  def author, do: @author
end

IO.puts Meta.author
