---
title: "Adjusting to Julia: The Levenshtein algorithm"
layout: post
mathjax: true
tags: [Julia]
category: [Programming]
---

In this second blog post about [Julia](https://julialang.org/), I'll share
with you a Julia implementation of the Levenshtein algorithm.

<!--more-->



## The Levenshtein algorithm
The basic Levenshtein algorithm is used to count the minimum number of 
insertions, deletions and substitutions that are needed to convert one
string into another. For instance, to convert English _doubt_ into
French _doute_, you need at least two operations. You could replace the
_b_ by a _t_ and then replace the _t_ by an _e_; or you could
delete the _b_ and then insert the _e_. As this example shows, there
may be more than one way to convert one string into another using the minimum
number of required operations, but this minimum number itself is unique
for each pair of strings.

## Implementation in Julia
I won't cover the logic of the Levenshtein algorithm here.
The following is a straightforward Julia implementation of the pseudocode 
found on Wikipedia, assuming a cost of 1 for all operations.
The function takes two inputs (a string `a` that is to be converted
to a string `b`) and outputs an array with the Levenshtein distances
between all substrings of `a` on the one hand and all substrings of `b`
on the other hand. The entry in the bottom right corner of this array
is the Levenshtein distances between the full strings and this is output
separately as well.


{% highlight julia %}
function levenshtein(a::String, b::String)
  # Initialise table
  distances = zeros(Int, length(a) + 1, length(b) + 1)
  distances[:, 1] = 0:length(a)
  distances[1, :] = 0:length(b)

  # Levenshtein logic
  for row in 2:(length(a) + 1)
    for col in 2:(length(b) + 1)
      distances[row, col] = min(
        distances[row - 1, col - 1] + 
          Int(a[row - 1] != b[col - 1] ? 1 : 0)
        , distances[row, col - 1] + 1
        , distances[row - 1, col] + 1
      )
    end
  end

  return distances, distances[length(a) + 1, length(b) + 1]
end
{% endhighlight %}

Let's compute the Levenshtein distance between
the German word _Zyklus_ ('cycle') and its
Swedish counterpart _cykel_.
Note the use of `;` at the end of the line to suppress
the output.


{% highlight julia %}
dist_matrix, lev_cost = levenshtein("zyklus", "cykel");
display(dist_matrix)
{% endhighlight %}



{% highlight text %}
## 7×6 Matrix{Int64}:
##  0  1  2  3  4  5
##  1  1  2  3  4  5
##  2  2  1  2  3  4
##  3  3  2  1  2  3
##  4  4  3  2  2  2
##  5  5  4  3  3  3
##  6  6  5  4  4  4
{% endhighlight %}

This checks out: you do indeed need four operations
to transform _Zyklus_ into _cykel_.

## A vectorised function
But what if we wanted to apply our new
functions to several pairs of strings?
Let's first define three Dutch-German word pairs:


{% highlight julia %}
dutch = ("boek", "zuster", "sneeuw");
german = ("buch", "schwester", "schnee");
{% endhighlight %}

We can run our `levenshtein()` on these three
word pairs without introducing for-loops by simply
appending a dot to the function name:


{% highlight julia %}
levenshtein.(dutch, german)
{% endhighlight %}



{% highlight text %}
## (([0 1 … 3 4; 1 0 … 2 3; … ; 3 2 … 2 3; 4 3 … 3 3], 3), ([0 1 … 8 9; 1 1 … 8 9; … ; 5 4 … 5 6; 6 5 … 6 5], 5), ([0 1 … 5 6; 1 0 … 4 5; … ; 5 4 … 4 3; 6 5 … 5 4], 4))
{% endhighlight %}

However, since the `levenshtein()` function outputs
two pieces of information (both the matrix with the
distances between the substrings as well as the final
Levenshtein distance), this vectorised call yields
a tuple of three subtuples, each subtuple containing
both a matrix and the corresponding final Levenshtein distance.
This is why the output above looks so messy.
If we wanted to obtain just the Levenshtein distances,
we could write a for-loop to extract them. 
But I think an easier solution is to first write a wrapper
around the `levenshtein()` function that outputs only
the final Levenshtein distance and use the vectorised version
of this wrapper instead:


{% highlight julia %}
function lev_dist(a::String, b::String)
  return levenshtein(a, b)[2]
end
{% endhighlight %}


Now use the vectorised version of `lev_dist()`:

{% highlight julia %}
lev_dist.(dutch, german)
{% endhighlight %}



{% highlight text %}
## (3, 5, 4)
{% endhighlight %}

Nice!

## Obtaining the operations
We now know that we need four operations to transform
_Zyklus_ into _cykel_ and five to transform _zuster_ 
into _Schwester_. But which are the operations that you need
for these transformations?
The function `lev_alignment()` defined below outputs
one possible set of operations that would do the job.
(Unlike the minimum number of operations required to
transform one string into another, the set of operations needed
isn't uniquely defined.)


{% highlight julia %}
function lev_alignment(a::String, b::String)
  source = Vector{Char}()
  target = Vector{Char}()
  operations = Vector{Char}()
  
  lev_matrix = levenshtein(a, b)[1]
  
  row = size(lev_matrix, 1)
  col = size(lev_matrix, 2)

  while (row > 1 && col > 1)
    if lev_matrix[row - 1, col - 1] == lev_matrix[row, col] &&
        lev_matrix[row - 1, col - 1] <= min(
          lev_matrix[row - 1, col]
          , lev_matrix[row, col - 1]
          )
      row = row - 1
      col = col - 1
      pushfirst!(source, a[row])
      pushfirst!(target, b[col])
      pushfirst!(operations, ' ')
    else 
      if lev_matrix[row - 1, col] <= min(
          lev_matrix[row - 1, col - 1]
          , lev_matrix[row, col - 1])
        row = row - 1
        pushfirst!(source, a[row])
        pushfirst!(target, ' ')
        pushfirst!(operations, 'D')
      elseif lev_matrix[row, col - 1] <= lev_matrix[row - 1, col - 1]
        col = col - 1
        pushfirst!(source, ' ')
        pushfirst!(target, b[col])
        pushfirst!(operations, 'I')
      else
        row = row - 1
        col = col - 1
        pushfirst!(source, a[row])
        pushfirst!(target, b[col])
        pushfirst!(operations, 'S')
      end
    end
  end

  # If first column reached, move up.
  while (row > 1)
    row = row - 1
    pushfirst!(source, a[row])
    pushfirst!(target, ' ')
    pushfirst!(operations, 'D')
  end

  # If first row reached, move left.
  while (col > 1)
    col = col - 1
    pushfirst!(source, ' ')
    pushfirst!(target, b[col])
    pushfirst!(operations, 'I')
  end
  
  return vcat(
    reshape(source, (1, :))
    , reshape(target, (1, :))
    , reshape(operations, (1, :))
  )
end
{% endhighlight %}


I won't cover the logic behind the algorithm as this is more
about learning Julia that the Levenshtein algorithm.
On the Julia side, note first how empty character vectors
can be initialised. Moreover, notice that the `pushfirst!()`  
function is decorated with a `!` (a 'bang'). This communicates
to whoever is reading the code that this function changes 
some of its input. For instance, `pushfirst!(source, a[row])`
means that the current character of `a` (i.e., `a[row]`)
is added to the front of the `source` vector. That is,
this command changes the `source` vector.
Finally, the `source`, `target` and `operations` vectors
are all column vectors. In order to display them somewhat
nicely, I converted each of them to a single-row matrix
using `reshape()`. Then, the three resulting rows are
concatenated vertically using `vcat()` to show how the 
two strings can be aligned and which operations are needed 
to transform one into the other.

Let's see how we can transform _Zyklus_ into _cykel_:


{% highlight julia %}
lev_alignment("zyklus", "cykel")
{% endhighlight %}



{% highlight text %}
## 3×7 Matrix{Char}:
##  'z'  'y'  'k'  ' '  'l'  'u'  's'
##  'c'  'y'  'k'  'e'  'l'  ' '  ' '
##  'S'  ' '  ' '  'I'  ' '  'D'  'D'
{% endhighlight %}

So we substitute _c_ for _z_,
insert an _e_ and delete the _u_ and _s_.
As I mentioned, this set of operations isn't
uniquely defined. Indeed, we could have also
substituted _c_ for _z_, _e_ for _l_
and _l_ for _u_ and then deleted the _s_.
This also corresponds to a Levenshtein distance
of four operations.

## Normalised Levenshtein distances
Above, we computed raw Levenshtein distances.
The problem with these is that longer string pairs
will tend to have larger raw Levenshtein distances
than shorter string pairs, even if they do seem
more similar. To correct for this, we can computed
normalised Levenshtein distances instead.
There are various ways to compute these;
one option is to divide the raw Levenshtein distance
by the length of the alignment:


{% highlight julia %}
function norm_lev_dist(a::String, b::String)
  raw_dist = lev_dist(a, b)
  alignment_length = size(lev_alignment(a, b), 2)
  return raw_dist / alignment_length
end
{% endhighlight %}


(Behind the scenes, we run the Levenshtein algorithm
twice: once in `lev_dist()` and again in `lev_alignment()`.
This seems wasteful - unless the Julia compiler is able
to clean up the double work? I'm not sure.)

We obtain a normalised Levenshtein distance of
about 0.57 for _Zyklus_ - _cykel_:


{% highlight julia %}
norm_lev_dist("zyklus", "cykel")
{% endhighlight %}



{% highlight text %}
## 0.5714285714285714
{% endhighlight %}

We can use a vectorised version of this function, too:


{% highlight julia %}
norm_lev_dist.(dutch, german)
{% endhighlight %}



{% highlight text %}
## (0.75, 0.5555555555555556, 0.5)
{% endhighlight %}

Of course, normalised Levenshtein distances are symmetric,
so we obtain the same result when running the following command:


{% highlight julia %}
norm_lev_dist.(german, dutch)
{% endhighlight %}



{% highlight text %}
## (0.75, 0.5555555555555556, 0.5)
{% endhighlight %}

