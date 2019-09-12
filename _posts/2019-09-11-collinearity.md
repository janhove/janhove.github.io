---
title: "Collinearity isn't a disease that needs curing"
layout: post
mathjax: true
tags: [R, multiple regression, assumptions, collinearity]
category: [Analysis]
---

Every now and again, some worried student or collaborator asks me 
whether they're "allowed" to fit a regression model in which some 
of the predictors are fairly strongly correlated with one another. 
Happily, most Swiss cantons have a laissez-faire policy with regard 
to fitting models with correlated predictors, so the answer to this 
question is "yes". Such an answer doesn't always set the student or 
collaborator at ease, so below you find my more elaborate answer.

<!--more-->



## What's collinearity?
Collinearity (or 'multicollinearity') means that a substantial
amount of information contained in some of the predictors
included in a statistical model can be pieced together as a
linear function of some of the other predictors in the model.
That's a mouthful, so let's look at some examples.

The easiest case is when you have a multiple regression model
with two predictors. These predictors can be continuous or
categorical; in what follows, I'll stick to continuous predictors.
I've created four datasets with two continuous predictors to illustrate
collinearity and its consequences. 
You find the `R` code reproduce all analyses at the bottom of this page.









The `outcome` in each dataset was created using the following equation:

![center](/figs/2019-09-11-collinearity/equation.png)

where the residuals were drawn from a normal distribution with a standard deviation of 3.5.

![center](/figs/2019-09-11-collinearity/residuals.png)

The four datasets are presented in **Figures 1 through 4**. Beginning analysts may be surprised
to see that I consider a situation where two predictors are correlated at r = 0.50 to be a case
of *weak* rather than moderate or strong collinearity. But in fact, the consequences of having
two predictors correlate at r = 0.50 (rather than at r = 0.00) are negligible. **Figure 4** 
highlights the _linear_ part in collinearity: while the two predictors in this
figure are perfectly related, there is no _linear_ relationship between them whatsoever.
Datasets such as the one in Figure 4 are not affected by any of the _statistical_ consequences
of collinearity, but they're useful to illustrate a point I want to make below.

![center](/figs/2019-09-11-collinearity/unnamed-chunk-5-1.png)

> **Figure 1.** A dataset with a strong degree of collinearity between the two predictors (r = 0.98).

![center](/figs/2019-09-11-collinearity/unnamed-chunk-6-1.png)

> **Figure 2.** A dataset with a weak degree of collinearity between the two predictors (r = 0.50).

![center](/figs/2019-09-11-collinearity/unnamed-chunk-7-1.png)

> **Figure 3.** A dataset in which the two predictors are entirely orthogonal and unrelated (r = 0.00).

![center](/figs/2019-09-11-collinearity/unnamed-chunk-8-1.png)

> **Figure 4.** A dataset with two orthogonal (r = 0.00) but perfectly related predictors: `predictor1` is a sinusoid transformation of `predictor2`. In other words, you can predict `predictor1` perfectly if you know `predictor2`.

If you fit multiple regressions on these four datasets,
you obtain the estimates that are shown in **Figure 5** along with
their 90% confidence intervals.



![center](/figs/2019-09-11-collinearity/unnamed-chunk-10-1.png)

> **Figure 5.** Estimated coefficients and their 90% confidence intervals for the models fitted to the four datasets. 


## What's the consequence of collinearity?

In essence, collinearity has one **statistical** consequence:
Estimates of regression coefficients that are affected by collinearity
vary more from sample to sample than estimates of regression coefficients
that aren't affected by collinearity; see **Figure 6** below.
As Figure 6 also illustrates, collinearity doesn't bias the coefficient estimates:
On average, the estimated coefficients equal the parameter's true value
both when there is no and very strong collinearity. It's just that 
the estimates vary much more around this average when there is strong collinearity.



![center](/figs/2019-09-11-collinearity/unnamed-chunk-12-1.png)

