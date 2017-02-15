---
title: "Which predictor is most important? Predictive utility vs. construct importance"
layout: post
tags: [effect sizes, correlational studies, measurement error]
category: Analysis
---

Every so often, I'm asked for my two cents on a correlational study
in which the researcher wants to find out which of a set of predictor
variables is the most important one. For instance, they may have 
the results of an intelligence test, of a working memory task and 
of a questionnaire probing their participants' motivation for 
learning French, and they want to find out which of these three 
is the most important factor in acquiring a nativelike French accent, 
as measured using a pronunciation task. As I will explain below, 
research questions such as these can be interpreted in two ways, 
and whether they can be answered sensibly depends on the 
interpretation intended.

<!--more-->

### Interpretation 1: Predictive utility
First, you can interpret questions such as
_Which of variables A, B and C is the most important factor in X?_ 
as follows: If you wanted to guesstimate a person's result on _X_
(e.g., nativelikeness of accent) and you could only know their score
on _A_, _B_ or _C_ (e.g., intelligence test, working memory task, 
motivational questionnaire), which one should you pick? Such questions
can make sense when you have a battery of tasks and questionnaires
that you need to slim down for a future study or evaluation.

Interpreted like this, such questions can be sensibly answered,
for instance by comparing the correlation coefficients for
_AX_, _BX_ and _CX_ or by comparing the fit of regression models
for each of the three predictor variables.

### Interpretation 2: Construct importance
Often, however, it turns out that researchers aren't interested
in the predictive utility of variables _A_, _B_ and _C_ _per se_,
but rather in the importance of the **construct** that these
variables represent. Concretely, they aren't so much interested
in the participants' _performance_ on an intelligence test
as they are interested in the participants' intelligence proper.
The tests, tasks and questionnaires are merely means for eliciting
this information, and imperfect means at that.

For the accent example, then, the intended research question under this
interpretation is this: What's more important for acquiring
a nativelike accent in French: your intelligence, your working memory
capacity or your motivation?

The difference between this interpretation and the 'predictive utility'
interpretation may seem small, but whereas I think that such
research questions are answerable under the 'predictive utility' 
interpretation, I think they are usually unanswerable when they 
concern the scientific constructs themselves. The reason for this, 
[as]({% post_url 2015-08-24-caveats-confounds-correlational-designs %}) 
[so]({% post_url 2015-03-16-standardised-es-revisited %}) 
[often]({% post_url 2015-02-05-standardised-vs-unstandardised-es %}),
is **measurement error**. 

Due to measurement error, the participants' scores on the intelligence 
test, working memory task and motivational questionnaire are but 
approximations of their true intelligence, working memory capacity 
and motivation. What is more, the extent to which these scores
are affected by measurement error will vary from task to task.
This is important because measurement error, on average,
attenuates between two variables. As a result, we may find that
intelligence scores predict nativelikeness of accent better than
working memory scores or motivational questionnaire scores,
but this doesn't have to mean that intelligence itself is more
important than working memory capacity or motivation:
it may well be the case that motivation is by far the most
important factor in accent acquisition, but that this factor
is less well captured by the questionnaire than intelligence is by
the intelligence test.

When it's construct importance you're interested in, the time
to worry about measurement error is before running the study.
For instance, at the cost of considerably more time and effort
on the part of the participants, you may want to use multiple
tests and tasks for each of the constructs you're interested in
and conduct a latent variable analysis. Or you can try to find
tasks whose reliability in measuring the construct is known
so you can correct for measurement error (see Chapter 7 in Faraway's
[_Linear models with R](http://www.maths.bath.ac.uk/~jjf23/LMR/)).
I don't have much experience with either strategy, though.

### Conclusion
When you want to find out which variable is the most important one,
think about whether it's predictive utility or construct importance
you're interested in. If it's (also) the latter, consider the 
attenuating effect of measurement error when designing your study.
