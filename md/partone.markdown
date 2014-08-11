# Introduction to Potions
### Basic Matching
Starting with the simplest program

    IO.puts "Hello, world"

Now on to the second simplest program, and already we have something different:

    a = 1
    >> 1

This seems the same, though. What has changed? In fact what's happening here isn't assignment (completely), it's a "match". To explain what that means:

    1 = a
    >> 1
    2 = a
    >> (MatchError)

What's actually happening during assignment is pattern matching. `a` is assigned to nothing in the first call so it matches anything, and is set equal to the rhs of the statement.

After that, when we type `1 = a` the pattern again matches because a *does* equal 1. So again we get the return value of 1. Finally we give it `2 = a` which does *not* match and we get a `MatchError` from that.

You might also assume that a would *become* 2 in order to make the match work, but on the rhs of an equals sign all variables are treated as their values, so what we're really saying is `2 = 1`, which is false, and gets an error because it's unexpected. However, if we put:

    a = 2

That works. Bare atoms always match what's on the rhs of an equals.

### Intermediate Matching
First let's make a list

    l = [1, 2, 3, 4]

Beautiful, what a clean and concise list.  What we have is a one dimensional list of four single elements.  Let's match on that pattern:

    [a, b, c, d] = l
    >> [1, 2, 3, 4]

The return there is simply the original list, but other stuff has gone on under the surface.

    a
    >> 1
    b
    >> 2
    c
    >> 3
    d
    >> 4

That's cool, what else can we do with this:

    [x, y, z, 4] = l

Matches on the first three elements and the literal `4 = 4` match for the fourth. This works as above and now `x` `y` and `z` are bound to variables. Wouldn't it be nice if we could match on some kind of wildcard pattern rather than a literal number/item in a list...

### Matching With Wildcard Patterns
You totally can!

    [t, v, _, _] = l

As an interesting aside, a variable can only be used once in a match. if you tried to do something like:

    [a, a] = [1, 2]

You'd get an error. Granted, `[a, a] = [1, 1]` *would* actually work for the reasons listed above.

Finally, suppose you want a variable on the lhs to match based on it's current value and not as a catch-all that will be reassigned by the rhs (assuming the pattern matches), you need to preface that with a caret.

    # We want a to match here, not be reassigned
    a = 1
    [1, a, 3] = [1, 2, 3]
    # Matching normally fails
    a
    >> 2

    a = 1
    [1, ^a, 3] = [1, 2, 3]
    >> MatchError
    ^a = 1
    >> 1

## Immutability
Per the functional focus all values in Elixir are immutable.  Dave Thomas makes the point in this book that programming is about transforming data, in that sense the functional mindset fits in nicely. When you pass data into a function you are transforming it into something new, not altering the inherent value that was passed in. Obviously many languages do alter values in place, but it doesn't change the concept.

Like Clojure, and most, if not all, functional languages there is a gap between concept and implementation here. When primitive values are transformed they are copied outright as their new values. This makes sense, as atomic values there's really no way to do this more intelligently. With collections of data, however, things are different.

Because a list is immutable you can make strong guarantees about constructing a structure from other structures. A list with a single item added is simply the original list plus one item, there's no need to copy every single item in the list to achieve immutability. In fact, it's immutability ensures that intelligent things like this can work in the first place.

### Garbage Collection
Elixir's approach to garbage collection is unique and stems directly from the Actor model that underpins the whole language. Elixir programs are composed of hundreds/thousands/millions of lightweight processes, each with their own heap and a much more limited scope for garbage collection. Furthermore, when an operation on a short-lived process completes, the heap associated with it can be reclaimed immediately.

## Types

- Values
  - Integers (arbitrary size)
  - Floating point numbers
  - Atoms
  - Regex
  - Ranges
- System Types
  - PIDs and Ports
  - References
- Collections
  - Tuples
  - Lists
  - Maps
  - Binaries
- Functions
  - Are first class

Internally Regex and Ranges are just structs, however they are used so frequently and have robust implementations as an inherent part of the language so it's worthwhile to treat them as types in and of themselves.

### Value Types
#### Integers
Can be written in decimal, hexidecimal, octal and binary

    1234 -- base-10
    0xcafe -- base-16
    0765 -- base-8
    0b1010 -- base-2

Decimals can contain underscores to improve readability

    1_000_000

Bringing the number of languages this intelligent up to 3.

As hinted at above, Integers are arbitrary size and you never need to faff about with conversions, their internal representation will simply grow as the number does.

#### Floating Point
Are written using a decimal. There needs to be at least one number before and a number after the decimal for it to parse. Floating points can contain optional exponent specifiers at the end.

    1.0
    0.23456
    0.314159e1
    314159.0e-5

