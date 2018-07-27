---
title: "Baby steps in Bayes: Piecewise regression with two breakpoints"
layout: post
tags: [breakpoint regression, non-linearities, Bayesian statistics]
category: [Analysis]
---

In this follow-up to the blog post [_Baby steps in Bayes: Piecewise regression_](http://janhove.github.io/analysis/2018/07/04/bayesian-breakpoint-model), 
I'm going to try to model the relationship between two continuous variables
using a piecewise regression with not one but two breakpoints.
(The rights to the movie about the first installment are still up for grabs, incidentally.)

<!--more-->

The kind of relationship I want to model is plotted in Figure 1.
According to some applied linguists, relationships similar to these
underpin some aspects of language learning, but we don't need to
go into those discussions here.

![center](/figs/2018-07-27-bayesian-two-breakpoint-model/unnamed-chunk-10-1.png)

> **Figure 1.** The underlying form of the x-y relationship
> is characterised by two breakpoints. The function's three
> pieces are connected to each other.

The code below shows how you can generate such an x-y relationship
and adds a modicum of noise to it. Figure 2 shows the simulated
data we'll work with in this blog post. I'm not going to analyse
actual data at this juncture because it's Friday afternoon and
I want to ride my bike.


{% highlight r %}
# Set random seed (today's date)
set.seed(2018-07-27)

# 56 data points
n <- 56

# Generate predictor data
x <- runif(n, min = 0, max = 20)

# Set the breakpoints
bp1 <- 4.3
bp2 <- 13.6

# Set the intercept and the slope 
# for the first piece (before first breakpoint)
a1 <- 4
b1 <- 0.2

# Set the intercept and the slope
# for the *third* piece (after the second breakpoint)
a3 <- 12
b3 <- 0.1

# The underlying form of the second piece
# is a straight line connecting the first and third piece
# at the breakpoints. I won't bore you with the derivation,
# but this results in the following intercept and slope:
a2 <- (a1*bp2 + b1*bp1*bp2 - a3*bp1 - b3*bp1*bp2) / (bp2 - bp1)
b2 <- ((a3 + b3*bp2) - (a1 + b1*bp1)) / (bp2 - bp1)

# Generate average conditional y values
y <- vector(length = n)
for (i in 1:n) {
  # Before 1st breakpoint
  if (x[i] < bp1) {
    y[i] <- a1 + b1*x[i]
  # After 2nd breakpoint
  } else if (x[i] > bp2) {
    y[i] <- a3 + b3*x[i]
  # Else (between the two breakpoints)
  } else {
    y[i] <- a2 + b2*x[i]
  }
}

# Add some noise
y_obs <- y + rnorm(n = n, sd = 1)

# Plot
plot(x, y_obs)
{% endhighlight %}

![center](/figs/2018-07-27-bayesian-two-breakpoint-model/unnamed-chunk-11-1.png)

> **Figure 2.** The simulated data we'll work with.

## Specifying the model
If none of this makes sense to you, please refer to the previous
_Baby steps in Bayes_ blog post.

### `data`
There's an _x_ and a _y_ variable, both of length _N_ (here: N = 56).

### `parameters`
This model has 7 parameters:

* Two breakpoints. Instead of specifying both breakpoints in the `parameters` block, I specify the first one (`bp1`) as well as the distance between the first and the second one (`bp_distance`). This allows me to tell the model that that the second breakpoint needs to occur after the first one by constraining the distance between them to be positive.
* the intercept and slope of the regression before the first breakpoint
(`a1` and `b1`);
* the intercept and slope of the regression after the _third_ breakpoint
(`a3` and `b3`). Note that I don't specify the intercept and the slope of the model's second piece, i.e., between the two breakpoints. The reason is that I want the three pieces to be connected at the breakpoints. With this constraint, if you know the form of the first and third piece as well as the position of the two breakpoint, you get the intercept and the slope of the second piece for free.
* the standard deviation of the normal error. Standard deviations are always positive;
    this constraint is set by including `<lower = 0>` in the declaration.
    
### `transformed parameters`
As in the previous blog post, I specify a transformed parameter
that contains the mean of _y_ conditional on the value of _x_.
Additionally, for convenience, I derive three parameters from
those specified in the previous block: the position of the
second breakpoint (from the position of the first and the
distance between them), as well as the intercept and slope
of the second piece (`a2` and `b2`).

(Sidebar: Since the second piece needs to be connected to
the other two pieces at the respective breakpoint, the 
expected _y_ value at the first breakpoint equals
both `a1` + `b1`*`bp1` 
and `a2` + `b2`*`bp1`. Similarly, the expected _y_ value
at the second breakpoint equals both
`a3` + `b3`*`bp2`
and `a2` + `b2`*`bp2`. From these equalities, `a2` and `b2`
can be expressed in terms of the parameters specified above.)

### `model`
This works similarly to the model specification in the previous blog post.
Since I only work with simulated data here, the priors aren't informed
by any subject-matter knowledge.

### `generated quantities`
To check if the model picks up on the relevant aspects of the data,
I let it generate alternative datasets. Ideally, these look similar
to the actual data analysed.


{% highlight r %}
model_2bp <- '
data { 
  int<lower=1> N;  // total number of observations (integer); at least 1
  real y[N];       // outcome variable with N elements (real-valued)
  real x[N];       // predictor variable with N elements (real-valued)
}

parameters { 
  real bp1;                       // breakpoint 1
  real<lower = 0> bp_distance;    // distance between breakpoint1 and 2;
                                  // bp2 needs to occur after bp1
  real a_1;          // intercept and slope before breakpoint 1
  real b_1;
  real a_3;          // intercept and slope before breakpoint 3
  real b_3;
  real<lower = 0> error;  // standard deviation of residuals
} 

transformed parameters{
  vector[N] conditional_mean; // the estimated average
  real bp2;  // second breakpoint
  real a_2;  // intercept and slope of the second piece
  real b_2;  // (between two breakpoints)

  bp2 = bp1 + bp_distance;
  a_2 = (a_1*bp2 + b_1*bp1*bp2 - a_3*bp1 - b_3*bp1*bp2) / (bp2 - bp1);
  b_2 = ((a_3 + b_3*bp2) - (a_1 + b_1*bp1)) / (bp2 - bp1);

  // the conditional mean depends on the predictor value s
  // position relative to the breakpoints
  for (i in 1:N) {
    if (x[i] < bp1) {
      conditional_mean[i] = a_1 + b_1 * x[i];
    } else if (x[i] > bp2) {
      conditional_mean[i] = a_3 + b_3 * x[i];
    } else {
      conditional_mean[i] = a_2 + b_2 * x[i];
    }
  }
}

model {
  // Set priors. These are painfully uninformed.
  a_1 ~ normal(0, 25);
  a_3 ~ normal(0, 25);
  a_1 ~ normal(0, 25);
  a_3 ~ normal(0, 25);
  bp1 ~ normal(0, 25);
  bp_distance ~ normal(0, 25);  // constrained to be positive
  error ~ normal(0, 25);        // Residual error, likely between 0 and 2*25

  // How the data are expected to have been generated:
  // normal distribution with mu = conditional_mean and 
  // std = error, estimated from data.
  for (i in 1:N) {
    y[i] ~ normal(conditional_mean[i], error);
  }
}

generated quantities {
  vector[N] sim_y;               // Simulate new data using estimated parameters.

  for (i in 1:N) {
    sim_y[i] = normal_rng(conditional_mean[i], error);
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
everything's fine. (Apologies for the blatant self-plagiarism throughout,
by the way.)


{% highlight r %}
data_list <- list(
  x = x,
  y = y_obs,
  N = n
)
fit_2bp_sim <- stan(model_code = model_2bp, 
                   data = data_list)
{% endhighlight %}

## Inspecting the model

### Model summary
A summary with the parameter estimates and their
uncertainties can be generated using the `print()` function.


{% highlight r %}
print(fit_2bp_sim,
      par = c("bp1", "bp2",
              "a_1", "b_1", 
              "a_2", "b_2",
              "a_3", "b_3",
              "error"))
{% endhighlight %}

<pre><code>Inference for Stan model: ade2f0f31038d9a48e5f69f1db76bc89.
4 chains, each with iter=2000; warmup=1000; thin=1; 
post-warmup draws per chain=1000, total post-warmup draws=4000.

       mean se_mean   sd  2.5%   25%   50%   75% 97.5% n_eff Rhat
bp1    2.58    0.05 1.30  1.11  1.63  2.15  3.28  6.02   804    1
bp2   14.53    0.02 0.68 13.04 14.14 14.58 14.97 15.73  1922    1
a_1    4.57    0.02 0.64  3.40  4.12  4.52  5.00  5.88  1113    1
b_1   -0.77    0.03 0.89 -2.76 -1.31 -0.61 -0.06  0.40   808    1
a_2    1.20    0.01 0.56 -0.10  0.92  1.25  1.55  2.11  1433    1
b_2    0.87    0.00 0.06  0.78  0.84  0.87  0.90  1.00  1552    1
a_3   15.08    0.09 3.50  8.88 12.63 14.90 17.33 22.32  1552    1
b_3   -0.08    0.01 0.21 -0.50 -0.21 -0.07  0.06  0.31  1557    1
error  0.93    0.00 0.10  0.76  0.86  0.92  0.99  1.14  1991    1

Samples were drawn using NUTS(diag_e) at Fri Jul 27 15:59:51 2018.
For each parameter, n_eff is a crude measure of effective sample size,
and Rhat is the potential scale reduction factor on split chains (at 
convergence, Rhat=1).
</code></pre>

Seems okay!

### Posterior predictive checks
If the model is any good, data simulated from it should be pretty similar
to the data actually observed. In the `generated quantities` block, I let the
model output such simulated data (`sim_y`). Using the `shinystan` package,
we can perform some 'posterior predictive checks':


{% highlight r %}
shinystan::launch_shinystan(fit_2bp_sim)
{% endhighlight %}

Click 'Diagnose' > 'PPcheck'. Under 'Select y (vector of observations)', 
pick `y_obs` (the simulated data analysed above).
Under 'Parameter/generated quantity from model',
pick `sim_y` (the additional simulated data generated in the model code).
Then click on 'Distributions of observed data vs replications' and 
'Distributions of test statistics' to check if the properties of the simulated data correspond
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
simulated_data <- rstan::extract(fit_2bp_sim)$sim_y
# simulated_data is a matrix with 4000 rows and 80 columns.
# For the plot, I select 8 rows at random:
simulated_data <- simulated_data[sample(1:4000, 8), ]
{% endhighlight %}



Then plot both the observed vectors and the simulated vectors:


{% highlight r %}
par(mfrow = c(3, 3))

# Plot the observed data
plot(data_list$x, data_list$y,
     xlab = "x", ylab = "y",
     main = "observed")

# Plot the simulated data
for (i in 1:8) {
  plot(data_list$x, simulated_data[i, ],
       xlab = "x", ylab = "y",
       main = "simulated")
}
{% endhighlight %}

![center](/figs/2018-07-27-bayesian-two-breakpoint-model/unnamed-chunk-18-1.png)

{% highlight r %}
par(mfrow = c(1, 1))
{% endhighlight %}

> **Figure 3.** The actual input data (top left) and eight
> simulated datasets. If the simulated datasets are highly
> similar to the actual data, the model was able to learn
> the relevant patterns in the data.

Seems fine by me!
