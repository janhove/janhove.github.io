---
layout: post
title: "Silly significance tests: Balance tests"
thumbnail: /figs/thumbnails/2014-09-26-balance-tests.png
category: [Reporting]
tags: [silly tests, simplicity, R]
---

It's something of a pet peeve of mine that your average research paper contains way too many statistical tests.
I'm all in favour of reporting research and analyses meticulously, but it'd make our papers easier to read -- and ultimately more impactful -- if we were to cut down on silly, superfluous significance tests.
Under scrutiny today: _balance tests_.

<!--more-->

The term 'silly significance test' in the title comes from Abelson's [_Statistics as principled argument_](http://books.google.ch/books?id=TgmbosIA7N0C)
and refers to tests that don't contribute anything to a research report other than making it harder to read.
I'd distinguish at least four kinds of 'silly tests' that we can largely do without -- in this post, I focus on _balance tests_ in randomised experiments.

### What are balance tests?

_Balance tests_, also called _randomisation checks_, are a ubiquitous type of significance test.
As an example of a balance test, consider a researcher who wants to compare a new vocabulary learning method to an established one. She randomly assigns forty participants to either the control group (established method) or the experimental group (new method). After four weeks, she tests the participants' vocabulary knowledge -- and let's pretend she finds a significant difference in favour of the experimental group (e.g. t(38) = 2.7, p = 0.01).

To pre-empt criticisms that the difference between the two groups could be due to factors other than the learning method,
the conscientious research also runs a t-test to verify that the control and experimental group don't differ significantly in terms of age
as well as a Χ²-test to check whether the proportion of men and women in approximately the same in both groups.
The goal of these tests is to enable the researcher to argue that the randomisation gave rise to groups that are balanced with respect to these variables and that the observed difference between the two groups therefore can't be due to these possible confounds.
If a balance test comes out significant, the researcher could be tempted to run another analysis with the possible confound as a covariate.

### Why are they superfluous?

