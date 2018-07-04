---
title: "Baby steps in Bayes: Piecewise regression"
layout: post
tags: [breakpoint regression, non-linearities, Bayesian statistics]
category: [Analysis]
---

Inspired by Richard McElreath's excellent book 
_Statistical rethinking: A Bayesian course with examples in R and Stan_, 
I've started dabbling in Bayesian statistics. 
In essence, Bayesian statistics is an approach to statistical inference
in which the analyst specifies a generative model for the data
(i.e., an equation that describes the factors they suspect gave rise to the
data) as well as (possibly vague) relevant information or beliefs 
that are external to the data proper. This information or these
beliefs are then adjusted in light of the data observed.

I'm hardly an expert in Bayesian statistics (or the more commonly
encountered 'orthodox' or 'frequentist' statistics, for that matter),
but I'd like to understand it better -- not only conceptually, but
also in terms of how the statistical model should be specified.
While quite a few statisticians and methodologists tout Bayesian
statistics for a variety of reasons, my interest is primarily piqued
by the prospect of being able to tackle problems that would be
impossible or at least awkward to tackle with the tools I'm pretty
comfortable with at the moment.

In order to gain some familiarity with Bayesian statistics, I plan
to set myself a couple of problems and track my efforts in solving
them here in a _Dear diary_ fashion. Perhaps someone else finds them
useful, too.

The first problem that I'll tackle is fitting a regression model
in which the relationship between the predictor and the outcome
may contain a breakpoint at one unknown predictor value. One domain
in which such models are useful is in testing hypotheses that claim
that the relationship between the age of onset of second language
acquisition (AOA) and the level of ultimate attainment in that second
language flattens after a certain age (typically puberty).
It's possible to fit frequentist breakpoint models, but 
estimating the breakpoint age is a bit cumbersome (see blog post
[_Calibrating p-values in 'flexible' piecewise regression models_](http://janhove.github.io/analysis/2014/08/20/adjusted-pvalues-breakpoint-regression)).
But in a Bayesian approach, it should be possible to estimate
both the regression parameters as well as the breakpoint itself
in the same model. That's what I'll try here.

<!--more-->

## Software
Apart from R, you'll need RStan. Follow the installation instructions
on RStan's [GitHub page](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started).

Once you've installed RStan, fire up a new R session and run these commands.


{% highlight r %}
# Load rstan package
library(rstan)
# Avoid unnecessary recompiling
rstan_options(auto_write = TRUE)
# optional: Distribute work over multiple CPU cores
options(mc.cores = parallel::detectCores())
{% endhighlight %}

## Simulating some data
I'll analyse some real data in a minute. But I think it's useful
to analyse some data I know the true data generating mechanism of
first in order to make sure that the model works as intended.
The commands below generate data with properties comparable
to the real data I'll analyse in a bit.

The first graph below shows the mean outcome value 
('GJT', i.e., L2 grammaticality judgement task result)
depending on the age of onset of acquisition. As you
can see, there's a bend in the function at age 10.


{% highlight r %}
# Set random seed (today's date)
set.seed(2018-07-04)

# 80 data points
n <- 80

# Generate 'age of acquisition' data (integers between 1 and 50)
AOA <- sample(1:50, size = n, replace = TRUE)

# Set breakpoint at some plausible age
BP <- 10

# Generate average values on GJT (~ 'grammar test') outcome
meanGJT <- ifelse(AOA < BP,
                  176 - 1.2 * (AOA - BP),
                  176 - 0.4 * (AOA - BP))
plot(AOA, meanGJT, main = "Underlying function")
segments(x0 = BP, y0 = 0, y1 = 176, lty = 2)
segments(x0 = 0, x1 = BP, y0 = 176, lty = 2)
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-2-1.png)

> **Figure 1.** In the simulated data, the 
> underlying relationship between AOA and GJT
> has a steeper slope for AOA values below 10
> than for AOA values over 10.

In the second graph, some random normal error has been
added to these mean values; it is the data in this figure
that I'll analyse first.


{% highlight r %}
# Generate observed values
error <- 3
obsGJT <- rnorm(n = n, mean = meanGJT, sd = error)
plot(AOA, obsGJT, main = "Observed data")
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-3-1.png)

