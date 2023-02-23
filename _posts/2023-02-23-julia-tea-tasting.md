---
title: "Adjusting to Julia: Tea tasting"
layout: post
mathjax: true
tags: [Julia]
category: [Programming]
---

In this third blog post in which I try my hand at the [Julia](https://julialang.org/)
language, I'll tackle a slight variation of an old problem -- Fisher's tea tasting
lady -- both analytically and using a brute-force simulation.

<!--more-->



## The lady tasting tea
In _The Design of Experiments_, Ronald A. Fisher explained the Fisher exact
test using the following example. Imagine that a lady claims she can taste
the difference between cups of tea in which the tea was poured into the cup
first and then milk was added, and cups of tea in which the milk was poured
first and then the tea was added. A sceptic might put the lady to the test
and prepare eight cups of tea -- four with tea to which milk was added,
and four with milk to which tea was added. (Yuck to both, by the way.)
The lady is presented with these in a random order and is asked to identify
those four cups with tea to which milk was added. Now, if the lady has no
discriminatory ability whatever, there is only a 1-in-70 chance she identifies
all four cups correctly. This is because there are 70 ways of picking
four cups out of eight, and only one of these ways is correct. In Julia:


{% highlight julia %}
binomial(8, 4)
{% endhighlight %}



{% highlight text %}
## 70
{% endhighlight %}

We can now imagine a slight variation on this experiment.
If the lady identifies all four cups correctly, we choose to believe she
has the purported discriminatory ability. If she identifies two or fewer
cups correctly, we remain sceptical. But she identifies three out of four
cups correctly, we prepare another eight cups of tea and give her another
chance under the same conditions.

We can ask two questions about this new procedure:

1. With which probability will we believe the lady if she, in fact, does not have any discriminatory ability?
2. How many rounds of tea tasting will we need on average before the experiment terminates?

In the following, I'll share both analytical and a simulation-based 
answers to these questions.

## Analytical solution
Under the null hypothesis of no discriminatory ability,
the number of correctly identified cups in any one draw ($X$) follows a 
[hypergeometric distribution](https://en.wikipedia.org/wiki/Hypergeometric_distribution)
with parameters $N = 8$ (total), $K = 4$ (successes) and $n = 4$ (draws), i.e.,
\[
  X \sim \textrm{Hypergeometric}(8, 4, 4).
\]
In any given round, the subject fails the test if she only identifies
0, 1 or 2 cups correctly. Under the null hypothesis, the probability of this
happening is given by $p = \mathbb{P}(X \leq 2)$, the value of which
we can determine using the cumulative mass function of the 
Hypergeometric(8, 4, 4) distribution.
We suspend judgement on the subject's discriminatory abilities if she
identifies exactly three cups correctly, in which case she has another go. 
Under the null hypothesis, the probability of this happening in any
given round is given by $q = \mathbb{P}(X = 3)$, the value of which
can be determined using the probability mass function of the Hypergeometric(8, 4, 4)
distribution.

With those probabilities in hand, we can now compute the probability that the
subject fails the experiment in a specific round, assuming the null hypothesis 
is correct. In the first round, she will fail the experiment with probability $p$.
In order to fail in the second round, she needed to have advanced to the
second round, which happens with probability $q$, and then fail in that round,
which happens with probability $p$. That is, she will fail in the second 
round with probability $pq$. To fail in the third round, she needed to advance
to the third round, which happens with probability $q^2$ and then fail in
the third round, which happens with probability $p$. That is, she will fail
in the third round with probability $pq^2$. Etc. etc.
The probability that she will fail somewhere in the experiment if the null
hypothesis is true, then,
is given by
\[
  \sum_{i = 1}^{\infty}pq^{i-1} = \sum_{i = 0}^{\infty}pq^i = \frac{p}{1-q},
\]
where the first equality is just a matter of shifting the index
and the second equality holds because the expression is a [geometric series](https://en.wikipedia.org/wiki/Geometric_series).

Let's compute the final results using Julia. 
The following loads the `DataFrames` and `Distributions` packages
and then defines `d` as the Hypergeometric(8, 4, 4) distribution.
Note that in Julia, the parameters for the Hypergeometric distribution
aren't $N$ (total), $K$ (successes) and $n$ (draws), but rather $k$ (successes), $N-k$ (failures) and $n$ (draws);
see the [documentation](https://juliastats.org/Distributions.jl/v0.14/univariate.html#Distributions.Hypergeometric).
We then read off the values for $p$ and $q$ from the cumulative mass function and probability mass function, respectively:

{% highlight julia %}
using Distributions
d = Hypergeometric(4, 4, 4);
p = cdf(d, 2);
q = pdf(d, 3);
{% endhighlight %}

The probability that the subject will fail the experiment if she does indeed not have the 
purported discriminatory ability is now easily computed:

{% highlight julia %}
p / (1 - q)
{% endhighlight %}



{% highlight text %}
## 0.9814814814814815
{% endhighlight %}

The next question is how many rounds we expect the experiment to carry on for
if the null hypothesis is true. At each round, the probability that
the experiment terminates in that round is given by $1 - q$.
From the [geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution),
we know that we then on average need $1/(1-q)$ attempts before the first 
terminating event occurs:


{% highlight julia %}
1 / (1 - q)
{% endhighlight %}



{% highlight text %}
## 1.2962962962962965
{% endhighlight %}

In sum, if the subject lacks any discriminatory ability, there is only 
a 1.85% chance that she will pass the test, and on average, the experiment
will run for 1.3 rounds.

## Brute-force solution
First, we define a function `experiment()` that runs the experiment once. 
In essence, we have an `urn` that contains four correct
identifications (`true`) and four incorrect identifications (`false`).
From this `urn`, we `sample()` four identifications without replacement.

Note, incidentally, that Julia functions can take both positional arguments
and keyword arguments. In the `sample()` command below, both `urn` and
`4` are passed as positional arguments, and you'd have to read the 
[documentation](https://juliastats.org/StatsBase.jl/stable/sampling/#StatsBase.sample)
to figure out which argument specifies what.
The keyword arguments are separated from the positional arguments by a semi-colon
and are identified with the parameter's name.

Next, we count the number of `true`s in our `pick` using `sum()`.
Depending on how many `true`s there are in `pick`, we
terminate the experiment, returning `false` if we remain sceptic
and `true` if we choose to believe the lady, or we run the experiment for one
more round. The number of attempts are tallied and output as well.


{% highlight julia %}
function experiment(attempt = 1)
	urn = [false, false, false, false, true, true, true, true]
	pick = sample(urn, 4; replace = false)
	number = sum(pick)
	if number <= 2
		return false, attempt
	elseif number >= 4
		return true, attempt
	else
	  return experiment(attempt + 1)
	end
end;
{% endhighlight %}

A single run of `experiment()` could produce the following output:

{% highlight julia %}
experiment()
{% endhighlight %}



{% highlight text %}
## (false, 2)
{% endhighlight %}


Next, we write a function `simulate()` that runs the `experiment()`
a large number of times, and outputs both whether each `experiment()`
led to us believe the lady or remaining sceptical, and how many round each
`experiment()` took. These results are tabulated in a `DataFrame` -- just because.
Of note, Julia supports list comprehension that Python users will be familiar with.
I use this feature here both the run the experiment a large number of times
as well as to parse the output.


{% highlight julia %}
using DataFrames

function simulate(runs = 10000)
	results = [experiment() for _ in 1:runs]
	success = [results[i][1] for i in 1:runs]
	attempts = [results[i][2] for i in 1:runs]
	d = DataFrame(Successful = success, Attempts = attempts)
	return d
end;
{% endhighlight %}

Let's swing for the fences and run this experiment a million times.
Like in Python, we can make large numbers easier to parse by inserting
underscores in them:


{% highlight julia %}
runs = 1_000_000;
{% endhighlight %}

Using the `@time` macro, we can check how long it take for this simulation
to finish.


{% highlight julia %}
@time d = simulate(runs)
{% endhighlight %}



{% highlight text %}
##   0.783903 seconds (4.50 M allocations: 380.651 MiB, 8.40% gc time, 59.95% compilation time)
{% endhighlight %}



{% highlight text %}
## 1000000×2 DataFrame
##      Row │ Successful  Attempts
##          │ Bool        Int64
## ─────────┼──────────────────────
##        1 │      false         2
##        2 │      false         1
##        3 │      false         1
##        4 │      false         1
##        5 │      false         1
##        6 │      false         1
##        7 │      false         1
##        8 │      false         1
##     ⋮    │     ⋮          ⋮
##   999994 │      false         2
##   999995 │      false         1
##   999996 │      false         1
##   999997 │       true         1
##   999998 │      false         1
##   999999 │      false         2
##  1000000 │      false         1
##              999985 rows omitted
{% endhighlight %}

On my machine then, running this simulation takes less
than a second. 
Note that 60% of this time is compilation time.
Indeed, if we run the function another time, i.e.,
after it's been compiled, the run time drops to about 0.3
seconds:


{% highlight julia %}
@time d2 = simulate(runs)
{% endhighlight %}



{% highlight text %}
##   0.299691 seconds (3.89 M allocations: 348.754 MiB, 9.35% gc time)
{% endhighlight %}



{% highlight text %}
## 1000000×2 DataFrame
##      Row │ Successful  Attempts
##          │ Bool        Int64
## ─────────┼──────────────────────
##        1 │      false         1
##        2 │      false         2
##        3 │      false         1
##        4 │      false         1
##        5 │      false         1
##        6 │      false         1
##        7 │      false         1
##        8 │      false         2
##     ⋮    │     ⋮          ⋮
##   999994 │      false         2
##   999995 │      false         1
##   999996 │      false         2
##   999997 │      false         1
##   999998 │      false         1
##   999999 │      false         1
##  1000000 │      false         1
##              999985 rows omitted
{% endhighlight %}

Using `describe()`, we see that this simulation --
which doesn't 'know' anything about hypergeometric
and geometric distributions, produces the same answers
that we arrived at by analytical means: 
There's a 1.85% chance that we end up believing the lady
even if she has no discriminatory ability whatsoever.
And if she doesn't have any discriminatory ability,
we'll need 1.3 rounds on average before terminating the
experiment:

{% highlight julia %}
describe(d)
{% endhighlight %}



{% highlight text %}
## 2×7 DataFrame
##  Row │ variable    mean      min      median   max      nmissing  eltype
##      │ Symbol      Float64   Integer  Float64  Integer  Int64     DataType
## ─────┼─────────────────────────────────────────────────────────────────────
##    1 │ Successful  0.018457    false      0.0     true         0  Bool
##    2 │ Attempts    1.29573         1      1.0        9         0  Int64
{% endhighlight %}

The ever so slight discrepancy between the simulation-based
results and the analytical ones are just due to randomness.
Below is a quick way for constructing 95% confidence
intervals around both of our simulation-based estimates,
and the analytical solutions fall within both intervals.


{% highlight julia %}
means = mean.(eachcol(d))
{% endhighlight %}



{% highlight text %}
## 2-element Vector{Float64}:
##  0.018457
##  1.295729
{% endhighlight %}



{% highlight julia %}
ses = std.(eachcol(d)) / sqrt(runs)
{% endhighlight %}



{% highlight text %}
## 2-element Vector{Float64}:
##  0.0001345970180477906
##  0.0006191088287649774
{% endhighlight %}



{% highlight julia %}
upr = means + 1.96*ses
{% endhighlight %}



{% highlight text %}
## 2-element Vector{Float64}:
##  0.01872081015537367
##  1.2969424533043792
{% endhighlight %}



{% highlight julia %}
lwr = means - 1.96*ses
{% endhighlight %}



{% highlight text %}
## 2-element Vector{Float64}:
##  0.018193189844626333
##  1.2945155466956206
{% endhighlight %}

