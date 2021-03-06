---
layout: post
title: "Some illustrations of bootstrapping"
category: [Teaching]
tags: [bootstrapping, R]
---



This post illustrates a statistical technique
that becomes particularly useful when you want to calculate the sampling variation of some custom statistic
when you start to dabble in mixed-effects models.
This technique is called [**bootstrapping**](https://books.google.ch/books/about/An_Introduction_to_the_Bootstrap.html?id=gLlpIUxRntoC&redir_esc=y)
and I will first illustrate its use in constructing confidence intervals around 
a custom summary statistic.
Then I'll illustrate three bootstrapping approaches when constructing
confidence intervals around a regression coefficient,
and finally, I will show how bootstrapping can be used to compute _p_-values.

The goal of this post is _not_ to argue that bootstrapping is superior to the traditional alternatives---in the examples 
discussed, they are pretty much on par---but merely to illustrate how it works.
The main advantage of bootstrapping, as I understand it, 
is that it can be applied in situation where the traditional alternatives
are not available, 
where you don't understand how to use them
or where their assumptions are questionable,
but I think it's instructive to see how its results compare to those of traditional approaches where both can readily be applied.

<!--more-->

Those interested can [download](http://janhove.github.io/RCode/bootstrapping.Rmd) the `R` code for this post.

### A confidence interval around an asymmetrically trimmed mean
The histogram below shows how well 159 participants
performed on a L1 German vocabulary test (_WST_).
While the distribution is clearly left-skewed,
we still want to characterise its central tendency.
Let's say, for the sake of this example,
that we decide to calculate the sample mean,
but we want to disregard the lowest 10% of scores.
For this sample, this yields a value of 32.7.

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-42-1.png)

> The distribution of 159 _WST_ (German vocabulary test) scores.
> Disregarding the bottom 10% of this sample (16 values), its mean is 32.7.

Easy enough, but let's say we want to express the sampling variation of this number (32.7) using an 80% confidence interval?
Constructing confidence intervals around regular means can be done using the appropriate _t_-distribution,
but we may not feel comfortable applying this approach to a mean based on the top 90% of the data only
or we may not be sure how many degrees of freedom the _t_-distribution should have (158 or 142?).
(In practice, this won't make much of a difference, but verifying this would be reassuring.)

One possible solution is to proceed as follows.
We take the sample that we actually observed (the green histogram below)
and use it to create a _new_ sample with the same number of observations (in this case: 159).
We do this by taking a random observation from the original dataset,
jotting down its value, 
putting it back in the dataset, 
sampling again etc.,
until we have the number of observations required (**resampling with replacement**).
This new sample will be fairly similar in shape to our original sample,
but won't be identical to it (the purple histogram below):
Some values will occur more often than in the original sample,
others less often, and some may not occur at all in the new sample.
We then compute the statistic of interest for the new sample (here: the mean after disregarding the lowest 10% of observations; the dashed red line) and jot down its value.
We can do this, say, 1,000 times to see to what extent the trimmed means
vary in the new, randomly created samples (blue histogram below).

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-43-1.png)

> _Top row:_ The observed distribution of WST scores; the dashed red line indicates the asymmetrically trimmed mean (disregarding the bottom 10% of the data).
> _Middle row_: Three new samples obtained by resampling with replacement from the observed WST distribution and their asymmetrically trimmed means.
> _Bottom row:_ The distribution of asymmetrically trimmed means in 1,000 such new samples.

To construct a 80% confidence interval around the asymmetrically trimmed mean of 32.7,
we can sort the values in the blue histogram from low to high 
and look up the values that demarcate the middle 80% (roughly 31.9 and 33.6).

The technique used above---generating new samples based on the observed data to assess how much a statistic varies in similar but different samples---is known as **bootstrapping**.
It is particularly useful when you want to
gauge the variability of a sample statistic 

* when you don't have an analytic means of doing so (e.g., based on a theoretical distribution such as the $t$-distribution for sample means)  
* or if you fear that the assumptions behind the analytic approach may be violated
to such an extent that it may not provide good enough approximations.  

While I've described _how_ bootstrapping works,
it's less easy to see _why_ it works.
To assess the sampling variation of a given sample statistic, we would ideally have access to the
population from which the sample at hand was drawn.
Needless to say, we rarely have this luxury,
and the sample at hand typically represents our best guess of how the population might look like,
so we use our sample as a stand-in for the population.

Perhaps you feel that it requires too big a leap of faith 
to use the sample we have as a stand-in for the population.
After all, by chance, 
the sample we have may poorly reflect the population from which it was drawn.
I think this is a reasonable concern,
but rather than to alleviate it, I will just point out
that analytical approaches operate on similar assumptions:
_t_-values, for instance, use the sample standard deviations as stand-ins for the population standard deviations,
and their use in smaller samples is predicated on the fiction that the samples were drawn from normal distributions.
Assumptions, then, are needed to get a handle on inferential problems,
whether you choose to solve them analytically, using bootstrapping or by another means.

### A confidence interval for a regression coefficient: Non-parametric, parametric and semi-parametric bootstrapping

The procedure outlined in the example above is only one kind of bootstrapping.
While it's usually just called 'bootstrapping', it is sometimes called **non-parametric bootstrapping**
to distinguish it from two other flavours of bootstrapping: 
**parametric bootstrapping** and **semi-parametric bootstrapping**.
In this section, I will briefly explain the difference between these three techniques
using a regression example.

We have a dataset with 159 observations of four variables,
whose intercorrelations are outlined below.
The outcome variable is `TotCorrect`; the other three variables serve as predictors.

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-44-1.png)




