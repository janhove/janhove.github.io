---
layout: post
title: "The curious neglect of covariates in discussions of statistical power"
category: [stats 201]
tags: [statistics]
---

The last couple of years have seen a spate of articles in (especially psychology) journals and on academic blogs discussing the importance of statistical power.
But the positive effects of including a couple of well-chosen covariates deserve more appreciation in such discussions.
My previous blog posts have been a bit on the long side, so I'll try to keep this one short and R-free.

<!--more-->

Discussions on the importance of statistical power serve the useful purpose of reminding researchers that experiments with 20 participants in each group are seriously underpowered. For example, a true effect typical of L2 research (d = 0.7 according to [Plonsky & Oswald, 2014](http://dx.doi.org/10.1111/lang.12079)) has a less than 60% chance of being detected in such a study. Furthermore, underpowered studies aren't as informative as many like to believe with respect to the estimated direction and size of any significant effect they do find ([Gelman & Carlin, 2014](http://dx.doi.org/10.1177/1745691614551642)).
These discussions are extremely valuable, but the typical advice they often seem to entail ('quintuple your sample size or don't bother doing the study') ignores a more practical solution to the power problem: **using covariates**.

In the vast majority of studies that I read, the researchers collect humongous amounts of 'background' data on their participants. For instance, in research on the cognitive correlates of bilingualism, researchers collect questionnaire data on language history (e.g., age of L2 acquisition, age of active daily bilingualism) and administer tests of verbal intelligence, working memory etc. - all of this is _in addition to_ the data that really interests them (typically some measure of cognitive control). These data are then summarised and neatly tabulated to demonstrate that the groups compared are 'matched' for working memory etc., so that it can be argued that whatever differences in cognitive control are found between the groups can't be explained through differences in cognitive control. Working memory is then ignored as researchers go about their ANOVA and _t_-test business.

To me, this is statistical sacrilege. Surely, if it's important to demonstrate that working memory capacity (to stick with that example) is comparable between the groups compared, it's because differences in working memory tend to be related to differences in cognitive control? 
While the groups may have comparable average working memory capacities, their will be substantial within-group variability in working memory capacity that is likely linked to within-group variability in cognitive control.
If we include working memory capacity as a covariate (or **control variable**), we'll be able to explain some of the error variance in cognitive control.
This, in turn, will improve the precision with which the effects of interest are estimated, i.e. greater statistical power.

The important thing here is that including covariates that are likely to be related to differences in the outcome variable is advantageous **even if the groups are comparable** with respect to them. By condemning potential 'confound variables' to summary tables, researchers are leaving money on the table -- if they're important enough to be collected, why not make full use of them?

Now, taking into account covariates in the main analyses means that researchers will have to abandon their simple statistical tools (_t_-tests, correlations, χ²-tests) in favour of multivariate statistics (multiple regression, logistic regression, or classification algorithms), which could take some getting used to.
But they can still focus on the effect they're interested in and they shouldn't be expected to discuss the effects of the covariates in any detail apart from mentioning that they were included in the analyses.

I'm glossing over some details here, but the general point that researchers are shooting themselves in the foot powerwise by not making use of the rich data they collect in the actual analyses merits more attention.
