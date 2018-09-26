---
layout: post
title: "Introducing cannonball - Tools for teaching statistics"
category: [Teaching]
tags: [cannonball, R]
---

I've put my first R package on GitHub!
It's called `cannonball` and contains a couple of functions that I use for teaching;
perhaps others will follow.
 
<!--more-->

# Installation 
Make sure you have the `devtools` package:


{% highlight r %}
install.packages("devtools")
{% endhighlight %}

Then load it and install `cannonball`:


{% highlight r %}
library(devtools)
install_github("janhove/cannonball")
{% endhighlight %}

To use it, load the package as per usual:


{% highlight r %}
library(cannonball)
{% endhighlight %}




# Overview of the functions

## plot_r(): Draw scatterplots with the same correlation coefficient
People seem to like this function from my
blog post [_What data patterns can lie behind a correlation coefficient?_](http://janhove.github.io/teaching/2016/11/21/what-correlations-look-like). Specify the number of observations and a desired sample Pearson correlation coefficient, and out come 16 rather different looking scatterplots conforming to these criteria:


{% highlight r %}
plot_r(r = -0.6, n = 42)
{% endhighlight %}

![center](/figs/2018-09-26-cannonball/unnamed-chunk-18-1.png)

For more details, type in `?plot_r` at the R prompt.

## clustered_data(): Simulate data from a cluster-randomised experiment
Cluster-randomised experiments are experiments in which whole groups
of participants (e.g., entire classes) are necessarily assigned to the same
condition. If the data from such experiments are analysed as though the
participants were assigned to the conditions _individually_ (e.g., by
running a _t_-test on the individual data points), the false positive rate
can go [through the roof](http://janhove.github.io/design/2015/09/17/cluster-randomised-experiments).
This function simulates data from such an experiment and allows
you to specify unequal cluster sizes (via the `parts_per_class` parameter):


{% highlight r %}
# Generate data
d <- clustered_data(ICC = 0.15, # intra-class correlation coefficient
                    parts_per_class = c(8, 13, 28, # sizes of the control clusters
                                        22, 18, 16),# sizes of the intervention clusters
                    effect = 0) # population effect size

# Plot
library(ggplot2)
ggplot(data = d,
       aes(x = class,
           y = outcome,
           fill = group_class)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(shape = 1,
             position = position_jitter(width = 0.1, height = 0))
{% endhighlight %}

![center](/figs/2018-09-26-cannonball/unnamed-chunk-19-1.png)

I mostly use this function in a simulation to illustrate the
effects of clustering on p-values. With a null effect, you'd
expect only 5% of the p-values to be lower than 0.05. Let's
see what happens when you analyse the individual data from 
a cluster-randomised experiment using a t-test:


{% highlight r %}
p_vals <- replicate(5000, {
  d <- clustered_data(ICC = 0.15,
                      parts_per_class = c(8, 13, 28, 22, 18, 16),
                      effect = 0)
  p <- t.test(outcome ~ group_class, data = d)$p.value
  return(p)
})
hist(p_vals)
{% endhighlight %}

![center](/figs/2018-09-26-cannonball/unnamed-chunk-20-1.png)

{% highlight r %}
mean(p_vals < 0.05)
{% endhighlight %}



{% highlight text %}
## [1] 0.3322
{% endhighlight %}

The false positive rate is now through the roof (33%).

## Graphically checking model assumptions
See the full-fledged [tutorial](http://janhove.github.io/tutorials/assumptions.html) for these functions.

# Why `cannonball`?
Glad you asked! Julian 'Cannonball' Adderley is one of my favourite alto saxophone players (check out his solos on [_Autumn Leaves_](https://www.youtube.com/watch?v=u37RF5xKNq8) (from around 2'03"; Somethin' Else) or [_Freddie Freeloader_](https://www.youtube.com/watch?v=RPfFhfSuUZ4) (6'22"; Kind of Blue)!) and he was a consummate jazz educator to boot.
