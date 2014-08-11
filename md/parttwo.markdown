# Intermediate Alchemy
## Anonymous Functions
#### Defining
The basic form:

    fn params -> body end

Or a slightly more complicated one

    fn
      params -> body
      params -> body
    end

As you can see you have different matches in the same function body. All of these matches must have the same arity, however.

#### Calling
Calling an anonymous function requires two bits of syntax.

    square = fn (x) -> x * x end
    square.(2)
    >> 4

    five = fn -> 5 end
    five.()
    >> 5

First, the name the function is bound to followed by a dot, then parentheses containing the arguments. Unlike named functions the parens are not optional, an anonymous function with no arguments still requires an empty set of parens at the end.

As seen above, though, you can omit the parens in the definition when a fn takes no arguments, and you can even omit them when it does.

    sum = fn a, b -> a + b end
    sum.(4, 2)
    >> 6

#### Pattern Matching
It's important to reiterate that what's actually happening when you define and call a function is an extension of the pattern matching used elsewhere. When you pass in arguments it matches them to one of the defined patterns then binds the variable names from that pattern to their respective pairs in the arguments.

    foil = fn
      {1, a}, {b, c} -> "#{b} + #{c} + #{a}*#{b} + #{a}*#{c}"
      {a, b}, {1, c} -> "#{a} + #{a}*#{c} + #{b} + #{b}*#{c}"
      {a, b}, {c, d} -> "#{a}*#{c} + #{a}*#{d} + #{b}*#{c} + #{b}*#{d}"
    end

Another, more practical example of pattern matching in functions

    handle_open = fn
      {:ok, file} -> "Read data: #{IO.read(file, :line)}"
      {_, error} -> "Error: #{:file.format_error(error)}"
    end

Finally, another example/exercise from the book using the venerable FizzBuzz. Write a function that returns "FizzBuzz" if the first two arguments are zero, "Fizz" if only the first is, "Buzz" if only the second is, and the third argument for all other cases.

    fizzbuzz = fn
      {0, 0, _} -> "FizzBuzz"
      {0, _, _} -> "Fizz"
      {_, 0, _} -> "Buzz"
      {_, _, a} -> a
    end

Now, another function that decomposes an integer into values that can be read by this first function:

    fizzbuzzifier = fn
      n -> {rem(n,3), rem(n,5), n}
    end

#### Returning Functions
Not surprisingly functions can return functions. Here's a few examples of that.

    hifn = fn -> fn -> "Hello" end end

This is a little easier to read when expanded

    hifn =
     fn ->
       fn ->
         "Hello"
       end
     end

So the function call will return another function which, when called, will return hello. Let's test that:

    hifn.().()
    >> "Hello"

#### Closures
Functions remember their outer environment. Take this example:

    greeter = fn name -> fn -> "Hello, #{name}" end end
    doug_greeter = greeter.("Doug")
    doug_greeter.()
    >> "Hello, Doug"

Take note of what's happening here. This does not return a partially evaluated function, it returns a function of zero arguments that has closed over a variable in an outer scope. When we call `greeter` we pass it the `name` variable, which only exists in the `greeter` function itself, it is not explicitly passed to the function returned by it so it should be out of scope when the returned function is called. Yet we call the returned function and the substitution takes place.

#### Passing as Arguments
As expected this totally works.

    square = fn n -> n * n end
    apply = fn fun, n -> fun.(n) end
    apply.(square, 4)
    >> 16

#### Shortenizing them
Because anonymous functions, and passing functions as arguments, and especially passing anonymous functions as arguments are such big parts of functional programming there is a special shorthand syntax for writing them.

    square = &(&1 * &1)

`&()` defines an anonymous function, within the parentheses the `&1`, `&2`, and so on stand for the first and second argument, respectively.

There's an even shorter form of this when you need to convert a named function call to an anonymous function. (I don't fully understand why some of these need this and some don't, I think it has to do with variadic functions, you need to specify an arity of the function to be called.) Anyway, there's a shorter form in that situation:

    l = &length/1
    len = &Enum.count/1

