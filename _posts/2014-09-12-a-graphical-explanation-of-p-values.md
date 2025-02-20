---
layout: post
title: "A purely graphical explanation of p-values"
thumbnail: /figs/thumbnails/2014-09-12-a-graphical-explanation-of-p-values.png
category: [Teaching]
tags: [significance, R]
---

_p_-values are confusing creatures--not just to students taking their first statistics course but to seasoned researchers, too.
To fully understand how _p_-values are calculated, you need to know a good deal of mathematical and statistical concepts (e.g. probability distributions, standard deviations, the central limit theorem, null hypotheses), and these take a while to settle in.
But to explain the _meaning_ of _p_-values, I think we can get by without such sophistication.
So here you have it, a purely graphical explanation of _p_-values.

<!--more-->



### A graphical _t_-test / ANOVA

The statistical tests you're most likely to run into are the two-sample _t_-test and its big brother, analysis of variance (ANOVA).
These tests are used to establish whether the difference between two or more group averages are due to chance or whether their is some underlying system to them.

For this example, I use data from my Ph.D. project.
The goal of this analysis (not of my thesis, though) is to establish whether men and women differ in their ability to understand spoken words in an unknown but related foreign language.
The following R code reads in the data, tabulates the number of men and women (`table()`) and shows the distribution of the participants' scores on the listening test (`hist()`).
To reproduce this analysis, you'll need to install R, which is freely available from [http://r-project.org/](http://r-project.org/)--and while you're at it, download a graphical user interface like [RStudio](http://rstudio.com/).


{% highlight r %}
dat <- read.csv("http://janhove.github.io/datasets/sinergia.csv")
table(dat$Sex)
{% endhighlight %}



{% highlight text %}
## 
## female   male 
##     90     73
{% endhighlight %}



{% highlight r %}
hist(dat$Spoken, main="Histogram", xlab="Score", col="lightblue")
{% endhighlight %}

![center](/figs/2014-09-12-a-graphical-explanation-of-p-values/unnamed-chunk-2.png) 

{% highlight r %}
#summary(dat)
{% endhighlight %}

To establish whether men and women differ 'significantly' from one another, we'd usually plot the data, run a _t_-test, and check the reported _p_-value,
but an alternative approach is discussed by [Wickham and colleagues](http://ieeexplore.ieee.org/xpls/icp.jsp?arnumber=5613434).

The **basic idea** is as follows.
If there is a systematic relationship between two variables (e.g. a difference in group averages), then we ought to be able to tell the _real_ dataset from _fake_ datasets that were randomly generated without an underlying systematic relationship.
To generate fake but 'realistic' datasets, we can permute the real data, i.e., randomly switch the datapoints between the groups.
Then, we organise a line-up (like in the movies!) with the real dataset hidden among several fake datasets.
If we can distinguish the real dataset from the fake ones, we have some evidence that there is some degree of system in the real data that is not present in the fake data.

This procedure is implemented in the `nullabor` package for R, which relies on the `ggplot2` package.
Make sure you have these two packages installed on your machine (`install.packages()`).


{% highlight r %}
# Remove the # before the two next lines to install the ggplot2 and nullabor packages.
# install.packages("ggplot2")
# install.packages("nullabor")
# Load packages
library(ggplot2)
library(nullabor)
{% endhighlight %}

The following code plots the listening scores for all participants according to whether they're male or female,
but the real dataset is hidden among 19 fake (permuted) datasets.
The crosshairs mark the means for each sex in each dataset.
Can you pick out the real dataset?
(The code to generate this plot is somewhat complicated but is of no consequence to the argument; don't lose yourself in it.)


{% highlight r %}
p <- ggplot(dat, aes(Sex, Spoken)) %+%
      lineup(null_permute("Spoken"), dat) +
      scale_y_continuous(limits = c(0, 30)) + 
      #geom_boxplot(outlier.shape = NA, na.rm = TRUE) +
      geom_point(size = 1,
                 aes(col=Sex),
                 position = position_jitter(w=0.3, h = 0)) +
      stat_summary(fun.y = mean, 
                   geom = "point", 
                   shape = 10, size = 4) +
      guides(colour = FALSE) +
      facet_wrap(~ .sample)
{% endhighlight %}



{% highlight text %}
## decrypt("42Dm dbSb 8o Kpq8S8po Y")
{% endhighlight %}



{% highlight r %}
p
{% endhighlight %}

![center](/figs/2014-09-12-a-graphical-explanation-of-p-values/unnamed-chunk-4.png) 

Most sample means are pretty similar, but not entirely identical, to each other.
Due to the randomness inherent in generating permutations, some differences between the sample means for men and women are in fact expected.
This is known as **sampling error**.
If men's and women's listening scores didn't differ systematically from one another, we wouldn't be able to pick out the real dataset with **above-chance accuracy**, i.e., we would only have a 1 in 20 (5%) chance of picking the right answer.

If there were some systematic difference between the two groups, however, we would be able to beat those odds.
Eye-balling these plots, I'd say that Panel 3 stands out in that the difference between men and women is larger than in the other panels.
Using the encrypted code provided above, we can check whether this hunch is correct:


{% highlight r %}
decrypt("42Dm dbSb 8o Kpq8S8po Y")
{% endhighlight %}



{% highlight text %}
## [1] "True data in position 3"
{% endhighlight %}

It is.
If there were no systematic difference between the two groups (``if the null hypothesis were correct'', in statistics parlance), I'd only have had a 1-in-20 chance of picking the right answer, yet I managed to do so.
Put differently, it's pretty unlikely (5%) to observe this noticeable a difference between the two groups if no systematic pattern existed, and from this we'd usually conclude that there _is_ some systematic pattern.
This, in effect, is what is expressed by '_p_ = 0.05'.
To establish '_p_ = 0.01' using this procedure, you'd have to be able to pick out the actual dataset when it's hidden among 99 fake datasets -- but that wouldn't work now since you already know how it looks.

A cautionary note, though: While we've established with some confidence that women have differerent (higher) listening scores from men, we've not demonstrated that it's the sex difference that _causes_ this difference.
In this study, the men were on average somewhat older than the women, for instance.

### A graphical correlation test

The graphical test can also be applied to the relationship between two continuous variables.
Usually, we'd compute a correlation test or fit a regression model to get a _p_-value for such a situation.

The following plot shows the relationship between a measure of intelligence ('Raven') and the participants' performance on a reading task.
The real dataset is again hidden among 19 fake datasets that were generated without an underlying pattern.
Can you spot the real dataset?


{% highlight r %}
q <- ggplot(dat, aes(Raven, Written)) %+%
      lineup(null_permute("Raven"), dat, n = 20) +
      geom_point(size = 1) +
      facet_wrap(~ .sample)
{% endhighlight %}



{% highlight text %}
## decrypt("42Dm dbSb 8o Kpq8S8po u9")
{% endhighlight %}



{% highlight r %}
q
{% endhighlight %}

![center](/figs/2014-09-12-a-graphical-explanation-of-p-values/unnamed-chunk-6.png) 

You might be able to spot the real dataset, but I had to peek at the right answer to know it was Panel 16.
In this case, I wasn't able to beat the odds since the real data look too similar to the fake data, suggesting that 'no systematic pattern' is a more parsimonious relationship.

Compare this to the following plot, which shows the participants' reading scores in function of their English skills.


{% highlight r %}
r <- ggplot(dat, aes(English, Written)) %+%
      lineup(null_permute("English"), dat, n = 20) +
      geom_point(size = 1) +
      facet_wrap(~ .sample)
{% endhighlight %}



{% highlight text %}
## decrypt("42Dm dbSb 8o Kpq8S8po k")
{% endhighlight %}



{% highlight r %}
r
{% endhighlight %}

![center](/figs/2014-09-12-a-graphical-explanation-of-p-values/unnamed-chunk-7.png) 

If you picked Panel 2 because its discernible positive trend, you'd be right. A statistical test would likely yield a _p_-value lower than 0.05. In fact, in this case, you'd probably be able to pick out the real data from among a much larger number of fake datasets.

### Concluding remarks
Obviously there's some subjectivity inherent in this type of analysis,
and the procedure breaks down when you already know the shape of the actual data.
To increase its reliability, you could try to enlist the help of a panel of independent judges who are not involved in the research project.
That said, the goal of this post was to clarify what enigmatic phrases like '_p_ < 0.05' express: the degree of unusualness of the data at hand compared to data with no underlying systematic pattern.
