---
title: "Nonparametric tests aren't a silver bullet when parametric assumptions are violated"
layout: post
mathjax: true
tags: [R, power, significance, simplicity, assumptions, nonparametric tests]
category: [Analysis]
---

Some researchers adhere to a simple strategy when comparing data from two
or more groups:
when they think that the data in the groups are normally distributed,
they run a parametric test ($t$-test or ANOVA);
when they suspect that the data are not normally distributed,
they run a nonparametric test (e.g., Mann--Whitney or Kruskal--Wallis).
Rather than follow such an automated approach to analysing data, I think
researchers ought to consider the following points:

* The $t$-test and ANOVA compare _means_; the Mann--Whitney and Kruskal--Wallis don't.
* The Mann--Whitney and Kruskal--Wallis do _not_ in general compare medians, either. I'll illustrate these first two points in this blog post.
* The main problem with parametric tests when you have nonnormal data is that these tests compare means, but that these means don't necessarily capture a relevant aspect of the data. But even if the data aren't normally distributed, comparing means can sometimes be reasonable, depending on what the data look like and what it is you're actually interested in. And if you _do_ want to compare means, parametric tests or bootstrapping are more sensible than running a nonparametric test. See also my blog post [_Before worrying about model assumptions, think about model relevance_]({% post_url 2019-04-11-assumptions-relevance %}).
* If you want to compare medians, look into bootstrapping or quantile regression.
* Above all, make sure that you know you're comparing when you run a test and that this comparison makes sense in light of the data _and your research question_.

In this blog post, I'll share the results of some simulations that demonstrate
that the Mann--Whitney (a) picks up on differences in the variance between
two distributions, even if they have the same mean and median;
(b) picks up on differences in the median between two distributions,
even if they have the same mean and variance;
and (c) picks up on differences in the mean between two distributions,
even if they have the same median and variance.
These points aren't new (see Zimmerman 1998), but since the automated
strategy ('parametric when normal, otherwise nonparemetric') is pretty widespread,
they bear repeating.

<!--more-->





<!-- ## Different distribution, but same mean, same median, same variance -->

<!-- Compare a sample drawn from a normal distribution with mean (and median) 0 -->
<!-- and standard deviation 1 -->
<!-- to a sample drawn from a uniform distribution from $-\sqrt{3}$ to $\sqrt{3}$. -->
<!-- This uniform distribution also has a mean and median of 0 and a standard -->
<!-- deviation of 1. -->



<!-- > **Figure 1.** -->

<!-- About 5% of significant results for both. -->

## Same mean, same median, different variance
The first simulation demonstrates the Mann--Whitney's sensitivity
to differences in the variance. I simulated samples
from a uniform distribution going from $-\sqrt{3}$ to $\sqrt{3}$
as well as from a uniform distribution going from $-3\sqrt{3}$ to $3\sqrt{3}$.
Both distributions have a mean and median of 0,
but the standard deviation of the first is 1 and that of the second is 3.
I compared these samples using a Mann--Whitney and recorded the $p$-value.
I generated samples of both 50 and 500 observations and repeated this
process 10,000 times. You can reproduce this simulation using the code below.

**Figure 1** shows the distribution of the $p$-values. 
Even though the distributions' means and medians are the same,
the Mann--Whitney returns significance ($p < 0.05$) in about 7% of the comparisons
for the smaller samples
and 18% for the larger samples. If the test were sensitive only to differences
in the mean or median, if should return significance in only 5% of the comparisons.


{% highlight r %}
# Load package for plotting
library(ggplot2)

# Set number of simulation runs
n_sim <- 10000

# Draw a sample of 50 observations from two uniform distributions with the same 
# mean and median but with different variances/standard deviations.
# Run the Mann-Whitney on them (wilcox.test()).
# Repeat this n_sim times.
pvals_50 <- replicate(n_sim, {
  x <- runif(50, min = -3*sqrt(3), max = 3*sqrt(3))
  y <- runif(50, min = -sqrt(3), max = sqrt(3))
  wilcox.test(x, y)$p.value
})

# Same but with samples of 500 observations.
pvals_500 <- replicate(n_sim, {
  x <- runif(50, min = -3*sqrt(3), max = 3*sqrt(3))
  y <- runif(500, min = -sqrt(3), max = sqrt(3))
  wilcox.test(x, y)$p.value
})

# Put in data frame
d <- data.frame(
  p = c(pvals_50, pvals_500),
  n = rep(c(50, 500), each = n_sim)
)