The form here is `&function/{arity}` and this is equivalent to `&Enum.count(&1)`. This is a good, shorthand way to pass functions to other functions.

## Modules and Named Functions
Thusfar all of our functions have been anonymous. Mysterious drifters wandering through the land of Elixir transforming data and riding off into the sunset. Time to meet their more respectable, but less hot cousins: named functions.

    defmodule Times do
      def two(n) do
        n * 2
      end
    end

Named functions are declared inside a module. Here we define a module called `Times` that multiplies numbers by a fixed constant, and single named function `two` that multiplies it by two.

This function is assigned the internal name `Times.two/1` confirming my earlier suspicion about function dispatch needing both a name and an arity. Going off book here, but this leads me to another suspicion: Operator overloading. Check this out:

    defmodule Times do
      def two(n) do
        n * 2
      end
      def two(a, b) do
        (a + b) * 2
      end
    end

This works, both functions can exist in the same namespace with the same name without being the same function, because as we saw they actually aren't as far as Elixir is concerned. That said, assigning the same name to two functions in the same namespace that don't do essentially the same thing is just a bad idea and serves only to confuse, so don't do that.

The `do end` block is actually a macro (I think) that converts the statements to the internal form which uses a sequence of `do:` statements.

    def double(n), do: n * 2

Or with multiline functions:

    def greet(greeting, name), do: (
      IO.puts greeting
      IO.puts "How are you doing #{name}"
    )

Obviously the form works much better with single line functions. Though for my money it seems like the conceptually cleaner thing to do is use `do end` for everything. Anonymous functions, even single-line anonymous functions, are defined using `do end` so why clutter the conceptual namespace with another way to do this.

### Back in Pat
Anyway, back to patterns. There's a bit of a distinction here between writing functions of the same name and same arity versus the same name and different arity.  As far as the computer is concerned, different arities are different functions, even if the names *happen* to be identical. With the same arity, however, multiple definitions are considered to be different clauses in the same definition. All of those patterns comprise the definition of a *single* function, in other words. Let's look at a pattern matching example with factorials

    defmodule Factorial do
      def of(0), do: 1
      def of(n), do: n * of(n-1)
    end

Boom, recursive factorial, four lines.  It's very Haskellian/MLericious. One pattern defines the base case, and another pattern recursively reduces the problem to something that will, at some point, reach the base case. Always worth remembering that the clauses will be read in the order that they appear. If you define the base case, or a specific match, below a wildcard clause then it will never be reached, and in a naive system would recurse infinitely. Elixir can identify clauses that can never be reached and will give you a warning about this, though as with most safeguards it's best not to rely on them, a little reasoning goes a long way.

Finally, all patterns of the same function should be adjacent to each other in the source file. Once again, Elixir will give you a warning if they are not. I'm guessing that this warning comes up more in the situation that you accidentally define two functions with the same name and arity, thus making them patterns for one another, without realizing it and having them separate in the source file.

### Guards! Guards!
Guard clauses are a conditional extension to pattern matching. In a normal pattern the first pattern to match is executed. With a guard clause the pattern is extended to require the predicate to return true. So the first matching pattern with the first true predicate will be the one to execute.

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

While trivial in function, this is an excellent example of this. Every pattern matches based on an arity of one argument, but with the guard clause only one will actually execute because only one would be true. Or all of them would be false because I'm sure there's more than three types in Elixir, but these are examples and the world is neat and clean.

We could improve our previous factorial example by including a guard clause that checks to ensure the number is greater than zero, to prevent negative numbers from causing an infinite loop.

There are a limited number of things that can appear in a guard clause:

- Comparison operators
- Boolean operators
- Arithmetic operators
- Join operators
- The `in` (membership) operator
- Type check functions
- A predefined list of built-in functions that can be found in the docs.

