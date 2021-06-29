---
title: "The consequences of controlling for a post-treatment variable"
layout: post
mathjax: true
tags: [R, multiple regression, DAG]
category: [Analysis]
---

Let's say you want to find out if
a pedagogical intervention boosts
learners' conversational skills in
L2 French. You've learnt that including
a well-chosen control variable
in your analysis can work 
[wonders](https://janhove.github.io/analysis/2017/10/24/increasing-power-precision)
in terms of statistical power and precision,
so you decide to administer a French vocabulary test
to your participants in order to include their
score on this test in your analyses as a covariate.
But if you administer the vocabulary test
_after_ the intervention, it's possible that the
vocabulary scores are themselves affected by the
intervention as well. If this is indeed the case,
you may end up doing more harm than good.
In this blog post, I will take a closer look at four
general cases where controlling for such a 'post-treatment'
variable is harmful, and one case where it improves matters.

<!--more-->

In the following, `x` and `y` refer to the 
independent and dependent variable of interest,
respectively, i.e., `x` would correspond to the intervention
and `y` to the L2 French conversational skills in
our example. `z` refers to the post-treatment variable,
i.e., the French vocabulary scores in our example.
`x` is a binary variable, `y` and `z` are continuous.
Since `z` is a post-treatment variable, it's possible
that it is itself influenced directly or indirectly
by `x`. In the first four cases examined below, this is
indeed the case.

I've included all R code as I think running simulations
like the ones below are a useful way to learn research
design and statistics. If you're just interested in the 
upshot, just ignore the code snippets :)



## Case 1: `x` affects both `y` and `z`; `y` and `z` don't affect each other.
In the first case, `x` affects both `y` and `z`, but `z` and `y` don't influence each other.

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-2-1.png)

> **Figure 1.1.** The causal links between `x`, `y` and `z`
> in Case 1.

In this case,
controlling for `z` doesn't bias the estimate
for the causal influence of `x` on `y`.
<!-- (here: $\beta_{xy} = 1$ by default). -->
It does, however, 
reduce the precision of these estimates. 
To appreciate this,
let's simulate some data. The function `case1()`
defined in the next code snippet generates 
a dataset corresponding to Case 1.
The parameter `beta_xy` specifies the coefficient
of the influence of `x` on `y`; the goal of the analysis
is to estimate the value of this parameter from the data.
The parameter `beta_xz` similarly specifies the coefficient
of the influence of `x` on `z`. Estimating the latter
coefficient isn't a goal of the analysis, since `z`
is merely a control variable.


{% highlight r %}
case1 <- function(n_per_group, beta_xy = 1, beta_xz = 1.5) {
  # Create x (n_per_group 0s and n_per_group 1s)
  x <- rep(c(0, 1), each = n_per_group)
  
  # x affects y; 'rnorm' just adds some random noise to the observations.
  # In a DAG, this noise corresponds to the influence of other variables that
  # didn't need to be plotted.
  y <- beta_xy*x + rnorm(2*n_per_group)
  
  # x affects z
  z <- beta_xz*x + rnorm(2*n_per_group)
  
  # Create data frame
  dfr <- data.frame(x = as.factor(x), y, z)
  
  # Add info: z above or below median?
  dfr$z_split <- factor(ifelse(dfr$z > median(dfr$z), "above", "below"))
  
  # Return data frame
  dfr
}
{% endhighlight %}

Use this function to create a dataset with 100 
participants per group:


{% highlight r %}
df_case1 <- case1(n_per_group = 100)
# Type 'df_case1' to inspect.
{% endhighlight %}

A graphical analysis that doesn't take the control variable
`z` into account reveals a roughly one-point difference
between the two conditions, which is as it should be.


{% highlight r %}
library(tidyverse)
ggplot(data = df_case1,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-5-1.png)

> **Figure 1.2.** Graphical analysis without the covariate
> for Case 1.

