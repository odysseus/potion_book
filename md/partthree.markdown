# Part 3: Advanced Artificing
## Lists and Recursion
#### Recursive Definition of a List
We already discussed how pattern matching can be used to grab successive elements from a list, but this only worked to grab single elements. To properly process a list in a functional way requires us to grab both the head and tail of a list. The Elixir syntax for this involves the join operator, also popularly known as `cons` in other languages, and denoted in Elixir using the `|`, let's look at some examples:

    [ 1 | [] ]

Is a pattern describing a list with a head of `1` and an empty tail. If you enter this into iex you get `[1]`.

Let's try to derive a more complex list from this.

    [ 1 | 2 ]
    >> [ 1 | 2 ]

That didn't work, in fact it appears to have returned the pattern and not a list at all. What's wrong here? The recursive definition of a list is a head of a single, naked element followed by a tail of elements in list form. Let's try putting two in a list.

    [ 1 | [ 2 ] ]
    >> [1, 2]

Boom, that's what we wanted, but how could we add another element to this?  We could use the list syntax, but that would miss the point, we're trying to define this solely as a derivation of heads and tails without resorting to the list literal syntax of `[1, 2, 3]`.

So we want `[1, 2, 3]`, we start with `1` as the head and that is likely to stay the same. So we have this:

    [ 1 | ...

We already know we can add `2` by placing that in a list and making it the tail of `1`:

    [ 1 | [ 2 ...

So if we added `2` as the tail of `1`, we could probably add `3` as the tail of `2`.

    [ 1 | [ 2 | [ 3 ] ] ]
    >> [1, 2, 3]

While this works, let's be a bit pedantic here. We know that a list of a single element can be defined as `[ el | [] ]`, and that the final element of a list is a list of a single element, (or a list with an empty tail, they equivalate out to the same thing). So let's change our previous example to be entirely sematically correct.

    [ 1 | [ 2 | [ 3 | [] ] ] ]

And if you put that into iex it will evaluate to `[1, 2, 3]`

#### Um, alright, but why do I care?
Turns out this head/tail recursive definition is the foundation of so much functional programming, so let's see what we can do with our newfound knowledge and nifty patterns.

    [a, b | t] = [1, 2, 3, 4, 5]
    a
    >> 1
    b
    >> 2
    t
    >> [3, 4, 5]

Neat, so now we can pattern match and assign variables to successive elements at the front of a list, as well as using a catch-all variable that matches the rest of the list. Looking at another example:

    [a, b | t] = [1, 2]

This works. `t` is now an empty list, while `a` and `b` are `1` and `2` as expected. Next let's make this a little more practical and look at Haskell style head/tail processing.

### Processing Lists With Head and Tail
Using these patterns in concert with function definitions is an excellent way to process a list.

    defmodule Listy do
      def len([]), do: 0
      def len([h|t]), do: 1 + len(t)
    end

This is a basic, recursive way to find the length of a list. The base case is the empty list, whose length is zero, and every other case is simply 1 plus the length of the tail. As expected, this works, though we never use the variable `h` so we'll get a warning for that, which we can suppress by replacing `h` with `_h` or (I assume) simply `_`.

Let's look at another example that squares every item in a list.

    defmodule Listy do
      ...
      def square([]), do: []
      def square([ head | tail ]), do: [ head*head | square(tail) ]
    end

This basic pattern can be used to iterate over any list. Applying functions, as we are basically doing here, is generally the job of map, but iterating over items like this is a generally useful pattern. To show that let's look at a function that takes the second to last item from a list.

    defmodule Listy do
      ...
      def second_to_last([ a, _ | [] ]), do: a
      def second_to_last([ _, _ | t ]), do: second_to_last(t)
    end

So when there are two items and an empty tail it returns the first of those two, otherwise it continues to recurse until it finds a list with two items and an empty tail, (in other words, the first pattern matches) and then returns the first of those two.

Now let's look at a basic implementation of map.

    defmodule Listy do
      ...
      def map([], _), do: []
      def map([ head | tail ], fun), do: [ fun.(head) | map(tail, fun) ]
    end

Again, this is the same basic pattern as everything we defined above, but this is much more general because it takes a function as an argument. In fact we could replace `square` with the map definition by defining a simple helper function called `square` and mapping it to every item in the list (an anonymous function also works). In fact, that would be a much cleaner result altogether because you wouldn't expect a function called `square` to operate on an entire list in the first place.

### Accumulator Values
A common functional pattern is to use accumulator patterns to "remember" the results of running calculations. Let's look at a purely recursive function that sums all items in a list:

    def sum([]), do: 0
    def sum([ head | tail ]), do: head + sum(tail)

This works, and follows the recursive pattern we've been using thusfar. However with all purely recursive functions there's a huge growth in memory space because none of the function calls can evaluate until the base case is reached, and then they all evaluate at once. What if, instead, we passed the current sum from call to call, thus removing the need for the evaluation of one call to be dependent on the evaluation of another.

    def sum([], total), do: total
    def sum([ head | tail ], total), do: sum(tail, head+total)

This is still recursive, but it's recursive in a way that a smart, functional compiler/runtime could optimize away. In other words, it's recursion that acts like iteration, running in constant memory space. However calling this is a little uggo. For every call we'd need to pass in an accumulator value of 0, which feels like something the function should be doing by itself. A pattern for doing things like this is to have a private function of the same name that does the work, and a public function that calls the private function with the proper value.

    def tail_sum(list), do: _tail_sum(list, 0)
    defp _tail_sum([], total), do: total
    defp _tail_sum([ head | tail ], total), do: _tail_sum(tail, head+total)

One thing to mention here: The leading underscores in the private functions cause the Erlang interpreter to treat them as separate functions, though to a human observer they are clearly the same function, or at least very closely related.

Let's expand this a bit and create a version of fold. Fold takes the first item of the list and folds it into the other values by applying a function.

    def fold([head | tail], fun), do: _fold(tail, fun, head)
    defp _fold([], _fun, acc), do: acc
    defp _fold([head | tail], fun, acc), do: _fold(tail, fun, fun.(acc, head))

This is a very multipurpose method. It takes any function of two arguments and returns a single value at the end. So the two values can be summed, multiplied, or you can even pass in things like the `max` or `min` functions and the accumulator will serve to hold the smallest or largest value yet seen.