By in large it seems that most of what you would want from a guard clause works by default. Rather than worry overmuch about what works, just be aware that some things don't and if you ever run into something that doesn't take a different approach.

### Default Parameters
Can be created in the function definition using the `\\` syntax:

    defmodule DefParams do
      def func(p1, p2 \\ 2, p3 \\ 3, p4) do
        IO.inspect [p1, p2, p3, p4]
      end
    end

Pattern matching with default params looks at the number of *requires* parameters to see if you passed enough arguments to meet that. If not then it's obviously an error, but if you at least the minimum then it begins to fill in the arguments left to right, while ensuring that all non-optional params have an argument. Logically it seems like you should really just have optional params at the end, then the arguments get filled in very logically left to right, but it's not a requirement of the language to do so, so even if you don't write methods this way it will still work.

One caveat of pattern matching is that it creates odd behavior when defining functions of different arity, because the default params version will match multiple arities. Using the example above, if you defined another function that took two arguments, it would be impossible for Elixir to know whether you wanted to call the two argument function with two arguments, or the four argument function with two arguments and the two defaults. Fortunately, Elixir analyzes this kind of thing and gives you a warning if the two functions are in danger of conflicting.

Another problem with default params comes about when defining multiple clauses of the same function along with default values.

    defmodule BadPat do
      def fun(p1 \\ :ok, p2, p3) do
        IO.puts "All good"
      end
      def fun(:error, p2, p3) do
        IO.puts "Halt and catch fire"
      end
    end

The problem here is that we have multiple clauses and a default value for the first argument. The default value in itself is a suggestion that, most of the time, we expect the first argument to return `:ok`. Note that the same thing would likely be matched by the pattern `(:ok, p2, p3)` so we're conflating two similar ideas in a somewhat confusing way. To avoid this ambiguity, default params with multiple clauses (clausi?) are instead declared with an empty function header up top containing the default values, followed by the pattern matches as usual.

    defmodule BadPat do
      def fun(p1 \\ :ok, p2, p3)
      def fun(:ok, p2, p3) do
        IO.puts "All is well"
      end
      def fun(:bad, p2, p3) do
        IO.puts "Panic and freak out"
      end
    end

This voids the ambiguity of combining default values with a specific pattern. At top we see the default params for each argument, and below we see patterns that match those default params. Precisely what we were going for in a bit of a cleaner way.

As a final example, an exercise from the book using most everything we've looked at thusfar. This takes a number and a range and repeatedly splits the range to guess the number. If no range is supplied it defaults to the numbers from 1 to 1,000.

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

### Private Functions
`defp` is a macro that defines a private function that can only be called within the module that defines it.

### Piping Hot
Alright, now the bit that I can honestly and a little bit ashamedly admit I have been awaiting anxiously. This thing `|>`

Take a code example that curries a bunch of values to get a result. Something like this:

    filing = prepare_filing(sales_tax(Orders.for_customers(DB.find_customers), 2013))

Hideous. No redeeming qualities. Not even a mother could love this code. For the sake of readability we could refactor this to:

    people = DB.find_customers
    orders = Orders.for_customers(people)
    tax = sales_tax(orders, 2013)
    filing = prepare_filing(tax)

But this still isn't great, it creates a lot of intermediate variables. Wouldn't it be terrific if you could somehow just pipe the results of the previous functions to the next one the way Unix does it?

    filing = DB.find_customers
                |> Orders.for_customers
                |> sales_tax(2013)
                |> prepare_filing

This takes the result of the expression on the left and inserts it as the first parameter value of the next function call. Basically the same as the thread first macro in Clojure, but somehow more elegant.

Always use parentheses when using the pipe operator otherwise the parser can have trouble parsing.

## Modules
We've already seen modules encapsulating named functions but they work for encapsulating all kinds of things, including other modules. Modception.

    defmodule Outer do
      defmodule Inner do
        def innerfn do
          IO.puts "He(Hello)llo"
        end
      end
      def outerfn do
        IO.puts "Hello"
      end
    end

    Outer.Inner.innerfn
    Outer.outerfn