A linear model is able to retrieve the `beta_xy` coefficient,
which was set at 1, well enough ($\widehat{\beta_{xy}} = 1.03 \pm 0.13$).


{% highlight r %}
summary(lm(y ~ x, df_case1))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.0161      0.092  -0.175 8.61e-01
## x1            1.0349      0.130   7.951 1.38e-13
{% endhighlight %}

Alternatively, we could analyse these data while taking
the control variable into account. The graphical analysis 
in Figure 3 achieves this by splitting up the control variable
at its median and plotting the two subset separately.
This is statistically suboptimal, but it makes the visualisation
easier to grok. Here we also find a roughly one-point difference
between the two conditions in each panel, which suggests that 
controlling for `z` won't induce any bias.


{% highlight r %}
ggplot(data = df_case1,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1) +
  facet_wrap(~ z_split)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-7-1.png)
> **Figure 1.3.** Graphical analysis with the covariate (median split) for Case 1.

The linear model is again able to retrieve the coefficient
of interest well enough ($\widehat{\beta_{xy}} = 1.04 \pm 0.16$),
though with a slightly wider standard error.


{% highlight r %}
summary(lm(y ~ x + z, df_case1))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept) -0.01615     0.0923 -0.1750 8.61e-01
## x1           1.04147     0.1632  6.3826 1.22e-09
## z           -0.00409     0.0613 -0.0667 9.47e-01
{% endhighlight %}

Of course, it's difficult to draw any firm conclusions about the analysis
of a single simulated dataset. To see that in this general case,
the coefficient of interest is indeed
estimated without bias but with decreased precision, let's generate 5,000
such datasets and analyse them with and without taking the control variable
into account. The function `sim_case1()` defined below runs these analyses;
the ggplot call plots the estimates for the $\beta_{xy}$ parameter.
As the caption to Figure 1.4 explains, this simulation confirms what we observed
above.


{% highlight r %}
# Another function. This one takes the function case1(),
# runs it nruns (here: 1000) times and extracts estimates
# from two analyses per generated dataset.
sim_case1 <- function(nruns = 5000, n_per_group = 100, beta_xy = 1, beta_xz = 1.5) {
  est_without <- vector("double", length = nruns)
  est_with <- vector("double", length = nruns)
  
  for (i in 1:nruns) {
    # Generate data
    d <- case1(n_per_group = n_per_group, beta_xy = beta_xy, beta_xz = beta_xz)
    
    # Analyse (in regression model) without covariate and extract estimate
    est_without[[i]] <- coef(lm(y ~ x, data = d))[[2]]
    
    # Analyse with covariate, extract estimate
    est_with[[i]] <- coef(lm(y ~ x + z, data = d))[[2]]
  }
  
  # Output data frame with results
  results <- data.frame(
    simulation = rep(1:nruns, 2),
    covariate = rep(c("with covariate", "without covariate"), each = nruns),
    estimate = c(est_with, est_without)
  )
}

# Run function and plot results
results_sim_case1 <- sim_case1()
ggplot(data = results_sim_case1,
       aes(x = estimate)) +
  geom_histogram(fill = "lightgrey", colour = "black", bins = 20) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  facet_wrap(~ covariate)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-9-1.png)

> **Figure 1.4.** In Case 1,
> the distribution of the parameter estimates is centred around the
> correct value both when the control variable is taken into account
> and when it isn't. The distribution is wider when taking the control
> variable into account, however, i.e., the estimates are less precise
> when taking the control variable into account than when not taking it
> into account.

The estimate for the $\beta_{xy}$ parameter is unbiased in both analyses,
but the analysis with the covariate offers *less* rather than more precision:
The standard deviation of the distribution of parameter estimates
increases from 0.14 to 0.18:


