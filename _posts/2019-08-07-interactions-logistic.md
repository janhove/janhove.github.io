---
title: "Interactions in logistic regression models"
layout: post
tags: [R, logistic regression, tutorial, bootstrapping, Bayesian statistics, brms]
category: [Analysis]
---


When you want to know if the difference between two conditions 
is larger in one group than in another, you're interested in the **interaction** 
between 'condition' and 'group'. Fitting interactions statistically 
is one thing, and I will assume in the following that you know how 
to do this. Interpreting statistical interactions, however, is another 
pair of shoes. In this post, I discuss why this is the case and how
it pertains to interactions fitted in logistic regression models.

<!--more-->

## The problem: Nonlinear mappings
The crux of the problem was discussed from a psychologist's perspective 
by [Loftus (1978](http://faculty.washington.edu/gloftus/MiscMissingArticles/Loftus.1978.pdf); 
see also [Wagenmakers et al. 2012](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3267935/)): 
Even if you find a statistical interaction between 'condition' and 'group', this doesn't necessarily 
mean that one group is more sensitive to the difference in conditions than the other group. 
By the same token, even if you _don't_ find a statistical interaction between 'condition' and 'group', 
this doesn't necessarily suggest that both groups _are_ equally sensitive to the difference in conditions. 
The reason for this ambiguity is that the measured outcome variable 
(e.g., test score, reaction time, etc.) need not map linearly onto the latent variable of interest 
(e.g., proficiency, effort, etc.). For example, a 3-point increase on an arbitrary scale 
from one condition to another may correspond to a greater gain in actual proficiency on the higher end of the scale 
than on the lower end. If one group progresses from 7 to 10 points and the other from 15 to 18 points, 
then, the statistical analysis won't reveal an interaction between 'condition' and 'group' in terms of the 
measured outcome variable, even though there is a greater gain in proficiency for the latter group than 
for the former. By the same token, a 4-point increase for the first group may correspond to a 3-point 
increase for the second group in terms of proficiency gained. If this doesn't make much sense to you, 
I suggest you read the first seven pages of 
[Wagenmakers et al. (2012)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3267935/).

Unfortunately, the problem with interpreting interactions doesn't vanish if you don't want to infer 
latent psychological variables and you stick strictly to observable quantities. 
For instance, if you want to compare the efficiency of two car makes (red vs. blue) 
depending on fuel type (petrol vs. diesel), you may not find an interaction between car make 
and fuel type when you express fuel efficiency in litres per 100 kilometres: There may be,
say, a one-litre difference between both fuel types for both car makes (Figure 1, left).
But if you express fuel consumption in miles per gallon (or kilometres per litre), you'd observe 
that the difference in distance travelled per amount of fuel consumed between diesel and petrol
is larger for one car make than for the other (Figure 1, right).
The reason is that, while both measures (litres/100 km and miles/gallon) are perfectly reasonable 
and use exactly the same information (distance travelled and fuel burnt), 
the mapping between them is nonlinear.

![center](/figs/2019-08-07-interactions-logistic/unnamed-chunk-2-1.png)

> **Figure 1.** You may not observe an interaction between fuel type and car make
> when fuel consumption is expressed as fuel burnt per distance covered 
> (litres per 100 km, left) even though
> you would observe such an interaction when fuel consumption is expressed as 
> distance covered per unit of fuel burnt (miles per gallon, right).

## Log-odds, odds, and proportions
You encounter the same problem when you fit interactions in a logistic model. 
The coefficients in logistic models are estimated on the log-odds scale, 
but such models are more easily interpreted when the coefficients or its 
predictions are converted to odds (by exponentiating the log-odds) or to 
proportions (by applying the logistic function to predictions obtained in log-odds). 
Both the exponential and the logistic function are nonlinear, so that you 
end up with the same problem as above: Whether or not you observe an 
interaction may depend on how you express the outcome variable.

(Sidebar: A proportion of 0.80 corresponds to odds of 0.80/(1-0.80) = 4 against 1.
By taking the natural logarithm of the odds, you end up with the log-odds of ln(0.80) = 1.39.
To arrive back at the odds, exponentiate: exp(1.39) = 4.
To arrive back at the proportion, apply the logistic function: 1/(1+exp(-1.39)) = 0.80.
All these functions are nonlinear.)

Figure 2 illustrates that a non-crossover interaction if the results are 
expressed in, say, log-odds needn't remain an interaction if you 
express the results in another way.

![center](/figs/2019-08-07-interactions-logistic/unnamed-chunk-3-1.png)

> **Figure 2.**
> _Top row:_ The difference in proportions between conditions A and B is 
> the same in groups C and D. When the same results are expressed in odds or log-odds, 
> however, the difference is larger in group D than in group C. 
> _Middle row:_ This time, the difference in odds is the same in both groups, 
> but when expressed in proportions or log-odds, the difference is larger in group C 
> than in group D. 
> _Bottom row:_ The difference in log-odds is the same in both groups. 
> When expressed in odds, it is _larger_ in group D, but when expressed in proportions, it is _smaller_ in group D.

What's the practical upshot of all this? 
First, before you interpret a non-crossover interaction, 
read [Wagenmakers et al. (2012)](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3267935/).
Second, if you're working with binary data and you predict a 
non-crossover interaction in a logistic model, be aware that a significant
interaction in terms of the log-odds output by your model needn't correspond
to an interaction in terms of proportions, and vice versa.

## How to check for interactions in terms of proportions
At this point, you may be wondering how you can check whether
a significant interaction in terms of log-odds in your own model corresponds
to a significant interaction in terms of proportions, too.
(If you aren't, check out this [random Garfield comic](https://garfield.com/comic/random) instead.)
In the following, I show two ways how you can do this:
using parametric bootstrapping and by going Bayesian.

We'll work with a simple made-up dataset. The question is whether variables AB and CD interact
with respect to the outcome variable Successes. For each combination of predictor variables,
1000 cases were observed, among which variable numbers of Successes:


{% highlight r %}
# Create a dataset
df <- expand.grid(
  AB = c("A", "B"),
  CD = c("C", "D")
)
df$Total <- 1000
df$Successes <- c(473, 524, 898, 945)
df
{% endhighlight %}



{% highlight text %}
##   AB CD Total Successes
## 1  A  C  1000       473
## 2  B  C  1000       524
## 3  A  D  1000       898
## 4  B  D  1000       945
{% endhighlight %}

### Using parametric bootstrapping
First, fit the logistic regression model.
Unsurprisingly (since this is a made-up dataset),
the interaction effect is significant when expressed
in log-odds (0.46, 95% confidence interval: [0.08, 0.85], _z_ = 2.38, _p_ = 0.017):


{% highlight r %}
# Fit a logistic regression model
m <- glm(cbind(Successes, Total - Successes) ~ AB*CD, data = df, 
         family = "binomial")
summary(m)$coefficients
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error z value Pr(>|z|)
## (Intercept)   -0.108     0.0633   -1.71 8.79e-02
## ABB            0.204     0.0896    2.28 2.26e-02
## CDD            2.283     0.1222   18.69 6.29e-78
## ABB:CDD        0.464     0.1954    2.38 1.74e-02
{% endhighlight %}



{% highlight r %}
confint(m)
{% endhighlight %}



{% highlight text %}
## Waiting for profiling to be done...
{% endhighlight %}



{% highlight text %}
##               2.5 % 97.5 %
## (Intercept) -0.2324 0.0159
## ABB          0.0287 0.3799
## CDD          2.0478 2.5271
## ABB:CDD      0.0849 0.8519
{% endhighlight %}

When expressed in proportions, however,
the difference between C and D in condition A
is pretty much as large as the difference between C and D in condition B.
For this example, we could just as well compute this directly
from dataset `df`, but a more general method is to ask the model
to predict the proportions and then compute the differences between them:


{% highlight r %}
# Predicted proportions in condition A
predict(m, type = "response", newdata = data.frame(AB = "A", CD = "C"))
{% endhighlight %}



{% highlight text %}
##     1 
## 0.473
{% endhighlight %}



{% highlight r %}
predict(m, type = "response", newdata = data.frame(AB = "A", CD = "D"))
{% endhighlight %}



{% highlight text %}
##     1 
## 0.898
{% endhighlight %}



{% highlight r %}
# difference:
0.898 - 0.473
{% endhighlight %}



{% highlight text %}
## [1] 0.425
{% endhighlight %}



{% highlight r %}
# Predicted proportions in condition B
predict(m, type = "response", newdata = data.frame(AB = "B", CD = "C"))
{% endhighlight %}



{% highlight text %}
##     1 
## 0.524
{% endhighlight %}



{% highlight r %}
predict(m, type = "response", newdata = data.frame(AB = "B", CD = "D"))
{% endhighlight %}



{% highlight text %}
##     1 
## 0.945
{% endhighlight %}



{% highlight r %}
# difference:
0.945 - 0.524
{% endhighlight %}



{% highlight text %}
## [1] 0.421
{% endhighlight %}



{% highlight r %}
# difference between differences:
0.425 - 0.421
{% endhighlight %}



{% highlight text %}
## [1] 0.004
{% endhighlight %}

0.004 is the estimated interaction effect when expressed
on the proportion scale. Now we need to express our uncertainty
about this number. Here I do this by means of a parametric
bootstrap. If you've never heard of bootstrapping,
you can read my blog post 
[_Some illustrations of bootstrapping_](http://janhove.github.io/teaching/2016/12/20/bootstrapping).
In a nutshell, we're going to use the model
to simulate new datasets, refit the model on those
simulate datasets, and calculate the interaction effect
according to these refitted models in the same way as we did above.
This will yield a large number of estimated interaction effects (some larger
than 0.004, others smaller) on the basis of which we can estimate
how large our estimation error could be:


{% highlight r %}
# The following code implements a parametric bootstrap
#   with 'bs_runs' runs.
bs_runs <- 20000

# Preallocate matrix to contain predicted proportions per cell
bs_proportions <- matrix(ncol = 4, nrow = bs_runs)

# Simulate new data from model, refit model, and
#   obtain predicted proportions a large number of times
for (i in 1:bs_runs) {
  # Simulate a new outcome from the model
  bs_outcome <- simulate(m)$sim_1
  
  # Refit model on simulated outcome
  bs_m <- glm(bs_outcome ~ AB*CD, data = df, family = "binomial")
  
  # Predicted proportion ("response") for each cell according to bs_m
  bs_proportions[i, 1] <- predict(bs_m, type = "response",
                                  newdata = data.frame(AB = "A",
                                                       CD = "C"))
  bs_proportions[i, 2] <- predict(bs_m, type = "response",
                                  newdata = data.frame(AB = "A", 
                                                       CD = "D"))
  bs_proportions[i, 3] <- predict(bs_m, type = "response",
                                  newdata = data.frame(AB = "B", 
                                                       CD = "C"))
  bs_proportions[i, 4] <- predict(bs_m, type = "response",
                                  newdata = data.frame(AB = "B", 
                                                       CD = "D"))
}

# Take the difference between D and C for condition A
bs_differences_A <- bs_proportions[, 2] - bs_proportions[, 1]

# Take the difference between D and C for condition B
bs_differences_B <- bs_proportions[, 4] - bs_proportions[, 3]

# Take the difference between these differences
bs_differences_diff <- bs_differences_B - bs_differences_A

# Plot
hist(bs_differences_diff, col = "tomato",
     main = "bootstrapped interaction effects\n(in proportions)",
     xlab = "estimates")
{% endhighlight %}

![center](/figs/2019-08-07-interactions-logistic/unnamed-chunk-7-1.png)

> *Figure 3*. Distribution of the bootstrapped interaction effect
> in proportions. 95% of this distribution falls between
> -0.054 and 0.046.

The confidence interval about the number 0.004 can be 
obtained as follows:


{% highlight r %}
# 95% confidence interval using the percentile approach
quantile(bs_differences_diff, probs = c(0.025, 0.975))
{% endhighlight %}



{% highlight text %}
##   2.5%  97.5% 
## -0.053  0.046
{% endhighlight %}

So while the interaction effect is significant
when expressed in log-odds, its [uncertainty interval](https://statmodeling.stat.columbia.edu/2010/12/21/lets_say_uncert/) nicely straddles 
0 when expressed in proportions. (Obviously, the example
was contrived to yield this result.)

### Going the Bayesian route
Alternatively, you can fit the data
in a Bayesian model. I've used
the `brm()` function
from the `brms` package in
a [previous blog post](http://janhove.github.io/analysis/2018/12/20/contrasts-interactions), but its syntax
should be fairly transparent. The only
real difference (in terms of syntax) between
`brm()` and `glm()` is in how you specify the
outcome variable in a binomial logistic model.
In this model (a Bayesian binomial logistic
model with uninformative priors), too, the 
interaction effect is 'significant' (not a Bayesian term) 
when expressed in log-odds 
(0.47, 95% credible interval: [0.09, 0.86]).


{% highlight r %}
library(brms)
m.brm <- brm(Successes | trials(Total) ~ AB*CD, data = df, 
             family = "binomial", 
             cores = 4,
             # large number of iter(ations) to reduce
             #   effect of randomness on inferences
             iter = 10000, warmup = 1000)
summary(m.brm)
{% endhighlight %}



{% highlight text %}
##  Family: binomial 
##   Links: mu = logit 
## Formula: Successes | trials(Total) ~ AB * CD 
##    Data: df (Number of observations: 4) 
## Samples: 4 chains, each with iter = 10000; warmup = 1000; thin = 1;
##          total post-warmup samples = 36000
## 
## Population-Level Effects: 
##           Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
## Intercept    -0.11      0.06    -0.23     0.02      27892 1.00
## ABB           0.20      0.09     0.03     0.38      22995 1.00
## CDD           2.29      0.12     2.05     2.53      21443 1.00
## ABB:CDD       0.47      0.19     0.09     0.85      20471 1.00
## 
## Samples were drawn using sampling(NUTS). For each parameter, Eff.Sample 
## is a crude measure of effective sample size, and Rhat is the potential 
## scale reduction factor on split chains (at convergence, Rhat = 1).
{% endhighlight %}

Bayesian models generate not just estimates but entire distributions
of estimates (the 'posterior distribution'). We can use these to
to output distributions of predicted proportions and of the
differences between them:


{% highlight r %}
# Draw predictions from posterior distribution (in log-odds):
brm_predictions <- posterior_linpred(m.brm,
                                     newdata = expand.grid(
                                       AB = c("A", "B"),
                                       CD = c("C", "D"),
                                       Total = 1000
                                       )
                                     )
# Instead of using newdata = expand.grid(...),
#   you could also generate the 4 distributions
#   one at a time, e.g.:
# brm_predictions_AC <- posterior_linpred(m.brm,
#                                         newdata = data.frame(
#                                           AB = "A",
#                                           CD = "C",
#                                           Total = 1000
#                                           )
#                                         )

# Convert predictions in log-odds to predictions in proportions:
brm_proportions <- plogis(brm_predictions)

# Take the difference between D and C for condition A
brm_difference_A <- brm_proportions[, 3] - brm_proportions[, 1]

# Take the difference between D and C for condition B
brm_difference_B <- brm_proportions[, 4] - brm_proportions[, 2]

# Take the difference between these differences
brm_difference_diff <- brm_difference_B - brm_difference_A
hist(brm_difference_diff, col = "steelblue",
     main = "posterior distribution of interaction\n(in proportions)",
     xlab = "estimates")
{% endhighlight %}

![center](/figs/2019-08-07-interactions-logistic/unnamed-chunk-10-1.png)

> *Figure 4.* Posterior distribution of the interaction effect
> in proportions. 95% of this distribution falls between
> -0.053 and 0.046.

The credible interval about the number 0.004 can be 
obtained as follows:


{% highlight r %}
# 95% credible interval
quantile(brm_difference_diff, probs = c(0.025, 0.975))
{% endhighlight %}



{% highlight text %}
##    2.5%   97.5% 
## -0.0531  0.0447
{% endhighlight %}

The parametric and the bootstrap approach thus yield essentially
the same results in this case.

## References
Loftus, Geffrey R. 1978. On interpretation of interactions. _Memory & Cognition_ 6(3). 312-319.

Wagenmakers, Eric-Jan, Angelos-Miltiadis Krypotos, Amy H. Criss and Geoff Iverson. 2012. On the interpretation of removable interactions: A survey of the field 33 years after Loftus. _Memory & Cognition_ 40(2). 145-160.
