---
layout: post
title: "Silly significance tests: The main effects no one is interested in"
thumbnail: /figs/blank.png
category: [Reporting]
tags: [simplicity, silly tests]
---

We are often more interested in interaction effects than in main effects. In a given study, we may not so much be interested in whether high-proficiency second-language (L2) learners react more quickly to target-language stimuli than low-proficiency L2 learners nor in whether L2 learners react more quickly to L1–L2 cognates than to non-cognates. Rather, what we may be interested in is whether the latency difference on cognates and non-cognates differs between high- and low-proficiency learners. When running an ANOVA of the two-way interaction, we should include the main effects, too, and our software package will dutifully report the F-tests for these main effects (i.e., for proficiency and cognacy).

But if it is the interaction that is of specific interest, I do not think that we have to actually _care_ about the significance of the main effects – or that we have to clutter the text by reporting them. Similarly, if a three-way interaction is what is of actual interest, the significance tests for the three main effects and two two-way interactions are not directly relevant to the research question, and the five corresponding F-tests can be omitted.

<!--more-->

### An example

To be clear, I'm not saying that reporting these main effects and lower-order interactions invalidates the inferences for the interaction of interest. Rather, my point is that they're distracting. To illustrate this, I've reproduced below three consecutive paragraphs of a results section in a [paper](http://dx.doi.org/10.1016/j.cognition.2009.08.001) on cognitive advantages of bilingualism. Any of several papers would've done, but with the recent [discussion](http://www.theatlantic.com/science/archive/2016/02/the-battle-over-bilingualism/462114/) about this topic, I thought most readers would be able to relate to this one. 

According to the authors, "[a]n effect of bilingualism would be indexed by either a main effect of 'Group of participants' in any of [the task versions] or by an interaction between 'Group of participants' and 'Type of flanker'" (p. 140). Here is the extract from the results section:

> In the RT analyses the main effect of "Task version" was not significant. The main effects of "Block" (_F_(2, 240) = 4.63, MSE = 921.93, _p_ = .011) and "Flanker type" (_F_(1, 120) = 1482.84, MSE = 1667.65, _p_ < .0001) were significant. Crucially, the main effect of "Group of participants" was significant (_F_(1, 120) = 11.86, MSE = 16976.12, _p_ < .001), with bilinguals producing faster RTs than monolinguals [cross-reference to a table].

> The main effects reported above need to be qualified by the multiple interactions observed in this experiment. The interaction between "Flanker type" and "Task version" (_F_(1, 120) = 49.60, MSE = 1667.65, _p_ < .0001) was significant, revealing that, although the conflict effect was present in both conditions (all ps < .01), it was larger in the 75% congruent version. Also, the magnitude of the conflict effect varied across experimental blocks ("Block" and "Flanker type" (F(2, 240) = 9.20, MSE = 320.76, _p_ = .0001).

> Let's now turn to the most interesting interactions involving the factor "Group of participants". First, the differences between monolinguals and bilinguals in overall RTs tended to be smaller in Block 2 and 3 than in Block 1 ("Group of Participants" X "Block" (_F_(2, 240) = 17.6, MSE = 921.93, _p_ = .0001). Although no other two-way interactions were observed involving the variable "Group of Participants", an informative three-way interaction between "Block", "Flanker type" and "Group of Participants" was significant (_F_(2, 240) = 4.66, MSE = 320.76, _p_ < .01). A closer look at this interaction revealed that, bilinguals tended to suffer a smaller conflict effect than monolinguals but only in the Block 1. In fact, this reduction in the conflict effect was present mostly in the 75% congruent task version. To get a better understanding of this pattern and given that the four-way interaction between "Block", "Flanker type", "Task version" and "Group of Participants" approached significant values (_F_(2, 240) = 2.38, MSE = 320.76, _p_ < .095), we conducted separate analyses for the two task versions. (etc.)

That's a lot of _F_-, MSE- and _p_-values, and I found it difficult to see the forest for the trees -- and there's a lot more _p_-values elsewhere in the paper, too.
Of the plethora of inferential statistics in the paragraphs above, only some have any direct bearing on the researchers' stated hypothesis, 
viz. the main effect of "Group of participants", 
the unreported interaction between "Group and of participants" and "Type of flanker", 
and perhaps the same main effect and interaction split up by task version 
(i.e., an interaction between "Group of participants", "Type of flanker" and "Task version"). 
Given the large number of tests, I consider this analysis to be more exploratory than confirmatory (which is fine), 
but even if the goal is to tease apart subtle effects of bilingualism vs. monolingualism in an exploratory analysis, 
I don't really see why the main effects of "Task version", "Block", and "Flanker type" or the interaction effects not involving "Group of participants" should be of interest. 

(There are other aspects of these paragraphs that could be discussed, but I'll leave it at that.)

### 'Silly' tests
I've written about ['silly' significance tests](http://janhove.github.io/tags.html#silly%20tests-ref) -- tests that don't add anything but make the report harder to read -- before, 
and for me, significance tests for uninteresting main effects and lower-order interactions fall in that category.
They clutter the text, and if a text contains too many of them, I'd expect my students (who take statistics on a voluntary basis if at all) to skip straight to the discussion.

I think that research papers would be easier to read and ultimately have more impact if the analyses focused on what the authors were really interested in. 
Consequently, I suggest researchers think twice and consider the paper's readability before reporting and discussing main effects and lower-order interactions 
if what they're interested in is a specific interaction. 
And if these tests are included for the sake of transparency, I propose the following alternatives in ascending order of my preference: 
(a) putting the ANOVA results in a separate table and only discussing the relevant bits in the running text; 
(b) including more informative graphs which also [show the individual data points]({% post_url 2015-01-07-some-alternatives-to-barplots %}) and refraining from rubber-stamping them with _F_- and _p_-values and what not; 
and, obviously, (c) [making your data and code available]({% post_url 2015-12-14-perks-data-sharing %}).
