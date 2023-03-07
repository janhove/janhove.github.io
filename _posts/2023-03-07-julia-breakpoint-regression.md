---
title: "Adjusting to Julia: Piecewise regression"
layout: post
mathjax: true
tags: [Julia, significance, breakpoint regression, multiple comparisons]
category: [Analysis]
---

In this fourth installment of _Adjusting to [Julia](https://julialang.org/)_,
I will at long last analyse some actual data.
One of the first posts on this blog was 
[Calibrating p-values in 'flexible' piecewise regression models]({% post_url 2014-08-20-adjusted-pvalues-breakpoint-regression %}).
In that post, I fitted a piecewise regression to a dataset 
comprising the ages at which a number of language learners started
learning a second language (age of acquisition, AOA)
and their scores on a grammaticality judgement task (GJT) in that second language.
A piecewise regression is a regression model in which the slope of the function
relating the predictor (here: AOA) to the outcome (here: GJT) changes at some
value of the predictor, the so-called breakpoint.
The problem, however, was that I didn't specify the breakpoint beforehand
but pick the breakpoint that minimised the model's deviance.
This increased the probability that I would find that the slope before and
after the breakpoint differed, even if they in fact were the same.
In the blog post I wrote almost nine years ago, I sought to recalibrate the
p-value for the change in slope by running a bunch of simulations in R.
In this blog post, I'll do the same, but in Julia.

<!--more-->




## The data set
We'll work with the data from the North America study 
conducted by [DeKeyser et al. (2010)](https://doi.org/10.1017/S0142716410000056).
If you want to follow along, you can download this dataset [here](https://janhove.github.io/datasets/dekeyser2010.csv) and save it to 
a subdirectory called `data` in  your working directory.

We need the `DataFrames`, `CSV` and `StatsPlots` packages 
in order to read in the CSV with the dataset as a data frame and draw some basic graphs.


{% highlight julia %}
using DataFrames, CSV, StatsPlots

d = CSV.read("data/dekeyser2010.csv", DataFrame);

@df d plot(:AOA, :GJT
           , seriestype = :scatter
           , legend = :none
           , xlabel = "AOA"
           , ylabel = "GJT")
{% endhighlight %}

![center](/figs/2023-03-07-julia-breakpoint-regression/unnamed-chunk-1-J1.png)

The `StatsPlots` package uses the `@df` macro to specify that the
variables in the `plot()` function can be found in the data frame
provided just after it (i.e., `d`).

## Two regression models
Let's fit two regression models to this data set using the `GLM` package.
The first model, `lm1`, is a simple regression model with `AOA` as the predictor
and `GJT` as the outcome. The syntax should be self-explanatory:


{% highlight julia %}
using GLM 

lm1 = lm(@formula(GJT ~ AOA), d);
coeftable(lm1)
{% endhighlight %}



{% highlight text %}
## ──────────────────────────────────────────────────────────────────────────
##                  Coef.  Std. Error       t  Pr(>|t|)  Lower 95%  Upper 95%
## ──────────────────────────────────────────────────────────────────────────
## (Intercept)  190.409      3.90403    48.77    <1e-57  182.63     198.188
## AOA           -1.21798    0.105139  -11.58    <1e-17   -1.42747   -1.00848
## ──────────────────────────────────────────────────────────────────────────
{% endhighlight %}

We can visualise this model by plotting the data in a scatterplot
and adding the model predictions to it like so. I use `begin` and `end`
to force Julia to only produce a single plot.


{% highlight julia %}
d[!, "prediction"] = predict(lm1);

begin
@df d plot(:AOA, :GJT
           , seriestype = :scatter
           , legend = :none
           , xlabel = "AOA"
           , ylabel = "GJT");
@df d plot!(:AOA, :prediction
            , seriestype = :line)
end
{% endhighlight %}

![center](/figs/2023-03-07-julia-breakpoint-regression/unnamed-chunk-3-J1.png)

Our second model will incorporate an 'elbow' in the regression line
at a given breakpoint -- a piecewise regression model.
For a breakpoint `bp`, we need to create a variable
`since_bp` that encodes how many years beyond this breakpoint the participants'
`AOA` values are. If an `AOA` value is lower than the breakpoint, the
corresponding `since_bp` value is just 0.
The `add_breakpoint()` value takes a dataset containing an `AOA` variable
and adds a variable called `since_bp` to it.


{% highlight julia %}
function add_breakpoint(data, bp)
	data[!, "since_bp"] = max.(0, data[!, "AOA"] .- bp);
end;
{% endhighlight %}

To add the `since_bp` variable for a breakpoint at age 12 
to our dataset `d`, we just run this function. Note that in Julia,
arguments are not copied when they are passed to a function. That is,
the `add_breakpoint()` function _changes_ the dataset; it does not create
a changed _copy_ of the dataset like R would:


{% highlight julia %}
# changes d!
add_breakpoint(d, 12);
print(d);
{% endhighlight %}

Since we don't know what the best breakpoint is,
we're going to estimate it from the data. For each 
integer in a given range (`minbp` through `maxbp`),
we're going to fit a piecewise regression model with 
that integer as the breakpoint. We'll then pick
the breakpoint that minimises the deviance of the fit
(i.e., the sum of squared differences between the model fit
and the actual outcome). The `fit_piecewise()` function takes care of this.
It outputs both the best fitting piecewise regression model and the breakpoint
used for this model.


{% highlight julia %}
function fit_piecewise(data, minbp, maxbp)
  min_deviance = Inf
  best_model = nothing
  best_bp = 0
  current_model = nothing
  
  for bp in minbp:maxbp
    add_breakpoint(data, bp)
    current_model = lm(@formula(GJT ~ AOA + since_bp), data)
    if deviance(current_model) < min_deviance
      min_deviance = deviance(current_model)
      best_model = current_model
      best_bp = bp
    end
  end
  
  return best_model, best_bp
end;
{% endhighlight %}

Let's now apply this function to our dataset.
The estimated breakpoint is at age 16, and the model
coefficients are shown below:


{% highlight julia %}
lm2 = fit_piecewise(d, 6, 20);
# the first output is the model itself, the second the breakpoint used
coeftable(lm2[1])
{% endhighlight %}



{% highlight text %}
## ───────────────────────────────────────────────────────────────────────────
##                  Coef.  Std. Error      t  Pr(>|t|)    Lower 95%  Upper 95%
## ───────────────────────────────────────────────────────────────────────────
## (Intercept)  212.423     11.555     18.38    <1e-28  189.394      235.452
## AOA           -2.86035    0.819957  -3.49    0.0008   -4.49452     -1.22618
## since_bp       1.78381    0.883513   2.02    0.0472    0.0229738    3.54465
## ───────────────────────────────────────────────────────────────────────────
{% endhighlight %}



{% highlight julia %}
lm2[2]
{% endhighlight %}



{% highlight text %}
## 16
{% endhighlight %}

Let's visualise this model by drawing a scatterplot and adding the regression
fit to it. While we're at it, we might as well add a 95% confidence band around
the regression fit.


{% highlight julia %}
add_breakpoint(d, 16);
predictions = predict(lm2[1], d;
                      interval = :confidence,
                      level = 0.95);
d[!, "prediction"] = predictions[!, "prediction"];
d[!, "lower"] = predictions[!, "lower"];
d[!, "upper"] = predictions[!, "upper"];

begin
@df d plot(:AOA, :GJT
           , seriestype = :scatter
           , legend = :none
           , xlabel = "AOA"
           , ylabel = "GJT"
      );
@df d plot!(:AOA, :prediction
            , seriestype = :line
            , ribbon = (:prediction .- :lower, 
                        :upper .- :prediction)
      )
end
{% endhighlight %}

![center](/figs/2023-03-07-julia-breakpoint-regression/unnamed-chunk-8-J1.png)

We could run an $F$-test for the model comparison like below,
but the $p$-value corresponds to the $p$-value for the `since_bp` value, 
anyway:

{% highlight julia %}
ftest(lm1.model, lm2[1].model);
{% endhighlight %}

But there's a problem: This $p$-value can't be taken at face value.
By looping through different possible breakpoint and then picking the one
that worked best for our dataset, we've increased our chances of finding
some pattern in the data even if nothing is going on. So we need to recalibrate
the $p$-value we've obtained.

## Recalibrating the p-value
Our strategy is as follows. We will generate a fairly large number of
datasets similar to `d` but of which we know that there isn't any
breakpoint in the `GJT`/`AOA` relationship. We will do this by simulating
new `GJT` values from the simple regression model fitted above (`lm1`).
We will then apply the `fit_piecewise()` function to each of these datasets,
using the same `minbp` and `maxbp` values as before and obtain the $p$-value
associated with each model. We will then compute the proportion of the
$p$-value so obtained that is lower than the $p$-value from our original model,
i.e., 0.0472.

I wasn't able to find a Julia function similar to R's `simulate()`
that simulates a new outcome variable based on a linear regression model.
But such a function is easy enough to put together:


{% highlight julia %}
using Distributions

function simulate_outcome(null_model)
  resid_distr = Normal(0, dispersion(null_model.model))
  prediction = fitted(null_model)
  new_outcome = prediction + rand(resid_distr, length(prediction))
  return new_outcome
end;
{% endhighlight %}

The `one_run()` function generates a single new outcome vector,
overwrites the `GJT` variable in our dataset with it,
and then applies the `fit_piecewise()` function to the dataset, 
returning the $p$-value of the best-fitting piecewise regression model.


{% highlight julia %}
function one_run(data, null_model, min_bp, max_bp)
  new_outcome = simulate_outcome(null_model)
  data[!, "GJT"] = new_outcome
  best_model = fit_piecewise(data, min_bp, max_bp)
  pval = coeftable(best_model[1]).cols[4][3]
  return pval
end;
{% endhighlight %}

Finally, the `generate_p_distr()` function runs the `one_run()` function
a large number of times and output the $p$-values generated.


{% highlight julia %}
function generate_p_distr(data, null_model, min_bp, max_bp, n_runs)
  pvals = [one_run(data, null_model, min_bp, max_bp) for _ in 1:n_runs]
  return pvals
end;
{% endhighlight %}

Our simulation will consist of 25,000 runs, and in each run, 16 regression
models will be fitted, for a total of 400,000 models. On my machine,
this takes less than 20 seconds (i.e., less than 50 microseconds per model).


{% highlight julia %}
n_runs = 25_000;
pvals = generate_p_distr(d, lm1, 6, 20, n_runs);
{% endhighlight %}

For about 11% of the datasets in which no breakpoint governed the data,
the `fit_piecewise()` procedure returned a $p$-value of 0.0472 or lower.
So our original $p$-value of 0.0472 ought to be recalibrated to about 0.12.


{% highlight julia %}
sum(pvals .<= 0.0472) / n_runs
{% endhighlight %}



{% highlight text %}
## 0.11784
{% endhighlight %}