{% highlight r %}
results_sim_case1 %>% 
  group_by(covariate) %>% 
  summarise(mean_est = mean(estimate),
            sd_est = sd(estimate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   covariate         mean_est sd_est
##   <chr>                <dbl>  <dbl>
## 1 with covariate       0.999  0.177
## 2 without covariate    0.998  0.141
{% endhighlight %}

## Case 2: `x` affects `y`, which in turn affects `z`.
In the second case, `x` affects `y` directly,
and `y` in turns affects `z`.

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-11-1.png)

> **Figure 2.1.** The causal links between `x`, `y` and `z`
> in Case 2.

This time, controlling for `z` biases the estimates
for the $\beta_{xy}$ parameter. To see this, let's again
simulate and analyse some data.


{% highlight r %}
case2 <- function(n_per_group, beta_xy = 1, beta_yz = 1.5) {
  x <- rep(c(0, 1), each = n_per_group)
  y <- beta_xy*x + rnorm(2*n_per_group)
  
  # y affects z
  z <- beta_yz*y + rnorm(2*n_per_group)
  
  dfr <- data.frame(x = as.factor(x), y, z)
  dfr$z_split <- factor(ifelse(dfr$z > median(dfr$z), "above", "below"))
  
  dfr
}

df_case2 <- case2(n_per_group = 100)
{% endhighlight %}

When the data are analyses without taking the control variable
into account, we obtain the following result:


{% highlight r %}
ggplot(data = df_case2,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-13-1.png)

> **Figure 2.2.** Graphical analysis without the covariate
> for Case 2.

This isn't quite as close to a one-point difference as in the previous
example, but as we'll see below that's merely due to the randomness
inherent in these simulations. The linear model yields a parameter estimate
of $\widehat{\beta_{xy}} = 0.76 \pm 0.14$.


{% highlight r %}
summary(lm(y ~ x, df_case2))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)    0.248     0.0958    2.59 1.02e-02
## x1             0.755     0.1354    5.57 8.06e-08
{% endhighlight %}
When we take the control variable into account, however, the difference
between the two groups defined by `x` becomes smaller:


{% highlight r %}
ggplot(data = df_case2,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1) +
  facet_wrap(~ z_split)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-15-1.png)

> **Figure 2.3.** Graphical analysis with the covariate
> for Case 2.

The linear model now yields a parameter estimate
of $\widehat{\beta_{xy}} = 0.18 \pm 0.08$, which is
considerably farther from the actual parameter value of 1.


{% highlight r %}
summary(lm(y ~ x + z, df_case2))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   0.0479     0.0531    0.90 3.69e-01
## x1            0.1790     0.0787    2.28 2.39e-02
## z             0.4717     0.0218   21.59 7.87e-54
{% endhighlight %}
The larger-scale simulation shows that the analysis with the covariate
is indeed biased if you want to estimate the causal influence of `x` on `y`.


{% highlight r %}
# Change beta_xz to beta_xy compared to the previous case
sim_case2 <- function(nruns = 5000, n_per_group = 100, beta_xy = 1, beta_yz = 1.5) {
  est_without <- vector("double", length = nruns)
  est_with <- vector("double", length = nruns)
  
  for (i in 1:nruns) {
    d <- case2(n_per_group = n_per_group, beta_xy = beta_xy, beta_yz = beta_yz)
    est_without[[i]] <- coef(lm(y ~ x, data = d))[[2]]
    est_with[[i]] <- coef(lm(y ~ x + z, data = d))[[2]]
  }
  
  results <- data.frame(
    simulation = rep(1:nruns, 2),
    covariate = rep(c("with covariate", "without covariate"), each = nruns),
    estimate = c(est_with, est_without)
  )
}

results_sim_case2 <- sim_case2()
ggplot(data = results_sim_case2,
       aes(x = estimate)) +
  geom_histogram(fill = "lightgrey", colour = "black", bins = 20) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  facet_wrap(~ covariate)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-17-1.png)

> **Figure 2.4.** In Case 2,
> the distribution of the parameter estimates is centred around the
> correct value when the control variable isn't taken into account
> but it is strongly biased when this control variable _is_ taken into account,
> i.e., the analysis with the covariate yields biased estimates.

