---
layout: post
title: "The problem with cutting up continuous variables and what to do when things aren't linear"
thumbnail: /figs/thumbnails/blank.png
category: [analysis]
tags: [power, generalised additive models, non-linarities]
---

A common analytical technique is to cut up continuous variables (e.g. age, word frequency, L2 proficiency) into discrete categories and then use them as predictors in a group comparison (e.g. ANOVA). 
For instance, stimuli used in a lexical decision task are split up into a high-frequency and a low-frequency group, whereas the participants are split up into a young, middle, and old group. 
Although discretising continuous variables appears to make the analysis easier, this practice has been criticised for years. 
Below I outline the problems with this approach and present some alternatives.

<!--more-->

### Problem 1: Loss of information and its consequences
The problem with discretising continuous variables is that it throws away meaningful information. 
This loss of information is most pronounced in the case of dichotomisation (carving up a continuous variable into two levels).
When splitting up words into a high- and a low-frequency group, 
within-group information about relative frequency differences is lost -- extremely frequent words and somewhat frequent words are treated as though they had the same frequency.
Doing so leads to an appreciable **loss of power**, i.e. a decrease in the probability of finding a pattern if there really is one 
([Altman & Royston 2006](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1458573/); 
[Cohen 1983](http://www.unc.edu/~rcm/psy282/cohen.1983.pdf); 
[MacCullum et al. 2002](http://www.psychology.sunysb.edu/attachment/measures/content/maccallum_on_dichotomizing.pdf); 
[Royston, Altman & Sauerbrei 2006](http://www-psychology.concordia.ca/fac/kline/734/royston.pdf)): 
[Cohen 1983](http://www.unc.edu/~rcm/psy282/cohen.1983.pdf) shows that carving up a continuous variable into two groups is akin to throwing away a third of the data. 
Paradoxically, dichotomisation can sometimes lead to a simultaneous **increase of false positives**, 
i.e. finding a pattern where there is in fact none 
([Maxwell & Delaney 1993](http://www.researchgate.net/profile/Harold_Delaney/publication/232580560_Bivariate_median_splits_and_spurious_statistical_significance/links/550065790cf2d61f820d6f93.pdf)) -- a statistical double whammy.

### Problem 2: Spurios threshold effects
Furthermore, discretisation draws categorical boundaries where none exist and may thereby **spuriously suggest the presence of cut-offs or threshold effects**
(e.g. [Altman & Royston 2006](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1458573/); 
[Vanhove 2013](http://dx.doi.org/10.1371/journal.pone.0069172)). 
For instance, by grouping 20- to 29-year-olds in one category and 30- to 39-year-olds in another, 
we create the impression that 20- and 29-year-olds tend to be more alike than 29- and 30-year-olds. 
If the outcome variable differs between the groups, it might even be tempting to conclude that some important change occurred in the 30th year.
I suspect -- I _hope_ -- that the researchers themselves are aware that such a sudden change is entirely due to their arbitrary cut-off choices,
but these details tend to get lost in citation,
and I wonder to what extent threshold theories in language acquisition owe their existence to continuous predictors being squeezed into the ANOVA straitjacket.

### Solutions

#### When the pattern is more or less linear
With the authors cited above, I agree that the best solution is usually to stop carving up continuous phenomena into discrete categories and to instead exploit the continuous data to the full in a **linear regression** analysis 
(see [Baayen 2010](http://www.sfs.uni-tuebingen.de/~hbaayen/publications/baayenML2010matching.pdf), 
and [Vanhove 2013](http://dx.doi.org/10.1371/journal.pone.0069172) for linguistic examples). 
Sometimes, however, the data suggest a non-linear trend that is less easily accommodated in a linear regression model. I turn to such cases next.

#### When the pattern is non-linear
A more sophisticated rationale for carving up a continuous predictor is that the relationship between the predictor and the outcome is not approximately linear. 
By way of example, Figure 1 shows how the performance on some test varies according to the participants’ age (data from [Vanhove & Berthele 2015](http://dx.doi.org/10.1515/iral-2015-0001),
available [here](http://homeweb.unifr.ch/VanhoveJ/Pub/Data/participants_163.csv)). 
What the data mean is of less importance for our present purposes; 
what is important is that the scatterplot highlights a non-linear trend.

![center](/figs/2015-10-16-nonlinear-relationships/unnamed-chunk-1-1.png) 

> **Figure 1:** Scatterplot of the original data.


An ordinary correlation analysis or a simple linear regression model would find a small, positive, non-significant age trend. 
But these analyses test the linear trend in the data, which is clearly not relevant in this case.
Dichotomising the age variable by means of a median split does not bring us much closer to a resolution, however: As the boxplots in the left-hand panel of Figure 2 show, a median split completely hides the trend in the data 
(see also [Altman & Royston 2006](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1458573/); 
[MacCullum et al. 2002](http://www.psychology.sunysb.edu/attachment/measures/content/maccallum_on_dichotomizing.pdf)). 
A more fine-grained discretisation, e.g., in slices of ten years, underscores the trend appreciably better as shown in the right-hand panel of Figure 2 (see also [Gelman & Hill 2007](http://www.stat.columbia.edu/~gelman/arm/), pp. 66-68). 
But it also raises a number of questions: What is the optimal number of bins? Where should we draw the cut-offs between the bins? Should every bin be equally as wide? And how much can we fiddle about with these bins without jeopardising our inferential statistics?

![center](/figs/2015-10-16-nonlinear-relationships/unnamed-chunk-2-1.png) 

> **Figure 2.** _Left:_ Boxplots after a median split of the age variable; the age pattern is unrecognisable. 
_Right:_ Boxplots after a more fine-grained discretisation; the non-linear pattern is now recognisible, but the cut-offs between the groups were drawn arbitrarily.

Clearly, it is preferable to side-step such arbitrary decisions. 
Apart from transforming the predictor, the outcome or both,
we can deal with non-linearities by modelling them directly.
There are a couple of options available in this domain
(e.g. [LO(W)ESS](https://en.wikipedia.org/wiki/Local_regression),
[polynomial regression](https://en.wikipedia.org/wiki/Polynomial_regression),
restricted cubic splines);
here I'll briefly demonstrate one of them: **generalised additive modelling**.
It's not my goal to discuss the ins and outs of generalised additive modelling,
but rather to illustrate its use and to direct those interested to more thorough sources.
In doing so, I'll be freely quoting from Section 4.3.2 from my [thesis](http://ethesis.unifr.ch/theses/downloads.php?file=VanhoveJ.pdf).

Generalised additive models (GAMs) are implemented in the `mgcv` package for R.
GAMs estimate the form of the non-linear relationship from the data.
This is essentially accomplished by fitting a kind of regression on subsets of the data and then glueing the different pieces together.
The more subset regression are fitted and glued together, the more 'wiggly' the overall curve will be.
Fitting too many subset regressions results in overwiggly curves that fit disproportionally much noise in the data ('oversmoothing').
To prevent this, the `mgcv` package implements a procedure that estimates the number of subset regression -- and hence the complexity of the overall curve -- that stands the best chance of predicting new data points.
For details, I refer to Chapter 3 in [Zuur et al. (2009)](http://www.highstat.com/book2.htm) and to a tutorial by [Clark (2013)](http://www3.nd.edu/~mclark19/learn/GAMS.pdf) for fairly accessible introductions.
An in-depth treatment is provided by [Wood (2006)](http://people.bath.ac.uk/sw283/igam/index.html).

The following R code reads in the dataset,
plots an unpolished version of the scatterplot in Figure 1 above,
and loads the `mgcv` package.


{% highlight r %}
# Read in data
dat <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/participants_163.csv",
                encoding = "UTF-8")
# Draw scatterplot of Age vs Spoken (not shown)
# plot(Spoken ~ Age, data = dat)

# Load mgcv package;
# run 'install.packages("mgcv")' if not installed:
library(mgcv)
{% endhighlight %}

The GAM is then fitted using the `gam()` function, whose interface is similar to that of the `lm()` function for fitting linear models.
The embedded `s()` function specified that the effect of `Age` should be fitted non-linearly (_s_ for _smoother_).
Plotting the model shows the non-linear age trend and its 95% confidence band:


{% highlight r %}
mod1 <- gam(Spoken ~ s(Age), data = dat)
plot(mod1)
{% endhighlight %}

![center](/figs/2015-10-16-nonlinear-relationships/unnamed-chunk-4-1.png) 

With the `summary()` function, numerical details about the model, including approximate inferential statistics,
can be displayed. See [Clark (2013)](http://www3.nd.edu/~mclark19/learn/GAMS.pdf) for details.


{% highlight r %}
summary(mod1)
{% endhighlight %}



{% highlight text %}
## 
## Family: gaussian 
## Link function: identity 
## 
## Formula:
## Spoken ~ s(Age)
## 
## Parametric coefficients:
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)    16.52       0.32    51.7   <2e-16
## 
## Approximate significance of smooth terms:
##        edf Ref.df    F p-value
## s(Age) 7.4   8.36 15.1  <2e-16
## 
## R-sq.(adj) =  0.429   Deviance explained = 45.5%
## GCV = 17.555  Scale est. = 16.65     n = 163
{% endhighlight %}

All of this is just to give you a flavour of what you can do when you're confronted with non-linear data than can't easily be transformed or fitted with a higher-order polynomials.
GAMs are flexible in that they can incorporate several predictors, non-linear interactions between continuous variables, and random effects, and they can deal with non-Gaussian outcome variables (e.g. binary data), too.

In conclusion, if you have continuous variables, don't throw away useful information and treat them as such.
If a scatterplot reveals an approximately linear pattern, linear regression is the way to go.
If a non-linear pattern emerges, consider fitting a non-linear model.

![center](/figs/2015-10-16-nonlinear-relationships/unnamed-chunk-6-1.png) 

> **Figure 3:** Scatterplot of the original data with a non-linear GAM-based scatterplot smoother and its 95% confidence band.


### R session info
For those interested:


{% highlight r %}
sessionInfo()
{% endhighlight %}



{% highlight text %}
## R version 3.2.2 (2015-08-14)
## Platform: i686-pc-linux-gnu (32-bit)
## Running under: Ubuntu 14.04.3 LTS
## 
## locale:
##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
##  [3] LC_TIME=de_CH.UTF-8        LC_COLLATE=en_US.UTF-8    
##  [5] LC_MONETARY=de_CH.UTF-8    LC_MESSAGES=en_US.UTF-8   
##  [7] LC_PAPER=de_CH.UTF-8       LC_NAME=C                 
##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
## [11] LC_MEASUREMENT=de_CH.UTF-8 LC_IDENTIFICATION=C       
## 
## attached base packages:
## [1] stats     graphics  grDevices utils     datasets  methods   base     
## 
## other attached packages:
## [1] knitr_1.11   mgcv_1.8-7   nlme_3.1-122
## 
## loaded via a namespace (and not attached):
##  [1] magrittr_1.5    Matrix_1.2-2    formatR_1.2.1   htmltools_0.2.6
##  [5] tools_3.2.2     yaml_2.1.13     stringi_0.5-5   splines_3.2.2  
##  [9] rmarkdown_0.8   grid_3.2.2      stringr_1.0.0   digest_0.6.8   
## [13] evaluate_0.8    lattice_0.20-33
{% endhighlight %}

