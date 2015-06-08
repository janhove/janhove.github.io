---
layout: post
title: "Silly significance tests: Tests unrelated to the genuine research questions"
thumbnail: /figs/thumbnails/blank.png
category: [analysis]
tags: [silly tests, simplicity, power, multiple comparisons]
---

Quite a few significance tests in applied linguistics don't seem to be relevant to the genuine aims of the study. 
Too many of these tests can make the text an intransparent jumble of t-, F- and p-values,
and I suggest we leave them out.

<!--more-->

An example of the kind of test I have in mind is this. Let's say a student wants to investigate the efficiency of a new teaching method. After going to great lengths to collect data in several schools, he compares the [mean test scores](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Vanhove_AnalyzingRandomizedInterventions.pdf#page=7) of classes taught with the new method to those of classes taught with the old method. But in addition to this key comparison, he also runs separate tests to see whether the test scores of the girls differ from those of the boys or whether the pupils' socio-econonomic status (SES) is linked to their test performance. 

These additional tests aren't needed to test the efficiency of the new teaching method (the genuine aim of the study), yet tests like these are commonly run and reported. They constitute the third type of 'silly test' that we can do without (the first two being [superfluous balance tests](http://janhove.github.io/reporting/2014/09/26/balance-tests) and [tautological tests](http://janhove.github.io/reporting/2014/10/15/tautological-tests/)).
In what follows, I respond to three possible arguments in favour of these tests. 

### Argument 1: 'But test scores are likely to be correlated with sex / SES / age etc.'
When designing a study, it's often possible to identify variables that could help to account for differences in the dependent variable (here: test scores). It sounds reasonable that we should collect these additional variables and take them into account in the analysis before jumping to conclusions about the experimental manipulation (here: teaching method).
What needs to be appreciated, however, is that additional variables such as the learners' sex, SES or age may be _important_ predictors of test performance but nonetheless _uninteresting_ in this study.

To take an example from another field, a nutrition researcher may be interested in the effect of protein-rich diets on children's height. The parents' height is obviously an important determinant of the children's height, but this relationship isn't the focus of the study.
Nonetheless, it would be a good idea to include the parents' height in the analysis -- not because the researcher is _interested_ in this link but in order to account for differences between children that are uninteresting for the present study.
Accounting for sources of uninteresting differences in the dependent variable reduces the residual error, which in turn leads to a more precise estimate of what the researcher is interested in. 

Crucially, if the idea behind running analyses on sex, SES etc. is to get a more precise estimate of the efficiency of the new teaching method, all of these variables **need to be included in the same statistical model**.
This means that instead of running a t-test with teaching method as the independent variable, another t-test with sex as the independent variable and an ANOVA with SES as the independent variable, you run _one_ ANOVA with teaching method, sex and SES as the independent variables. If you have a continuous additional variable that shows a linear relationship to the dependent variable, you can include it alongside the other variables in an ANCOVA or multiple regression.
The decision to include additional variables in the analysis, incidentally, is one to be taken in advance: 
fiddling about with such additional variables until you get the result you were hoping for is bad practice 
as it increases the study's false positive rate (finding a significant effect when none exists).

Sometimes researchers try to contain the influence of additional variables by ensuring that the experimental groups are perfectly balanced with respect to them. For instance, they ensure that the number of boys and girls in the different conditions are equal.
This is known as 'blocking'. Once again, however, precision only increases if the blocking variable is included in the same statistical model as the variable of interest.