The fact that the distribution of the parameter estimates is narrower
when taking the covariate into account is completely immaterial,
since these estimates are estimating the wrong quantity.


{% highlight r %}
results_sim_case2 %>% 
  group_by(covariate) %>% 
  summarise(mean_est = mean(estimate),
            sd_est = sd(estimate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   covariate         mean_est sd_est
##   <chr>                <dbl>  <dbl>
## 1 with covariate       0.310 0.0856
## 2 without covariate    1.00  0.141
{% endhighlight %}

# Case 3: `x` and `y` both affect `z`. `x` also affects `y`.
Now `z` is affected by both `x` and `y`. 
`x` still affects `y`, though. Taking the
covariate into account again yields biased estimates.

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-19-1.png)

> **Figure 3.1.** The causal links between `x`, `y` and `z`
> in Case 3.

Same procedure as last year, James.


{% highlight r %}
case3 <- function(n_per_group, beta_xy = 1, beta_xz = 1.5, beta_yz = 1.5) {
  x <- rep(c(0, 1), each = n_per_group)
  y <- beta_xy*x + rnorm(2*n_per_group)
  
  # x and y affect z
  z <- beta_xz*x + beta_yz*y + rnorm(2*n_per_group)
  
  dfr <- data.frame(x = as.factor(x), y, z)
  dfr$z_split <- factor(ifelse(dfr$z > median(dfr$z), "above", "below"))

  dfr
}

df_case3 <- case3(n_per_group = 100)
{% endhighlight %}


{% highlight r %}
ggplot(data = df_case3,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-21-1.png)

> **Figure 3.2.** Graphical analysis without the covariate
> for Case 3.

Again, the analysis without the control variable
yields a reasonably accurate estimate of the true
parameter value of 1
($\widehat{\beta_{xy}} = 1.07 \pm 0.15$).


{% highlight r %}
summary(lm(y ~ x, df_case3))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.0817      0.105  -0.778 4.37e-01
## x1            1.0687      0.148   7.197 1.25e-11
{% endhighlight %}
When we take the control variable into account, however, the difference
between the two groups defined by `x` becomes smaller:


{% highlight r %}
ggplot(data = df_case3,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1) +
  facet_wrap(~ z_split)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-23-1.png)

> **Figure 3.3.** Graphical analysis with the covariate
> for Case 3.

The linear model now yields a parameter estimate
of $\widehat{\beta_{xy}} = -0.31 \pm 0.11$, which is
considerably farther from the actual parameter value of 1
and even has the wrong sign. (This isn't evident from Figure 3.3,
but keep in mind that the graphical analysis in Figure 3.3 uses
a median split on the continuous covariate whereas the linear model
below respects the continuous nature of this covariate.)


{% highlight r %}
summary(lm(y ~ x + z, df_case3))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   0.0038     0.0594  0.0639 9.49e-01
## x1           -0.3067     0.1071 -2.8631 4.65e-03
## z             0.4614     0.0224 20.6083 4.71e-51
{% endhighlight %}
For the sake of completeness, let's run this
simulation 5,000 times, too.


{% highlight r %}
sim_case3 <- function(nruns = 5000, n_per_group = 100, beta_xy = 1, beta_xz = 1.5, beta_yz = 1.5) {
  est_without <- vector("double", length = nruns)
  est_with <- vector("double", length = nruns)
  
  for (i in 1:nruns) {
    d <- case3(n_per_group = n_per_group, beta_xy = beta_xy, beta_xz = beta_xz, beta_yz = beta_yz)
    est_without[[i]] <- coef(lm(y ~ x, data = d))[[2]]
    est_with[[i]] <- coef(lm(y ~ x + z, data = d))[[2]]
  }

  results <- data.frame(
    simulation = rep(1:nruns, 2),
    covariate = rep(c("with covariate", "without covariate"), each = nruns),
    estimate = c(est_with, est_without)
  )
}