After standardising the three predictors,
we fit a multiple regression model on these data,
which yields the following estimated coefficients:


{% highlight text %}
##                 Estimate
## (Intercept)        16.50
## z.WST               1.15
## z.Raven             1.89
## z.English.Cloze     1.60
{% endhighlight %}

To express the variabilitity of `z.WST`'s coefficient, we want to construct a 90% confidence interval around it.
We could use the regression model's output to construct a 90% confidence interval using the appropriate $t$-distribution, but for the sake of the argument, let's pretend that option is off the table.




#### Non-parametric bootstrap

For the non-parametric bootstrap, we do essentially the same as in the previous example,
but rather than computing the trimmed means for 1,000 new samples,
we fit a regression model on them and jot down the estimated coefficient for `z.WST`.

1. Resample 159 rows with replacement from the original dataset.
2. Fit the multiple regression model on the new dataset.
3. Jot down the estimated coefficient for `z.WST`.
4. Perform steps 1--3 1,000 times.



(The results are shown further down.)

#### Parametric bootstrap

The regression model above is really just an equation:

![Regression equation](http://janhove.github.io/figs/2016-12-20-bootstrapping/equation.png)

where the random errors are assumed to be normally distributed around 0 with a standard deviation
that is estimated from the data.

Instead of randomly resampling cases from the original dataset, 
we could use this regression equation to generate new outcome values.
Due to the random error term, new simulated samples will differ from each other.
We can then refit the regression model on the new values to see how much the estimated coefficients vary.

1. Simulate 159 new outcome values on the basis of the regression model (prediction + random error from normal distribution) and the original predictors.
2. Fit the multiple regression model on the new outcome values using the old predictors.
3. Jot down the estimated coefficient for `z.WST`.
4. Perform steps 1--3 1,000 times. 



This approach is called _parametric_ bootstrapping
because it relies on the original model's estimated regression coefficients (parameters),
its error term estimate as well as the assumption that the errors are drawn from a normal distribution.

#### Semi-parametric bootstrap

As its name suggests, the semi-parametric bootstrap is a compromise between the non-parametric and the parametric bootstrap.
The new outcome values are partly based on the original regression model,
but instead of drawing the errors randomly from a normal distribution,
the original model's errors are resampled with replacement and added to the model's predictions.

1. Extract the residuals (errors) from the original regression model.
2. Predict 159 new outcome values on the basis of the regression model (prediction only) and the original predictors.
3. Resample 159 values with replacement from the errors extracted in step 1 and add these to the predictions from step 2.
4. Fit the multiple regression model on the new outcome values (prediction + resampled errors) using the old predictors.
5. Jot down the estimated coefficient for `z.WST`.
6. Perform steps 3--5 1,000 times. 



This approach is called _semi-parametric_ bootstrapping
because, while it relies on the original model's estimated regression coefficients,
the error distribution is assumed to be normal but is instead approximated by sampling from the original model's errors.

#### Results

The histograms below show the sampling variability of the estimated `z.WST` coefficient
according to each method.

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-51-1.png)

To construct 90% confidence intervals, 
we sort the bootstrapped estimates from low to high and pick the 50th and 950th value.
The resulting intervals are plotted below alongside the 90% confidence interval constructed from the model summary.
In this case, they're all pretty similar.

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-52-1.png)

### Testing null hypotheses using bootstrapping

Another use for parametric and semi-parametric bootstrapping is to compute _p_-values
if they can't be computed analytically or if the assumptions of the analytical approach aren't adequately met.
The basic logic is the same in either case: You generate a large number of datasets in which you _know_ the null hypothesis (e.g., 'no difference' or 'the coefficient is 0' or perhaps even 'the difference/coefficient is 0.3') to be true.
You then compute whichever statistic you're interested in for all of these new datasets
and you calculate the proportion of cases where the statistic in the new datasets
exceeds the statistic in your original sample.
This proportion is a _p_-value as it expresses the (approximate) probability of observing a
sample statistic of at least this magnitude if the null hypothesis is actually true.

