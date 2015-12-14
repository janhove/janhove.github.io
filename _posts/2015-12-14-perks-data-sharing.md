---
layout: post
title: "Some advantages of sharing your data and code"
thumbnail: /figs/blank.png
category: [Reporting]
tags: [open science]
---

I believe researchers should put their datasets and any computer code used to analyse them online as a matter of principle, without being asked to, 
and many researchers ([Dorothy Bishop](http://deevybee.blogspot.co.uk/2015/11/whos-afraid-of-open-data.html), [Rolf Zwaan](http://rolfzwaan.blogspot.ch/2015/12/stepping-in-as-reviewers.html), [Jelte Wicherts](http://www.nature.com/news/psychology-must-learn-a-lesson-from-fraud-case-1.9513), and certainly dozens more) have cogently argued that such ‘open data’ should be the norm.
However, it seems to me that some aren’t too enthused at the prospect of putting their data and code online as they fear that some curmudgeon will go over them with the fine-toothed comb to find some tiny error and call the whole study into question. 
Why else would anyone be interested in their data and code?

I would. 
The scientific ideals of transparency and allowing yourself to be corrected are important arguments for open data.
But I can see plenty of advantages to open data other than spotting errors and running alternative analyses whose results may contradict those of the original study. 
In the hopes that researchers will be more willing to share their data and code
if they better appreciate such perks, I discuss four of them.

<!--more-->

### Realistic examples for teaching statistics
When teaching statistics, real datasets are great for going beyond the formulae and discussing other crucial aspects of quantitative research. 
The data might not follow a textbook distribution – should we be worrying? 
Some values may be missing – does this matter in this case? 
Some variables may be ambiguously labelled – a reminder to properly label them yourselves. 
There may be several ways to transform a variable – how strongly does our choice affect the results? 
And you can actually draw some subject-matter conclusions on the basis of real data, which could increase interest in the exercise.

I have a few datasets that I can incorporate in our own [introductory statistics course](http://janhove.github.io/statintro.html), 
but for many examples and exercises I have to resort to datasets from other fields or even simulated data. 
While the latter are often inspired by real studies, they’d be much instructive if they were based on the actual datasets with all their imperfections.
Now, it’s of course possible that in working through a real dataset, 
we could stumble on some errors or arbitrary decisions that have a major impact on the original study’s conclusions. 
But that’s just a by-product of wanting to learn more about dealing with data.

### Making analyses and results more intelligible

Having access to the data behind research papers would also be great when teaching subject-matter courses. 
For a typical class in an MA seminar, I ask my students to read a research paper, which we then dissect in class. 
Naturally, we devote considerable time to how the data are analysed and to how the conclusions follow from the results.

Inferential statistics aren’t very intuitive, however, 
and I like to refer as much as possible to descriptive statistics during the discussion – ideally in the form of graphs showing the raw data (e.g. scatterplots). 
When the paper doesn’t contain such graphs, 
it’d be incredibly useful if I could draw them myself using the original data – and show the students what “t(46) = 2.1, p = 0.04” actually looks like.

There are other things you could do when you have the raw data behind a paper. 
For instance, you could try to explain sampling error, signal detection and p-values using [graphical inference](http://janhove.github.io/teaching/2014/09/12/a-graphical-explanation-of-p-values) – it doesn’t hurt to revisit these concepts outside of the statistics class. 
The same goes for more involved analyses:
While I could have a crack at describing what hierarchical regression does, 
I think it’d be much more instructive to draw a scatterplot matrix of the variables involved or plots where the residuals of the previous step are regressed against the next predictor. 
For this, having the original data would be great.

Again, we might well end up concluding that the original study glosses over some unbecoming patterns in the data. 
But that too would be a by-product of trying to really understand a study.

Of course, having the original data and code wouldn’t only be useful for teaching students, but also for teaching yourself as a researcher. 
This may include learning about complex techniques such as importing data from online corpora or visualising a logistic regression model, 
but it could equally well include more mundane things like finding a more straightforward method for sorting a data frame in R, 
computing accuracy scores per participant per experimental condition, or even simply checking how others organise their datasets. 
Either way, your data and code can be instructive to others.

### Irrelevant to you, interesting to me

For my Ph.D. project I designed a pretty simple task in which people had to guess the meaning of words in a language they didn’t know but that was genealogically related to their native language. 
Naturally I wondered whether it would matter whether I tested my German-speaking participants in Swedish, Danish, Norwegian, Frisian, Dutch etc., so it would’ve been interesting to see how strongly translation performance correlated across target languages in previous studies. 
Only in one study that I knew of were the participants actually tested in several related languages with similar tasks. 
But the intercorrelations weren’t mentioned in the report as they simply hadn’t been of interest to the authors. 
I requested access to the data in order to compute them myself (easier than asking the authors to compute them for me, I thought), 
but my request was turned down on the grounds that the data were “too complex”.

To be clear, I fully understand why these intercorrelations were irrelevant to these authors, 
but with their data (about 1800 participants!) I could have pretty easily found an answer that was interesting to me. 
This, I think, applies to other datasets, too – there may be some aspect of your data that doesn’t interest you but may well help someone else design a study or refine a research question. 
By sharing your data without being asked to, 
you allow others to build on your work in ways you might not have conceived of.

### More focused writing

One thing I find difficult when writing is catering for the diverse backgrounds of my intended readership. 
Consider logistic mixed-effects models. 
I have pretty good reasons for using such models for analysing my data, 
but I’m often unsure in how much detail I should discuss them in papers. 
For instance, the ‘random correlations’ between the random intercepts and the random slopes in these models may be of interest to some readers, but probably not to most. 
Worse, the jargon may convince some readers that the paper isn’t meant for them. 
This would be a shame if these random correlations aren’t of too much importance for the paper’s conclusion. Similarly, does anyone really care that I use [cubic regression splines](https://stat.ethz.ch/R-manual/R-devel/library/mgcv/html/smooth.terms.html) rather than thin plate regression splines to model non-linear trends? 
Most readers won’t, and some may be confused by what I consider to be an unimportant detail. 
But I can’t rule out that some readers may be genuinely interested in it.

However, I’m willing to assume that anyone knowing enough about statistics to care about random correlations or regression spline classes will be able to make sense of my R script, 
so I just put it online alongside the data. 
(For future projects, I consider putting the R script on RPubs so that interested readers can look up the details without having to actually run the analyses. See [this example](https://rpubs.com/Reinhold/17313).) 
That way, I can focus on what I consider to be the important aspects of the analysis, 
which makes for clearer writing.

### Conclusions

To me, open data isn't just about preventing fraud and fixing honest mistakes.
It's also about getting most mileage out of your data by allowing it to be used for educating future scientists, helping colleagues, and catering to your readers' interests and background.
