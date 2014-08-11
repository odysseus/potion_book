# Part 3: Advanced Artificing
## Lists and Recursion
#### Recursive Definition of a List
We already discussed how pattern matching can be used to grab successive elements from a list, but this only worked to grab single elements. To properly process a list in a functional way requires us to grab both the head and tail of a list. The Elixir syntax for this involves the bar `|`, let's look at some examples:

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

    defmodule ListOps do
      def len([]), do: 0
      def len([h|t]), do: 1 + len(t)
    end

This is a basic, recursive way to find the length of a list. The base case is the empty list, whose length is zero, and every other case is simply 1 plus the length of the tail. As expected, this works, though we never use the variable `h` so we'll get a warning for that, which we can suppress by replacing `h` with `_h` or (I assume) simply `_`.
