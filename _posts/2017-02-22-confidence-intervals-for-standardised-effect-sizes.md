---
layout: post
title: "Confidence intervals for standardised mean differences"
category: [Analysis]
tags: [R, effect sizes]
---

Standardised effect sizes express patterns found in the data in 
terms of the variability found in the data. For instance, a mean difference
in body height could be expressed in the metric in which the data were
measured (e.g., a difference of 4 centimetres) or relative to the 
variation in the data (e.g., a difference of 0.9 standard deviations).
The latter is a standardised effect size known as Cohen's _d_.

As I've 
[written]({% post_url 2015-02-05-standardised-vs-unstandardised-es %}) 
[before]({% post_url 2015-03-16-standardised-es-revisited %}), 
I don't particularly like standardised effect sizes.
Nonetheless, I wondered how confidence intervals around standardised
effect sizes (more specifically: standardised mean differences) 
are constructed. Until recently, I hadn't really thought about it
and sort of assumed you would compute them the same way as 
confidence intervals around
raw effect sizes. But unlike raw (unstandardised) mean differences,
standardised mean differences are a combination of _two_ estimates 
subject to sampling error: the mean difference itself 
and the sample standard deviation. 
Moreover, the sample standard deviation is a biased estimate of 
the population standard deviation (it tends to be 
[too low](https://en.wikipedia.org/wiki/Unbiased_estimation_of_standard_deviation#Background)),
which causes Cohen's _d_ to be an upwardly biased estimate of the 
population standardised mean difference.
Surely both of these factors must affect how 
the confidence intervals around standardised effect sizes are constructed?

It turns out that indeed they do. When I compared the confidence
intervals that I computed around a standardised effect size
using a naive approach that assumed that the standard deviation
wasn't subject to sampling error and wasn't biased, I got different 
results than when I used specialised R functions.

But these R functions all produced different results, too.

Obviously, there may well be more than one way to skin a cat, but this
caused me to wonder if the different procedures for computing confidence
intervals all covered the true population parameter with the nominal
probability (e.g., in 95% of cases for a 95% confidence interval).
I ran a simulation to find out, which I'll report in the remainder of this post.
**If you spot any mistakes, please let me know.**

<!--more-->

### Introducing the contenders

Below, I'm going to introduce three R functions for computing
confidence intervals for standardised effect sizes (standardised mean
differences, to be specific). To illustrate how they work, though,
I'm first going to generate a two samples
from normal distributions with standard deviations of 1 and
means of 0.5 and 0, respectively.


{% highlight r %}
# Set random seed for reproducible results
# (today's date)
set.seed(2017-02-21)

# Population standardised mean difference
d <- 0.5
# Number of observations per sample
n <- 20

# Generate data
y <- c(rnorm(n, d, sd = 1), 
       rnorm(n, 0, sd = 1))
x <- factor(c(rep("A", n),
              rep("B", n)))
{% endhighlight %}

#### `cohen.d` in the `effsize` package

The first function is `cohen.d` from the `effsize` package.
It takes as its arguments the two samples you want to compare and
the desired confidence level (here: 90%). You can also specify
whether you want to apply `hedges.correction`, 
which causes the function to compute
[Hegdes' _g_](https://en.wikipedia.org/wiki/Effect_size#Hedges.27_g)
and confidence intervals for it.
(Hedges' _g_ is less biased than Cohen's _d_.)


{% highlight r %}
effsize::cohen.d(y, x, conf.level = 0.9,
                 hedges.correction = FALSE)
{% endhighlight %}



{% highlight text %}
## 
## Cohen's d
## 
## d estimate: 0.8112944 (large)
## 90 percent confidence interval:
##      inf      sup 
## 0.241104 1.381485
{% endhighlight %}

90% confidence interval for Cohen's _d_: [0.24, 1.38].


{% highlight r %}
effsize::cohen.d(y, x, conf.level = 0.9,
                 hedges.correction = TRUE)
{% endhighlight %}



{% highlight text %}
## 
## Hedges's g
## 
## g estimate: 0.7951759 (medium)
## 90 percent confidence interval:
##       inf       sup 
## 0.2258802 1.3644717
{% endhighlight %}

90% confidence interval for Hedges' _g_: [0.23, 1.36].

(Incidentally, `cohen.d` also has a parameter called `noncentral`, 
but setting it to `TRUE` doesn't seem to work...)

#### `tes` in the `compute.es` package

The second function is `tes` from the `compute.es` package.
It takes as its arguments the _t_ statistic for the _t_ test comparing the two samples,
the sample sizes and the desired confidence level (as a percentage, not as a proportion):


{% highlight r %}
# Compute t-statistic
t.stat <- t.test(y ~ x, var.equal = TRUE)$statistic
# Compute effect sizes and confidence intervals
compute.es::tes(t.stat, n.1 = 20, n.2 = 20, level = 90)
{% endhighlight %}



{% highlight text %}
## Mean Differences ES: 
##  
##  d [ 90 %CI] = 0.81 [ 0.26 , 1.37 ] 
##   var(d) = 0.11 
##   p-value(d) = 0.02 
##   U3(d) = 79.14 % 
##   CLES(d) = 71.69 % 
##   Cliff's Delta = 0.43 
##  
##  g [ 90 %CI] = 0.8 [ 0.25 , 1.34 ] 
##   var(g) = 0.1 
##   p-value(g) = 0.02 
##   U3(g) = 78.67 % 
##   CLES(g) = 71.3 % 
##  
##  Correlation ES: 
##  
##  r [ 90 %CI] = 0.38 [ 0.13 , 0.59 ] 
##   var(r) = 0.02 
##   p-value(r) = 0.02 
##  
##  z [ 90 %CI] = 0.41 [ 0.13 , 0.68 ] 
##   var(z) = 0.03 
##   p-value(z) = 0.02 
##  
##  Odds Ratio ES: 
##  
##  OR [ 90 %CI] = 4.36 [ 1.59 , 11.91 ] 
##   p-value(OR) = 0.02 
##  
##  Log OR [ 90 %CI] = 1.47 [ 0.47 , 2.48 ] 
##   var(lOR) = 0.36 
##   p-value(Log OR) = 0.02 
##  
##  Other: 
##  
##  NNT = 3.47 
##  Total N = 40
{% endhighlight %}

This function outputs a lot of standardised effect sizes and their confidence intervals.
Here, I'm only interested in Cohen's _d_, whose 90% confidence interval now is [0.26, 1.37]. 
(The confidence interval for Hedges' _g_ is also different from that from the `cohen.d` function.)

Note, incidentally, that the Cohen's _d_ and Hedges' _g_ values are the same for the 
`tes` and the `cohen.d` function; 
it's just the confidence intervals that are different.

#### `ci.smd` in the `MBESS` package

Lastly, the `ci.smd` function from the `MBESS` package takes
as its input a Cohen's _d_, the two sample sizes, and the desired confidence level.
Here I compute Cohen's _d_ using the `cohen.d` function and then feed it to `ci.smd`.


{% highlight r %}
# Compute Cohen's d
d.stat <- effsize::cohen.d(y, x, conf.level = 0.9,
                           hedges.correction = FALSE)$estimate

# Compute confidence intervals
MBESS::ci.smd(smd = d.stat, n.1 = 20, n.2 = 20, conf.level = 0.9)
{% endhighlight %}



{% highlight text %}
## $Lower.Conf.Limit.smd
## [1] 0.2641582
## 
## $smd
##         A 
## 0.8112944 
## 
## $Upper.Conf.Limit.smd
## [1] 1.348279
{% endhighlight %}

This time, the 90% confidence interval is [0.26, 1.35]. 
It was fairly small differences between the three functions 
such as these that led me to run the simulation I report below.

### Coverage of the population standardised mean difference by different confidence intervals

#### Method
For the simulation I generated lots of samples from two normal distributions
with the same standard deviation whose means where half a standard deviation apart.
In other words, the population standardised mean difference was 0.5.
For each sample, I computed 90% confidence intervals around the sample standardised
mean difference (Cohen's d) using the `cohen.d`, `tes` and `ci.smd` functions;
I also computed 90% confidence intervals around Hedges' _g_ using the `cohen.d` function.
I then checked how often these intervals contained the population mean standardised 
difference (0.5). Ideally, this should be the case in about 90% of the samples generated.
If it's fewer than that, the confidence intervals are too narrow;
if it's more than that, they're too wide.
I ran this simulation for different sample sizes, ranging from 5 observations per
group to 500 per group.

The R code for this simulation is available at the bottom of this post.

#### Results

![center](/figs/2017-02-22-confidence-intervals-for-standardised-effect-sizes/unnamed-chunk-6-1.png)

> Figure 1. Coverage of the population standardised mean difference (0.5)
> by confidence intervals computed using the `cohen.d`, `tes` and `ci.smd` functions
> based on 10,000 simulation runs per sample size.
> The dashed horizontal line shows the nominal confidence level;
> the grey lines around it show the values between which the coverage rates should
> lie with 95% probability if the confidence interval had their nominal coverage rate.

As Figure 1 clearly shows, the coverage rates for the confidence intervals computed around
Cohen's _d_ using the `ci.smd` function are at their nominal level even for small samples.
The confidence intervals computed using the `cohen.d` and `tes` functions, however, are too wide
for sample sizes of up to 50 observations per group.

### Conclusions and further reading
First of all, I want to reiterate that I think standardised effect sizes,
including standardised mean differences and correlation coefficients,
are overvalued and that I think we should strive to interpret 
raw effect sizes instead.

That said, on a practical level, this simulation suggests that 
if you nonetheless want to express your results as a standardised
mean difference and you want to compute a confidence around it, 
it's a good idea to take a look at the `MBESS` package.
The package's [vignette](http://www.jstatsoft.org/v20/i08/paper) also has 
a good discussion of how exact confidence intervals can be constructed around standardised effect sizes,
and the package provides a fast implementation of these methods.

By contrast, the `effsize` and `compute.es` packages seem to rely on overly
conservative approximations to these exact methods, and differ between
each other in how the variance for Cohen's _d_ is computed (see [here](https://cran.r-project.org/web/packages/compute.es/compute.es.pdf#page=81)
and [here](https://cran.r-project.org/web/packages/effsize/effsize.pdf#6)).

For those of you interested in further details, Wolfgang Viechtbauer provided
[some](https://twitter.com/wviechtb/status/834009942323519489) 
[links](https://twitter.com/wviechtb/status/834047963307634688) on Twitter that you may want to take a look at.

<hr />

### R code

For those interested, here's the R code I used for the simulation.
If you spot an error that explains the results above, please let me know.

First, I defined a function, `d_ci`, that generates two samples from normal distributions
with standard deviations of 1. In the simulation, the mean difference between these populations
is 0.5, which, since both population have standard deviations of 1, means that the
true standardised mean difference is 0.5.
Then, four confidence intervals are computed around the sample Cohen's _d_:

1. Using `cohen.d` with Hedges' correction.  
2. Using `tes`. (I only used the code relevant to Cohen's _d_ to speed things up.)
3. Using `ci.smd`.
4. Using `cohen.d` without Hedges' correction.

`d_ci` simply returns, for each of these four intervals, whether they contain the true
population standardised mean difference (i.e., 0.5).


{% highlight r %}
d_ci <- function(d = 0.5, n = 20, ci = 0.80) {
  # Two samples with specified d
  y <- c(rnorm(n, d, sd = 1), 
         rnorm(n, 0, sd = 1))
  x <- factor(c(rep("A", n),
                rep("B", n)))

  # Run t-test
  ttest <- t.test(y ~ x, var.equal = TRUE, conf.level = ci)

  # Effect size using effsize package ----------------------
  # with Hedges' correction
  es <- effsize::cohen.d(y, x, conf.level = ci, 
                         hedges.correction = TRUE
  d.lo1 <- es$conf.int[1]
  d.hi1 <- es$conf.int[2]

  # Effect size using compute.es ---------------------------
  # This is a selection from the source code for compute.es::tes.
  df <- 2 * n - 2
  d.est2 <- ttest$statistic * sqrt((2 * n)/(n * n))
  var.d <- (2 * n)/(n * n) + (d.est2^2) / (2 * (2 * n))
  crit <- qt((1 - ci)/2, df, lower.tail = FALSE)
  d.lo2 <- d.est2 - crit * sqrt(var.d)
  d.hi2 <- d.est2 + crit * sqrt(var.d)
  
  # MBESS package ---------------------------------------
  # (d.est2 computed above for compute.es)
  mbess_out <- MBESS::ci.smd(smd = d.est2, n.1 = n, n.2 = n, conf.level = ci)
  d.lo3 <- mbess_out$Lower.Conf.Limit.smd
  d.hi3 <- mbess_out$Upper.Conf.Limit.smd
  
  # Effect size using effsize package 
  # no hedges corrections ----------------------
  es4 <- effsize::cohen.d(y, x, conf.level = ci, 
                         hedges.correction = FALSE)
  d.lo4 <- es4$conf.int[1]
  d.hi4 <- es4$conf.int[2]
  
  # In CI? ----------------------------------------------------
  d.in.ci1 <- (d < d.hi1 && d > d.lo1)      # effsize::cohen.d
  d.in.ci2 <- (d < d.hi2 && d > d.lo2)      # compute.es::tes
  d.in.ci3 <- (d < d.hi3 && d > d.lo3)      # MBESS::ci.smd
  d.in.ci4 <- (d < d.hi4 && d > d.lo4)      # MBESS::ci.smd
  
  # Return -------------------------------------------- 
  return(list(d.in.ci1, d.in.ci2, d.in.ci3, d.in.ci4))
}
{% endhighlight %}

Then I wrote a function, `sim_es`, which runs `d_ci` a set number of times
and return the proportion of times the four confidence intervals
contained the true population _d_.


{% highlight r %}
# Run d_ci a couple of times and store the coverage rates
sim_es <- function(runs = 1e1, n = 10, d = 0.5, ci = 0.8) {
  reps <- replicate(runs, d_ci(n = n, d = d, ci = ci))
  return(list(mean(unlist(reps[1, ])),
              mean(unlist(reps[2, ])),
              mean(unlist(reps[3, ])),
              mean(unlist(reps[4, ]))))
}
{% endhighlight %}

Next I ran `sim_es` 10,000 times for 9 different samples, from
5 observations per sample to 500.
The desired confidence level was 90%.


{% highlight r %}
# Define the sample sizes
sampleSizes <- c(5, 10, 20, 30, 40, 50,
                 100, 200, 500)

# Define the confidence level and the number of runs
ci <- 0.90
runs <- 10000

# Evaluate sim_es for different sampleSizes
# but with runs and ci set to the same value each time.
# You can use mapply instead of mcmapply.
# Remove the last line (with mc.cores) in that case.
library(parallel)
results <- mcmapply(sim_es,
                    n = sampleSizes,
                    MoreArgs = list(runs = runs, ci = ci),
                    mc.cores = detectCores())
{% endhighlight %}

Finally, I stored the results to a dataframe and plotted them.


{% highlight r %}
# Store results in dataframe
d_results <- data.frame(sampleSizes)
d_results$`cohen.d (correction) in\neffsize package` <- unlist(results[1, ])
d_results$`tes in\ncompute.es package` <- unlist(results[2, ])
d_results$`ci.smd in\nMBESS package` <- unlist(results[3, ])
d_results$`cohen.d (no correction) in\neffsize package` <- unlist(results[4, ])

# Load packages for plotting
library(magrittr)
library(tidyr)
library(ggplot2)
library(cowplot)

# Plot
ggplot(d_results %>% 
         gather(., Method, Coverage, -sampleSizes),
       aes(x = sampleSizes,
           y = Coverage)) +
  # Draw lines for expected coverage rate and its 2.5 and 97.5% percentiles.
  geom_hline(yintercept = qbinom(p = 0.025, runs, ci)/runs, colour = "grey80") +
  geom_hline(yintercept = qbinom(p = 0.975, runs, ci)/runs, colour = "grey80") +
  geom_hline(yintercept = ci, linetype = 2, colour = "grey10") +
  geom_point() +
  geom_line() +
  scale_x_log10(breaks = c(5, 50, 500, 5000)) +
  scale_y_continuous(breaks = seq(0.8, 1, 0.02)) +
  facet_wrap(~ Method, ncol = 4) +
  xlab("sample size per group") +
  ylab("Coverage of true standardised d\nby 90% confidence interval") +
  theme(legend.position = "top", legend.direction = "vertical")
{% endhighlight %}