results_sim_case3 <- sim_case3()
ggplot(data = results_sim_case3,
       aes(x = estimate)) +
  geom_histogram(fill = "lightgrey", colour = "black", bins = 20) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  facet_wrap(~ covariate)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-25-1.png)

> **Figure 3.4.** In Case 3, too,
> the distribution of the parameter estimates is centred around the
> correct value when the control variable isn't taken into account
> but it is strongly biased when this control variable _is_ taken into account,
> i.e., the analysis with the covariate yields biased estimates.

The fact that the distribution of the parameter estimates is narrower
when taking the covariate into account is completely immaterial,
since these estimates are estimating the wrong quantity.


{% highlight r %}
results_sim_case3 %>% 
  group_by(covariate) %>% 
  summarise(mean_est = mean(estimate),
            sd_est = sd(estimate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   covariate         mean_est sd_est
##   <chr>                <dbl>  <dbl>
## 1 with covariate      -0.382  0.104
## 2 without covariate    1.00   0.144
{% endhighlight %}
## Case 4: `x` affects `z`; both `x` and `z` influence `y`.
That is, `x` influences both `y` and `z`, but `z` also influences `y`.
Let $\beta_{xy}$ be the direct effect of `x` on `y`,
$\beta_{xz}$ the effect of `x` on `z`
and $\beta_{zy}$ the effect of `z` on `y`.
Then the _total_ effect of `x` on `y` is $\beta_{xy} + \beta_{xz}\times\beta_{zy}$.

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-27-1.png)

> **Figure 4.1.** The causal links between `x`, `y` and `z`
> in Case 4.

Using the defaults in the following function, the total effect of `x` on `y` is
$1 + 1.5\times 0.5 = 1.75$. 
If this doesn't make immediate sense, consider what a change of one unit in `x` causes downstream:
A one-unit increase in `x` directly increases `y` by 1.
It also increases `z` by 1.5.
But a one-unit increase in `z` causes an increase of 0.5 in `y` as well, so a 1.5-unit increase in `z` causes an additional increase of 0.75 in `y`. So in total, a one-unit increase in `x` causes a 1.75-point increase in `y`.


{% highlight r %}
case4 <- function(n_per_group, beta_xy = 1, beta_xz = 1.5, beta_zy = 0.5) {
  x <- rep(c(0, 1), each = n_per_group)
  
  # x affects z
  z <- beta_xz*x + rnorm(2*n_per_group)
  
  # x and z affect y
  y <- beta_xy*x + beta_zy*z + rnorm(2*n_per_group)
  
  dfr <- data.frame(x = as.factor(x), y, z)
  
  dfr$z_split <- factor(ifelse(dfr$z > median(dfr$z), "above", "below"))
  
  dfr
}

df_case4 <- case4(n_per_group = 100)
{% endhighlight %}


{% highlight r %}
ggplot(data = df_case4,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-29-1.png)

> **Figure 4.2.** Graphical analysis without the covariate
> for Case 4.

Again, the analysis without the control variable
yields a reasonably accurate estimate of the true _total_
influence of `x` on `y` of 1.75 (!)
($\widehat{\beta_{xy}} = 1.67 \pm 0.16$).


{% highlight r %}
summary(lm(y ~ x, df_case4))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   0.0802      0.115   0.695 4.88e-01
## x1            1.6744      0.163  10.263 4.36e-20
{% endhighlight %}
When we take the control variable into account, however, the difference
between the two groups defined by `x` becomes smaller:


{% highlight r %}
ggplot(data = df_case4,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1) +
  facet_wrap(~ z_split)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-31-1.png)

> **Figure 4.3.** Graphical analysis with the covariate
> for Case 4.

The linear model now yields a parameter estimate
of $\widehat{\beta_{xy}} = 1.11 \pm 0.17$.
This analysis correctly estimates the _direct_
effect of `x` on `y` (i.e., without the additional causal link between `x` on `y` through `z`).
This may be interesting in its own right, but the analysis
addresses a question different from ''What's the causal
influence of `x` on `y`?''