#### Atoms
Are preceded with a colon and followed by an atom word. An atom word can contain letters, digits, and underscores (no dashes), the end of an atom can contain punctuation like bangs and question marks.  You can create atoms of arbitrary characters by enclosing them in quotes, thus making the forbidden characters list bidden.

    :atom
    :eve?
    :here@there
    :===
    :<>
    :"dashing-atom"
    :"you can do anything... in quotes"

#### Ranges
Are represented as `start..end` where the beginning and end can be a value of any type. If you want built in iteration support, however, those values need to be integers.

Ranges at first seem counter-intuitive. Unlike Unix and some other languages it doesn't seem to recognize alphabetic ordering so in that sense a range is not a range (That I'm used to at least) because it won't automatically iterate over the values contained within that range. On the other hand, ranges in Elixir are capable of supporting any type, rather than being a range with inherent behavior it is rather a start point and an end point that can be used to define a range when combined with some sort of programmed in logic.

#### Regex
Have a literal syntax all their own and the Regexes themselves seem to conform to the Perl standard and can be combined with a whole list of options.

    # Literal Syntax
    ~r{regexp}
    ~r{regexp}opts

The delimiters can actually be any non-alphanumeric characters so things like this would work as well

    ~r|regexp|
    ~r/regexp/
    ~r[regexp]

Keep in mind that what you use as the delimiter will need to be escaped if it appears in the actual pattern, so the choice of delimiter is largely one of convenience. The pattern returned by Elixir uses the classic `/pattern/` syntax and automatically escapes `/` characters that appear in the pattern when your choice of delimiter was different.

- `f`: The pattern must begin to match on the first line of a multiline string
- `g`: Support named groups
- `i`: Case insensitivity
- `m`: Multiline string, `^` and `$` continue to match the beginning and end of lines, and `\A` and `\z` now match the beginning and end of the string.
- `r`: Changes `*` and `+` from 'greedy' modifiers that match as much as possible to 'reluctant' modifiers that match as little as possible.
- `s`: allows `.` to match newline characters
- `u`: Enables Unicode specific patterns

### System Types
Reflect types used by the underlying Erlang system.

- `pid`: The id of a process
- `port`: A reference to an external resource
- `reference`: a globally unique reference that none other will be equal to, `make_ref()` is used to create these.

### Collection Types
#### Tuples
An ordered, fixed length collection of values. Granted, everything in Elixir is fixed length because the data is immutable, but tuples moreso than other functional constructs rely on fixed lengths and known positions. Pattern matches on tuples will typically be one for one, whereas pattern matches on collections or lists usually involve a parameter that grabs a variable number of items from the end to be processed homogenously at a later iteration.

As a general rule, if you have more than four elements you probably want a map or a struct instead of a tuple. Now let's look at some examples.

    {status, count, action} = {:ok, 42, "next"}
    status
    >> :ok
    count
    >> 42
    action
    >> "next"

Many actions return a tuple where the first item in the tuple is the status of the action. Let's assume we have a file called `test` in the current directory.

    {status, file} = File.open("test")
    status
    >> :ok
    file
    >> #PID<0.100.0>

    {status, file} = File.open("nonexistent")
    status
    >> :error
    file
    >> :enoent

Here we see that `:ok` was sent along as confirmation that the action completed successfully for the file that existed, and `:error` for the file that didn't. It's common to match on `:ok` directly which makes error handling much cleaner.

    {:ok, file} = File.open("test")
    {:ok, failed} = File.open("nonexistent")

The second one will raise a `MatchError` at the command line, but with more patterns to be matched you can easily handle a successful file read and a failed file read solely by using different patterns.

#### Lists
Lists are singly linked, as in most functional languages. Unlike some functional languages (clojure) Elixir does not provide an analogue to the conventional array that provides lookup in constant time. Therefore, reading the nth element in Elixir will always be a comparatively expensive action because iteration will always start at the front.

However, from an immutable standpoint there are some big advantages to using a linked list. If we want to take the head and tail of a ll all we need to do is return the first item from the list and a pointer to the second, the immutable/linked nature of the structure makes it equivalent to copying and returning the whole remainder of the list.  Similarly if we want to concatenate two lists we simply take the pointer from the end of the first and point it at the head of the second. Different versions of the same list are slightly more complicated, but in essence they all rely on having pointers to the subset of the data that they want.

Lists are denoted with square brackets and their internal elements are separated by commas.

    l = [1, 2, 3, 4, 5]

Lists have a handful of special operators that work only on lists:

    concatenation = [1, 2, 3] ++ [4, 5, 6]
    difference = [1, 2, 3, 4] -- [2, 4]
    membership = 1 in [1, 2, 3, 4]

