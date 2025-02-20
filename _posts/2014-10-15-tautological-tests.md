---
layout: post
title: "Silly significance tests: Tautological tests"
thumbnail: /figs/thumbnails/2014-10-15-tautological-tests.png
category: [Reporting]
tags: [silly tests, simplicity]
---

We can do with fewer significance tests.
In my previous blog post, I argued that using significance tests to check whether
random assignment 'worked' doesn't make much sense.
In this post, I argue against a different kind of silly significance test
of which I don't see the added value:
dividing participants into a 'high X' and a 'low X' group and then testing whether the groups differ with respect to 'X'.


<!--more-->

### What do I mean by 'tautological tests'?
Every so often, I stumble upon a study where it says something along the following lines:

> The 70 participants were divided into three proficiency groups according to their performance on a 20-point French-language test.
> The high-proficiency group consisted of participants with a score of 16 or higher (_n_ = 20); the mid-proficiency group of participants with a score between 10 and 15 (_n_ = 37); and the low-proficiency group of participants with a score of 9 or lower (_n_ = 13).
> An ANOVA showed significant differences in the test scores between the high-, mid- and low-proficiency groups (_F_(2, 67) = 133.5, _p_ < 0.001).

This is a fictitious example, but the general procedure is somewhat common in research papers in applied linguistics: 
the researcher creates groups of participants so that the groups show no overlap on a certain variable (e.g. task performance, age), 
and then proceeds to rubber-stamp this grouping by showing that there exist significant between-group differences on that very same variable.
It's not necessarily the grouping of participants that is rubber-stamped;
every once in a while, the researchers' choice of stimuli (e.g. high- vs. low-frequency words) is justified in a similar fashion.
For want of a better term, I'll call this practice **tautological** significance testing.

### The problem
As their name suggests, tautological tests are silly because they can't tell us anything that's both correct and new.
Since we ourselves created participant or stimulus groups that don't show any overlap on a particular variable, 
we obviously _know_ that the groups must differ with respect to this variable.
If the significance test returns a non-significant _p_-value,
then this tells us more about the sample size than about group differences with respect to the variable in question.

This non-informativeness is what tautological tests have in common with the silly significant tests that I discussed previously, [balance tests]({% post_url 2014-09-26-balance-tests %}).
In the case of balance tests, we tested for the _absence_ of a difference (which we know doesn't really exist); 
when using tautological tests, we tested for the _presence_ of a difference which we know does exist.
I don't think that tautological tests negatively affect the study's results,
but they clutter research reports with useless -- but often dauntingly looking -- prose.

### The larger issue: Overuse of ANOVA
More problematic than tautological significance tests is what preceeds them:
discretising a fine-grained variable.
The point is [not new](http://www.unc.edu/~rcm/psy282/cohen.1983.pdf) but bears repeating: By carving up a fine-grained variable into groups, you throw away valuable information. 
As a result, you have less statistical power than you could've had if you'd used the original variable in your analyses.
Additionally, the choice of the cut-off points is often arbitrary, and the outcome may well differ had different cut-off points been chosen.

Researchers often seem to think that they need to form groups in order to sensibly analyse their data.
The underlying idea could be that group comparisons (i.e. ANOVAs) are somehow more respectable or objective than analyses involving continuous variables (e.g. linear regression).
Or perhaps researchers think that ANOVAs are necessary to deal with more complicated data, such as data with crossed dependency structures (e.g. featuring both stimulus- and participant-related variables) or data exhibiting non-linearities.
Researchers who'd like to disabuse themselves of these notions can take a look at 
a position paper by [Harald Baayen](http://languagelog.ldc.upenn.edu/myl/ldc/Pitzer/BaayenStatistics.pdf)
as well as at some articles in the [2008 special issue of the Journal of Memory and Language](http://www.sciencedirect.com/science/journal/0749596X/59/4) (e.g. the Baayen et al. and Jaeger papers).
If your data exhibits non-linearities that you hope to 'cure' by discretising a continuous variables, I suggest you first take a look at Michael Clark's introduction to [generalised additive models](http://www3.nd.edu/~mclark19/learn/GAMS.pdf), which can cope with non-linearities, or perhaps look into the possibility of transforming your variables so that the relationship between them becomes approximately linear. 

### Solution
The solution to tautological tests is again straightforward.
First, we ought to ask whether it's really necessary to categorise a finer-grained variable. 
Often, an regression-based analysis that stays true to the original variable is feasible.
Second, if for whatever reason it's not possible to carry out a regression, just don't carry out such tautological tests.

### A related kind of test use
A related kind of significance test (ab)use is when researchers try to ensure the comparability of stimuli or participants between conditions. For instance, when investigating the effect of word frequency on vocabulary retention, researchers often want to make sure that high- and low-frequency words are similar in respects other than frequency (e.g. word length).
While I wouldn't call this use of significance tests silly,
it's not exactly ideal either.
[Imai et al.](http://gking.harvard.edu/files/matchse.pdf) discuss the use of significance tests to evaluate the success of a matching procedure (Section 7.2) and argue against it.
In Section 7.3, they discuss some alternatives, but the main take-home message is quite simple: significance tests aren't suited for this purpose.
