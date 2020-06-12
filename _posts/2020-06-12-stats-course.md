---
title: "Interpreting regression models: a reading list"
layout: post
mathjax: true
tags: [measurement error, logistic regression, organisation, correlational studies, mixed-effects models, multiple regression, predictive modelling, research questions, contrast coding, reliability]
category: [Teaching]
---

Last semester I taught a class for Phd students and collaborators that 
focused on how the output of regression models is to be interpreted.
Most participants had at least some experience with fitting regression models,
but I had noticed that they were often unsure about the precise _statistical_
interpretation of the output of these models (e.g., _What does this
parameter estimate of 1.2 correspond to in the data?_). 
Moreover, they were usually a bit too eager to move from the model output to 
a _subject-matter_ interpretation
(e.g., _What does this parameter estimate of 1.2 tell me about language learning?_).
I suspect that the same goes for many applied linguists, and social scientists 
more generally, so below I provide an overview of the course contents as well
as the reading list.

<!--more-->



## Course content

### Week 1: Uses of statistical models: Description vs. prediction vs. inference

Statistical models have three main uses. 
The first is to describe the data at hand, and once you've figured out what aspects of
the data the parameter estimates reflect, a descriptive interpretation of a
statistical model isn't too difficult to get right. Weeks 6, 7, 8 and 11 are devoted
to statistical interpretation of model parameters and how variables can be recoded
so that the model output aligns more closely with the research questions.

However, their main use
in the social sciences is to draw inferences, usually causal ones. 
Moving from a descriptive to causal interpretation of a statistical model
requires making additional assumptions. Weeks 2 through 5 are devoted to a tool
(directed acyclic graphs)
that allows you to make explicit the assumptions you're willing to make about
the causal relationships between your variables and that allows you to derive
from these assumptions which causal claims are permissible.
Another type of inference is the move from observable quantities (e.g., test scores)
to unobervables (e.g., language skills). Weeks 10 and 11 are devoted to this
topic.

The third use is to use the model to make predictions about new data.
This week's text (Shmueli 2010) explains why a model that has been optimised
for making predictions about new data may be all but worthless for inference,
and why a model that has been optimised for inference may not yield the best
possible predictions. The take-home points are that when planning a research
project, you need to be crystal-clear what its main goal is (e.g., causal
inference or prediction) and that you should be careful not to assume that
a model selected for its predictive power is best-suited for drawing causal
conclusions.

* Text: Shmueli (2010).
* Further reading: Breiman (2001); Yarkoni and Westfall (2017).

### Week 2: Causal inferences from observational data (I)

The texts for weeks 2 through 5 introduce directed acyclic
graphs (DAGs) and go through numerous examples for them. 
DAGs are useful for identifying the variables that you should
control for and the ones you should _not_ control for if you want to estimate
some causal relationship in your data. (Some researchers seem to assume
that the more variables you control for, the better, but controlling for the
wrong variables can mess up your inferences entirely.)
This, of course, is most useful when you're still planning your research project,
because otherwise you may find out that you need to control for a variable
that you didn't collect, or that you controlled (on purpose or by accident)
for a variable you shouldn't have controlled for.

* Text: McElreath (2020), Chapter 5.

### Week 3: Causal inferences from observational data (II)

* Text: McElreath (2020), Chapter 6.

### Week 4: Causal inferences from observational data (III)

* Text: Rohrer (2018).

### Week 5: Causal inferences from observational data (IV)

* No obligatory reading.
* Further reading: Elwert (2013).

### Week 6: Understanding parameter estimates (I)

Leaving causal interpretations aside, what do all those numbers in the
output of a regression model actually express? DeBruine and Barr (2019)
explain how you can analyse simulated datasets to learn which parameter
estimates in the simulation correspond to which parameter settings in the
simulation set-up. 

A related point that I highlighted in class was 
that the random effect estimates as well as the BLUPs in mixed-effects 
models should always be interpreted conditionally on the fixed effects
in the model. This is true of all estimates in regression models, but 
people tend to have more difficulties in interpreting random effects and 
BLUPS. 
Another point was that you can also gain a better understanding
of what the model parameters express by _first_ fitting the model
on your data and _then_ having this model predict new data.
As you're figuring out how the model came up with these predictions,
you learn what each parameter estimate literally means.

* Text: DeBruine and Barr (2019).

### Week 7: Understanding parameter estimates (II)

