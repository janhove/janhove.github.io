---
layout: post
title: "Multiple comparisons and the link between theory and analysis"
category: [Analysis]
tags: [significance, power]
---

Daniël Lakens recently [blogged](http://daniellakens.blogspot.ch/2016/02/why-you-dont-need-to-adjust-you-alpha.html) about a topic that crops up every now and then:
Do you need to correct your _p_-values when you've run several significance tests?
The blog post is worth a read,
and I feel this quote sums it up well:

> We … need to make a statement about which tests relate to a single theoretical inference, which depends on the theoretical question. I believe many of the problems researchers have in deciding how to correct for multiple comparisons is actually a problem in deciding what their theoretical question is.

I think so, too,
which is why in this blog post, I'll present five common-ish scenarios and
discuss how I feel about correcting for multiple comparisons in each of them.
By and large, I think that if correcting for multiple comparisons is truly necessary,
MORE SPECIFIC THEORY.

<!--more-->

### The problem: multiple comparisons
But first, let's briefly review what multiple comparisons are.
Increase in Type-I error rate -- the more flexible you are about evidence favouring your theory etc.

Differences between statistical hypotheses and research hypotheses.

### Five scenarios
Assume no data snooping (looking at your data before deciding what to test formally) or selective reporting,
no HARKing (running a test and only then coming up with a theory and taking the test's result as evidence for this theory),


#### Scenario 1: 'Differences exist'
One dependent variable, one independent variable (multiple levels).
Theory underlying the study will be vindicated if the dependent variable differs for different levels of the independent variable.

In my view, correcting for multiple comparisons is not necessary in this scenario inasmuch as multiple comparisons aren't necessary: omnibus one-way ANOVA was made for this.

For correlations, similar tests exist.

#### Scenario 2: A single specific test suffices
> Someone wants to investigate whether a moderate intake of alcohol boosts learners' fluency in the L2.
> Participants are randomly assigned to one of three groups and drink a pint of (real) ale, alcohol-free ale or water.
> They then describe a video clip in the L2, and the number of syllables per minute is counted for each participant.

In principle, three comparisons could be carried out (ale vs. alcohol-free, ale vs. water, alcohol-free vs. water),
and at first blush one might want to correct for multiple comparisons.
However, the _alcohol-free vs. water_ comparison is irrelevant for the research question (which concerns the intake of actual alcohol).
Furthermore, the _ale vs. water_ comparison is a much less stringent test of the researcher's hypothesis than the _ale vs. alcohol-free_ comparison as it confounds 'intake of alcohol' with 'assumed intake of alcohol' such that differences between
the _ale_ and _water_ groups could come about due to a placebo effect.

For these reasons,
I don't think correcting for multiple comparisons is necessary here as -- again --
no multiple comparisons are needed for testing the researcher's hypothesis:
comparing the _ale_ and _alcohol-free_ groups suffices.
The additional _alcohol-free_ vs. _water_ comparison would be useful to test for the different hypothesis
that assumed intake of alcohol influences L2 fluency,
but I don't think this should affect the way the first hypothesis should be tested.
(Note the caveat about HARKing above.)

#### Scenario 3: Different theories are subjected to a different test each
> Same

#### Scenario 4: Theory survives

#### Scenario 5: Two specific positive tests are needed to corroborate theory


> E.g., when you'd regard a theory corroborated by the data if and only if the test showed two specific differences.



### Conclusion and further reading