> **Figure 6.** I simulated samples of 50 observations from a distribution
> in which the two predictors were completely orthogonal (r = 0.00) and from
> a distribution in which they were highly correlated (r = 0.98). In all
> cases, both predictors were independently related to the outcome:
> ![equation](/figs/2019-09-11-collinearity/equation.png).
> On each simulated sample, I ran a multiple regression model, and I then 
> extracted the estimated model coefficients. This figure shows the estimated
> coefficients for the first predictor. While the estimates vary more when
> the predictors are strongly correlated than when they're not, 
> the estimates are unbiased in either case: On average, they equal the
> true population parameter (dashed red line).

Crucially, and happily, this greater variability is reflected in the standard errors and
confidence intervals around these estimates: The standard errors
are automatically wider when the estimated
coefficients are affected by collinearity and the confidence intervals
retain their nominal coverage rates (i.e., 95% of the 95% confidence intervals
will contain the true parameter value). So the statistical consequence
of collinearity is automatically taken care of in the model's output and
requires no additional computations on the part of the analyst.
This is illustrated in Figure 5 above: The confidence intervals
for the two predictors' estimated coefficients are considerably wider
when these are affected by strong collinearity.

The greater variability in the estimates, the larger standard errors,
and the wider confidence intervals all reflect a relative lack of information
in the sample:

