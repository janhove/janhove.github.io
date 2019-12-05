---
title: "Five suggestions for simplifying research reports"
layout: post
mathjax: true
tags: [simplicity, silly tests, graphics, cluster-randomised experiments, open science]
category: [Reporting]
---

Whenever I’m looking for empirical research articles to discuss in my classes on
second language acquisition, I’m struck by how needlessly complicated and
unnecessarily long most articles in the field are. Here are some suggestions for
reducing the numerical fluff in quantitative research reports.

<!--more-->

## (1) Round more
Other than giving off an air of scientific exactitude, there is no reason for
reporting the mean age of a sample of participants as “41.01 years” rather than
as just “41 years”. Nothing hinges on the 88 hours implied by “.01 years”, and
people systematically underreport their age anyway: I’d report my age as 33
years, not as 33.34 years. 
[Overprecise reporting](http://janhove.github.io/reporting/2015/01/14/overaccuracy) 
makes it harder to spot patterns in results 
(see Ehrenberg [1977](http://doi.org/10.2307/2344922),[1981](http://doi.org/10.2307/2683143)). 
Moreover, it can give readers the
impression that there is much more certainty about the findings than there
really is if the overprecise numbers aren’t accompanied by a measure of
uncertainty.

**So round more.** Average reaction times needn’t be reported to one-hundredth of a
millisecond. Correlation coefficients rounded to two decimal places are probably
overprecise enough already. Average responses on a 5-point scale are probably
best reported to one decimal place rather than to two or---heaven
forbid---three. Percentages rarely need to be reported to decimal places at all.
There are exceptions to these suggestions. But they’re exceptions.

## (2) Show the main results graphically
Some sort of a visualisation goes a long way in making the results of a study
more understandable. Instead of detailed numerical descriptions, try to come up
with one or a couple of graphs on the basis of which readers can answer the
research questions themselves even if they don’t understand the ins and outs of
the analysis. Depending on the data you’re working with, you could plot the raw
data that went into the analyses or some summary statistics (e.g., a plot of
group means or proportions) or draw model-based effect plots.

Admittedly, drawing a good graph can be difficult and can cost a lot of time,
but perhaps some of the tutorials I wrote are of some help:

* [Tutorial: Drawing a scatterplot](https://janhove.github.io/reporting/2016/06/02/drawing-a-scatterplot)
* [Tutorial: Drawing a line chart](https://janhove.github.io/reporting/2016/06/13/drawing-a-linechart)
* [Tutorial: Drawing a boxplot](https://janhove.github.io/reporting/2016/06/21/drawing-a-boxplot)
* [Tutorial: Drawing a dot plot](https://janhove.github.io/reporting/2016/08/30/drawing-a-dotplot)
* [Tutorial: Plotting regression models](https://janhove.github.io/reporting/2017/04/23/visualising-models-1)
* [Visualising statistical uncertainty using model-based graphs](https://janhove.github.io/visualise_uncertainty/)
    
    
## (3) Run and report _much_ fewer significance tests
A sizable number of significance tests are run and reported as a matter of
course, without there being any real scientific benefit to them. In fact, some
of these tests are detrimental to the study’s main inferential results. But my
main concern for the purposes of this blog post is that they make research
reports all but impregnable to readers who haven’t yet learnt that, frankly,
most numbers in an average research report are just fluff. Some tests are easy
to do without. These include:

* [tautological tests](https://janhove.github.io/reporting/2014/10/15/tautological-tests), where researchers group participants, items, etc. based on some variable and then confirm that the groups differ with respect to said variable;
* [balance tests](https://janhove.github.io/reporting/2014/09/26/balance-tests), where researchers randomly assign participants to conditions and then check whether the different groups are ‘balanced’ with respect to some measured confound variables. Balance tests in studies without random assignment are less silly, but I’m yet to be convinced they’re useful.

Some other tests are reported so routinely that may be more difficult to leave out, but they are merely clutter all the same. These tests include:

* [significance tests for the main effects if it’s only the interaction that’s of interest](https://janhove.github.io/reporting/2016/02/23/uninteresting-main-effects). When the research question concerns an interaction, it’s almost always necessary to include the main effects in the analysis. The statistical software will dutifully output significance tests for these main results. But if they’re not relevant to the research question, I don’t see why these main effects should then be discussed in the main text.
* significance tests for control variables. There may be excellent reasons for
including control variables in the analysis: These may make the estimate for the
effect of interest more precise. But they’re almost always not of scientific
relevance. So again, I don’t see why the significance tests for control
variables should be discussed in the main text.

My own preference is to report this information in the supplementary materials
or to make available the data and computer code so that readers who, for some
reason, might be interested in it can run these significance tests themselves. A
workable alternative would be to disregard APA guidelines and to report all of
the significance tests in a table instead of in the main text and then to only
discuss the _relevant_ test in the main text.


## (4) Details that someone, somewhere might interested in don’t belong in the main text
Try to resist the urge to include in the main text all information that isn’t directly relevant to your research question but that someone, somewhere might be interested in. Instead, report this information in the appendix or in the online supplementary materials. If you’re able to put your data and analysis script online, you can be skimpy on many details. Examples of this include:

* which optimiser you used when fitting models with mixed-effects models. The people that might care would have no problem identifying this piece of information from an R script that you put online.
* in a within-subjects design, what the correlation between the outcome in the different conditions is. This information could be useful for people who want to run a power analysis for their own study, but it’s unlikely to be relevant to your research question. If you put the data online, though, these people have access to this piece of information and you don’t have to befuddle your readers with it.
* full-fledged alternative analyses. For instance, you may have run a couple of alternative analyses (e.g., in- or excluding outliers) that yielded essentially identical results. One sentence and a reference to the appendix or supplementary materials should suffice; there’s no need to report the alternative analyses in full.
* standardised effect sizes. I’m not a fan of them, so I don’t report them. But meta-analysts should be able to compute them from the summary statistics or from the raw data provided in the supplementary materials.

## (5) If two analyses yield essentially the same results, report the simpler one
Some analyses look complicated, but they always boil down to analyses that are
fairly easy. In these cases, the complicated analysis has no added value. Other
complicated analyses are arguably a priori more suitable than their more
commonly used counterparts, but they often yield similar results. In these
cases, I think it’s sensible to carry out both analyses, but only report the
more complicated one in the main text if it produces substantially different
results from the simpler one.

### ‘Mixed’ repeated-measures ANOVA vs. a t-test
One example of a complicated analysis that always yields the same result as a simpler analysis is repeated-measures ANOVA for analysing pretest/posttest experiments:

> "A repeated-measures ANOVA yielded a nonsignificant main effect of Condition ($F(1, 48) < 1$) but a significant main effect of Time ($F(1, 48) = 154.6$, $p < 0.001$): In both groups, the posttest scores were higher than the pretest scores. In addition, the Condition × Time interaction was significant ($F(1, 48) = 6.2$, $p = 0.016$): The increase in reading scores relative to baseline was higher in the treatment than in the control group."

As I’ve written [before](https://janhove.github.io/reporting/2016/02/23/uninteresting-main-effects), it’s only the interaction that’s of any interest here, and exactly the same p-value can be obtained using a simpler method:

> "We calculated the difference between the pretest and posttest performance for each participant. A two-sample t-test showed that the treatment group showed a higher increase in reading scores than the control group ($t(48) = 2.49$, $p = 0.016$)."

Other ‘mixed’ repeated-measures ANOVAs can similarly be simplified. For instance, research on cognitive advantages of bilingualism often compares bilinguals with monolinguals on tasks such as the Simon or flanker task. These tasks consist of both congruent and incongruent trials, and the idea is that cognitive advantages of bilingualism would be reflected in a smaller effect of congruency in the bilingual than in the monolingual participants. The results of such a study are then often reported as follows:

> "A repeated-measures ANOVA showed a significant main effect of Congruency, with longer reaction times for incongruent than for congruent items ($F(1, 58) = 14.3, p < 0.001$). The main effect for Language Group did not reach significance, however ($F(1, 58) = 1.4, p = 0.24$). The crucial interaction between Congruency and Language Group was significant, with bilingual participants showing a smaller Congruency effect than monolinguals ($F(1, 58) = 5.8$, $p = 0.02$)."

If the question of interest is merely whether the Congruency effect is smaller in bilinguals than in monolinguals, the following analysis will yield the same inferential results but is easier to navigate through:

> "For each participant, we compute the difference between their mean reaction time on congruent and on incongruent items. On average, these differences were smaller for the bilingual than for the monolingual participants ($t(58) = 2.4$, $p = 0.02$)."

If three or more groups are compared, a one-way ANOVA could be substituted for
the t-test, which is still easier to report and navigate than a two-way RM-ANOVA
that produces two significance tests that don’t answer the research question.

To seasoned researchers, the difference the original write-ups and my
suggestions may not seem like much. But novices---sensibly but
incorrectly---assume that each reported significance test must have its role in
a research paper. The two irrelevant significance tests detract them from the
paper’s true objective. Additionally, novices are more likely to be familiar
with t-tests than with repeated-measures ANOVA, so the simpler write-up may be
considerably less daunting to them.

### Multilevel models vs. cluster-level analyses
Cluster-randomised experiments are experiments in which pre-existing groups of participants are assigned in their entirety to the experimental conditions. Importantly, the fact that the participants weren’t all assigned to the condition independently of one another needs to be taken into account in the analysis since the inferences can otherwise be [spectacularly anti-conservative](http://doi.org/10.14746/ssllt.2015.5.1.7). A write-up of a cluster-randomised experiments could look as follows:

> "Fourteen classes with 18 pupils each participated in the experiment. Seven randomly picked classes were assigned in their entirety to the intervention condition, the others constituted the control condition. (...) To deal with the clusters in the data (pupils in classes), we fitted a multilevel model using the lme4 package for R (Bates et al. 2015) with class as a random effect. p-values were computed using Satterthwaite’s degrees of freedom method as implemented in the lmerTest package (Kuznetsova et al. 2017) and showed a significant intervention effect ($t(12) = 2.3$, $p = 0.04$)."

Technically, this analysis is perfectly valid, but a novice may be too bamboozled by the specialised software and the sophisticated analyses to be motivated enough to follow along. Compare this to the following write-up:

> "Fourteen classes with 18 pupils each participated in the experiment. Seven randomly picked classes were assigned in their entirety to the intervention condition, the others constituted the control condition. (...) To deal with the clusters in the data (pupils in classes), we computed the mean outcome per class and submitted these means to a t-test comparing the intervention and the control classes. This revealed a significant intervention effect ($t(12) = 2.3$, $p = 0.04$)."

Computing means is easy enough, as is running a t-test: The entire analysis could easily be run in the reader’s spreadsheet program of choice. Moreover, the result is exactly the same in this case. In fact, if the cluster sizes are all the same, the multilevel approach and the cluster-mean approach will always yield the exact same result.

If the cluster sizes aren’t all the same, the results that both approaches yield won’t be exactly the same. As far as I know, there are no published comparisons of which approach is best in such cases, but my own [simulations](https://janhove.github.io/analysis/2019/10/28/cluster-covariates) indicate that both are equally powerful statistically. If that doesn’t put you at ease, you could run both analyses. If they yield approximately the same results, you could report the easier one in the main text and the more complicated one in the appendix; if they yield different results, you’d report the more complicated one in the main text and the simpler one in the appendix. In terms of p-values, you could define them to be "approximately the same" if they both fall into the same predefined bracket, e.g., "both $p < 0.01$" or "both $0.01 < p < 0.05$" or "both $p > 0.05$". Of course, what you shouldn’t do is to always just report the analysis that yielded the lowest p-value.

### Parametric vs. non-parametric tests
I would follow the same procedure as above: If, for some reason, you're convinced you should run a non-parametric test but it yields approximately the same results, report the results for the parametric test, which more readers will be familiar with, in the main text.

### Ordinal models vs. linear models
Some people argued for the need to analyse Likert-type data using ordinal regression models rather than using linear models (including t-tests). I myself find it difficult to wrap my head around the different types of ordinal models, I don’t find the model visualisations intuitively understandable, and for some reason, my ordinal models don’t converge in a reasonable time. But that’s for some other blog post. My point is that, even though I accept that ordinal models represent a better default for dealing with Likert-type data, I find them much more complicated than linear models. I suspect that the same would go for any readership.

At the same time, I also suspect that, in a great many cases, ordinal and linear models applied to the same data would point to the same answer to the research question. In those cases, I’d prefer for the linear model to be reported in the main text and the ordinal model in the appendix.