Reasonable though this strategy may appear to be, balance tests are problematic in several respects.
The following list is based on a paper by [Mutz and Pemantle (2013)](http://www.math.upenn.edu/~pemantle/papers/Preprints/perils.pdf).
This discussion gives you the short version;
for a somewhat more detailed treatment of balanced tests geared towards applied linguists, see the first section of my (as yet unpublished) paper on [analysing randomised controlled interventions](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Unpublished/AnalyzingRandomizedInterventions.pdf).

#### Balance tests are uninformative...
Statistical tests are used to draw inferences about a _population_ rather than about a specific _sample_.
Sure, it's possible to end up with 3 men in the experimental group and 14 in the control group; a Χ²-test would then produce a significance result.
But would we seriously go on to argue that men are more likely to end up in the control group than in the experimental group? 
Of course not!
We _know_ men were equally likely to end up in the control or experimental group because we randomly assigned all participants to the conditions -- we _know_ the null hypothesis (no difference between the groups) is true with respect to this variable.
Consequently, every significant balance test is a false alarm that has come about due to sheer randomness.
A balance test can't tell us anything we don't know already.

#### ... as well as unnecessary...
Researchers that concede the first point may go on to argue 
that their use of balance tests isn't intended to make inferences about populations,
but to give an idea about the magnitude of the unbalancedness between the groups.
However, perfectly balanced groups are not a prerequisite for making valid statistical inferences.
Thus, balance tests are also unnecessary.

To elaborate on this point, randomisation guarantees that all possible confounds -- both the ones we had _and those we hadn't_ thought of --
are balanced out on average, i.e. in the infamous long run.
A given randomisation may give rise to an experimental group that is older
or that has more women, or has a higher proportion of _MasterChef_ fans -- 
and, yes, unbalancedness with respect to such variables could conceivably give rise to a larger or smaller observed treatment effect in any given study.
But the distribution of such fluke findings follows the laws of probability.
The _p_-value for the main analysis already takes such flukes into account
and doesn't need to be 'corrected' for an unbalanced distribution of possible confound variables.

#### ... and they invalidate significance tests.

Since _p_-values have their precise meaning when no balance test is carried out, it follows that they don't have their precise meaning when a balanced test _is_ carried out.
_p_-values are conditional probability statements ('the probability of observing data at least this extreme if the null hypothesis were true'), but by using balance tests, we add a condition to this statement: 'the probability of observing data at least this extreme if the null hypothesis were true and if the balance test yields a particular result'.
This doesn't seem like much, but it is a form of **data-dependent analysis**, which invalidates significance tests. (For a more general discussion of data-dependent analyses, see [Gelman & Loken 2013](http://www.stat.columbia.edu/~gelman/research/unpublished/p_hacking.pdf).)

A demonstration of this point seems in order.
I ran a small simulation (R code below) of the following scenario.
We want to test an experimental effect and randomly assign 40 participants to an experimental or a control condition.
The participants vary in age between 20 and 40.
The age variable doesn't interest us so much, but it is linearly related to the outcome variable.
However, the treatment effect is 0, i.e. the null hypothesis is true.
Our analytical strategy is as follows:
We run a significance test on the age variable to see whether the experimental and control groups are 'balanced' in terms of age.
If this test comes back non-significant, we conclude that we have balanced groups and run a t-test on the outcome variable;
if the test comes back significant, we run an ANCOVA with age as a covariate.
I simulated this scenario 10,000 times and compared the distribution of the _p_-values for the treatment effect resulting from this 'conditional' analytical strategy with those provided by t-tests and ANCOVAs that were run regardless of the outcome of the balance test. The histograms below show the distributions of _p_-values for these three testing strategies.

![center](/figs/2014-09-26-balance-tests/unnamed-chunk-1.png) 

Since the null hypothesis is true in this case, the distribution of _p_-values should be uniform, i.e. all bars should be roughly equally as high. This is the case in the left and middle histograms, showing that _p_-values are correctly distributed when the analysis is not affected by balance tests.
Put simply, _p_-values have their intended meaning in these cases.
The right histogram shows that low _p_-values are too rare when the analysis is affected by balance tests: the test of the treatment effect is too conservative, i.e. its _p_-value doesn't have its intended meaning.

Recent blogs and articles have highlighted the fact that data-dependent analysis yields anti-conservative _p_-values, i.e. that it is too likely to observe a significant effect where none exists (e.g. [Gelman & Loken 2013](http://www.stat.columbia.edu/~gelman/research/unpublished/p_hacking.pdf) and [Simmons et al. 2011](http://papers.ssrn.com/sol3/papers.cfm?abstract_id=1850704)).
It may therefore seem strange to highlight that data-dependent analysis can produce overconservative results, too.
My main point, however, is that balance tests produce _inaccurate_ results that can easily be avoided -- regardless of the direction of the error.
That said, overconservatism has a practical downside as well, namely lower power: it's less likely to observe a statistically significant effect when the effect does in fact exist.
The following histograms show the _p_-value distribution when there is a relatively small effect (see also R code below).

![center](/figs/2014-09-26-balance-tests/unnamed-chunk-2.png) 

Clearly, the ANCOVA-only strategy wins hands-down in terms of power, whereas the balance test strategy doesn't even compare favourably to the _t_-test-only approach.

### Solutions
The solution to simple: **just don't use balance tests**.
They clutter up the research report and don't have any obvious advantages when analysing randomised experiments.
When there are good reasons to assume that a covariate affects the results, it's a good idea to include it in the main analysis _regardless_ of whether the experimental and control groups are balanced with respect to this variable.
In fact, [Mutz and Pemantle (2013)](http://www.math.upenn.edu/~pemantle/papers/Preprints/perils.pdf) show that including a covariate in the analysis is slightly _more_ effective when the groups are in fact balanced.
While this post is strictly on _randomised_ experiments, I would think that this is also the most sensible strategy when analysing non-randomised quasi-experiments.

Alternatively, it can make sense to consider the covariate in the design of the study, i.e. before randomising (see the part in my [analysis paper](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Unpublished/AnalyzingRandomizedInterventions.pdf) on 'blocking', pp. 6-7).

### R code


{% highlight r %}
simulate.balance <- function(effect = 0, covar.effect = 0) {
  age <- seq(from = 20, to = 40, length.out = 40)
  condition <- sample(c(rep(0, 20), rep(1, 20)), replace = FALSE)
  var <- covar.effect*age + effect*condition + rnorm(40, sd=2)
  
  # t-test regardless of balancedness
  test1 <- t.test(var ~ factor(condition), var.equal = TRUE)$p.value
  
  # balance test
  check <- t.test(age ~ factor(condition), var.equal = TRUE)$p.value
  # conditional analysis
  if (check <= 0.05) {
    test2 <- anova(lm(var ~ age + factor(condition)))$'Pr(>F)'[2]
  } else {
    test2 <- test1
  }
  
  # ancova regardless of balancedness
  test3 <- anova(lm(var ~ age + factor(condition)))$'Pr(>F)'[2]
  
  return(list(test1 = test1,
              test2 = test2,
              test3 = test3,
              check = check))
}
sims <- replicate(10000, simulate.balance2(effect = 0, covar.effect = 1))
{% endhighlight %}

Settings for histograms above: `effect = 0` and `effect = 1`.

