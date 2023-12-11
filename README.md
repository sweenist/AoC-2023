# AoC-2023
Advent of Code 2023... in perl!

## Journal

The following entries are discoveries I made while using Perl to crack Advent of Code 2023 problems. Not all entries have spoilers. More often than not, the language syntax itself was the time sink than concocting the approach to solving the problem per day. Though, some of these problems were doozies. Some prompts be [like](https://youtu.be/7sl0e9yKwTk?si=03yJq0UBiphQ7Zkx). 

<details>
  <summary>Day 1</summary>

Solving day 1 wasn't too bad. I regexed my way through it without too much issue.

<h3>Gotchas</h3>

* **Regex Patterns in Variables**

This didn't feel straightforward. Simply using `$pattern = /(\d)\D$/;` wasn't working when using it with the `~=` match operator.
Ended up with the pattern itself in a scalar (`$pattern = q"(\d)\D$";`) and then storing a quoted regex (`qr`) in another scalar (`$re_pattern = qr/$pattern/;`)

* **Perl Modules**

In an effort to abstract solutions from the main runner, I decided to move solution code to perl modules. Then I can just import the module and it should just work.

However...

I had to install the Exporter library (`sudo cpan Exporter`).
Then use the following syntax at the top of my module:

```perl Day1.pm
# Modules/Day1.pm
package Modules:Day1

use Exporter ( import );

our @ISA = qw( Exporter );
our @EXPORT_OK = qw( part_one part_two );
```

The above is the final solution. I didn't know that the package had to be named respecting the path.

```perl
#modules/Day1.pm
package Day::One;  #file path needs to be Day/One.pm
``` 

While we're talking about paths, the main script needs a line like:

```perl
use lib './';
```

Without it, perl will traverse its predefined path variable searching for `Modules/Day1`. The `use lib './'` line prepends the current working directory to this list. 

 * **Syntax Highlighting**

 Maybe it's my machine, but despite using various perl extensions in vscode, I'm not seeing erroneous code and am left to interpret syntax errors on the command line on my own.

 I spent a few hours googling syntax errors on @EXPORT_OK to no avail. Can you see the problem?

 ```perl
# Modules/Day1.pm
package Modules:Day1

use Exporter ( import );

our @ISA = qw( Exporter );
our @EXPORT_OK qw( part_one part_two );
```
Can you see the problem? If you said, "You're missing an equals sign after @EXPORT_OK" then WHERE WERE YOU LAST NIGHT WHEN I WAS TRYING TO GET THIS FIGURED OUT???!!!

Anyway...

 </details>


<details>
  <summary>Day 2</summary>

This game of "show me cubes" doesn't sound very fun...

<h3>Things I learned</h3>

* `le` keyword doesn't behave the same as `<=`

When checking each game set for the number of colored cubes, my validator method only returned a handful of valid games if and only if, a set had a valid value for each color. Predefining as 0 and comparing using `le` returned `falsy` (eg `return 0 le 13` ). It's possible that `<=` is explicitly for numbers and will respect `0` values. `le` is a string comparison operator after checking the internet

* returning chained boolean statements

a statement like this: 

```perl
return $set_red <= $max_red and $set_green <= $max_green and $set_blue <= $max_blue;
```
doesn't behave like I expected. But this works:

```perl
return ($set_red <= $max_red and $set_green <= $max_green and $set_blue <= $max_blue);
```
If I had to guess, the former statement only returns the first part of the expression `$set_red <= $max_red`

* control flow with `next`

I'm used to a keyword like `continue` for processing the next enumeration in a loop. Perl uses `next`. I like this in combination with `unless`. It's succinct:
```perl
next unless validate($blah);
```
</details>


<details>
  <summary>Day 3</summary>

Reminds me of the "oil field" interview problem.

I thought on this a bit (part 1). I think if we get the absolute indicies of the symbols and then go back through and see if the symbol index exists in the surround array of positions around the number, this would be a good idea. There may be a better way but this is what my brain came up with.

\* by `absolute` I mean, the index of a symbol found if the whole data set was one string. Since each line in my data was 140 characters long, the 3rd character in the 4th row would be index 422 => row_index(3) * line_length(140) + symbol_index(2) (0-based indexing for row and symbol)

<h3>Things I learned</h3>

 * Getting length of array

  I discovered that you can get the length of a perl array by assigning a scalar ($variable) to the list (@variable). Super neat? I leave that to you to decide.

  ```perl
  my $array_len = @blah_array;
  ```

 * Array index variables

  When you using the regex match operation (ie `$blah =~ /m/<regex_pattern>/`), upon finding a match, there are some special perl variables available. `$-[0]` gets the index of the first matched character of the match in a string. `$+[0]` gets the starting of the charcter after a match. I just subtract 1 from the `$+[0]` scalar to get the last index of my match.   

  * chomp - remove trailing space

  In languages like c#, `.Trim()` functions return the new value. Not so with `chomp`. It does an in place mutation trimming the input separator character (new line, essentially). `chomp` does return a value: the number of characters it removed from the variable in question.

  * hashes of array references, oh my

  To talk through my approach to solving the part two problem, I wanted to get the absolute data indices of all gears (`*`). Effectively, when I matched the asterisk character in string, I'd use that index as my hash key and set it to an array reference.

  ```perl
  my $gear_index = $-[0] + (LINE_LENGTH * $row_number);
	$gears{$gear_index} = []; # [] is an array ref; () is an undefined array. Can't push to () via hash index
  ```
  Then, I churned back through the data to match surrounding indices to any available gear index. If a matching gear existed, then push the number to the hash at corresponding gear index key.

  Straightforward, right? I then used `List::AllUtils` `product` function to give me the product of each hash array value with exactly two numbers. The problem: the product was being applied to the array reference (which didn't do anything because 1 x address reference = address reference). WHat gives?

  well, you can't just do this:

  ```perl
  for(keys %gears) {
    my @nums = $gears{$_}; # <-- array ref eg ARRAY5987651

    #if length of array is 2 -- scalar @array returns length...
    if(scalar @nums == 2) { # this would never be true
      my $product = product @nums;
      $aggregate += $product;
    }
	}
  ```

  Instead, do this:

  ```perl
  my @nums = @{$gears{$_}} # oh baby, cast that arrayref to an array!
  ```

In short... I've spend more time so far working in spite of perl and its nuances than on the algorithm for solving these problems.

</details>

<details>
<summary>Day 4</summary>

The only real oddity is when splitting strings. Not a big deal separating winning numbers from the ones that were owned except the `|` had to be escaped -> `\|`. Then splitting numbers by space took a moment because I would get a blank item in my list as evidenced by a preceding comma when I do:

```perl
say join ',', @winning_numbers;

# output ,4,8,15,16,23,42
```

adding a `trim` function to the input fixed that. Also, the split expression required `/\s+/`.

Otherwise, the fastest I've completed a pair of problems.

</details>

<details>
<summary>Day 5</summary>

<h3>References strike again</h3>

* The problem with hash references

In solving the seed-soil...location problem for part 1, I decided to be clever and define a bunch of hashes and when I encounter a specific string (ie `humidity-to-location`) I'd use and eval statement to dynamically store the reference and pass it on to a subrountine so I could cascade the source/destination values.

   * **problem 1** - assigning a new hash to the reference creates a new hash with different reference

  I don't even recall what I did but it seemed that this code created a new hash reference so any key-value pairs added are lost to the ether

  ```perl
  sub cascade_recipe() {
    my $recipe_ref = shift;
    my $data = shift;
    my %hash = %$recipe_ref;
    ...
    $hash{$key} = $value;
  ```

  when printing my variable, the reference was different for the `%hash` but the `$recipe_ref` had the appropriate hash for the thing I wanted from the caller.

  * **problem 2** - try using a prototype

  args to a subroutine are a list of scalars effective. For lists and hashes those are references but a hash is just a fancy list that has keys and values so the whole thing gets stored as a list (according to the internet). I though there was a problem getting the hash to resolve correctly. So I used a prototype.

  ```perl
  sub cascade_recipe(\%) {
    my $recipe_ref = shift;
    my $data = shift;
    my %hash = %$recipe_ref;
    ...
    $hash{$key} = $value;
  ```

  That `\%` in the rountine parens means the first arg in `@_` (the arg list) shall be a hash reference. But using this didn't do anything. Back to stackoverflow for some different word combinations.

  * **The solution** 

  There are two ways to access a hash. either `$hash{key}` or `$hash->{key}`. The latter dereferences and since we're using a reference, the arrow is the way to amend the hash ref you care about. No need to use a prototype either.

  ```perl
  sub cascade_recipe() {
    my $recipe_ref = shift;
    my $data = shift;
    ...
    $recipe_ref->{$key} = $value;
  ```

<h3>This implementation begs for monads</h3>
I'd love to dot chain my hashes. I can probably still do it...

<h3>Example works but my data input kills perl</h3>

Let's see what happens on a different machine...

</details>

<details>
<summary>Day 6</summary>

This was an interesting application of the quadratic equation (or, at least that's how I approached it).
turns out, `ceil()` and `floor()` are not exactly included. You have to `use POSIX` to get these functions.

Also, to raise a number by a power, use `**`, not `^`. The caret is used to XOR binary expressions or for bitwise operations. 

I was afraid of buffer overflow in part two b ut it was fine.
</details>

<details>
  <summary>Day 7</summary>

<h3>Threading</h3>
Had a thought about threading. I'm looking at this problem in two slices:
  * Identify the strength types into their own buckets (five of a kind, full house, etc)
  * sort each of the buckets accordingly (this is the part I want to thread)

[Threading](https://perldoc.perl.org/threads) in perl feels a little daunting but maybe because it looks a little different than in C# or Javascript. It should be fine if I pass the sub buckets as array references. 

<h3>sorting optimizations</h3>
Thinking about the sorting of hands... I got curious about the efficiency differences between numeric and string comparisons in perl. Luckily, [someone else already did this research](https://limited.systems/articles/writing-faster-perl/#:~:text=Integer%20comparison%20is%20faster%20than%20string%20comparison).

How can I take 13 possible values and make them sort efficient? 2-9 are already numbers. A,K,Q,J and T are valued at 14..10. 
As I was bringing the dogs back from a walk, I had a mind to convert each character to a hex value 0x2 - 0xE. Seems a bit heavy because 57.1428% of my characters are numerical to begin with. Since 1 isn't a value and regex is efficient, I can swap the alpha character with their numerical value. Then I would do a thing like `/1\d|\d/` to fetch appropriate values for sorting.

<h3>multi initialization</h3>

I didn't want 7 lines to declare a bunch of empty arrays... though, I wouldn't do this in c#... anyway, here's a nifty (or whatever) thing to assign a bunch of empty, yet unique, array ~references~ (edit: don't use references, just make them empty arrays (`()` instead of `[]`), otherwise, conacatenating at the end is a nightmare. You'll get 7 array references and then their contents. lame):

```perl
my (@fivek, @fourk, @fh, @threek, @twop, @onep, @def) = () x 7;
```
`x` is a repetition operator. you just have to be able to count how many things you're declaring, which makes two modifications you need to make if you add or remove an array initialization.

<h3>given... the perl switch statement</h3>

There's a switch like syntax as follows:

```perl
given($some_var) {
  when('foo') { do blah; }
  default { do other blah; }
}
```

but... it doesn't work out of the box. One must use:

```perl
use feature qw ( switch );
```

of all things...

<h2>Part Two</h2>
Ah, so J is no longer 11 and it's less than two... and since letters were previous assigned 1x (10-14), I'll make J a really low number: 0!

The only real snafu I ran into was that implemnented `given...when...default` wrongly for my case where only single versions of each non-joker card existed. I pleaced the default outside an inner given and it did weird things. I had a handful of high card weights where 1 or more jokers were present

```perl
given($max_card_appearance) {
  ...
  when(1) {
    given($key_count) {
      when(1) { push @{$fivek}, $hand; }
      when(2) { push @{$fourk}, $hand; }
      when(3) { push @{$threek}, $hand; }
      when(4) { push @{$onep}, $hand; }
    }
    default	{ push @{$def}, $hand; } #oopsie. weird side effect. None of the above evaluated
  }
}
```

Once I corrected to the snippet below, everything was as expected. The `default` case, I suspect, was being evaluated before attempting the inner given loop:

```perl
given($max_card_appearance) {
  when(1) {
    given($key_count) {
      when(1) { push @{$fivek}, $hand; }
      when(2) { push @{$fourk}, $hand; }
      when(3) { push @{$threek}, $hand; }
      when(4) { push @{$onep}, $hand; }
      default	{ push @{$def}, $hand; }
    }
  }
}
```

Now that that is over, I have an idea how to make perl not commit sepuku when I run Day 5 solution.

</details>