(Example for more advanced users: 
Likelihood ratio tests used for comparing nested mixed effects models are based on the assumption that likelihood ratios follow a Χ² distribution if the null hypothesis is true. 
This is a good enough assumption for large samples, 
but when you're fitting mixed effects models, it isn't always clear exactly what a large sample is.
When in doubt, you can [resort](https://cran.r-project.org/web/packages/pbkrtest/index.html) to [bootstrapping](https://cran.r-project.org/web/packages/lme4/lme4.pdf#page.6) in such cases:
You generate new datasets in which the null hypothesis is true and compute likelihood ratios for them.
These likelihood ratios then serve as distribution of likelihood ratios under the null hypothesis
against which you can then compare the likelihood ratio computed for your original dataset.)

For illustrative purposes, we're going to compute the _p_-value for the estimated `z.WST` coefficient from the previous example using parametric and semi-parametric bootstrapping, although there are no reasons to suspect that the _t_-distribution-based _p_-value in the model output (0.012) is completely off.
As such, we'd expect the three methods to yield similar results.
For both the parametric and semi-parametric bootstraps,
we need to generate datasets in which we _know_ the null hypothesis to be true (i.e., the coefficient for `z.WST` = 0).
This we do by first fitting a **null model** to the data,
that is, a model that is similar to the full model we want to fit
but without the `z.WST` term we want to compute the _p_-value for.
Then we generate new datasets on the basis of this null model.
This guarantees that the null hypothesis is actually true in all newly generated samples,
so that the distribution of the estimated `z.WST` coefficients for the newly generated samples
can serve as an approximation of the estimated `z.WST` coefficient's distribution under the null hypothesis.

The steps for computing _p_-values using a parametric and semi-parametric bootstrap are pretty similar;
the only real difference is 
whether we're more comfortable assuming that the residuals are drawn from a normal distribution or
that their distribution is similar to that of the null model's residuals.

#### Parametric bootstrapping

1. Fit a null model, i.e., a model _without_ whichever term you want to compute the _p_-value for (here: `z.WST`).
2. Simulate 159 new outcome values on the basis of the null model (prediction + random error from normal distribution) and the predictors in the null model.
3. Fit the _full_ multiple regression model, i.e., with the term we want to compute the _p_-value for, on the new outcome values using the old predictors.
4. Jot down the esetimated coefficient for `z.WST`.
5. Perform steps 2--4 10,000 times.
6. See how often the estimated `z.WST` coefficients in the 10,000 samples generated under the null hypothesis are larger in magnitude than the estimated `z.WST` coefficient in the original sample. This is the _p_-value. 

(Results below.)



#### Semi-parametric bootstrapping

1. Fit a null model, i.e., a model _without_ whichever term you want to compute the _p_-value for (here: `z.WST`).
2. Extract the null model's residuals (errors).
3. Predict 159 new outcome values on the basis of the null model (prediction only) and the predictors in the null model.
4. Resample 159 values with replacement from the errors extracted in step 2 and add these to the predictions from step 3.
5. Fit the _full_ multiple regression model, i.e., with the term we want to compute the _p_-value for, on the new outcome values (prediction + resampled error) using the old predictors.
6. Jot down the estimated coefficient for `z.WST`.
7. Perform steps 4--6 10,000 times.
8. See how often the estimated `z.WST` coefficients in the 10,000 samples generated under the null hypothesis are larger in magnitude than the estimated `z.WST` coefficient in the original sample. This is the _p_-value.



#### Results

The distribution of the `z.WST` looks pretty similar whether we use parametric or semi-parametric bootstrapping.

![center](/figs/2016-12-20-bootstrapping/unnamed-chunk-55-1.png)

The _p_-value obtained by parametric bootstrapping is 0.0142 (i.e., 142 out of 10,000 estimated `z.WST` coefficients have absolute values larger than 1.15),
the one obtained by semi-parametric bootstrapping is 0.0124,
whereas the _t_-distribution-based _p_-value was 0.012.
As expected, then, there is hardly any difference between them.
The bootstrapped _p_-values are themselves subject to random variation,
and different runs of the bootstrap will produce slightly different results.
We could increase the number of bootstrap runs for greater accuracy,
but I don't think this is really necessary here.

### Concluding remarks
My goal was to illustrate how bootstrapping works 
rather than to discuss at length when to use which approach.
Indeed, in the regression example above, the results of the bootstraps
hardly differ from the _t_-distribution-based results,
so the choice of method doesn't really matter much.

That said, bootstrapping is a technique that's useful to at least know about
as it comes in handy if you want to estimate the sampling variation of a summary statistic in some funky distribution 
or if you want to verify, say, a likelihood ratio test for nested mixed-effects models.
