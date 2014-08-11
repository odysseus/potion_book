IO.puts "Hello, world!"

f = fn
  (1, b) -> b * 2
  (2, b) -> b * 3
end

IO.puts f.(1, 3)
IO.puts f.(2, 3)

foil = fn
  {1, b}, {c, d} -> "#{c} + #{d} + #{b}*#{c} + #{b}*#{d}"
  {a, b}, {1, d} -> "#{a} + #{a}*#{d} + #{b} + #{b}*#{d}"
  {a, b}, {c, d} -> "#{a}*#{c} + #{a}*#{d} + #{b}*#{c} + #{b}*#{d}"
end

handle_open = fn
  {:ok, file} -> "Read data: #{IO.read(file, :line)}"
  {_, error} -> "Error: #{:file.format_error(error)}"
end

fizzbuzz = fn
  {0, 0, _} -> "FizzBuzz"
  {0, _, _} -> "Fizz"
  {_, 0, _} -> "Buzz"
  {_, _, a} -> a
end

fizzbuzzerizer = fn
  n -> {rem(n,3), rem(n,5), n}
end

fizzbuzzify = fn
  rng -> Enum.each rng, &(IO.puts fizzbuzz.(fizzbuzzerizer.(&1)))
end

hifn =
 fn ->
   fn ->
     "Hello"
   end
 end

greeter = fn name -> fn -> "Hello, #{name}" end end

square = fn n -> n * n end
apply = fn fun, n -> fun.(n) end

IO.puts foil.({1, 2}, {3, 4})
IO.puts handle_open.(File.open("test"))
IO.puts handle_open.(File.open("nonexistent"))
IO.puts hifn.().()
doug_greeter = greeter.("Doug")
IO.puts doug_greeter.()
IO.puts apply.(square, 4)
fizzbuzzify.(1..25)