{% highlight r %}
summary(lm(y ~ x + z, df_case4))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.0451     0.1073  -0.421 6.75e-01
## x1            1.1054     0.1742   6.346 1.49e-09
## z             0.4853     0.0768   6.321 1.70e-09
{% endhighlight %}
For the sake of completeness, let's run this
simulation 5,000 times, too.


{% highlight r %}
sim_case4 <- function(nruns = 5000, n_per_group = 100, beta_xy = 1, beta_xz = 1.5, beta_zy = 0.5) {
  est_without <- vector("double", length = nruns)
  est_with <- vector("double", length = nruns)
  
  for (i in 1:nruns) {
    d <- case4(n_per_group = n_per_group, beta_xy = beta_xy, beta_xz = beta_xz, beta_zy = beta_zy)
    est_without[[i]] <- coef(lm(y ~ x, data = d))[[2]]
    est_with[[i]] <- coef(lm(y ~ x + z, data = d))[[2]]
  }
  
  results <- data.frame(
    simulation = rep(1:nruns, 2),
    covariate = rep(c("with covariate", "without covariate"), each = nruns),
    estimate = c(est_with, est_without)
  )
}

results_sim_case4 <- sim_case4()
ggplot(data = results_sim_case4,
       aes(x = estimate)) +
  geom_histogram(fill = "lightgrey", colour = "black", bins = 20) +
  geom_vline(xintercept = 1.75, linetype = "dashed") +
  facet_wrap(~ covariate)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-33-1.png)

> **Figure 4.4.** In Case 4, the analysis without the
> covariate correctly estimates the _total_ causal influence
> that `x` has on `y`, while the analysis with the covariate
> correctly estimates the _direct_ causal effect of 
> `x` on `y`. Either may be relevant, but you have to know
> which!


{% highlight r %}
results_sim_case4 %>% 
  group_by(covariate) %>% 
  summarise(mean_est = mean(estimate),
            sd_est = sd(estimate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   covariate         mean_est sd_est
##   <chr>                <dbl>  <dbl>
## 1 with covariate        1.00  0.178
## 2 without covariate     1.75  0.158
{% endhighlight %}

## Case 5: `x` and `z` affect `y`; `x` and `z` don't affect each other.
In the final general case, `x` and `z` both affect `y`, but
`x` and `z` don't affect each other. That is, `z` isn't affected by the
intervention in any way and so functions like a pre-treatment control variable would.
The result is an increase in statistical precision. This is the only of the five
cases examined in which the control variable has added value for the purposes
of estimated the causal influence of `x` on `y`.

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-35-1.png)

> **Figure 5.1.** The causal links between `x`, `y` and `z`
> in Case 5.

Using the defaults in the following function, the total effect of `x` on `y` is
$1 + 1.5\times 0.5 = 1.75$. 
If this doesn't make immediate sense, consider what a change of one unit in `x` causes downstream:
A one-unit increase in `x` directly increases `y` by 1.
It also increases `z` by 1.5.
But a one-unit increase _in `z`_ causes an increase of 0.5 in `y` as well, so a 1.5-unit increase in `z` causes an additional increase of 0.75 in `y`. So in total, a one-unit increase in `x` causes a 1.75-point increase in `y`.


{% highlight r %}
case5 <- function(n_per_group, beta_xy = 1, beta_zy = 1.5) {
  x <- rep(c(0, 1), each = n_per_group)
  
  # Create z
  z <- rnorm(2*n_per_group)
  
  # x and z affect y
  y <- beta_xy*x + beta_zy*z + rnorm(2*n_per_group)
  
  dfr <- data.frame(x = as.factor(x), y, z)
  dfr$z_split <- factor(ifelse(dfr$z > mean(dfr$z), "above", "below"))
  
  dfr
}

df_case5 <- case5(n_per_group = 100)
{% endhighlight %}


{% highlight r %}
ggplot(data = df_case5,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-37-1.png)

> **Figure 5.2.** Graphical analysis without the covariate
> for Case 5.

Again, the analysis without the control variable
yields an estimate within one standard error of the true parameter value of 1
($\widehat{\beta_{xy}} = 0.76 \pm 0.24$).


{% highlight r %}
summary(lm(y ~ x, df_case5))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  0.00417      0.172  0.0242   0.9807
## x1           0.75596      0.244  3.1027   0.0022
{% endhighlight %}


{% highlight r %}
ggplot(data = df_case5,
       aes(x = x, y = y)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(position = position_jitter(width = 0.2), pch = 1) +
  facet_wrap(~ z_split)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-39-1.png)

> **Figure 5.3.** Graphical analysis with the covariate
> for Case 5.

The linear model now yields a parameter estimate
of $\widehat{\beta_{xy}} = 1.08 \pm 0.15$,
with is also a reasonable estimate but with a smaller standard error.


{% highlight r %}
summary(lm(y ~ x + z, df_case5))$coefficient
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)  -0.0376     0.1027  -0.366 7.15e-01
## x1            1.0823     0.1462   7.402 3.80e-12
## z             1.4193     0.0748  18.986 2.23e-46
{% endhighlight %}
For the sake of completeness, let's run this
simulation 5,000 times, too.


