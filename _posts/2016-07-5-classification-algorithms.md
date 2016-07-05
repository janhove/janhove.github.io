---
layout: post
title: "Classifying second-language learners as native- or non-nativelike: Don't neglect classification error rates"
category: [Analysis]
tags: [machine learning, random forests]
---

I'd promised to write another installment on drawing [graphs]({% post_url 2016-06-21-drawing-a-boxplot %}),
but instead I'm going to write about something that 
I had to exclude, for reasons of space, 
from a recently published [book chapter](http://janhove.github.io/publications.html#section) 
on age effects in second language (L2) acquisition:
**classifying** observations (e.g., L2 learners) and **estimating error rates**.

I'm going to illustrate the usefulness of classification algorithms
for addressing some problems in L2 acquisition research,
but my broader aim is to show that there's more to statistics than running significance tests
and to encourage you to explore---even if superficially---what else is out there.

<!--more-->

### Background: classifying L2 learners as native- or non-nativelike
In the field of second language acquisition, there are a couple of theories that predict
that L2 learners who begin learning the L2 after a certain age will never be
'native-like' in the L2. The 'certain age' differs between studies, and
what the prediction boils down to in some versions is that _no_ L2 learner will ever be fully 'native-like' in the L2.

I, for one, don't think that 'nativelikeness' is a useful scientific construct, 
but that doesn't matter for this post: Some researchers obviously do consider it useful,
and for them the question is how they can test their prediction.

Researchers interested in nativelikeness 
usually administer a battery of linguistic tasks to a sample of L2 learners
as well as to a 'control' sample of L1 speakers.
On the basis of the L1 speakers' results, they then define a **nativelikeness criterion**---an interval
that is considered typical of L1 speakers' performance.
Common intervals are (a) the L1 speakers' mean ± two standard deviations or (b) the range of the L1 speakers' results.
L2 speakers whose results fall outside this interval are considered non-nativelike,
and the goal of the study is often to establish from which age of L2 acquisition onwards 
no nativelike L2 speakers can be found.

### The problem: Misclassifications
The procedure I've just sketched is pretty common but it's fundamentally **flawed**.
One problem with it is that it may misclassify non-nativelike speakers as nativelike.
I think most researchers are aware of this problem, 
as they sometimes seem to imply that fewer L2 learners would've qualified as nativelike 
if only more and more reliable data were available.
This may well be true.
But the other side of the coin is rarely considered: 
_not all L1 speakers may pass the nativelikeness criterion either!_

To my knowledge, no paper in L2 acquisition provides an **error-rate estimate**,
i.e., a quantitative appraisal of how well the nativelikeness criterion would
distinguish between L2 and L1 speakers _other than those used for defining the criterion_.
Nonetheless, I think this is precisely what is needed if we are to sensibly interpret such studies.
Let me illustrate.

### Illustration
[Abrahamsson and Hyltenstam](http://dx.doi.org/10.1111/j.1467-9922.2009.00507.x) 
subjected 41 advanced Spanish-speaking learners of L2 Swedish 
as well as 15 native speakers of Swedish to a battery of linguistic tasks.
From these tasks, 14 variables were extracted; the details don't matter much here, 
but you can look them up in the paper (see Table 6 on page 280).
Abrahamsson and Hyltenstam defined the minimum criterion of nativelikeness as the lowest native-speaker result on each measure,
but I'm going to define it as the range of native-speaker results (i.e., between lowest and highest; it doesn't really matter much).

The original raw data aren't available, but I've simulated some placeholder data to illustrate my point.

<small>(For the 15 native speakers, I simulated 14 variables from normal distributions with the same mean as in Abrahamsson & Hyltenstam's Table 6; the standard deviation was estimated by taking the range and dividing it by 4. For the 41 non-native speakers, I simulated the same 14 variables but with generally lower means and larger standard deviations.
None of the variables were systematically correlated.
This simulation obviously represent a huge simplification; life would be easier if people [put their data online]({% post_url 2015-12-14-perks-data-sharing %}).)</small>

Using these simulated data, we can compute the range of the native-speaker results.
Don't be intimidated by the R code, the comments say what it accomplishes, which is really all you need to know.


{% highlight r %}
## Read in data
dat <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/nativelikeness.csv")
str(dat)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	56 obs. of  15 variables:
##  $ Pred1 : int  18 15 17 13 22 21 15 20 18 20 ...
##  $ Pred2 : int  12 17 14 16 16 12 19 13 22 14 ...
##  $ Pred3 : int  18 11 16 15 20 14 20 18 18 14 ...
##  $ Pred4 : int  -5 11 0 -3 2 -9 2 7 16 6 ...
##  $ Pred5 : int  19 11 21 8 20 24 13 9 14 19 ...
##  $ Pred6 : int  29 22 21 24 19 24 28 27 19 21 ...
##  $ Pred7 : int  -10 -8 -5 -9 -8 -6 -8 -7 -4 -2 ...
##  $ Pred8 : int  16 15 16 17 16 17 17 16 16 15 ...
##  $ Pred9 : int  73 74 70 64 70 72 64 76 63 63 ...
##  $ Pred10: int  71 70 74 67 73 65 73 66 72 66 ...
##  $ Pred11: int  7852 6977 7246 7768 8106 8457 7680 8156 7672 8417 ...
##  $ Pred12: int  38 34 35 33 36 35 36 37 33 36 ...
##  $ Pred13: int  45 41 45 42 46 40 36 38 39 48 ...
##  $ Pred14: int  41 40 36 36 40 41 41 44 38 36 ...
##  $ Class : Factor w/ 2 levels "L1 speaker","L2 speaker": 1 1 1 1 1 1 1 1 1 1 ...
{% endhighlight %}



{% highlight r %}
## Load packages
library(magrittr) # for piping (%>% below)
library(dplyr)    # for working with dataframes

## Retain L1 speakers
dat.L1 <- dat %>%
  filter(Class == "L1 speaker")
## Compute minimum and maximum for numeric data
min.L1 <- dat.L1 %>%
  summarise_if(is.numeric, min)
max.L1 <- dat.L1 %>%
  summarise_if(is.numeric, max)
{% endhighlight %}

We can then take a look at the L2 speakers' results and filter out the L2 speakers
whose results aren't all within the native speakers' range:


{% highlight r %}
## Retain L2 speakers
dat.L2 <- dat %>% filter(Class == "L2 speaker")

## Retain only L2 speakers whose results lie within L1 speakers' range
dat.nativelikeL2 <- dat.L2 %>%
  filter(Pred1 >= min.L1[[1]], Pred1 <= max.L1[[1]]) %>%
  filter(Pred2 >= min.L1[[2]], Pred2 <= max.L1[[2]]) %>%
  filter(Pred3 >= min.L1[[3]], Pred3 <= max.L1[[3]]) %>%
  filter(Pred4 >= min.L1[[4]], Pred4 <= max.L1[[4]]) %>%
  filter(Pred5 >= min.L1[[5]], Pred5 <= max.L1[[5]]) %>%
  filter(Pred6 >= min.L1[[6]], Pred6 <= max.L1[[6]]) %>%
  filter(Pred7 >= min.L1[[7]], Pred7 <= max.L1[[7]]) %>%
  filter(Pred8 >= min.L1[[8]], Pred8 <= max.L1[[8]]) %>%
  filter(Pred9 >= min.L1[[9]], Pred9 <= max.L1[[9]]) %>%
  filter(Pred10 >= min.L1[[10]], Pred10 <= max.L1[[10]]) %>%
  filter(Pred11 >= min.L1[[11]], Pred11 <= max.L1[[11]]) %>%
  filter(Pred12 >= min.L1[[12]], Pred12 <= max.L1[[12]]) %>%
  filter(Pred13 >= min.L1[[13]], Pred13 <= max.L1[[13]]) %>%
  filter(Pred14 >= min.L1[[14]], Pred14 <= max.L1[[14]])
dat.nativelikeL2 %>% nrow()
{% endhighlight %}



{% highlight text %}
## [1] 0
{% endhighlight %}



{% highlight r %}
## = empty dataset
{% endhighlight %}

Sure enough, none of the L2 learners classify as nativelike. 
With more realistic data, a handful probably would have, cf. Abrahamsson & Hyltenstam's results.

By contrast, and quite obviously, all fifteen native speakers are classified as nativelike:


{% highlight r %}
dat.L1 %>%
  filter(Pred1 >= min.L1[[1]], Pred1 <= max.L1[[1]]) %>%
  filter(Pred2 >= min.L1[[2]], Pred2 <= max.L1[[2]]) %>%
  filter(Pred3 >= min.L1[[3]], Pred3 <= max.L1[[3]]) %>%
  filter(Pred4 >= min.L1[[4]], Pred4 <= max.L1[[4]]) %>%
  filter(Pred5 >= min.L1[[5]], Pred5 <= max.L1[[5]]) %>%
  filter(Pred6 >= min.L1[[6]], Pred6 <= max.L1[[6]]) %>%
  filter(Pred7 >= min.L1[[7]], Pred7 <= max.L1[[7]]) %>%
  filter(Pred8 >= min.L1[[8]], Pred8 <= max.L1[[8]]) %>%
  filter(Pred9 >= min.L1[[9]], Pred9 <= max.L1[[9]]) %>%
  filter(Pred10 >= min.L1[[10]], Pred10 <= max.L1[[10]]) %>%
  filter(Pred11 >= min.L1[[11]], Pred11 <= max.L1[[11]]) %>%
  filter(Pred12 >= min.L1[[12]], Pred12 <= max.L1[[12]]) %>%
  filter(Pred13 >= min.L1[[13]], Pred13 <= max.L1[[13]]) %>%
  filter(Pred14 >= min.L1[[14]], Pred14 <= max.L1[[14]]) %>%
  nrow()
{% endhighlight %}



{% highlight text %}
## [1] 15
{% endhighlight %}

This comes as no surprise: the nativelikeness criterion was based on these speakers' scores,
so of course they should pass it with flying colours.

But what happens when we test a new sample of native speakers _using the old nativelikeness criterion_?
I simulated data for another 10,000 native speakers using the same procedure I used to create the first 15 native speakers' data.



{% highlight r %}
## Read in data for *new* L1 speakers
new.L1 <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/new_nativelikeness.csv")
str(new.L1)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	10000 obs. of  14 variables:
##  $ Pred1 : int  14 15 21 17 17 18 18 17 23 18 ...
##  $ Pred2 : int  14 18 16 12 16 15 15 10 15 15 ...
##  $ Pred3 : int  17 18 14 16 23 13 20 21 22 21 ...
##  $ Pred4 : int  1 21 -17 3 -2 1 7 0 -1 16 ...
##  $ Pred5 : int  23 15 14 12 11 15 6 14 17 20 ...
##  $ Pred6 : int  24 24 26 26 26 29 17 29 24 25 ...
##  $ Pred7 : int  -10 -6 -8 -6 -10 -3 -6 -8 -6 -9 ...
##  $ Pred8 : int  16 13 15 14 17 17 15 14 18 16 ...
##  $ Pred9 : int  64 77 69 64 66 73 67 70 71 66 ...
##  $ Pred10: int  67 73 70 63 74 74 75 62 66 75 ...
##  $ Pred11: int  7159 8098 8344 7113 7142 7808 7388 8062 8124 7864 ...
##  $ Pred12: int  38 32 28 32 38 32 39 38 35 31 ...
##  $ Pred13: int  41 42 44 49 40 37 44 47 43 52 ...
##  $ Pred14: int  36 38 38 40 36 45 41 40 43 39 ...
{% endhighlight %}



{% highlight r %}
## Retain only participants whose results lie within *original* L1 speakers' range
new.L1 %>%
  filter(Pred1 >= min.L1[[1]], Pred1 <= max.L1[[1]]) %>%
  filter(Pred2 >= min.L1[[2]], Pred2 <= max.L1[[2]]) %>%
  filter(Pred3 >= min.L1[[3]], Pred3 <= max.L1[[3]]) %>%
  filter(Pred4 >= min.L1[[4]], Pred4 <= max.L1[[4]]) %>%
  filter(Pred5 >= min.L1[[5]], Pred5 <= max.L1[[5]]) %>%
  filter(Pred6 >= min.L1[[6]], Pred6 <= max.L1[[6]]) %>%
  filter(Pred7 >= min.L1[[7]], Pred7 <= max.L1[[7]]) %>%
  filter(Pred8 >= min.L1[[8]], Pred8 <= max.L1[[8]]) %>%
  filter(Pred9 >= min.L1[[9]], Pred9 <= max.L1[[9]]) %>%
  filter(Pred10 >= min.L1[[10]], Pred10 <= max.L1[[10]]) %>%
  filter(Pred11 >= min.L1[[11]], Pred11 <= max.L1[[11]]) %>%
  filter(Pred12 >= min.L1[[12]], Pred12 <= max.L1[[12]]) %>%
  filter(Pred13 >= min.L1[[13]], Pred13 <= max.L1[[13]]) %>%
  filter(Pred14 >= min.L1[[14]], Pred14 <= max.L1[[14]]) %>%
  nrow()
{% endhighlight %}



{% highlight text %}
## [1] 1048
{% endhighlight %}

Only 1048 of the 10,000 new native speakers pass the nativelikeness criterion!
And these 10,000 new native speakers were sampled from the _exact same_ population as the 
fifteen speakers used to establish the nativelikeness criterion---factors that would matter in
real life such as social status, age, region, linguistic background, and what not don't matter here;
these would only make matters worse (see this [paper](http://dare.uva.nl/document/2/148989) on the selection of native-speaker controls by Sible Andringa).

Clearly, **the finding that none of the L2 speakers are classified as nativelike carries considerably less weight now that we know that most L1 speakers wouldn't have, either**.
Such information about the error rate associated with the nativelikeness criterion is therefore
crucial to properly interpret studies relying on such a criterion.
In practice, the bias against being classified as nativelike may not be huge as in this simulated example, but without an error-rate estimate (or access to the raw data), we've no way of knowing.

### Estimating error rates using classification algorithms
If researchers want to classify L2 learners as nativelike or non-nativelike
and sensibly interpret their results,
I suggest they stop defining nativelikeness criteria as intervals based on native speakers' scores.
Instead, they can turn to tools developed in a field specialised in such matters: **machine learning**, or **predictive modelling**.
There's an astounding number of algorithms out there
that were developed for taking a set of predictor variables (e.g., task scores) 
on the one hand and a
set of class labels (e.g., _L1 speaker_ vs. _L2 speaker_) on the other hand,
deriving a classification model from these data,
and estimating the error rate of the classifications.

I won't provide a detailed introduction---Kuhn & Johnson's [_Applied Predictive Modeling_](http://appliedpredictivemodeling.com/) seems excellent---but I'll just illustrate one such classification algorithm, **random forests**.
In fact, the precise workings of this algorithm, which was developed in 2001 by Leo Breiman, needn't really concern us here---you can read about them [from the horse's mouth](http://projecteuclid.org/euclid.ss/1009213726), so to speak, 
in my [thesis](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Diss/VanhoveJ.pdf#subsection.9.3.2),
or in tutorials by [Tagliamonte & Baayen](http://dx.doi.org/10.1017/S0954394512000129) or 
[Strobl and colleagues](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2927982/).
What's important is that it often produces **excellent classification models**
and that it computes an **error-rate estimate** as a matter of course.

The `randomForest` function in the `randomForest` package implements the algorithm.
There are a couple of settings that the user can tweak; again these needn't concern us here---you
can read about these in the articles referred to above.














{% highlight r %}
## Load the randomForest package;
## you may need to run 'install.packages("randomForest")' first.
library(randomForest)

## Random forest have built-in random variability;
## by setting the random seed, you'll get the same result as me.
## You can try setting a different seed or not setting one
## and see what happens
set.seed(5-7-2016)

## Use a random forest to predict Class (L1 vs. L2 speaker)
## by means of all other variables in the dataset.
nativelike.rf <- randomForest(Class ~ ., data = dat)

## Output, including confusion matrix
nativelike.rf
{% endhighlight %}



{% highlight text %}
## 
## Call:
##  randomForest(formula = Class ~ ., data = dat) 
##                Type of random forest: classification
##                      Number of trees: 500
## No. of variables tried at each split: 3
## 
##         OOB estimate of  error rate: 12.5%
## Confusion matrix:
##            L1 speaker L2 speaker class.error
## L1 speaker         10          5  0.33333333
## L2 speaker          2         39  0.04878049
{% endhighlight %}

The output shows the estimated classification error 
that was computed on the basis of the original (simulated) data with
15 L1 and 41 L2 speakers (`OBB estimate of error rate`):
an estimated 12.5% of observations will be misclassified by this algorithm.
With more data (more observations, more predictors, more reliable predictors),
this estimated error rate may become more accurate.

More interesting for our present purposes is the confusion matrix:
The algorithm wrongly classifies two out of 41 L2 speakers as L1 speakers---these could perhaps be considered to have passed an updated 'nativelikeness criterion' inasmuch as they 'fooled' the algorithm.
**But it also misclassifies 5 of the 15 L1 speakers as L2 speakers.**
In this case, then, the 5% 'nativelikeness incidence' among L2 speakers may be an underestimate, as the algorithm seems to be biased against classifying participants as L1 speakers.
This is likely due to the **imbalance** in the data: there are about 3 times more L2 than L1 speakers, so the algorithm naturally defaults to L2 speakers.
(Take-home message if you want to conduct a study on nativelikeness: include more native speakers.)

The same random forest can also be applied to the 10,000 new L1 speakers,
which gives a better estimate of how much the odds are stacked against classifying
a participant as an L1 speaker:


{% highlight r %}
new.predictions <- predict(nativelike.rf, newdata = new.L1)
summary(new.predictions)
{% endhighlight %}



{% highlight text %}
## L1 speaker L2 speaker 
##       7787       2213
{% endhighlight %}

While the random forest doesn't classify all L1 speakers in the original control sample as L1 speakers (as the naïve nativelikeness procedure did),
it performs much better on new L1 data, classifying 78% of new L1 speakers as L1 speakers.
Evidently, in a real study, we wouldn't have a sample of 10,000 participants on the side to check the estimated classification error rate.


### Conclusions
1. By using common definitions of nativelikeness criteria, L2 acquisition studies are likely to stack the odds against findings of nativelikeness and yield generally uninterpretable results.  

2. Random forests and other classification algorithms will yield
considerably **better classifications** than ad-hoc criteria, but they may be far from perfect.
Their **imperfection**, unlike that of ad-hoc criteria, can be quantified, however, which is crucial for interpreting the results.  

3. You're unlikely to learn about such algorithms in an introductory course to statistics,
but it's useful to **simply know that they exist**. 
This is how you build up your statistical toolbox:
when you know that these tools exist and have a vague sense of what they're for, 
you can brush up on them when you need them. 
There's a world beyond _t_-tests, ANOVA and Pearson's _r_.  






### Package versions etc.

{% highlight r %}
devtools::session_info(c("magrittr", "dplyr", "randomForest"))
{% endhighlight %}



{% highlight text %}
## Session info --------------------------------------------------------------
{% endhighlight %}



{% highlight text %}
##  setting  value                       
##  version  R version 3.3.1 (2016-06-21)
##  system   x86_64, linux-gnu           
##  ui       RStudio (0.99.491)          
##  language en_US                       
##  collate  en_US.UTF-8                 
##  tz       Europe/Zurich               
##  date     2016-07-05
{% endhighlight %}



{% highlight text %}
## Packages ------------------------------------------------------------------
{% endhighlight %}



{% highlight text %}
##  package      * version  date       source        
##  assertthat     0.1      2013-12-06 CRAN (R 3.3.0)
##  BH             1.60.0-2 2016-05-07 CRAN (R 3.3.0)
##  DBI            0.4-1    2016-05-08 CRAN (R 3.3.0)
##  dplyr        * 0.5.0    2016-06-24 CRAN (R 3.3.1)
##  lazyeval       0.1.10   2015-01-02 CRAN (R 3.3.0)
##  magrittr     * 1.5      2014-11-22 CRAN (R 3.3.0)
##  R6             2.1.2    2016-01-26 CRAN (R 3.3.0)
##  randomForest * 4.6-12   2015-10-07 CRAN (R 3.3.0)
##  Rcpp           0.12.5   2016-05-14 CRAN (R 3.3.0)
##  tibble         1.1      2016-07-04 CRAN (R 3.3.1)
{% endhighlight %}

