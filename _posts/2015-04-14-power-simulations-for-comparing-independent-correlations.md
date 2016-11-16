---
layout: post
title: "Power simulations for comparing independent correlations"
thumbnail: /figs/thumbnails/2015-04-14-power-simulations-for-comparing-independent-correlations.png
category: [Design]
tags: [significance, power, R]
---

Every now and then, researchers want to compare the strength of a correlation between two samples or studies.
Just establishing that one correlation is significant while the other isn't [doesn't work]({% post_url 2014-10-28-assessing-differences-of-significance %}) -- 
what needs to be established is whether the _difference_ between the two correlations is significant.
I wanted to know how much power a comparison between correlation coefficients has,
so I wrote some simulation code to find out.

<!--more-->

### The results

The contour plots below show the power
of comparisons with sample sizes of 2×20, 2×40 and 2×80 observations for all combinations of population correlation coefficients.
For instance, the first contour plot shows
that you have about 90% power to find a significant difference between two correlation coefficients
if the true population correlation in population A (x-axis) is 0.4 and -0.6 in population B (y-axis)
and both sample contain 20 observations.
If the correlation in population B is -0.2, however, you have less than 50% power.
In blue is the contour line for 80% power for reference.



![center](/figs/2015-04-14-power-simulations-for-comparing-independent-correlations/unnamed-chunk-2-1.png) 

For unequal sample sizes, the contour plot might look like this:

![center](/figs/2015-04-14-power-simulations-for-comparing-independent-correlations/unnamed-chunk-3-1.png) 

### Conclusions
Not really any new insights, but a good opportunity to stress once again that [_The difference between "significant" and "not significant" is not itself statistically significant_](http://www.tandfonline.com/doi/abs/10.1198/000313006X152649#.VEn854_sM7w). 
And I got to play around with the `outer` and `mapply` functions,
which are quite useful for avoiding for-loops in simulations (see below).

### Caveat
These simulations estimate the power for comparisons of _independent_ correlations.
Independent correlations are correlations computed for different samples (or different studies).
An example of _dependent_ correlations would be when you measure a variable,
e.g. Italian proficiency, and correlate it to two other variables (e.g., French proficiency and Spanish proficiency) using the same participants.
Since you used the same participants, there will exist some intercorrelation between French proficiency and Spanish proficiency, which needs to be taken into account when comparing the correlations between Italian and French proficiency on the one hand and Italian and Spanish proficiency on the other.

### Simulation code

First load the `MASS` and `psych` packages (run `install.packages(c("MASS", "psych"))` if they aren't installed yet).


{% highlight r %}
library(MASS)
library(psych)
{% endhighlight %}

Using the `mvrnorm` function from the `MASS` package, 
we can generate samples drawn from a bivariate normal distribution with a specific population correlation coefficient (the numbers of the antidiagonal in the `Sigma` parameter; in this example: 0.3).
With `cor` we compute the _sample_ correlation coefficients for these samples;
these will differ from sample to sample.


{% highlight r %}
# Example
# Generate sample with n = 25 and r = 0.25
sample25 <- mvrnorm(25, mu = c(0, 0), # means of the populations, doesn't matter 
                    Sigma = matrix(c(1, 0.3, 
                                     0.3, 1), ncol = 2))
# Compute correlation matrix
cor(sample25[,1], sample25[,2])
{% endhighlight %}



{% highlight text %}
## [1] 0.3293883
{% endhighlight %}

With the `r.test` function from the `psych` package,
we can compute the significance of the _difference_ between two sample correlation coefficients.
In this case, the correlation coefficients were computed for independent samples,
hence the `r12` and `r34` parameters are specified.


{% highlight r %}
# Example
# Compute p-value for difference btwn sample cors
# of 0.5 (n = 20) and 0.2 (n = 50)
r.test(n = 20, r12 = 0.5,
       n2 = 50, r34 = 0.2)$p
{% endhighlight %}



{% highlight text %}
## [1] 0.2207423
{% endhighlight %}

With that out of the way, we now write a new function, `compute.p`,
that generates two samples of sizes `n1` and `n2`, respectively,
from bivariate normal distributions with _population_ correlations of `popr12` and `popr34`, respectively.


{% highlight r %}
compute.p <- function(popr12, popr34, n1, n2) {
  return(r.test(n = n1, n2 = n2,
                r12 = cor(mvrnorm(n1, mu = c(0, 0), 
                                  Sigma = matrix(c(1, popr12, 
                                                   popr12, 1), ncol = 2)))[1,2], 
                r34 = cor(mvrnorm(n2, mu = c(0, 0), 
                                  Sigma = matrix(c(1, popr34, 
                                                   popr34, 1), ncol = 2)))[1,2])$p)
}
# Example
compute.p(n1 = 20, popr12 = 0.5, n2 = 50, popr34 = 0.2)
{% endhighlight %}



{% highlight text %}
## [1] 0.6419873
{% endhighlight %}

Now we write another function, `compute.power`, that takes `compute.p`, runs it, say, 1000 times,
and returns how many p-values lie below 0.05 -- i.e., the comparison's estimated power.


{% highlight r %}
compute.power <- function(n.sims = 1000, popr12, popr34, n1, n2) {
  return(mean(replicate(n.sims, 
                        compute.p(popr12 = popr12, popr34 = popr34, 
                                  n1 = n1, n2 = n2)
                        ) <= 0.05)
         )
}
# Example
compute.power(n.sims = 1000, 
              n1 = 20, popr12 = 0.5,
              n2 = 50, popr34 = 0.2)
{% endhighlight %}



{% highlight text %}
## [1] 0.252
{% endhighlight %}

Here's where the R fun begins. 
I want to compute the power not only for a single comparison,
but for nearly the whole `popr12` v. `popr34` spectrum of possible comparisons:
-0.95 v. -0.90, -0.95 v. -0.85, ..., 0.7 v. -0.3 etc.
All relevant correlations are stored in `corrs`:


{% highlight r %}
corrs <- seq(-0.95, 0.95, 0.05)
{% endhighlight %}

Using the `outer` function, I generate a grid featuring every possible combination of coefficients in `corrs` and run `compute.power` on each combination using `mapply`.
Here, I estimate the power for a comparison with two samples of 20 observations.


{% highlight r %}
results20 <- outer(corrs, corrs, 
                   function(x, y) mapply(compute.power, 
                                         popr12 = x, popr34 = y, 
                                         n1 = 20, n2 = 20, 
                                         n.sims = 1000))
{% endhighlight %}

With `contour`, the results matrix is then visualised:

{% highlight r %}
contour(x = corrs, y = corrs, z = results20, nlevels = 10, 
        labcex = 0.9, col = "gray26", at = seq(-1, 1, 0.2),
        main = "n = 20 in both samples",
        xlab = "Correlation in population A",
        ylab = "Correlation in population B")
abline(v = seq(-1, 1, 0.2), lwd = 1, col = "lightgray", lty = 2)
abline(h = seq(-1, 1, 0.2), lwd = 1, col = "lightgray", lty = 2)
contour(x = corrs, y = corrs, z = r20, levels = 0.80, 
        drawlabels = FALSE, at = seq(-1, 1, 0.2),
        add = TRUE, lwd = 3, col = "steelblue3")
{% endhighlight %}

This code could probably be optimised a bit;
the power for the comparison between -0.5 and 0.3 is obviously identical to
the power for the comparison between 0.5 and -0.3, for instance.