# Plot
ggplot(data = d,
       aes(x = p,
           fill = (p < 0.05))) +
  geom_histogram(
    breaks = seq(0, 1, 0.05),
    colour = "grey20") +
  scale_fill_manual(values = c("grey70", "red")) +
  facet_wrap(~ n) +
  geom_hline(yintercept = n_sim*0.05, linetype = 2) +
  theme(legend.position = "none") +
  labs(
    title = element_blank(),
    subtitle = "Same mean, same median, different variance",
    caption = "Comparison for two sample sizes (50 vs. 500 observations per group):
    uniform distribution from -sqrt(3) to sqrt(3)
    vs. uniform distribution from -3*sqrt(3) to 3*sqrt(3)"
  )
{% endhighlight %}

![center](/figs/2020-05-23-nonparametric/unnamed-chunk-96-1.png)

> **Figure 1.**

## Same mean, different median, same variance
The second simulation demonstrates that the Mann--Whitney does not
compare means. The simulation set-up was the same as before, but the samples
were drawn from different distributions.
The first sample was drawn from a log-normal distribution 
with mean $\exp{(\ln{10} + \frac{1}{2})} \approx 16.5$,
median 10 and standard deviation $\sqrt{(\exp{(1)}-1)\exp{(2\ln{10}+1)}} \approx 21.6$.
The second sample was drawn from a normal distribution
with the same mean (i.e., about 16.5) and the same standard deviation
(i.e., about 21.6), but with a different median (viz., 16.5 rather than 10).

**Figure 2** shows that the Mann--Whitney returned
significance for 12% of the comparisons of the smaller samples
and 92% of the comparisons for the larger samples.
So the Mann--Whitney does _not_ test for differences in the mean;
otherwise only 5% of the comparisons should have been significant
(since the means of the distributions are the same).



![center](/figs/2020-05-23-nonparametric/unnamed-chunk-98-1.png)

> **Figure 2.**

## Different mean, same median, same variance
The last simulation demonstrates that the Mann--Whitney does not
compare medians, either. 
The first sample was again drawn from a log-normal distribution 
with mean $\exp{(\ln{10} + \frac{1}{2})} \approx 16.5$,
median 10 and standard deviation $\sqrt{(\exp{(1)}-1)\exp{(2\ln{10}+1)}} \approx 21.6$.
The second sample was now drawn from a normal distribution
with the same median (i.e., 10) and the same standard deviation
(i.e., about 21.6), but with a different mean (viz., 10 rather than 16.5).

**Figure 3** shows that the Mann--Whitney returned
significance for 20% of the comparisons of the smaller samples
and 91% of the comparisons for the larger samples.
So the Mann--Whitney does _not_ test for differences in the median;
otherwise only 5% of the comparisons should have been significant
(since the medians of the distributions are the same).

![center](/figs/2020-05-23-nonparametric/unnamed-chunk-99-1.png)

> **Figure 3.**

## Nonparametric tests make assumptions, too
Many researchers think that nonparametric tests don't
make any assumptions about the distributions from which the data were drawn.
This belief is half-true (i.e., wrong):
Nonparametric tests such as the Mann--Whitney don't assume that the data were
drawn from a _specific_ distribution (e.g., from a normal distribution). However,
they do assume that the data in the different groups being compared were drawn
from the _same_ distribution (but for a shift in the location of this distribution).
If researchers run nonparametric tests because they are worried about violating
the assumptions of parametric tests, I suggest they worry about the assumptions
of their nonparametric tests, too.

But a better solution in my view is to 
them to consider more carefully what they actually want to compare.
If it is really the means that are of interest, parametric tests are often okay,
and their results can be double-checked using the bootstrap if needed. Permutation
tests would be an alternative.
If it is the medians that are of interest, quantile regression, bootstrapping,
or permutation tests may be useful.
If another measure of the data's central tendency is of interest, robust regression
may be useful.
A discussion of these techniques is beyond the scope of this blog post, whose
aims merely were to alert researchers to the fact that nonparametric tests
aren't a silver bullet when parametric assumptions are violated and that
nonparametric tests aren't just sensitive to differences in the mean or median.

## Reference

Zimmerman, Donald W. 1998. [Invalidation of parametric and nonparametric statistical tests by concurrent violation of two assumptions](https://doi.org/10.1080/00220979809598344). _Journal of Experimental Education_ 67(1). 55-68.