As seen above, these can be called by using their fully qualified names. "What other connections does that give us!?" You ask with feverish excitement. Actually none, in fact, there are fewer connections here than you already thought, so basically negative one.

While handy for organizing code, module nesting is actually a clever illusion. There is no relationship between "nested" classes other than the superficial similarity of their names. Elixir compiles all your nested modules into modules with "nested" names. In other words, Inner is defined at the top level with the module name `Outer.Inner`. It is a standalone module in all respects.

Similarly, you can create "nested" modules directly by defining modules with names like `One.Two.Three`, without the modules `One` or `Two` even existing. Knowing that the "nested" modules are simply a naming convention allows you to leverage the conceptual clarity of nested names without needing a mess of nested source files. It allows you to organize code into categories using modules that may not even exist.

### Directives
Elixir has three directives that make working with modules easier. All of these are executed at runtime and are lexically scoped. In other words they are evaluated at the line that they are encountered in code, and available thereafter only in that enclosing scope.

#### Import
`import` imports the functions and macros of a module into the current scope. This is obviously handy for cutting down on typing a code clutter that comes from typing a module name over and over again.

    defmodule Example do
      def func1 do
        List.flatten [1, [2, 3], 4]
      end
      def func2 do
        import List, only: [flatten: 1]
        flatten [5, [6, 7], 8, 9]
      end
    end

In the example above `flatten` is imported only for `func2` and only `flatten` is imported. If we added a `func3` after that and attempted to use flatten it would raise an error as flatten would be out of scope by that point.

The full syntax of the statement is:

    import Module [, only:|except: ]

With `only` or `except` allowing you to specifically include/exclude certain functions. These are then followed by a list of `functionname: arity` pairs.

As a general rule, don't abuse the power of `import`. Import as little as you need to for as short a period as you can. Obviously this is a judgment call but it's best to keep the namespace clean wherever possible. In situations where you need a lot of imported functions, `alias` might be a better option.

#### Alias
Alias simply shortens a module name into whatever you specify:

    defmodule Example do
      alias Mix.Tasks.Doctest as: Doctest
      ...
    end

Alias actually has an intelligent default which aliases to the last name in a nested module when it isn't passed an argument. So we could have written `alias Mix.Tasks.Doctest` and it would have been aliased to `Doctest` anyway. Aside from that, the only apparent requirement of alias is that the aliased name begin with a capital letter, and a single capital letter seems to work. Super short names like that are idiomatic in Clojure, but they don't appear to be so in this. Based on the idiomatic code samples we've seen thusfar I get the sense that Erlang might have a more cluttered namespace than other languages.

#### Require
`require` is needed when you want to use the macros defined in that module. It ensures that the module is loaded before your code tries to use any of its macros. Will be discusses later when the book gets to the macro section.

### Module Attributes
Modules can have metadata, called *attributes* of the module. Each attribute is preceded by an `@` sign and assigned and accessed using this same form.

    defmodule Meta do
      @author "Dave Thomas"

      def get_author, do: @author

    end

You can re-bind the value multiple times during the module definition, and when it is called from a function you will get the value that is in effect at that point in the module. While these resemble class variables from Ruby they really aren't variables in the traditional sense. Attributes are more like constants. Constants that can be reassigned in a predictable way.

### Naming Conventions
Modules in Elixir are CamelCase and the functions are called via dot notation. If we inspect the value of an Elixir module, say the `IO` module, we would see that it is an atom with a name like `:"Elixir.IO"`, and in fact if you added a dot to the end of that you could call functions off of it.

Erlang, in comparison, uses uppercase names for variables and lowercase names for atoms. So the Erlang module `timer` is just called `timer` and is referred to by the atom `:timer`, so functions from Erlang are called using `:erlangmodule.function`
