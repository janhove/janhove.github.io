---
layout: post
title: "Covariate adjustment in logistic mixed models: Is it worth the effort?"
thumbnail: /figs/thumbnails/2015-09-02-covariate-adjustment-mixed-logistic-regression.png
category: [design]
tags: [power, effect sizes, logistic regression, mixed-effects models]
---

The [previous]({% post_url 2015-07-17-covariate-adjustment-logistic-regression %}) post
investigated whether adjusting for covariates is useful 
when analysing binary data collected in a randomised experiment with one observation per participant.
This turned out to be the case in terms of statistical power 
and obtaining a more accurate estimate of the treatment effect.
This posts investigates whether these benefits carry over to 
mixed-effect analyses of binary data collected in randomised experiments 
with several observations per participant.
The results suggest that, while covariate adjustment may be worth it if the covariate is a very strong determinant of individual differences in the task at hand,
the benefit doesn't seem large enough to warrant collecting the covariate variable in an experiment I'm planning.

<!--more-->

### Background
I mostly deal with binary dependent variables -- whether a word was translated correctly (yes or no), for instance.
When each participant contributes only a single datapoint,
binary data can be analysed using logistic regression models.
More often than not, however, participants are asked to translate several words,
i.e. several datapoints are available per participant.
This 'clustering' needs to be taken into account in the analysis, which is where logistic mixed-effects models come in 
(see [Jaeger 2008](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2613284/) for a rundown).

For a new experiment I'm planning, 
it'd be useful to know whether I should collect **between-subjects variables** 
(the participants' language skills) 
that are likely to account for inter-individual differences in translation performance 
but that don't interest me as such.
What interests me instead is the effect of the learning condition, to which the participants will be assigned randomly.
Nonetheless, as the [previous]({% post_url 2015-07-17-covariate-adjustment-logistic-regression %}) post shows,
accounting for important if uninteresting covariates could be beneficial in terms of power and the accuracy of the estimated treatment effect.

However, when analysing an earlier [experiment](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Vanhove_CorrespondenceRules.pdf), 
I noticed that including covariates did not really affect the estimate of the treatment effect nor its standard error.
Since collecting these variables will lengthen the data collection sessions,
it'd be useful to know whether the additional time and effort are actually worth it from a statistical point of view.
I didn't find much in the way of readable literature that addresses this questions,
so I ran some simulations to find out.

### Set-up
The set-up for the simulations is as follows.
Sixty German-speaking participants are randomly and evenly assigned 
to either the experimental or the control condition.
During training, the participants in the experimental condition are exposed to a series of Dutch--German word pairs, 
some of which feature a systematic interlingual correspondence (e.g. Dutch _oe_ = German _u_ as in 'groet'--'Gruss').
The participants in the control group are exposed to comparable word pairs without this interlingual correspondence.
During testing, all participants are asked to translate previously unseen Dutch words into German.
The target stimuli are those that contain Dutch _oe_,
and the question is whether participants in the experimental condition are more likely 
to apply the interlingual correspondence when translating these words than the participants in the control group.
After the experiment, all participants take a German vocabulary test, 
which a previous [study](http://dx.doi.org/10.1515/iral-2015-0001) had suggested to be a strong predictor of
interindividual differences in this kind of task.

### Settings

The technical detals of the simulation are available [here](https://github.com/janhove/janhove.github.io/blob/master/RCode/GLMMPowerSimulation.md).
While I'd be chuffed if someone would go through it with the fine-toothed comb,
the general idea is this.
I took data from a previous experiment similar to the one I'm planning and fitted a model to this dataset.
On the basis of the fitted model, I generated new datasets for which I varied the following parameters:

* the number of target stimuli: 5 vs. 20 items per participant;
* the size of the effect of the between-subjects covariate: realistic (a slope of 0.1) and hugely exaggerated (slope of 1.0). The slope of 0.1 is 'realistic' in that it is pretty close to the covariate effect found in the original study.
The simulations with the much larger covariate effect were run in order to gauge power in situations were large inter-individual differences exist that can, however, be captured using a covariate.

The distribution of the covariate scores in the simulated datasets was similar 
to the one in the original one.
The number of participants was fixed at 60, distributed evenly between the two conditions,
and the size of the experimental effect was assumed to be equal to that of the original study.
A study with more participants or investigating a larger effect size will obviously have more statistical power,
but the precise power level isn't what interests me.
Rather, what I wanted to find out is, given a fixed effect size and a fixed number of participants,
would it be worth it to collect a between-subjects covariate and include it in the analysis?
To address this question, I compared the power of logistic mixed-effects models with and without covariates fitted to the simulated datasets.
Per parameter combination, 500 simulated datasets were generated and analysed.
This is not a huge number, but running logistic mixed model analyses takes a _lot_ of time.

### Results

#### Treatment estimate

Figure 1 shows how well logistic mixed-effect models with and without the between-subjects covariate estimated the true treatment effect on average.


![center](/figs/2015-09-02-covariate-adjustment-mixed-logistic-regression/unnamed-chunk-1-1.png) 

> **Figure 1:** Average estimated experimental effect of 500 logistic mixed-effects models without (o) and with the covariate modelled as a fixed effect (+).
> The vertical dashed line shows the true simulated experimental effect (0.95 log-odds).

For the realistic covariate slope of 0.1,
the covariate-adjusted and -unadjusted models produce essentially the same and highly accurate estimate of the treatment effect.
Even for the unrealistically large covariate slope of 1.0, i.e. for datasets with extreme but readily accountable inter-individual differences, the two models perform more or less on par.

From this, I tentitatively conclude that, for this kind of study, accounting for known sources of inter-individual variation using covariates does not substantially affect the estimates of the experimental effect.

#### Power

Figure 2 shows the proportion of significant treatment effects out of 500 simulation runs for the covariate-adjusted and -unadjusted models.

![center](/figs/2015-09-02-covariate-adjustment-mixed-logistic-regression/unnamed-chunk-2-1.png) 

> **Figure 2:** Estimated power to detect an experimental effect of 0.95 log-odds of logistic mixed-effects models without (o) and with the covariate modelled as a fixed effect (+).

For a realistic covariate effect (slope of 0.1), adding the between-subjects covariate improves power only marginally (by 1 to 2 percentage points).
For larger covariate effects, however, the gain in power is dramatic,
especially if a fair number of datapoints are available per participant.

### Conclusion and outlook
Adjusting for a between-subjects covariate in a between-subjects randomised experiment may be well worth it 
in terms of statistical power if the covariate is very strongly related to the outcome.
For the kind of task I want to investigate, though, the relationship between the covariate and the outcome doesn't seem to be large enough for covariate adjustment to have any noticeable effect on the results.
Presumably, the model's by-subject random intercepts do a sufficiently good job in accounting for interindividual differences in this case.
In practical terms, these insights will be useful to me as not collecting the between-subjects variable should free up time elsewhere in the data collection sessions.

Lastly, some new questions that arose during this exploration:

* Does accounting for a strong within-subjects covariate affect power in a between-subjects randomised experiment?
* Would by-item/by-participant variability in the covariate effects change these conclusions? Specifically, would accounting for the covariate effect using both a fixed and a random term improve power? In this dataset, the by-item variability in the between-subjects covariate was negligible, but this is probably different for other variables.
