---
layout: post
title: "Common-language effect sizes"
category: [Reporting]
tags: [simplicity, effect sizes, R]
---

The goal of this blog post is to share with you a simple `R` function
that may help you to better communicate the extent to which two groups differ and overlap
by computing _common-language effect sizes_.

<!--more-->

### What is the 'common-language effect size'?
In 1992, [McGraw and Wong](http://psycnet.apa.org/doi/10.1037/0033-2909.111.2.361) introduced the common-language effect size,
which they defined as

> the probability that a score sampled at random from
> one distribution will be greater than a score sampled from
> some other distribution.

For instance, if you have scores on an English reading comprehension task for
both French- and German-speaking learners, you can compute
the probability that a randomly chosen French-speaking learner
will have a higher score than a randomly chosen German-speaking learner.
This gives you an idea of how much the groups' scores overlap,
and the number can more easily be communicated to an audience that
has no firm notion of what quantiles are 
or of what standardised effect sizes such as _d = 0.3_ mean.

### Computing common-language effect sizes in R
Below I first generate some data:
40 data points in a group creatively called `A` vs. 30 data points in group `B`.


{% highlight r %}
# Generate data
set.seed(16-11-2016)
df <- data.frame(Outcome = c(rbeta(40, 4, 14),   # 40 observations in A
                             rbeta(30, 2, 4)),   # 30 in B
                 Group = c(rep("A", 40), rep("B", 30)))
{% endhighlight %}

A couple of boxplots to show the spread and central tendencies:

![center](/figs/2016-11-16-common-language-effect-sizes/unnamed-chunk-21-1.png)

And the key summary statistics:


{% highlight text %}
##   Group Mean Standard_Deviation
## 1     A 0.24              0.084
## 2     B 0.30              0.172
{% endhighlight %}

On the basis of the group means and standard deviations, McGraw and Wong's common-language
effect size can be computed as follows:


{% highlight r %}
pnorm(0, 0.24 - 0.30, sqrt(0.084^2 + 0.172^2), lower.tail = FALSE)
{% endhighlight %}



{% highlight text %}
## [1] 0.38
{% endhighlight %}

I.e., there's a 38% chance that if you put an observation from Group A and one from Group B together at random, the one from Group A will be greater.

Strictly speaking, McGraw and Wong's method assumes normally distributed, continuous data.
While they point out that their measure is quite robust with respect to this assumption,
you can use a brute-force method that doesn't make this assumption to see 
if that yields different results.

**Edit: On Twitter, Guillaume Rousselet [suggested](https://twitter.com/robustgar/status/798962929475457024) a quicker _and_ mor exhaustive brute-force method for computing common-language effect sizes. I've updated the code and post to implement his suggestion.**

On [http://janhove.github.io/RCode/CommonLanguageEffectSizes.R](http://janhove.github.io/RCode/CommonLanguageEffectSizes.R), 
I provide a function, `cles.fnc()`,
that pairs each observation from the first group to each observation from the second group
and then checks how often the observation from the first group is larger than the one from the second group.
Ties are also taken into account.

Here's how the `cles.fnc()` function works:


{% highlight r %}
# Read in the function
source("http://janhove.github.io/RCode/CommonLanguageEffectSizes.R")

# Set variable you want to compare between the groups,
# the group name,
# the baseline level,
# and the dataset:
cles <- cles.fnc(variable = "Outcome", group = "Group", baseline = "A", data = df)
{% endhighlight %}



{% highlight text %}
## Common-language effect size:
## 
## The probability that a random Outcome observation from group A
## is higher/larger than a random Outcome observation from the other group(s):
## 
##     Algebraic method:   0.38
##     Brute-force method: 0.4
{% endhighlight %}

The results for both methods aren't identical (38% vs. 40%), but they're in the same ballpark.
This is more often the case than not.

You can turn off the output by setting the parameter `print` to `FALSE`:

{% highlight r %}
## (not run)
# cles <- cles.fnc(variable = "Outcome", group = "Group", baseline = "A", data = df, print = FALSE)
{% endhighlight %}

You can also extract information from the `cles` object if you want to pass it on to other functions:


{% highlight r %}
cles$algebraic # McGraw & Wong's method
{% endhighlight %}



{% highlight text %}
## [1] 0.38
{% endhighlight %}



{% highlight r %}
cles$brute     # brute-force method
{% endhighlight %}



{% highlight text %}
## [1] 0.4
{% endhighlight %}


### An example with non-overlapping distributions
The code below generates a dataset with two non-overlapping groups.


{% highlight r %}
# Generate data
set.seed(16-11-2016)
df <- data.frame(Outcome = c(sample(0:20, 10, replace = TRUE),
                             sample(21:25, 10, replace = TRUE)),
                 Group = c(rep("A", 10), rep("B", 10)))
{% endhighlight %}

Boxplots:

![center](/figs/2016-11-16-common-language-effect-sizes/unnamed-chunk-28-1.png)

McGraw & Wong's (1992) method suggests that there's a 6% chance
that a random observation in A will be higher than one in B.
This may well be true at the population level, but it's clearly not true at the sample level.
The brute-force method pegs this probability at 0%, which may be wrong at the population level,
but it's clearly correct at the sample level.


{% highlight r %}
cles <- cles.fnc(variable = "Outcome", group = "Group", baseline = "A", data = df)
{% endhighlight %}



{% highlight text %}
## Common-language effect size:
## 
## The probability that a random Outcome observation from group A
## is higher/larger than a random Outcome observation from the other group(s):
## 
##     Algebraic method:   0.06
##     Brute-force method: 0
{% endhighlight %}

### For use with more complex datasets
Let's say you have data from a longitudinal study 
in which you collected data for Groups A and B at Times 1, 2 and 3,
and you want to compare the groups at each time:


{% highlight r %}
# Generate data
set.seed(16-11-2016)
df <- data.frame(Time = c(rep(1, 40), rep(2, 40), rep(3, 40)),
                 Group = rep(c(rep("A", 25), rep("B", 15)), 3),
                 Outcome = c(rnorm(25, 1.1, 1.0), rnorm(15, 1.2, 0.3),
                             rnorm(25, 1.2, 0.6), rnorm(15, 1.2, 0.8),
                             rnorm(25, 1.8, 0.4), rnorm(15, 1.7, 1.0)))
{% endhighlight %}

The boxplots:

![center](/figs/2016-11-16-common-language-effect-sizes/unnamed-chunk-31-1.png)

Using the `by()` function, you can run `cles.fnc()` separately for each `Time`.
For more complex datasets, you can include more variables in the `INDICES` list.


{% highlight r %}
cles <- with(df, # select dataframe df
             by(data = df, # group dataframe df
                INDICES = list(Time = Time), # by Time
                # and run cles.fnc() within each group
                FUN = function(x) cles.fnc("Outcome", "Group", "A", data = x, print = FALSE)))
cles
{% endhighlight %}



{% highlight text %}
## Time: 1
## $algebraic
## [1] 0.45
## 
## $brute
## [1] 0.55
## 
## -------------------------------------------------------- 
## Time: 2
## $algebraic
## [1] 0.46
## 
## $brute
## [1] 0.5
## 
## -------------------------------------------------------- 
## Time: 3
## $algebraic
## [1] 0.75
## 
## $brute
## [1] 0.77
{% endhighlight %}