> Collinearity is at base a problem about information.
> If two factors are highly correlated, researchers do not
> have ready access to much information about conditions
> of the dependent variables when only one of the factors
> actually varies and the other does not. If we are faced
> with this problem, there are really only three fundamental
> solutions:
> (1) find or create (e.g. via an experimental design)
> circumstances where there is reduced collinearity;
> (2) get more data (i.e. increase the N size), so that
> there is a greater quantity of information about rare
> instances where there is some divergence between the collinear
> variables; or
> (3) add a variable or variables to the model, with some
> degree of independence from the other independent variables,
> that explain(s) more of the variance of Y, so that there is 
> more information about that which is being modeled.
> ([York 2012:1384](https://www.ncbi.nlm.nih.gov/pubmed/23017962))


## But is collinearity a _problem_?

For the most part, I think that collinearity is a problem for 
statistical analyses in the same way that Belgium's lack of mountains 
is detrimental to the country's chances of hosting the Winter Olympics: 
It's an unfortunate fact of life, but not something that has to be solved. 
Running another study, obtaining more data or reducing
the error variance are all sensible suggestions, but if you have to
work with the data you have, the model output will appropriately reflect 
the degree of uncertainty in the estimates.

So I don't consider collinearity a problem.
What _is_ the case, however, is that collinearity highlights problems
with the way many people think about statistical models and inferential 
statistics. Let's look at a couple of these.

### 'Collinearity decreases statistical power.'
You may have heared that collinearity decreases statistical
power, i.e., the chances of obtaining statistically significant coefficient
estimates if their parameter value isn't zero. 
This is true, but the lower statistical power is a direct result
of the larger standard errors, which appropriately reflect the greater sampling
variability of the estimates. This is only a _problem_ if you interpret
"lack of statistical significance" as "zero effect". But then the problem
doesn't lie with collinearity but with the 
[false belief](https://www2.psych.ubc.ca/~schaller/528Readings/Schmidt1996.pdf#page=12)
that non-significant estimates correspond to zero effects. It's just that this false belief
is even more likely than usual to lead you astray when your predictors are collinear.
If instead of focusing soly on the p-value, you take into account both
the estimate _and_ its uncertainty interval, there is no problem.

Incidentally, I think it's somewhat misleading to say that collinearity _decreases_
statistical power or _increases_ standard errors. It's true that relative
to situations in which there is less or no collinearity and all other things 
are equal, the standard errors are larger and statistical power is lower
when there is stronger collinearity. But I don't see how you can _reduce_
collinearity but keep all other things equal outside of a computer simulation.
In the real world, collinearity isn't an unfolding process that can be nipped
in the bud without bringing about other changes in the research design,
the sampling procedure or the statistical model and its interpretation.

### 'None of the predictors is significant but the overall model fit is.'
With collinear predictors, you may end up with a statistical model 
for which the $F$-test of overall model fit is highly significant 
but that doesn't contain a single significant predictor. This is illustrated
in **Table 1**: The overall model fit for the dataset with strong collinearity
(see Figure 1) is highly significant, but as shown in Figure 5, neither predictor
has an estimated coefficient that's significantly different from zero.

> **Table 1.** R²- and p-values for the overall model fit for the multiple 
> regression models on the four datasets. Even though neither predictor has a 
> significant estimated coefficient in the `strong` dataset (shown in Figure 1), 
> the overall fit is highly significant.

<table class="table" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> Dataset </th>
   <th style="text-align:right;"> R² </th>
   <th style="text-align:right;"> p-value of overall fit </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> strong </td>
   <td style="text-align:right;"> 0.255 </td>
   <td style="text-align:right;"> 0.001 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> weak </td>
   <td style="text-align:right;"> 0.220 </td>
   <td style="text-align:right;"> 0.003 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> none </td>
   <td style="text-align:right;"> 0.201 </td>
   <td style="text-align:right;"> 0.005 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> nonlinear </td>
   <td style="text-align:right;"> 0.293 </td>
   <td style="text-align:right;"> 0.000 </td>
  </tr>
</tbody>
</table>

If this seems paradoxical, you need to keep in mind that the tests for the
individual coefficient estimates and the test for the overall model fit
seek to answer different questions, so there's no contradiction if they yield
different answers. To elaborate, the test for the overall model fit asks if
all predictors jointly earn their keep in the model; the tests for the
individual coefficients ask whether these are different from zero. 
With collinear predictors, it's possible that the answer to the first question 
is "yes" and the answer to the second is "don't know". The reason for this is
that with collinear predictors, either predictor could act as the stand-in
of the other so that, as far as the model is concerned, either coefficient could
well be zero, provided the other isn't. But due to the lack of information
in the collinear sample, it's not sure which, if any, is zero.

So again, there is no real problem: The tests answer different questions, so
they may yield different answers. It's just that when you have collinear
predictors, this tends to happen more often than when you don't.

### 'Collinearity means that you can't take model coefficients at face value.'
It's sometimes said that collinearity makes it more difficult to interpret 
estimated model coefficients. Crucially, the appropriate interpretation of an 
estimated regression coefficient is always the same, regardless of the degree of
collinearity: According to the model, what would the difference in the mean 
outcome be if you took two large groups of observations that differed by one 
unit in the focal predictor _but whose other predictor values are the same_. The
interpretational difficulties that become obvious when there is collinearity 
aren't caused by the collinearity itself but with mental shortcuts that people 
take when interpreting regression models.

For instance, you may obtain a coefficient estimate in a multiple regression 
model that you interpret to mean that older children perform more poorly on an 
L2 writing task than do younger children. (For the non-linguists: L2 = second or
foreign language.) This may be counterintuitive, and you may indeed find that, 
in fact, in your sample older children actually outperform younger ones. You 
could chalk this one up to collinearity, but the problem really is related to a 
faulty mental shortcut you took when interpreting your model: You forgot to take
into account the "_but whose other predictor values are the same_" clause. If 
your model also included measures of the children's previous exposure to the L2,
their motivation to learn the L2, and their L2 vocabulary knowledge, then what 
the estimated coefficient means is emphatically _not_ that, according to the 
model, older children perform on average more poorly on a writing task than 
younger children. It's that, according to the model, older children will perform
more poorly than younger children _with the same values on the previous 
exposure, motivation, and vocabulary knowledge measures_. This is pretty much 
the whole point of fitting multiple regression models. But if, on reflection, 
this isn't what you're actually interested in, then you should fit a different 
model. For instance, if you're interested in the overall difference between 
younger and older children regardless of their previous exposure, motivation and
vocabulary knowledge, don't include these variables as predictors.

Another interpretational difficulty emerges if you recast the
interpretation of the estimate as follows: According to the model, what would 
the difference in the mean outcome be if you _increased_ the focal predictor by 
one unit but keep the other predictor values constant. The difference between 
this interpretation and the one that I offered earlier is that we've moved from 
a purely descriptive one both a causal and an interventionist one (viz., the 
idea that one could _change_ some predictor values while keeping the others 
constant and that this would have an effect on the mean outcome). In the face of
strong collinearity, it becomes clear that this interventionist interpretation 
may be wishful thinking: It may be impossible to change values in one predictor 
without also changing values in the predictors that are collinear with it. But 
the problem here again isn't the collinearity but the mental shortcut in the 
interpretation.

In fact, you can run into the same difficulties when you apply the 
interventionist mental shortcut in the absence of collinearity: In the dataset 
shown in Figure 4, it's impossible to change the second predictor without also 
changing the first since the first was defined as a function of the second. Yet 
the two variables aren't collinear. Another example would be if you wanted to 
model quality ratings of texts in terms of the number of words in the text 
("tokens"), the number of unique words in the text ("types"), and the type/token
ratio. The model will output estimated coefficients for the three predictors, 
but as an analyst you should realise that it's impossible to find two texts 
differing in the number of tokens but having both the same number of types and 
the same type/token ratio: If you change the number of tokens and keep constant 
the number of types, the type/token ratio changes, too.

A final mental shortcut that is laid bare in the presence of collinearity is 
conflating a measured variable with the theoretical construct that this variable
is assumed to capture. The literature on lexical diversity offers a case in 
point. The type/token ratio (TTR) discussed in the previous paragraph is one of 
several possible measures of a text's lexical diversity. If you take a 
collection of texts, you're pretty much guaranteed to find that their type/token
ratios are negatively correlated with their lengths.
That is, longer texts tend to have lower TTR values. This correlation is 
known as the "text-length problem" and has led researchers to 
abandon the use of TTR, even though the relationship isn't _that_ strong
(see **Figure 7** for an example).

![center](/figs/2019-09-11-collinearity/unnamed-chunk-14-1.png)

> **Figure 7.** The type/token ratio tends to be negatively correlated
> with text length (here: log-10 number of tokens). This is known
> as the "text length" problem in research on lexical diversity.
> But the problem isn't that the type/token ratio is collinear with
> text length; it's that the type/token ratio also measures something
> it isn't supposed to measure and consequently is a poor measure
> of what it _is_ supposed to measure, viz., lexical diversity.
> The diversity rating shown are based on human judgements of 
> the texts' lexical diversity.
> (Data from the French corpus published by [Vanhove et al. 2019](https://doi.org/10.17239/jowr-2019.10.03.04).)

However, the reason why researchers have abandoned the use of TTR is _not_
collinearity per se. Rather, it is that TTR is a poor measure of what it's
supposed to capture, viz., the lexical diversity displayed in a text.
Specifically, because of the [statistical properties of
language](https://en.wikipedia.org/wiki/George_Kingsley_Zipf), the TTR is pretty
much bound to conflate a text's lexical diversity with its length. The negative
correlation between TTR and text length isn't much of a problem for statistical
modelling; it's a symptom of a more fundamental problem: A measure of lexical
diversity shouldn't as a matter of fact be related to text length. The fact that
TTR does shows that it's a poor measure of lexical diversity.

To be clear: It's not necessarily a problem that measures of lexical diversity 
correlate with text length since it's possible that the lexical diversity of
longer texts is greater than that of shorter texts or vice versa. The problem 
with TTR is that it _necessarily_ correlates with text length, even if the the
texts' lexical diversity can be assumed to be constant. For instance, if you
take increasingly longer snippets of texts from the same book, you'll find that
the TTR goes down, but that doesn't mean that the writer's vocabulary skills
went down in the process of writing the book. More generally, if your predictors
correlate strongly when they're not supposed to, the problem you have needn't be
collinearity but may instead be that in trying to capture one construct, you've
also captured the one represented by the other predictor.

**In sum, the interpretational challenges encountered when predictors are collinear aren't caused by the collinearity itself but by mental shortcuts that may lead researchers astray even in the absence of collinearity.**

## Collinearity doesn't require a statistical solution

> Statistical "solutions," such as residualization that are often used
> to address collinearity problems do not, in fact, address
> the fundamental issue, a limited quantity of information,
> but rather **serve to obfuscate it**. It is perhaps obvious
> to point out, but nonetheless important in light of the
> widespread confusion on the matter, that no statistical
> procedure can actually produce more information than
> exists in the data. 
> ([York 2012:1384](https://www.ncbi.nlm.nih.gov/pubmed/23017962), my emphasis)

Quite right. Apart from the non-solution that York (2012) mentioned (residualisation),
other common statistical "solutions" to collinearity include dropping predictors,
averaging collinear predictors, and resorting to different estimation methods
such as ridge regression. Since this blog post is long enough as it is, I'll
comment on these only briefly. Further suggested articles are 
[O'Brien (2007)](https://doi.org/10.1007/s11135-006-9018-6) 
and 
[Wurm and Fisicaro (2014)](https://doi.org/10.1016/j.jml.2013.12.003).

* Dropping predictors: I don't mind this "solution", but the problem it solves isn't collinearity but rather that the previous model was misspecified. This is obviously only a solution to the extent that the new model is capable of answering the researchers' question since, crucially, estimated coefficients from different models don't have the same meaning (see the previous section). Something to be particularly aware of is that by dropping one of the collinear predictors, you bias the estimates of the other predictors as shown in **Figure 8**.

![center](/figs/2019-09-11-collinearity/unnamed-chunk-15-1.png)

> **Figure 8.** Dropping a collinear predictor biases the estimate for the predictor retained as well as its meaning.

* Averaging predictors: Again, I don't mind this solution per se, but please be aware that your model now answers a different question.

* Ridge regression and other forms of deliberately biased estimation: Ridge regression and its cousins try to reduce the sample-to-sample variability in the regression estimates by deliberately biasing them. The result is, quite naturally, that you end up with biased estimates: The estimates for the weaker predictor will tend to be biased upwards (see **Figure 9**), and those for the stronger predictor will be biased downwards. Moreover, the usefulness of standard errors and confidence
intervals for ridge regression and the like is contested, see 
[Goeman et al. (2018, p. 18)](https://cran.r-project.org/web/packages/penalized/vignettes/penalized.pdf).


![center](/figs/2019-09-11-collinearity/unnamed-chunk-16-1.png)

> **Figure 9.** Ridge regression is a form of biased estimation, so naturally the estimates it yields are biased.

## tl;dr

1. Collinearity is a form of lack of information that is appropriately reflected in the output of your statistical model.
2. When collinearity is associated with interpretational difficulties, these difficulties aren't caused by the collinearity itself. Rather, they reveal that the model was poorly specified (in that it answers a question different to the one of interest), that the analyst overly focuses on significance rather than estimates and the uncertainty about them or that the analyst took a mental shortcut in interpreting the model that could've also led them astray in the absence of collinearity.
3. If you do decide to "deal with" collinearity, make sure you can still answer the question of interest.

## References
Goeman, Jelle, Rosa Meijer and Nimisha Chaturvedi. 2018. 
[L1 and L2 penalized regression models.](https://cran.r-project.org/web/packages/penalized/vignettes/penalized.pdf)

O'Brien, Robert M. 2007. 
[A caution regarding rules of thumb of variance inflation factors.](https://doi.org/10.1007/s11135-006-9018-6) 
_Quality & Quantity_ 41. 673-690.

Vanhove, Jan, Audrey Bonvin, Amelia Lambelet and Raphael Berthele. 2019.
[Predicting perceptions of the lexical richness of short French, German, and Portuguese texts using text-based indices.](https://doi.org/10.17239/jowr-2019.10.03.04)
_Journal of Writing Research_ 10(3). 499-525.

Wurm, Lee H. and Sebastiano A. Fisicaro. 2014. 
[What residualizing predictors in regression analyses does (and what it does not do).](https://doi.org/10.1016/j.jml.2013.12.003) 
_Journal of Memory and Language_ 72. 37-48.

York, Richard. 2012. 
[Residualization is not the answer: Rethinking how to address multicollinearity.](https://www.ncbi.nlm.nih.gov/pubmed/23017962)
_Social Science Research_ 41. 1379-1386.

## R code


{% highlight r %}
# Packages
library(tidyverse)
library(broom)

# Read in the four generated datasets
strong <- read.csv("https://janhove.github.io/datasets/strong_collinearity.csv")
weak <- read.csv("https://janhove.github.io/datasets/weak_collinearity.csv")
none <- read.csv("https://janhove.github.io/datasets/no_collinearity.csv")
nonlinear <- read.csv("https://janhove.github.io/datasets/nonlinearity.csv")

# Load the custom function for drawing scatterplot matrices, 
# then drew Figures 1-4
source("https://janhove.github.io/RCode/myScatterMatrix.R")
myScatterMatrix(strong[, c(3, 1, 2)])
myScatterMatrix(weak[, c(3, 1, 2)])
myScatterMatrix(none[, c(3, 1, 2)])
myScatterMatrix(nonlinear[, c(3, 1, 2)])

# Fit multiple regression models
strong.lm <- lm(outcome ~ predictor1 + predictor2, data = strong)
weak.lm <- lm(outcome ~ predictor1 + predictor2, data = weak)
none.lm <- lm(outcome ~ predictor1 + predictor2, data = none)
nonlinear.lm <- lm(outcome ~ predictor1 + predictor2, data = nonlinear)

# Extract estimates + 90% CIs
strong_out <- tidy(strong.lm, conf.int = TRUE, conf.level = 0.90) %>% 
  mutate(dataset = "strong")
weak_out <- tidy(weak.lm, conf.int = TRUE, conf.level = 0.90) %>% 
  mutate(dataset = "weak")
none_out <- tidy(none.lm, conf.int = TRUE, conf.level = 0.90) %>% 
  mutate(dataset = "none")
nonlinear_out <- tidy(nonlinear.lm, conf.int = TRUE, conf.level = 0.90) %>% 
  mutate(dataset = "nonlinear")
outputs <- bind_rows(strong_out, weak_out, none_out, nonlinear_out)

# Draw Figure 5
dummy <- data.frame(term = unique(outputs$term), prm = c(0, 0.4, 1.9))
outputs %>% 
  ggplot(aes(x = factor(dataset, levels = c("nonlinear", "none", 
                                            "weak", "strong")),
             y = estimate,
             ymin = conf.low,
             ymax = conf.high)) +
  geom_pointrange() +
  facet_wrap(~ term) +
  geom_hline(data = dummy, aes(yintercept = prm),
             linetype = "dashed") +
  ylab("estimated coefficient with 90% confidence interval") +
  xlab("dataset") +
  coord_flip()

# Function for simulating effect of collinearity on estimates
collinearity <- function(n_sim = 1000, n_sample = 50,
                         rho = 0.90,
                         coefs = c(0.4, 1.9),
                         sd_error = 3.5) {
  # This function generates two correlated
  # predictors and an outcome. It then
  # runs regression models (including ridge regression) 
  # on these variables and outputs the estimated
  # regression coefficients for the predictors.
  # It does this a large number of times (n_sim).
  
  # Package for LASSO/ridge regression
  require("glmnet")

  estimates <- matrix(ncol = 8, nrow = n_sim)

  for (i in 1:n_sim) {
    # Generate correlated predictors
    predictors <- MASS::mvrnorm(
      n = n_sample,
      mu = c(0, 0),
      Sigma = rbind(
        c(1, rho),
        c(rho, 1)
      )
    )

    # Generate outcome
    outcome <- as.vector(coefs %*% t(predictors) + rnorm(n_sample, sd = sd_error))

    # Run multiple regression model
    multiple_regression <- lm(outcome ~ predictors[, 1] + predictors[, 2])
    
    # Run single regression models
    simple_first <- lm(outcome ~ predictors[, 1])
    simple_second <- lm(outcome ~ predictors[, 2])
    
    # Ridge regression
    lambda_seq <- 10^seq(2, -2, by = -0.1)
    cv_output <- cv.glmnet(predictors, outcome, nfolds = 10,
                           alpha = 0, lambda = lambda_seq)
    best_lambda <- cv_output$lambda.min
    ridge_model <- glmnet(predictors, outcome, alpha = 0,
                          lambda = best_lambda)

    # Save regression coefficients
    estimated_coefficients <- c(
      coef(multiple_regression)[2:3],
      summary(multiple_regression)$coefficients[2:3, 2],
      coef(simple_first)[2],
      coef(simple_second)[2],
      coef(ridge_model)[2:3]
      )
                                
    estimates[i, ] <- estimated_coefficients
  }

  results <- data.frame(
    multiple_est_pred1 = estimates[, 1],
    multiple_est_pred2 = estimates[, 2],
    multiple_se_pred1 = estimates[, 3],
    multiple_se_pred2 = estimates[, 4],
    simple_est_pred1 = estimates[, 5],
    simple_est_pred2 = estimates[, 6],
    ridge_est_pred1 = estimates[, 7],
    ridge_est_pred2 = estimates[, 8]
  )
  results
}

# Simulate effects of strong collinearity
strong_coll <- collinearity(rho = 0.98)

# Simulate effect of perfect orthogonality (zero collinearity)
no_coll <- collinearity(rho = 0)

# Combine
strong_coll$Collinearity <- "strong collinearity\n(r = 0.98)"
no_coll$Collinearity <- "no collinearity\n(r = 0.00)"
all_data <- bind_rows(strong_coll, no_coll)

# Figure 6
ggplot(all_data,
       aes(x = multiple_est_pred1,
           y = ..density..)) +
  geom_histogram(bins = 50, colour = "black", fill = "grey80") +
  facet_wrap(~ Collinearity) +
  geom_vline(xintercept = 0.4, linetype = "dashed", colour = "red") +
  xlab("estimated regression coefficient for first predictor\nin multiple regression models")

# Table 1
map_dfr(list(strong.lm, weak.lm, none.lm, nonlinear.lm), glance) %>% 
  mutate(Dataset = c("strong", "weak", "none", "nonlinear")) %>% 
  select(Dataset, `R²` = r.squared, `p-value of overall fit` = p.value) %>% 
  knitr::kable(., "html") %>% 
  kableExtra::kable_styling(., full_width = FALSE)

# Figure 7
lexdiv <- read_csv("https://janhove.github.io/datasets/LexicalDiversityFrench.csv")
ratings <- read_csv("https://janhove.github.io/datasets/meanRatingPerText_French.csv")
ratings$Text <- substr(ratings$Text, 15, nchar(ratings$Text))
d <- left_join(ratings, lexdiv, by = c("Text" = "textName"))
myScatterMatrix(d %>% select(meanRating, TTR, nTokens) %>% 
                  mutate(sqrt_nTokens = log10(nTokens)) %>% 
                  select(-nTokens),
                labels = c("mean diversity rating",
                           "type/token ratio",
                           "log10 tokens"))

# Figure 8
ggplot(all_data,
       aes(x = simple_est_pred1,
           y = ..density..)) +
  geom_histogram(bins = 50, colour = "black", fill = "grey80") +
  facet_wrap(~ Collinearity) +
  geom_vline(xintercept = 0.4, linetype = "dashed", col = "red") +
  xlab("estimated regression coefficient for first predictor\nin simple regression models")

# Figure 9
ggplot(all_data,
       aes(x = ridge_est_pred1,
           y = ..density..)) +
  geom_histogram(bins = 50, colour = "black", fill = "grey80") +
  facet_wrap(~ Collinearity) +
  geom_vline(xintercept = 0.4, linetype = "dashed", col = "red") +
  xlab("estimated regression coefficient for first predictor\nin ridge regression models")
{% endhighlight %}
