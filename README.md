# AoC-2023
Advent of Code 2023... in perl!

## Journal


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

</details>