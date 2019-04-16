---
title: "Walkthrough: A significance test for a two-group comparison"
layout: post
tags: [significance, R, walkthrough]
category: [Teaching]
---



I wrote an R function that's hopefully useful
to teach students what significance tests do
and how they can and can't be interpreted.

<!--more-->

I'll integrate the function in the `cannonball`
package when I'll come round to it. In the meantime,
you can use it by running the following line.


{% highlight r %}
source("https://raw.githubusercontent.com/janhove/janhove.github.io/master/RCode/walkthrough_p.R")
{% endhighlight %}

The basic use is simple. Just run `walkthrough_p()` and follow
the on-screen instructions.


{% highlight r %}
walkthrough_p()
{% endhighlight %}

## What does the function do?
Data are generated from a normal distribution with the requested
standard deviation. Then, the data points are randomly assigned to two
equal-sized groups. Data points in the intervention group receive a boost
as specified by 'diff'. Finally, a significance test is ran on the data.

By default, the significance test is a two-sample Student's t-test.
Technically, the p-value from this test is the probability
that a t-statistic larger than the one observed
would've been observed if only chance were at play, but
the walkthrough text says that is the probability that
a mean difference larger than the one observed would've
been observed if only chance were at play. That is,
I use the t-test as an approximation to a permutation test.
Switch on pedant mode if you want to run a permutation test.

## Parameters

* `n`: the number of data points per group
* `diff`: The boost that participants in the intervention group receive.
* `sd`: The standard deviation of the normal distribution from which the data were generated.
* `showdata`: Do you want to output a dataframe containing the plotted data (TRUE) or not (FALSE, default)?
* `pedant`: Do you want to run the significance test in pedant mode (TRUE; performs a permutation test) or not (FALSE, default; performs Student's t-test)?

## Examples


{% highlight r %}
walkthrough_p(n = 12, diff = 0.2, sd = 1.3)

# Save data and double check results
dat <- walkthrough_p(n = 10, diff = 0.2, sd = 2)
t.test(score ~ group, data = dat, var.equal = TRUE)

# Run in pedant mode (= permutation test)
dat <- walkthrough_p(n = 13, diff = 1, sd = 4, pedant = TRUE)
t.test(score ~ group, data = dat, var.equal = TRUE)
{% endhighlight %}

