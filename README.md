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

<h3>Take what you need</h3>

The approach above was pretty heavy handed. There's no need to store all the possible destination-source values. I changed the approach to only cache each recipe and let each seed be it's own input. to get the next component and interate. I often solve the via iteration. Anyway, part 1 works. Part 2 dies with "Out of Memory".

ALso, the cognitive load on this one is high because of the number of mapings and the array of seed ranges. I had to leave a bunch of breadcrumbs for myself until I solved the breakdown.

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

<details>
  <summary>Day 8</summary>

  Part 1 was easy. Part 2 was going to take 8 billion seconds. Ain't no one got time for that.

  With the help of friends doing the challenge, a juicy hint about LCM (Lowest Common Multiple) was dropped and I was a bit confused at first. I assumed getting from `/A$/` to `/Z$/` had many paths with many lengths. A simple test proved that each path run multiple times aggregates to the same base factor. I just had to trust the data.

  Built my own LCM utility, tested it out and felt pretty good about it. Then my answer in the hundreds of quadrillions was "too high".

  I could only specultae an off by one error. Boy, was I right!

  My part 1 solution looked a bit like this:

  ```perl
  while($current_key ne $end_key) {
		my $index = $steps % $direction_length;
		my $dir_index = $ref_directions->[$index];

		my $next_key = $locations{$current_key}[$dir_index];
		$current_key = $next_key;

		$steps++;
	}
  ```

  part two, I kept some things, moved other things around...

  ```perl
  while(1) {
		$steps++;
    my $index = $steps % $direction_length;
		my $dir_index = $ref_dir->[$index];

		my $next_key = $locations{$key}[$dir_index];
		$key = $next_key;
		return $steps if $key =~ m/Z$/;
	}
  ```

  I do not recall what bright idea led me to moving the `$steps++` to the top of the loop, but I depend on the modulo of that over the length of my directions to use the correct R/L. Moving `$steps++` below `my $index = $steps % $direction_length;` fixes it. 

  This one wasn't so bad. Getting away from brute force solutions and thinking about the data differently is making be a better human.
</details>

<details>
  <summary>Day 9</summary>

Alright... it seems that the time has now come for me to leave a note to myself about how reference and value types in perl work. I'm running into dereferencing issues again when I pass an array on to a sub routine. I'm sure hashes will give me guff, too.

_Example 1:_ Pushing an array reference to a subroutine, dereferencing and pushing into a hash

I want to maintain a bunch of lists in a hash. Maybe I could get by with a mulridimensional array but I want this to work... dammit!

```perl
sub test {
	my $line = "10 13 16 21 30 45";

	my @data = split /\s+/, $line;
	my %hash = example(\@data);
}


sub example() {
	my $input_list = shift;
	my %working_sets = {0 => @$input_list};
	my $set_index = 0;
	my @working_set = $working_sets{$set_index};
...
}
```

this gives me a `Odd number of elements in anonymous hash` on line 2 of the `example` sub. 

**solution**
use parens, not curly braces when initializing a hash. Also, the array in the hash needs to be an array ref. 

This:

```perl 
	my %working_sets = {0 => @$input_list}; #curly braces { } X wrong
```

should be 

```perl
	my %working_sets = (0 => $input_list); #parens ( ) correct. use an arrayref
```

<h3>Array references</h3>
I can't quite figure it out. I suspect that something like this creates an array, eg (1,2,3)

```perl
my @blah = split /\s/ "1 2 3";
```

so when it gets passed on to a function like so:

```perl
some_func(\@blah);
```
It remains a ref essentially (I think). I say this because passing the dereference version of this array causes problems in my utility function.

<h3>Dereferencing Array refs in hashes... more malarkey</h3>
I spent too much time trying to figure out what's going on with trying to slice arrays. Spoiler alert: you can't slice array references.

When dereferencing from a hash, one much do this:

```perl
	my %working_sets = (0 => $input_list);
	my $set_index = 0;
	my @values = @{$working_sets{$set_index}};
```