{% highlight r %}
sim_case5 <- function(nruns = 1000, n_per_group = 100, beta_xy = 1, beta_zy = 1.5) {
  est_without <- vector("double", length = nruns)
  est_with <- vector("double", length = nruns)
  
  for (i in 1:nruns) {
    d <- case5(n_per_group = n_per_group, beta_xy = beta_xy, beta_zy = beta_zy)
    est_without[[i]] <- coef(lm(y ~ x, data = d))[[2]]
    est_with[[i]] <- coef(lm(y ~ x + z, data = d))[[2]]
  }

  results <- data.frame(
    simulation = rep(1:nruns, 2),
    covariate = rep(c("with covariate", "without covariate"), each = nruns),
    estimate = c(est_with, est_without)
  )
}

results_sim_case5 <- sim_case5()
ggplot(data = results_sim_case5,
       aes(x = estimate)) +
  geom_histogram(fill = "lightgrey", colour = "black", bins = 20) +
  geom_vline(xintercept = 1, linetype = "dashed") +
  facet_wrap(~ covariate)
{% endhighlight %}

![center](/figs/2021-06-29-posttreatment/unnamed-chunk-41-1.png)

> **Figure 5.4.** In Case 5, both analyses are centred
> around the correct value, i.e., both are unbiased.
> The analysis with the control variable yields a narrower
> distribution of estimates, however, i.e., it is more precise.


{% highlight r %}
results_sim_case5 %>% 
  group_by(covariate) %>% 
  summarise(mean_est = mean(estimate),
            sd_est = sd(estimate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 2 x 3
##   covariate         mean_est sd_est
##   <chr>                <dbl>  <dbl>
## 1 with covariate       1.00   0.138
## 2 without covariate    0.999  0.250
{% endhighlight %}
## Conclusion
When a control variable is collected _after_ the intervention took place,
it is possible that it is directly or indirectly affected by the intervention.
If this is indeed the case, including the control variable in the analysis
may yield biased estimates or decrease rather than increase the precision of the
estimates. In designed experiments, the solution to this problem is evident:
collect the control variable before the intervention takes place. If this isn't
possible, you had better be pretty sure that the control variable isn't a 
post-treatment variable. More generally, throwing predictor variables into
a statistical model in the hopes that this will improve the analysis is a dreadful
idea.

<!-- ## Reference -->

<!-- Zimmerman, Donald W. 1998. [Invalidation of parametric and nonparametric statistical tests by concurrent violation of two assumptions](https://doi.org/10.1080/00220979809598344). _Journal of Experimental Education_ 67(1). 55-68. -->