Lastly, as long as the reason for including additional variables in the analysis is to increase precision, **we shouldn't care about whether these additional variables have significant effects**: whether you find a significant effect of sex or SES on test performance would be immaterial to the real aim of the study. Consequently, the effects of these additional variables don't have to be discussed any further (see [Oehlert 2010, p. 321](http://users.stat.umn.edu/~gary/book/fcdae.pdf#page=341)), and I even think you can do without reporting their p-values -- thereby focusing the report more strongly on what's really of interest.

### Argument 2: 'The efficiency of the new teaching method might be different according to sex / socio-econonomic status / age etc.'
The second objection that I would anticipate is that the variable of interest (here: teaching method) might have a different effect depending on some additional variable such as the learners' sex, SES, age etc.
This argument is different from the first one: According to the first argument, boys are expected to perform differently from girls in the experimental (new method) and control condition (old method) alike. According to the second argument, boys might profit more from the new teaching method than do girls (or vice versa). Such a finding could be an important nuance when comparing the new and the old method.

Running an additional t-test with sex as the independent variable doesn't account for this nuance, however. Instead, it's the **interaction** between teaching method and sex that's of interest here.

In my experience, however, the rationale behind such interaction tests is rarely theoretically or empirically buttressed:
the idea is merely that the effect of interest _might_ somehow differ according to sex, SES etc.
Clearly, then, the interactions aren't the focus of the study.
I therefore think it's best to **explicitly label any such interaction tests as exploratory**, if you want to run them at all,
and demarcate them from the study's main aim for greater reader-friendliness.
Any interesting patterns can then be left to a new study that explicitly targets these interactions.

### Argument 3: 'After painstakingly collecting this much data, running just one test seems a bit meagre.'
The third objection isn't so much a rational argument as an emotional appeal -- and one that I'm entirely sympathetic to:
After travelling through the country to collect data, negotiating with school principals, sending out several reminders for getting parental consent, trying to make sense of illegible handwriting etc., running a single straightforward t-test seems pretty underwhelming.

Saying that a straightforward analysis is the reward for a good design and that the scientific value of a study isn't a (positive) function of the number of significance tests it features probably offers only scant consolation.
Nothing speaks against conducting additional analyses on your painstakingly collected data, however, 
provided that these **exploratory analyses are labelled as such** and, ideally, clearly demarcated from the main analysis.
Furthermore, keeping track of tens of test results when reading a research paper is a challenge,
which is why I think it pays to be **selective** when conducting and reporting exploratory analyses.
First, exploratory analyses are ideally still **theoretically guided** and pave the way towards a follow-up study.
Second, I think exploratory analyses should **only compare what can sensibly be compared** in the study.
For instance, learners' comprehension of active and passive sentences might sensibly be compared inasmuch as these form each other's counterpart (especially if the active and passive sentences express the same proposition). But it'd be more difficult to justify a comparison between the comprehension of object questions and that of unrelated relative clauses.
Third, before drawing sweeping conclusions from exploratory analyses, researchers should remind themselves
that their **chances of finding some significant results increase with each comparison, even if no real differences exist**.

Lastly, I think there's an argument to be made to report exploratory analyses **descriptively only**, e.g. using graphs and descriptive statistics but without t-tests, ANOVAs, p-values and the like, but I fear that reviewers and editors would probably insist on some inferential measures.

### Summary and conclusion
A thread running through this blog is my convinction that typical quantitative research papers in applied linguistics and related fields
contain too many significance tests, which can make for a challenging read even for dyed-in-the-wool quantitative researchers.
In addition to doing away with [balance tests](http://janhove.github.io/reporting/2014/09/26/balance-tests) and obviously [tautological tests](http://janhove.github.io/reporting/2014/10/15/tautological-tests/), I suggest that we get rid of tests that don't contribute to the study's primary aim. To that end, I propose three guidelines:

* If you analyse variables that you aren't genuinely interested in because 
they may nonetheless give rise to differences in the dependent variable, 
consider including them in the _same_ analysis as the variables that you _are_ interested in.
* If you analyse such variables because they could reasonably interact with the effect you're really interested in,
it's the interaction effect you want to take a look at.
* By all means, conduct exploratory analyses on rich datasets, but show some restraint in choosing which comparisons to run and in interpreting them.

To wrap off, here's a rule of thumb that could have some heuristic value: 
If a comparison isn't worth the time and effort and for a decent-looking graph to show it,
it probably isn't worth testing it.