fffffff... I know I made the choice to use this language. This is not the first time that the bulk of the time solving the day's problem came down to "how do I use perl?"

<h3>Special syntax for getting the last item in an array</h3>

Get the last item by simply doing `$array[-1];`.

What about array references? Super easy:
prepend another `$` sigil to the front of the array ref like so:

```perl
$$arr_ref[-1];
```

Wanna really impress your friends? There's a special variable for last index!

```perl
$array[$#array]
# for array refs prepend an extra $ sigil. for the index token, a $ after $#
$$arr_ref[$#$arr_ref];
```

Wanna keep your friends? Don't use perl...
</details>

<details>
  <summary>Day 10</summary>

I've approached this problem or something like it handling joystick presses in a maze game I made ages ago. I thought of things in terms of North, South, East and West. I did cheat it a little bit because I made a purely recursive method and it was single threaded. Each visited coordinate got stored in a hash. If a coordinate was already visited, break the program. Since I was incrementing a value with each position, When I got back to the first point after the start, I added one and divided by two to get my halfway point. I think I tried to mess with threads, I'd run into different problems. 

Handling position changes was done in a giant `given...when` processor.

I don't care enough to solve part 2 at this point though I may revisit it. The problem of finding interior tiles sounds a little interesting though complex.
</details>

<details>
  <summary>Day 11</summary>
  <h2>Expanding Space</h2>

  I read this prompt before driving to Home Depot for some unfortunate DIY supplies. On the way there I thought:
  > If I work the starfield array backwards and identify starless columns, I can splice each row with another '.' at the encountered index. Then, I'll go through each row and do the same.

  This approach was fairly straightforward and easy to solve. (I should mention: array references in hashes bit me again. I'm surer I get it but...). And then along comes part two. There's a MILLION spans of spane for each starless line. Then I went to bed.

  As I was brushing my teeth I thought:

  > starfield expansion is merely a function 2d arrays. For every blank row/column, I previously increased the corresponding x or y by one. It was merely obfuscated by virtue of expanding the field, not padding numbers per empty dimension.

  Pretty straight forward but prone to off by one errors. One needs to offset x/y by `expansion_rate -1` per encounter. I stored the grid indices where the empty row/columns lived and applied a modifier when the x/y compnent was > the identified row/column.

  Part 2 solution runs for the same amount of time regardless of whther the expansion rate is 2 or 1,000,000 (0.130s)
</details>

<details>
  <summary>Day 12</summary>

It's a game of find the possible arrangments of broken springs given some data.
I spent some time downstairs on the whiteboard with raw forms of mapping possibilities. I yreated a contiguous set as one unit for the sake of identifying unique mappings. There seems to be a relationship between the width of a set of plots and the delta of the numbers to work with. Each # must have at least one space between it and the next #. The possibilities seem to be a summation of 1..n where n is the delta between the broken parts and spaces with the width of the field.

eg: ??????? 1,1,1 is 7 - 5 (# plus space, or comma, in this case) plus 1 (I dunno where that comes from, maybe default case?) which should be sum of 

```perl
(1**2 + 1)//2 + (2**2 + 2)//2 + (3**2 + 3)//2

2//2 + 6//2 + 12//2

1 + 3 + 6 = 10
```

Which gives the following possibilities:

```perl
 1 ..#.#.#
 2 .#..#.#
 3 .#.#..#
 4 .#.#.#.
 5 #...#.#
 6 #..#..#
 7 #..#.#.
 8 #.#...#
 9 #.#..#.
10 #.#.#..
```

There are other phenomena about these data sets but I think I should attempt to solve these sets with what I've discovered so far. Known good or bad springs will pose a special problem.

<h3>Et tu, Brute Force?</h3>
So... much to my shame, I couldn't make a smart and perhaps efficient solution happen. At this point, I'm about to call it a year for AoC. I want to dig back into ASM6507 for Atari. So I effectively made a combo of patterns and doubled my inputs for each `?`. The smart solution is within my grasp... maybe a good night's sleep will do the trick.
 
</details>