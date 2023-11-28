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