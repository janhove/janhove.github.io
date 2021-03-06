---
layout: post
title: "Calibrating p-values in 'flexible' piecewise regression models"
thumbnail: /figs/thumbnails/2014-08-20-adjusted-pvalues-breakpoint-regression.png
category: [Analysis]
tags: [significance, breakpoint regression, multiple comparisons, R]
---

Last year, I published an [article](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0069172) in which I critiqued the statistical tools used to assess the hypothesis that ultimate second-language (L2) proficiency is non-linearly related to the age of onset of L2 acquisition.
Rather than using ANOVAs or correlation coefficient comparisons, I argued, breakpoint (or piecewise) regression should be used.
But unless the breakpoint is specified in advance, such models are demonstrably anti-conservative.
Here I outline a simulation-based approach for calibrating the _p_-values of such models to take their anti-conservatism into account.


<!--more-->

### Piecewise regression
Piecewise (or breakpoint) regression is a pretty self-descriptive term:
it's a regression model with an elbow in the function.
For instance, in the graph below, the function relating _x_ to _y_ flattens for _x_ values higher than 0.5.

![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-1.png) 

What is important here is that the analyst has to specify at which _x_ point the regression curve is allowed to change slopes -- in the graph above, I had to specify the breakpoint parameter myself (see my [article](http://www.plosone.org/article/info%3Adoi%2F10.1371%2Fjournal.pone.0069172) on how this can be done).

### The problem: increased Type-I error rates

Language researchers may be familiar with piecewise regression
thanks to Harald Baayen's excellent [_Analyzing linguistic data_](http://www.cambridge.org/us/academic/subjects/languages-linguistics/grammar-and-syntax/analyzing-linguistic-data-practical-introduction-statistics-using-r),
in which he illustrates a method to automate the selection of the breakpoint.
Briefly, this method consists of looping through all possible breakpoints and fitting a piecewise regression model for each of them.
Then, the best-fitting model is retained.

In my article on analyses in critical period research, I too adopted this procedure in order to illustrate that the data in the two studies that I scrutinised were not characterised by the predicted non-linearities.
What I may have underemphasised in that article, however, is that this breakpoint selection procedure yields a **higher-than-nominal Type-I error rate** of finding a non-linearity.
In plain language, looping through several possible breakpoints increases your risk of finding non-linearities when in fact none exist.

The intuition behind this is probably (hopefully) dealt with in every introductory statistics course. If you run a two-samples _t_-test with an alpha level of 0.05, you accept a 5% risk to find a significant difference between the two groups even if the populations do not differ. If you run five _t_-tests on unrelated data, each with an alpha level of 0.05, the risk of finding a non-existing difference is still 5% for each test considered individually -- but the global risk ('familywise Type-I error rate') is now about 23%:

{% highlight r %}
1 - (1 - 0.05) ^ 5
{% endhighlight %}



{% highlight text %}
## [1] 0.2262
{% endhighlight %}

Similarly, if you loop through, say, 5 possible breakpoints to establish whether a non-linearity exists using piecewise regression, your Type-I error rate goes up.
But it won't be as high as 23% since you're not conducting the same analysis on unrelated data.
It'd be nice if we could calibrate the _p_-values from a piecewise regression model that suffers from this multiple comparison problem,
but I wouldn't know how to go about it analytically.
Instead, I suggest a **simulation-based approach**.
But first, let's make the problem a bit more concrete by turning to the actual datasets.

### The data
In my CPH article, I re-analysed two datasets from [DeKeyser et al. (2010)](http://dx.doi.org/10.1017/S0142716410000056).
The specifics of these two datasets aren't too important for our present purposes, so I'll skip them.
The two datasets are available [here](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/CPH/DeKeyser2010Israel.csv) (Israel data) and [here](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/CPH/DeKeyser2010NorthAmerica.csv) (North America data); the following plots show the relationship between the AOA (age of onset of L2 acquisition) and GJT (a measure of L2 proficiency) variables in both datasets.

![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-3.png) 

Piecewise regressions carried out using the a priori cut-off AOA values specified by DeKeyser et al. (AOA = 18) did not yield significant improvements over straightforward linear models ( _p_ = 0.98 and 0.07 for the Israel and North America data, respectively).
In a second series of analyses, I determined the optimal breakpoints following the approach suggested by Baayen. 
For the Israel data, the optimal breakpoint was located at AOA 6 but a piecewise model still failed to yield a significant improvement over a linear model ( _p_ = 0.62). For the North America data, fitting a breakpoint at AOA 16 did yield such an improvement ( _p_ = 0.047).

As I looped through several breakpoints (from AOA 5 till 19), however, these _p_-values will be anti-conservative.

### Computing adjusted _p_-values

As always, a _p_-value is supposed to express the probability of finding a significant result _if the null hypothesis were true_.
When fitting piecewise regressions, the **null hypothesis** is that the relationship between the two variables is **linear**.
We don't know precisely how a linear relationship between our two variables looks like under the null hypothesis (intercept, slope and dispersion parameters) but a reasonable starting point is to **fit a linear model** to the data we have and take its parameters as the population parameters. After all, they're our best guess. We're then going to **simulate new datasets** based on this model.

By way of illustration, the following R code reads in the Israel data and uses it to create 9 linear AOA-GJT relationships with similar properties.

{% highlight r %}
# Read in Israel data
dat <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/papers/CPH/DeKeyser2010Israel.csv")
# Fit linear model
mod <- lm(GJT ~ AOA, data = dat)
# Create grid for 9 plots
par(mfrow=c(3,3),
    oma=c(0, 0, 2, 0), # room for title
    bty="l", las="1")
# Draw 9 plots with simulated data
plots <- replicate(9,
                   plot(dat$AOA, unlist(simulate(mod)),
                        xlab="AOA", ylab="simulated GJT"))
title(main="9 simulated datasets", outer=TRUE)
{% endhighlight %}

![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-4.png) 

As you can see, some of the simulated GJT values lie outside the range of the original GJT data. DeKeyser et al. used a test that consisted of 204 yes/no items, so values higher than 204 are impossible whereas a score of 102 corresponds to random guessing.
Our regression model doesn't know that 102 and 204 represent the de facto limits of the GJT variable, and while we could try to use [censored regression models](http://en.wikipedia.org/wiki/Tobit_model#Variations_of_the_Tobit_model) to deal with that, I'm just going to tell R to set values higher than 204 to 204 and values lower than 102 to 102.
The following function, `generateBreakpointData.fnc`, does just that and, while we're at it, rounds off the simulated values to integers.


{% highlight r %}
straight.lm <- lm(GJT ~ AOA, dat)
AOAvals <- dat$AOA
generateBreakpointData.fnc <- function(AOA = AOAvals) {
  UA <- round(unlist(simulate(straight.lm)))
  UA[UA>204] <- 204
  UA[UA<102] <- 102
  return(data.frame(AOA = AOA,
                    UA = UA))
}
{% endhighlight %}

Next, we're going to **fit a piecewise model with a specified breakpoint to the simulated data**. Here, the breakpoint is at AOA 12.


{% highlight r %}
fitBreakpoint.fnc <- function(Data = Data,
                              Breakpoint = 12) {
  with.lm <- lm(UA ~ AOA + I(pmax(AOA-Breakpoint, 0)), Data)
  pval <- anova(with.lm)$'Pr(>F)'[2]
  dev <- deviance(with.lm)
  return(data.frame(pval = pval,
                    dev = dev))
}
{% endhighlight %}

Here's the outcome of running the two commands after each other:

{% highlight r %}
dat <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/papers/CPH/DeKeyser2010Israel.csv")
straight.lm <- lm(GJT ~ AOA, dat)
AOAvals <- dat$AOA
Data <- generateBreakpointData.fnc(AOA = AOAvals)
fitBreakpoint.fnc(Data = Data, Breakpoint = 12)
{% endhighlight %}



{% highlight text %}
##    pval   dev
## 1 0.575 12091
{% endhighlight %}

The values that are returned are the _p_-value of the test whether the slope is different before from after the breakpoint and the model's deviance (i.e. lack of fit).

Next, we're going to **loop through all possible breakpoints** while jotting down the _p_-values and deviances. 
I say 'loop', but in R you really want to [vectorise](http://www.noamross.net/blog/2014/4/16/vectorization-in-r--why.html) your repeated calculations as much as possible. 
This is what the `mapply` line below does.
The `generateFitBreakpoint.fnc` (among other programming-related stuff, I'm terrible at naming functions) takes two arguments,
the lowest considered breakpoint value and the higher considered breakpoint value, and returns the _p_-value associated with the optimal breakpoint model as well as the location of said breakpoint.


{% highlight r %}
generateFitBreakpoint.fnc <- function(MinBreakpoint = min(AOAvals) + 1,
                                      MaxBreakpoint = 19) {
  Data <- generateBreakpointData.fnc()
  Results <- mapply(fitBreakpoint.fnc,
                  Breakpoint = MinBreakpoint:MaxBreakpoint,
                  MoreArgs=list(Data = Data))
  Summary <- data.frame(Breakpoint = MinBreakpoint:MaxBreakpoint,
                    PValues = unlist(Results['pval',]),
                    Deviances = unlist(Results['dev',]))
  BestP = Summary$PValues[which.min(Summary$Deviances)]
  BestBP = Summary$Breakpoint[which.min(Summary$Deviances)]
  return(list(OptimalBP = BestBP,
              OptimalP = BestP))
}
{% endhighlight %}

All that is left to do now is to repeat that process a couple of thousand times and inspect the distribution of the recorded _p_-values.
The code below simulates 10,000 datasets based on DeKeyser et al.'s Israel data, loops through each of them to determine the individual best-fitting breakpoint models (possible breakpoints between AOA 5 and 19) and saves the associated _p_-values.

(I ran this code on a Linux terminal. It may not work on other systems, in which case you can let me know.)

{% highlight r %}
# Load 'parallel' package for faster computing.
library(parallel)
# Distribute the job among a couple of CPU cores
cl <- makeCluster(detectCores() - 1)
# Supply the other cores with the information necessary 
clusterExport(cl, c("dat", "straight.lm", "AOAvals",
                    "generateBreakpointData.fnc",
                    "fitBreakpoint.fnc",
                    "generateFitBreakpoint.fnc"))
# Run 10000 times
ReplicateResults <- parSapply(cl, 1:10000,
                              function(i, ...) generateFitBreakpoint.fnc())
# Save to disk
write.csv(ReplicateResults, "breakpointsimulationIsrael.csv", row.names=FALSE)
{% endhighlight %}

### Results
If the null hypothesis is true, _p_-values should be distributed uniformly between 0 and 1. As the following graph shows, however, by looping through several possible breakpoints, the _p_-value distribution is skewed towards 0.
Out of 10,000 datasets simulated under the null,
1270 produced a significant but spurious non-linearity -- more than double the nominal Type-I error rate of 5%.


{% highlight r %}
# Set graphical parameters
par(mfrow=c(1,1), bty="l", las="1")
# Read in data (and transpose for clarity's sake)
resIsr <- t(read.csv("/home/jan/breakpointsimulationIsrael.csv"))
# Draw histogram of p-values
hist(resIsr[,2], col="lightblue", breaks=seq(0,1,0.05),
     xlim=c(0,1),
     xlab="p value", ylab="Frequency",
     main="Distribution of p-values under the null\n(Israel data)")
{% endhighlight %}
![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-11.png) 

To calibrate the observed _p_-value against this skewed distribution, we just look up the proportion of _p_-values generated under the null equal to or lower than the observed _p_-value.
I observed a _p_-value of 0.62 after looping through breakpoints from AOA 5 till 19.
0.62 lies in the 96th quantile of the simulated _p_-value distribution (i.e. about 96% of _p_-values are lower than 0.62), so the calibrated _p_-value is 0.96 rather than 0.62:




{% highlight r %}
plot(ecdf(resIsr[,2]),
     xlab="observed p-value",
     ylab="cumulative probability",
     main="Cumulative probability of p-values under the null\n(Israel data)")
abline(v=0.62, col="lightblue", lwd=3)
table(resIsr[,2] <= 0.62)
{% endhighlight %}



{% highlight text %}
## 
## FALSE  TRUE 
##   420  9580
{% endhighlight %}



{% highlight r %}
abline(h=9580/10000, col="lightblue", lwd=3)
{% endhighlight %}

![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-12.png) 

I'll skip the code for simulating the _p_-value distribution for the North America analyses (just read in the other dataset and go through the same steps) and get straight to the simulated distribution:

![center](/figs/2014-08-20-adjusted-pvalues-breakpoint-regression/unnamed-chunk-13.png) 

For the North America data, the estimated Type-I error rate is about 10.5%, which is pretty similar to the one for the Israel data. (Not surprisingly, since the linear models for both datasets are remarkably similar.) The observed _p_-value of 0.047 lies in the 10th quantile of the simulated distribution, so the calibrated _p_-value is 0.10 rather than 0.047.

### Conclusions

> Looping through different breakpoints increases the Type-I error rate of piecewise regression models.  
> The observed _p_-values can be calibrated against the distribution of _p_-values under the simulated null.

The distribution of simulated _p_-values will **vary** from **dataset** to dataset and will depend on the **range of breakpoints considered** (the smaller the range, the smaller the skew). Lastly, multiple comparison problem **doesn't only apply when following the automatised procedure** suggested by Baayen: even if you look at the data first and then decide which breakpoint to fit, your _p_-values will be off if you don't take into account on which breakpoints you _could_ have decided had the data come out differently (see [Gelman and Loken](http://www.stat.columbia.edu/~gelman/research/unpublished/p_hacking.pdf) for a treatment of a more general version of this problem).