> **Figure 2.** Interindividual differences obfuscate
> the nonlinear relationship and the true position of 
> the breakpoint age somewhat.

## Specifying the model
While there exist some (truly excellent) front-end
interfaces for fitting Bayesian models (e.g., 
[brms](https://github.com/paul-buerkner/brms)),
I'll specify the model in RStan proper. This is
considerably more involved than writing out a model
using R's `lm()` function, but this added complexity
buys you something in terms of flexibility.

A Stan model specification has three required blocks.

### `data`
This is where you specify what the input data looks like. Below I specified that the model should accept two variables (`GJT` and `AOA`)
both with the same number of observations (`N`). Unlike `lm()`,
`stan()` accepts non-rectangular data (e.g., variables with different lengths), 
so you need to prespecify the number of observations per variable.

### `parameters`

The model parameters you want to estimate. A breakpoint
regression model has five parameters:

* The breakpoint. I constrained the breakpoint to be between 1 and 20 since
    breakpoints beyond that range are inconsistent with any proposed theory;
* the slope of the regression before the breakpoint;
* the slope of the regression after the breakpoint;
* a constant term ('intercept'), most easily written 
    as the expected outcome value at the breakpoint;
* the standard deviation of the normal error. Standard deviations are always positive;
    this constraint is set by including `<lower = 0>` in the declaration.
    (Incidentally, the error term doesn't have to be normal.)

### `model`
This is where you specify how the parameters and the data relate to each other.
The assumed (and for the simulated data: correct) data generating mechanism is that the observed GJT values 
were drawn from a normal distribution whose mean depends on the participant's AOA 
(see `transformed parameters` below) and the breakpoint 
and which has the same standard deviation everywhere.

You also have to provide so-called prior distributions for any parameters. These encode the information 
or beliefs you have about the parameters which you didn't need the data for. I set the following priors:

* A truncated normal prior for the breakpoint centred at 12 and with a standard deviation of 6. 
      The prior is truncated at 1 and at 20; this was specified in the `parameters` block.
      This prior essentially encodes that, for all I know, the breakpoint occurs somewhere
      between the ages of 1 and 20 and is slightly more likely to occur around age 10 to 14
      and around ages 2 or 19. I tried specifying a uniform prior, but that didn't work.
* Normal priors centred around 0 and with standard deviations of 5 for both slope parameters. What
      this means is that I think it's highly unlikely that these slopes are incredibly steep (say,
      a 100-point increase or decrease per additional AOA). These priors aren't particularly informative,
      though: According to them, negative and positive slopes are equally likely. If you have a sufficient
      amount of data, such priors only have a minimal effect on the results. But when you don't have this
      luxury, even such slightly informative priors may be better than none at all for keeping the inferences
      within reasonable bounds.
* A normal prior centred around 150 with a standard deviation of 25 for the intercept. This essentially
      means that I expect the average outcome at the breakpoint to lie somewhere between 100 and 200.
      For the real data I'll analyse later, this assumption is reasonable enough since the data were
      pretty much guaranteed to be bound between 102 and 204.
* A half-normal prior starting at 0 with a standard deviation of 20 for the standard deviation of
      the residuals. The _normal_ part is specified in this prior, the _half_ part results from
      the constraint set in the `parameters` block. A half-normal distribution starting at 0
      with a standard deviation of 20 in essence encodes the belief that the residual error will probably have
      a standard deviation of less than 2*20 = 40, with smaller values being more likely than large ones.
      If you don't set a prior for this parameter (or any other parameter, for that matter), a uniform
      prior spanning to infinity is assumed. So even when you don't specify a prior, you're using one.

I also added two optional blocks:

### `transformed parameters`
This block specifies derivations of model parameters, be it because they're
the actual object of inference or just because it simplifies the notation. 
I specified two derived parameters.

* `conditional_mean` describes the outcome of the regression equation without the error term for
    each observation:
    * If the participant's AOA is _before_ the breakpoint, `conditional_mean` = `intercept` + `slope1` * `AOA`. 
    * If the participant's AOA is _after_ the breakpoint, `conditional_mean` = `intercept` + `slope2` * `AOA`.
* `slope_difference` is just the difference between the slope after and the slope before the breakpoint.

### `generated quantities`
Here you can specify some model outputs. I specified three such outputs:

* `sim_GJT`: Using the `normal_rng()` function, I simulate new GJT data from the model
for each AOA observation in the original dataset. If the model
is approximately accurate, the actually observed data should look fairly similar to these simulated
data points. I'll check this later.
* `log_lik`: I won't discuss this in this post.
* `sim_conditional_mean`: For each AOA between 1 and 50 (hence: a vector of length 50), I'll ask
the model to output what it thinks is the conditional GJT mean. This will be useful for drawing effect plots.


{% highlight r %}
model_bp <- '
// You need to specify the kind of input data, incl. number of observations.
data { 
  int<lower=1> N;  // total number of observations (integer); at least 1
  real GJT[N];     // outcome variable with N elements (real-valued)
  real AOA[N];     // predictor variable with N elements (real-valued)
}

// the parameters to be estimated from the data
parameters { 
  real intercept;                 // = predicted outcome at breakpoint
  real slope_before;              // slope before the breakpoint
  real slope_after;               // slope after the breakpoint
  real<lower = 1, upper = 20> bp; // the breakpoint age, with some constraints
  real<lower = 0> error;          // standard deviation of residuals
                                  //  (always positive, hence <lower = 0>)
} 

// Functions of estimated parameters.
transformed parameters{
  vector[N] conditional_mean; // the estimated average GJT for each AOA observation
  real slope_difference;      // the difference between slope_after and slope_before

  slope_difference = slope_after - slope_before;  

  // conditional_mean depends on whether AOA is before or after bp
  for (i in 1:N) {
    if (AOA[i] < bp) {
      conditional_mean[i] = intercept + slope_before * (AOA[i] - bp);
    } else {
      conditional_mean[i] = intercept + slope_after * (AOA[i] - bp);
    }
  }
}

// The model itself specifies how the data are expected to have
// been generated and what the prior expectations for the model parameters are.
model {
  // Set priors
  intercept ~ normal(150, 25);  // Average GJT at breakpoint
  slope_before ~ normal(0, 5);  // Slope before breakpoint
  slope_after ~ normal(0, 5);   // Slope after breakpoint
  bp ~ normal(12, 6);           // Breakpoint age, pretty wide, but somewhere in childhood/puberty
  error ~ normal(0, 20);        // Residual error, likely between 0 and 2*20
  
  // How the data are expected to have been generated:
  // normal distribution with mu = conditional_mean and 
  // std = error, estimated from data.
  for (i in 1:N) {
    GJT[i] ~ normal(conditional_mean[i], error);
  }
}

generated quantities {
  vector[N] sim_GJT;               // Simulate new data using estimated parameters.
  vector[N] log_lik;               // Useful for model comparisons; not done here.
  vector[50] sim_conditional_mean; // Useful for plotting.

  // Compute conditional means for AOAs between 1 and 50.
  for (i in 1:50) {
    if (i < bp) {
      sim_conditional_mean[i] = intercept + slope_before * (i - bp);
    } else {
      sim_conditional_mean[i] = intercept + slope_after * (i - bp);
    }
  }

  for (i in 1:N) {
    sim_GJT[i] = normal_rng(conditional_mean[i], error);
    log_lik[i] = normal_lpdf(GJT[i] | conditional_mean[i], error);
  }
}
'
{% endhighlight %}

## Running the model

To fit the model, first put the input data in a list.
Then supply this list and the model code to the `stan()`
function. The `stan()` function prints a lot of output 
to the console, which I didn't reproduce here. 
Unless you receive genuine warnings or error (i.e., red text), 
everything's fine.


{% highlight r %}
data_list <- list(
  AOA = AOA,
  GJT = obsGJT,
  N = length(AOA)
)
fit_bp_sim <- stan(model_code = model_bp, 
                   data = data_list)
{% endhighlight %}

## Inspecting the model

### Model summary
A summary with the parameter estimates and their
uncertainties can be generated using the `print()` function.


{% highlight r %}
print(fit_bp_sim,
      par = c("intercept", "bp", "slope_before", "slope_after", "slope_difference", "error"))
{% endhighlight %}

<pre><code>Inference for Stan model: 629e36e16adca8e685810178a8ac5cc8.
4 chains, each with iter=2000; warmup=1000; thin=1; 
post-warmup draws per chain=1000, total post-warmup draws=4000.

                   mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
intercept        175.36    0.03 1.31 173.06 174.47 175.26 176.16 178.29  1425    1
bp                10.43    0.06 2.14   6.17   9.08  10.45  11.72  14.86  1169    1
slope_before      -1.18    0.01 0.28  -1.83  -1.32  -1.15  -1.00  -0.76  1318    1
slope_after       -0.38    0.00 0.03  -0.44  -0.40  -0.38  -0.36  -0.32  1958    1
slope_difference   0.80    0.01 0.29   0.36   0.62   0.77   0.94   1.45  1376    1
error              2.91    0.00 0.24   2.50   2.74   2.90   3.06   3.43  2391    1

Samples were drawn using NUTS(diag_e) at Wed Jul  4 11:15:11 2018.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</code></pre>

For each parameter, the `mean` column contains the mean estimate of that parameter,
whereas the `50%` column contains its median estimate. The `sd` column shows the
standard deviation of the parameter estimates; this corresponds to the parameter estimate's
standard error. The `2.5%`, `25%`, `75%` and `97.5%` columns contain the respective
percentiles of the distribution of the parameter estimates. So the average estimated
breakpoint (`bp`) occurs somewhere between age 10 and 11, with 95% of the estimates
contained in an interval between roughly 6 and 15 years. Similarly, the 
average estimated slope before the breakpoint is about -1.2 with a 95% 'credibility'
interval from -1.83 to -0.76, and so on. The parameter estimates, then, are neatly
centred around their true values, suggesting that the model does what it's supposed
to do.

### Posterior predictive checks
If the model is any good, data simulated from it should be pretty similar
to the data actually observed. In the `generated quantities` block, I let the
model output such simulated data (`sim_GJT`). Using the `shinystan` package,
we can perform some 'posterior predictive checks':


{% highlight r %}
shinystan::launch_shinystan(fit_bp_sim)
{% endhighlight %}

Click 'Diagnose' > 'PPcheck'. Under 'Select y (vector of observations)', 
pick `obsGJT` (the simulated data analysed above).
Under 'Parameter/generated quantity from model',
pick `sim_GJT` (the additional simulated data generated in the model code).
Then click on 'Distributions of observed data vs replications' and 'Distributions of test statistics' to check if the properties of the simulated data correspond
to those of the real data.

You can also take this a step further and check whether the
model is able to generate scatterplots similar to the one in Figure 2.
If the following doesn't make any immediate sense, please refer
to the blog post [_Checking model assumptions without getting paranoid_](http://janhove.github.io/analysis/2018/04/25/graphical-model-checking),
because the logic is pretty similar.

First extract some vectors of simulated data from the model output:


{% highlight r %}
# rstan's 'extract' is likely to conflict with another function
# called 'extract', so specify the package, too.
simulated_data <- rstan::extract(fit_bp_sim)$sim_GJT
# simulated_data is a matrix with 4000 rows and 80 columns.
# For the plot, I select 8 rows at random:
simulated_data <- simulated_data[sample(1:4000, 8), ]
{% endhighlight %}



Then plot both the observed vectors and the simulated vectors:


{% highlight r %}
par(mfrow = c(3, 3))

# Plot the observed data
plot(data_list$AOA, data_list$GJT,
     xlab = "AOA", ylab = "GJT",
     main = "observed")

# Plot the simulated data
for (i in 1:8) {
  plot(data_list$AOA, simulated_data[i, ],
       xlab = "AOA", ylab = "GJT",
       main = "simulated")
}
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-10-1.png)

{% highlight r %}
par(mfrow = c(1, 1))
{% endhighlight %}

> **Figure 3.** The actual input data (top left) and eight
> simulated datasets. If the simulated datasets are highly
> similar to the actual data, the model was able to learn
> the relevant patterns in the data.

The simulated data look pretty much identical to the observed
data, again demonstrating that the model is doing a pretty good
job of learning the patterns in the data. This isn't surprising,
since I knew how the data were generated and constructed the 
model correspondingly. But it's reassuring.

(Incidentally, I'm sure it's possible to generate lineups
more similar to the ones in that [previous blog post](http://janhove.github.io/analysis/2018/04/25/graphical-model-checking), 
but this blog post is long as it is already.)


### Effect plot

To visualise the model, you can draw an effect plot
showing the average estimated relationship between
AOA and GJT as well as the uncertainty about this relationship.
To this end, I had the model output vectors of the
fitted conditional means for AOAs 1 through 50
(`sim_conditional_mean`). With the commands below,
I extract these vectors and then compute their
mean values as well as some percentiles at each AOA.


{% highlight r %}
sim_conditional_means <- rstan::extract(fit_bp_sim)$sim_conditional_mean
df_sim_cond_means <- data.frame(
  AOA = 1:50,
  meanGJT = apply(sim_conditional_means, 2, mean),
  lo80GJT = apply(sim_conditional_means, 2, quantile, 0.10),
  hi80GJT = apply(sim_conditional_means, 2, quantile, 0.90),
  lo95GJT = apply(sim_conditional_means, 2, quantile, 0.025),
  hi95GJT = apply(sim_conditional_means, 2, quantile, 0.975)
)
head(df_sim_cond_means)
{% endhighlight %}
<pre><code>  AOA  meanGJT  lo80GJT  hi80GJT  lo95GJT  hi95GJT
1   1 186.0719 184.4968 187.6861 183.6659 188.5466
2   2 184.8881 183.5345 186.2415 182.7746 186.9900
3   3 183.7059 182.5237 184.8700 181.7739 185.5634
4   4 182.5286 181.4676 183.6046 180.7615 184.1998
5   5 181.3583 180.3321 182.3849 179.5348 182.9460
6   6 180.1979 179.0882 181.2284 178.2483 181.7938
</code></pre>



These mean values and percentiles can then be plotted as follows;
the black line shows the average regression line,
the light grey ribbon its 95% credibility region,
and the dark grey ribbon its 80% credibility region.


{% highlight r %}
library(ggplot2)
ggplot(df_sim_cond_means,
       aes(x = AOA,
           y = meanGJT)) +
  geom_ribbon(aes(ymin = lo95GJT,
                  ymax = hi95GJT),
              fill = "lightgrey") +
  geom_ribbon(aes(ymin = lo80GJT,
                  ymax = hi80GJT),
              fill = "darkgrey") +
  geom_line()
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-13-1.png)

> **Figure 4.** The modelled relationship between
> AOA and GJT for the made-up data with
> 80% and 95% credibility regions. The bend around
> AOA = 10 is noticeable but it smoothed out due
> to the uncertainty about the precise position of
> the breakpoint.

## And now for real

Let's now analyse some real data using the same model.
These data stem from a study by 
[DeKeyser et al. (2010)](https://doi.org/10.1017/S0142716410000056).


{% highlight r %}
d <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/papers/CPH/DeKeyser2010NorthAmerica.csv")
data_list <- list(
  AOA = d$AOA,
  GJT = d$GJT,
  N = nrow(d)
)
plot(data_list$AOA, data_list$GJT)
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-14-1.png)

> **Figure 5.** AOA--GJT relationship as observed in DeKeyser et al.'s
> (2010) North America study.

Let's fit the model:


{% highlight r %}
fit_bp <- stan(model_code = model_bp, data = data_list)
{% endhighlight %}

And output summary statistics:


{% highlight r %}
print(fit_bp,
      par = c("intercept", "bp", "slope_before", "slope_after", "slope_difference", "error"))
{% endhighlight %}

<pre><code>Inference for Stan model: 629e36e16adca8e685810178a8ac5cc8.
4 chains, each with iter=2000; warmup=1000; thin=1; 
post-warmup draws per chain=1000, total post-warmup draws=4000.

                   mean se_mean   sd   2.5%    25%    50%    75%  97.5% n_eff Rhat
intercept        172.30    0.26 7.44 159.92 166.69 171.10 177.64 187.86   827 1.00
bp                12.54    0.15 4.41   3.05   9.41  13.34  16.00  19.30   853 1.01
slope_before      -2.89    0.13 2.53  -8.20  -3.84  -2.82  -2.00   3.21   383 1.00
slope_after       -1.13    0.00 0.13  -1.38  -1.21  -1.13  -1.04  -0.87  1311 1.00
slope_difference   1.76    0.13 2.55  -4.47   0.86   1.72   2.77   7.03   388 1.00
error             16.40    0.03 1.36  14.05  15.45  16.32  17.22  19.35  2214 1.00

Samples were drawn using NUTS(diag_e) at Wed Jul  4 11:17:02 2018.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</code></pre>

The model doesn't seem to have learnt a whole lot about the position
of the breakpoint: the 95% credibility interval ranges from age 3 till age 19.
Furthermore, it doesn't really seem to know about what happens at this breakpoint:
the 95% CrI for the difference between the _after_ and the _before_ slopes
ranges from about -4.5 till 7.

We ought to perform some posterior predictive checks to make sure
the model makes sense, though:


{% highlight r %}
# rstan's 'extract' is likely to conflict with another function
# called 'extract', so specify the package, too.
simulated_data <- rstan::extract(fit_bp)$sim_GJT
# simulated_data is a matrix with 4000 rows and 80 columns.
# For the plot, I select 8 rows at random:
simulated_data <- simulated_data[sample(1:4000, 8), ]
{% endhighlight %}




{% highlight r %}
par(mfrow = c(3, 3))

# Plot the observed data
plot(data_list$AOA, data_list$GJT,
     xlab = "AOA", ylab = "GJT",
     main = "observed")

# Plot the simulated data
for (i in 1:8) {
  plot(data_list$AOA, simulated_data[i, ],
       xlab = "AOA", ylab = "GJT",
       main = "simulated")
}
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-19-1.png)

{% highlight r %}
par(mfrow = c(1, 1))
{% endhighlight %}

> **Figure 6.** The actual input data (top left) and eight
> simulated datasets. Some patterns in the simulated data
> couldn't have occurred in the actual dataset: the maximum
> possible GJT result was 204, yet a couple of datasets
> contain values above that. This is something that may
> be worth taking into account in a more refined model,
> but baby steps.

Figure 6 suggests that it may be possible to improve
the model since the simulated data display some patterns
that would have been impossible to observe in the 
actual study (viz., GJT values larger than 204).
But this should suffice for now.

As a final step, we can draw an effect plot as before:


{% highlight r %}
sim_conditional_means <- extract(fit_bp)$sim_conditional_mean
df_sim_cond_means <- data.frame(
  AOA = 1:50,
  meanGJT = apply(sim_conditional_means, 2, mean),
  lo80GJT = apply(sim_conditional_means, 2, quantile, 0.10),
  hi80GJT = apply(sim_conditional_means, 2, quantile, 0.90),
  lo95GJT = apply(sim_conditional_means, 2, quantile, 0.025),
  hi95GJT = apply(sim_conditional_means, 2, quantile, 0.975)
)
{% endhighlight %}




{% highlight r %}
ggplot(df_sim_cond_means,
       aes(x = AOA,
           y = meanGJT)) +
  geom_ribbon(aes(ymin = lo95GJT,
                  ymax = hi95GJT),
              fill = "lightgrey") +
  geom_ribbon(aes(ymin = lo80GJT,
                  ymax = hi80GJT),
              fill = "darkgrey") +
  geom_line()
{% endhighlight %}

![center](/figs/2018-07-04-bayesian-breakpoint-model/unnamed-chunk-22-1.png)

> **Figure 7.** Effect plot for the
> piecewise regression model applied to
> DeKeyser et al.'s (2010) North America data.
> There is substantial uncertainty about whether
> the regression line should indeed contain a breakpoint.

Given the uncertainty about the position of
the breakpoint and what happens to the regression
line at that breakpoint, it would make sense
to fit a linear regression model to these data
and then estimate how much allowing for a breakpoint
actually buys us in terms of fit to the data.
This is why I had the model generate `log_lik` values,
too, but I'll discuss those another time.