Weeks 7 and 8 were devoted to contrast coding, i.e., how you can
recode non-numeric predictors such that the model's output aligns
more closely with what you want to know. I've recently
[blogged](https://janhove.github.io/analysis/2020/05/05/contrast-coding) 
about contrast coding, and I was surprise I didn't learn about this useful
technique until 2020 (of all years).

* Text: Schad et al. (2020), up to and including the section _What makes a good set of contrasts?_

### Week 8: Understanding parameter estimates (III)

* No obligatory reading.
* Further reading: Schad et al. (2020), from the section _A closer look at hypothesis and contrast matrices_.

### Week 9: Consequences of measurement error (I)

The measured variables included in a model are often but approximations
of what is actually of interest. For instance, you may be interested in
the learners' L2 skills, but what you've measured is their performance
on an L2 test. The test results will only approximately reflect the learners'
true skills. Interpreting the output of a model, which may be valid at the
level of the observed variables, in terms of such unobserved but inferred
constructs is fraught with difficulties that researchers and consumers of
research need to be aware of.

The reading for week 9 deals with some consequences of measurement error
on a predictor variable. The reading of week 10 doesn't strictly deal
with measurement error but with the mapping of the observed outcome variable
on the unobserved construct of interest and how it affects the interpretation
of interactions.

* Text: Westfall and Yarkoni (2016).
* Further reading: Berthele and Vanhove (2020).

### Week 10: Consequences of measurement error (II)

* Text: Wagenmakers et al. (2012).
* Further reading: Wagenmakers (2015).

### Week 11: Understanding parameter estimates (IV)

Logistic regression models can be difficult to understand, and the linear
probability model (i.e., ordinary linear regression) isn't to be dismissed
out of hand when working with binary data. A related blog post is [_Interactions in logistic regression models](https://janhove.github.io/analysis/2019/08/07/interactions-logistic).

* Text: Huang (2019).

### Week 12: Translating verbal research questions into quantitative hypotheses

In week 12 I went through some examples of verbal research questions or hypotheses
that at first blush seem pretty well delineated. On closer inspection, however,
it becomes clear that radically different patterns in the data would yield the 
same answer to these questions, and that the research questions or hypotheses
were, in fact, underspecified.

No texts.

### Week 13: Ascension (no class)

### Week 14: Take-home points + working reproducibly

For the last week, I stressed the following take-home points from this course:

* Be crystal-clear about the main aim of your statistical model: Describing the data, predicting new data, or drawing inferences about causality or unobserved phenomena? Plan accordingly by identifying the factors that must be controlled for and those that mustn't be controlled for.
* Anticipate the consequences of measurement error. If measurement error could mess up the interpretation of the results, try to collect several indictators of the constructs of interest and adopt a latent variable approach.
* Outline _precisely_ how you'd interpret the possible patterns in the data in terms of your research question.
* If a regression model is necessary, recode your predictors so that you can interpret the parameter estimates directly in terms of your research question.
* Analyse simulated data if you're unsure what the model's parameter estimates correspond to.
* Keep in mind that parameter estimates are always to be interpreted conditionally on the other predictors in the model. I suspect that lots of counterintuitive findings stem from researchers interpreting their parameter estimates unconditionally.

I also showed how you can make your analyses reproducible by
working with [RStudio projects](https://r4ds.had.co.nz/workflow-projects.html), 
the [here package](https://cran.r-project.org/web/packages/here/index.html),
and R Markdown.

No texts.

## References

Berthele, Raphael and Jan Vanhove. 2020.
[What would disprove interdependence? Lessons learned from a study on biliteracy in Portuguese heritage language speakers in Switzerland](https://doi.org/10.1080/13670050.2017.1385590).
_International Journal of Bilingual Education and Bilingualism_ 23(5). 550-566.

Breiman, Leo. 2001. 
Statistical modeling: The two cultures.
_Statistical Science_ 16. 199-215.

DeBruine, Lisa M. & Dale J. Barr. 2019. 
[Understanding mixed effects models through data simulation](https://doi.org/10.31234/osf.io/xp5cy). 
PsyArXiv.

Elwert, Felix. 2013. 
Graphical causal models. 
In S. L. Morgan (ed.), 
_Handbook of Causal Analysis for Social Research_, pp. 245-273.
Dordrecht, The Netherlands: Springer.

Huang, Francis L. 2019.
[Alternatives to logistic regression models in experimental studies](https://doi.org/10.1080/00220973.2019.1699769).
_Journal of Experimental Education_.

McElreath, Richard. 2020. 
_Statistical rethinking: A Bayesian course with examples in R and Stan_, 2nd edn.
Boca Raton, FL: CRC Press.

Rohrer, Julia. 2018.
[Thinking clearly about correlations and causation: Graphical causal models for observational data](https://doi.org/10.1177%2F2515245917745629).
_Advances in Methods and Practices in Psychological Science_ 1(1). 27-42.

Schad, Daniel J., Shravan Vasishth, Sven Hohenstein and Reinhold Kliegl. 2020. 
[How to capitalize on a priori contrasts in linear (mixed) models: A tutorial](https://doi.org/10.1016/j.jml.2019.104038). 
_Journal of Memory and Language_ 110.

Shmueli, Galit. 2010. 
[To explain or to predict?](https://www.stat.berkeley.edu/~aldous/157/Papers/shmueli.pdf)
_Statistical Science_ 25. 289-310.

Wagenmakers, Eric-Jan. 2015.
[A quartet of interactions](https://doi.org/10.1016/j.cortex.2015.07.031).
_Cortex_ 73. 334-335.

Wagenmakers, Eric-Jan, Angelos-Miltiadis Krypotos, Amy H. Criss and Geoff Iverson. 2012. 
[On the interpretation of removable interactions: A survey of the field 33 years after Lotus](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3267935/). 
_Memory & Cognition_ 40. 145-160.

Westfall, Jacob and Tal Yarkoni. 2016.
[Statistically controlling for confounding constructs is harder than you think](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0152719).
_PLoS ONE_ 11(3). e0152719.

Yarkoni, Tal and Jacob Westfall. 2017.
[Choosing prediction over explanation in psychology: Lessons from machine learning](http://jakewestfall.org/publications/Yarkoni_Westfall_choosing_prediction.pdf).
_Perspectives on Psychological Science_ 12. 1100-1122.