Accessing the items in a list are done largely through the classic recursive list approaches, but that topic is covered later.

For a list of key-value pairs there is a shorthand:

    kvs = [firstname: "Ryan", lastname: "Dangerous", location: "Hacker School"]

Note that this is not equivalent to a map, this simply turns the list into a list of tuples containing the keys and the values.

When a keyword list is being passed to a function, and the keyword list is the last item in the function call, then the brackets can be left off.

    DB.save record, use_transaction: true, logging: "HIGH"

#### Maps
Are collections of key/value pairs with constant time lookup.

    %{ key => value, key => value }

That's right, bringing Ruby back. Keys can be any type and you can even have different types of keys within the same map... You know, if you're into that kind of thing. Let's look at some examples:

    %{ "NY" => "New York", "CO" => "Colorado" }
    %{ {:error, :busy} => :retry, {:error, :enoent} => :fatal }

The second example shows how you can use a map for a kind of pattern-matching control flow thingy. When the keys are atoms, which seems likely, you can use the Ruby style syntax for key assignment:

    %{ one: 1, two: 2, three: 3 }

So fresh and so clean.

A natural question here is why there's a difference between maps and keyword lists? Keyword lists allow the same keys to be repeated, which is not allowed in Maps. Furthermore, keyword lists are lightweight and excellent for things like parameter passing, shown in the example above. Beyond that, however, you typically want to use Maps. Maps grow more efficiently, have constant time lookup, and can also be used for pattern matching.

Extracting a value from a map is done with square brackets.

    states["NY"]
    >> "New York"

If the keys are atoms (again, a good practice) you can also extract the values using dot notation.

    thedude = %{ name: "Lebowski", rug: "Really ties the room together" }
    thedude.name
    >> "Lebowski"

Methinks mesees the beginnings of an object-like syntax here. If you use the normal bracket syntax missing keys will return `nil`, but if you use the dot syntax you'll get a KeyError.

#### Binaries
When you need to access binary values directly you can surround them with `<< >>`.

    bin = <<1, 2>>

This packs 1 and 2 into bytes.

    byte_size bin
    >> 2

Each field is a single byte here, if you try to pack values larger than 255 into the byte it will wrap around. (It doesn't appear to actually overflow into other memory, so the wrapping is an incidental consequence of overflowing the allotted memory and not an intentional effort to handle that specific error.)

You can specify a bit size for each item in the binary.

    bin = <<3 :: size(2), 5 :: size(4), 1 :: size(2)>>
    >> <<213>>
    byte_size bin
    >> 1

This

## Conventions
#### Names
combinations of upper and lower case ASCII, digits, and underscores, they can end with a `!` or `?`. Module, record, protocol, and behavior names are in `CamelCase` and everything else is `snake_case`. a variable that starts with an underscore (or maybe is just an underscore?) doesn't produce an error when it is matched and not used, so this is the convention for ignoring variables.

Source files are utf-8 but the identifier character set only uses ASCII. Source indentation is Ruby-style. Two spaces per tab, but no actual tab characters in the source file.

Comments use the `#` hash symbol and run to the EOL.

#### Truthiness
`true` `false` and `nil` are the three fundamental truth values. `nil` is treated as false in boolean contexts and essentially every other extant value is treated as true. There is no special inherent truthiness to values like 0 or the empty string.

#### Comparison Operators
- `===` Strict equality, so `1.0 === 1` is `false`
- `!==` Strict inequality, the inverse of the above, so `1.0 !== 1` is `true`
- `==` Value equality, `1.0 == 1` is `true`
- `!=` Value inequality, the inverse of the above, `1.0 != 1` is `false`
- `> >= < <=` Work as they do in other languages

Comparison in Elixir is much less strict in the sense that different types can be directly compared. When the types are the same and an ordinal comparison is defined, that ordering is used. Otherwise comparisons follow this rule:

    number < atom < reference < function < port < pid < tuple < map < list < binary

#### Strict Boolean Operators
Expect a boolean argument as their first value.

- `a or b`
- `a and b`
- `a xor b`
- `not a`

#### Relaxed Boolean
Will take arguments of any type and use the inherent truthiness of the values to get the result

- `a || b`
- `a && b`
- `!a`

#### Arithmetic

- `+ - *` Follow normal type coercion rules
- `/` Always returns a float
- `div` Integer division
- `rem` Remainder, not entirely the same as modulus because the result will have the same sign as the first argument.

#### Join Operators
- `<>` Concatenates two binaries, including strings, since strings in Erlang are binaries.
- `++` Concatenates two lists
- `--` The difference between two lists

#### In
- `x in coll` Tests the inclusion of x in the collection
