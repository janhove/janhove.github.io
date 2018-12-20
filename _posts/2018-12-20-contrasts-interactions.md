---
title: "Baby steps in Bayes: Recoding predictors and homing in on specific comparisons"
layout: post
tags: [Bayesian statistics, brms, R, graphics, mixed-effects models, contrast coding]
category: [Analysis]
---

Interpreting models that take into account a host of possible
interactions between predictor variables can be a pain, especially
when some of the predictors contain more than two levels.
In this post, I show how I went about fitting and then making sense
of a multilevel model containing a three-way interaction between
its categorical fixed-effect predictors. To this end, I used
the [`brms`](https://github.com/paul-buerkner/brms) package,
which makes it relatively easy to fit Bayesian models using a notation
that hardly differs from the one used in the popular `lme4` package.
I won't discuss the Bayesian bit much here (I don't think it's too important),
and I will instead cover the following points:

1. How to fit a multilevel model with `brms` using `R`'s default way of handling categorical predictors (treatment coding).
2. How to interpret this model's fixed parameter estimates.
3. How to visualise the modelled effects.
4. How to recode predictors to obtain more useful parameter estimates.
5. How to extract information from the model to home in on specific comparisons.

<!--more-->

## The data
For a longitudinal project, 328 children wrote narrative and argumentative texts
in Portuguese at three points in time. About a third of the children hailed
from Portugal, about a third were children of Portuguese heritage living
in the French-speaking part of Switzerland, and about a third were children
of Portuguese heritage living in the German-speaking part of Switzerland.
Not all children wrote both kinds of texts at all three points in time,
and 1,040 texts were retained for the analysis. For each text, we computed
the Guiraud index, which is a function of the number of words (tokens) and the
number of _different_ words (types) in the texts. Higher values are assumed
to reflect greater diversity in vocabulary use.

If you want to know more about this project, check out Bonvin et al. (2018),
Lambelet et al. (2017a,b) and Vanhove (forthcoming); you'll find the references
at the bottom of this page.

Read in the data:


{% highlight r %}
# Read in data from my webspace and show its structure
d <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/portuguese_guiraud.csv")
str(d)
{% endhighlight %}



{% highlight text %}
## 'data.frame':	1040 obs. of  6 variables:
##  $ Group   : Factor w/ 3 levels "monolingual Portuguese",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Class   : Factor w/ 25 levels "monolingual Portuguese_AI",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ Child   : Factor w/ 328 levels "monolingual Portuguese_AI_1",..: 1 1 1 2 2 2 2 3 3 4 ...
##  $ Time    : Factor w/ 3 levels "T1","T2","T3": 1 1 2 1 1 3 3 1 3 1 ...
##  $ TextType: Factor w/ 2 levels "argumentative",..: 1 2 2 1 2 1 2 2 2 1 ...
##  $ Guiraud : num  4.73 5.83 3.9 4.22 4.57 ...
{% endhighlight %}



{% highlight r %}
summary(d)
{% endhighlight %}



{% highlight text %}
##                     Group                           Class    
##  monolingual Portuguese:360   monolingual Portuguese_AK:104  
##  Portuguese-French     :360   Portuguese-French_Y      : 96  
##  Portuguese-German     :320   monolingual Portuguese_AJ: 93  
##                               monolingual Portuguese_AL: 89  
##                               Portuguese-French_AD     : 82  
##                               monolingual Portuguese_AI: 74  
##                               (Other)                  :502  
##                           Child      Time              TextType  
##  monolingual Portuguese_AI_17:   6   T1:320   argumentative:560  
##  monolingual Portuguese_AJ_16:   6   T2:340   narrative    :480  
##  monolingual Portuguese_AJ_5 :   6   T3:380                      
##  monolingual Portuguese_AK_20:   6                               
##  Portuguese-French_D_3       :   6                               
##  Portuguese-French_Z_2       :   6                               
##  (Other)                     :1004                               
##     Guiraud     
##  Min.   :2.324  
##  1st Qu.:3.928  
##  Median :4.636  
##  Mean   :4.754  
##  3rd Qu.:5.479  
##  Max.   :8.434  
## 
{% endhighlight %}

Let's also plot the data. Incidentally, and contrary to popular belief,
I don't write `ggplot` code such as this from scratch. What you see is
the result of drawing and redrawing (see comments).


{% highlight r %}
# Load tidyverse suite
library(tidyverse)

# Plot Guiraud scores
ggplot(d,
       aes(x = Time,
           y = Guiraud,
           # reorder: sort the Groups by their median Guiraud value
           fill = reorder(Group, Guiraud, median))) +
  # I prefer empty (shape = 1) to filled circles (shape = 16).
  geom_boxplot(outlier.shape = 1) +
  facet_grid(. ~ TextType) +
  # The legend name ("Group") seems superfluous, so suppress it;
  # the default colours contain red and green, which can be hard to
  #  distinguish for some people.
  scale_fill_brewer(name = element_blank(), type = "qual") +
  # I prefer the black and white look to the default grey one.
  theme_bw() +
  # Put the legend at the bottom rather than on the right
  theme(legend.position = "bottom")
{% endhighlight %}

![center](/figs/2018-12-20-contrasts-interactions/unnamed-chunk-2-1.png)

> **Figure 1.** The texts' Guiraud values by time of data collection,
> text type, and language background.

## A multilevel model with treatment coding
Our data are nested: Each child wrote up to 6 texts, and 
the data were collected in classes, with each child belong to one class.
It's advisable to take such nesting into account since you may end
up overestimating your degree of certainty about the results otherwise.
I mostly use `lme4`'s `lmer()` and `glmer()` functions to handle such data,
but as will become clearer in a minute, `brms`'s `brm()` function offers
some distinct advantages. So let's load that package:


{% highlight r %}
library(brms)
{% endhighlight %}

### Fitting the model
We'll fit a model with a three-way fixed-effect interaction between
`Time`, `TextType` and `Group` as well as with by-`Child` and by-`Class`
random intercepts. In order to take into account the possibility that
children vary in the development of their lexical diversity, we add
a random slope of `Time` by `Child`, and in order to take into account
the possibility that their lexical diversity varies by text type, we
do the same for `TextType`. Similarly, we add by-`Class` random slopes
for `Time` and `TextType`.


{% highlight r %}
m_default <- brm(Guiraud ~ Time*TextType*Group +
                   (1 + TextType + Time|Class) +
                   (1 + TextType + Time|Child),
                 data = d)
{% endhighlight %}


### Interpreting the parameter estimates

{% highlight r %}
# Output edited for legibility
summary(m_default)
{% endhighlight %}
<pre><code> Family: gaussian 
  Links: mu = identity; sigma = identity 
Formula: Guiraud ~ Time * TextType * Group + (1 + TextType + Time | Class) + (1 + TextType + Time | Child) 
   Data: d (Number of observations: 1040) 
Samples: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
         total post-warmup samples = 4000

[[...]]

Population-Level Effects: 
                                                Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
Intercept                                           5.25      0.13     5.01     5.51       2151 1.00
TimeT2                                              0.57      0.13     0.30     0.82       2017 1.00
TimeT3                                              0.91      0.14     0.63     1.17       2509 1.00
TextTypenarrative                                  -0.27      0.17    -0.61     0.07       1884 1.00
GroupPortugueseMFrench                             -1.07      0.17    -1.39    -0.73       2131 1.00
GroupPortugueseMGerman                             -1.30      0.16    -1.63    -0.98       2422 1.00
TimeT2:TextTypenarrative                           -0.23      0.16    -0.55     0.08       2295 1.00
TimeT3:TextTypenarrative                           -0.06      0.17    -0.38     0.27       2489 1.00
TimeT2:GroupPortugueseMFrench                      -0.55      0.19    -0.91    -0.18       2508 1.00
TimeT3:GroupPortugueseMFrench                      -0.38      0.19    -0.73     0.01       2790 1.00
TimeT2:GroupPortugueseMGerman                      -0.63      0.18    -0.99    -0.29       2469 1.00
TimeT3:GroupPortugueseMGerman                      -0.22      0.19    -0.61     0.16       2612 1.00
TextTypenarrative:GroupPortugueseMFrench            0.14      0.24    -0.33     0.63       2027 1.00
TextTypenarrative:GroupPortugueseMGerman            0.19      0.23    -0.28     0.66       2348 1.00
TimeT2:TextTypenarrative:GroupPortugueseMFrench     0.36      0.24    -0.10     0.82       2703 1.00
TimeT3:TextTypenarrative:GroupPortugueseMFrench     0.25      0.24    -0.22     0.71       2652 1.00
TimeT2:TextTypenarrative:GroupPortugueseMGerman     0.54      0.25     0.04     1.04       4000 1.00
TimeT3:TextTypenarrative:GroupPortugueseMGerman     0.26      0.25    -0.23     0.74       3065 1.00

Family Specific Parameters: 
      Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
sigma     0.60      0.02     0.55     0.65        459 1.00

[[...]]
</code></pre>

The output looks pretty similar to what we'd obtain when using `lmer()`, 
but let's review what these estimates actually refer to.
By default, `R` uses treatment coding. This entails that the `Intercept`
refers to a specific combination of factors: the combination of all
reference levels. Again by default, the reference levels are chosen
alphabetically:

* `Time` consists of three levels (`T1`, `T2`, `T3`); for alphabetical reasons, `T1` is chosen as the default reference level.
* `Group` also consists of three levels (`monolingual Portuguese`, `Portuguese-French`, `Portuguese-German`); `monolingual Portuguese` is chosen as the default level.
* `TextType` consists of two levels (`argumentative`, `narrative`); `argumentative` is the default reference level.

The `Intercept`, then, shows the modelled mean Guiraud value of `argumentative` texts
written by `monolingual Portuguese` children at `T1`: 5.25.

If you're unsure which factor level was used as the reference level, you can use the `contrasts()` function.
The reference level is the one in whose rows only zeroes occur.


{% highlight r %}
contrasts(d$Group)
{% endhighlight %}



{% highlight text %}
##                        Portuguese-French Portuguese-German
## monolingual Portuguese                 0                 0
## Portuguese-French                      1                 0
## Portuguese-German                      0                 1
{% endhighlight %}

Crucially, all other estimated effects are computed with respect to this
intercept. That is, `TimeT2` (0.57) shows the difference between T1 and T2
_for monolingual Portuguese children writing argumentative texts_.
Similarly, `TimeT3` (0.91) shows the difference between _T1_ and T3
for monolingual Portuguese children writing argumentative texts,
and `TextTypenarrative` (-0.27) shows the difference between 
the mean Guiraud values of argumentative and narrative texts written
by monolingual Portuguese children writing at T1.
The texts written by the Portuguese-German and Portuguese-French bilinguals
don't enter into these estimates.

Now, it's possible to piece together the mean values associated
with each combination of predictor values, but questions such as the following
remain difficult to answer with just these estimates at hand:

* What's the overall difference between T2 and T3 and its uncertainty?
* What's the overall difference between the Guiraud values of texts written by Portuguese-French and Portuguese-German children and its uncertainty?
* ...

We'll tackle these questions in a minute; for now, the point is merely
that the estimated parameters above all refer to highly specific comparisons
that may not be the most relevant.

### Plotting the fitted values and the uncertainty about them
When working with `brms`, it's relatively easy to obtain 
the modelled average outcome value for each combination
of the predictor variables as well as a measure of the uncertainty associated
with them.

First construct a small data frame containing the unique
combinations of predictor variables in our dataset:


{% highlight r %}
d_pred <- d %>% 
  select(Group, Time, TextType) %>% 
  distinct() %>% 
  arrange(Group, Time, TextType)
d_pred
{% endhighlight %}



{% highlight text %}
##                     Group Time      TextType
## 1  monolingual Portuguese   T1 argumentative
## 2  monolingual Portuguese   T1     narrative
## 3  monolingual Portuguese   T2 argumentative
## 4  monolingual Portuguese   T2     narrative
## 5  monolingual Portuguese   T3 argumentative
## 6  monolingual Portuguese   T3     narrative
## 7       Portuguese-French   T1 argumentative
## 8       Portuguese-French   T1     narrative
## 9       Portuguese-French   T2 argumentative
## 10      Portuguese-French   T2     narrative
## 11      Portuguese-French   T3 argumentative
## 12      Portuguese-French   T3     narrative
## 13      Portuguese-German   T1 argumentative
## 14      Portuguese-German   T1     narrative
## 15      Portuguese-German   T2 argumentative
## 16      Portuguese-German   T2     narrative
## 17      Portuguese-German   T3 argumentative
## 18      Portuguese-German   T3     narrative
{% endhighlight %}

If you feed the model (here: `m_default`) and 
the data frame we've just created (`d_pred`) to the `fitted()` function,
it outputs the modelled mean estimate for each combination of
predictor values (`Estimate`), the estimated error of this mean estimate (`Est.Error`),
and a 95% uncertainty interval about the estimate (`Q2.5` and `Q97.5`).
One more thing: The `re_formula = NA` line specifies that we do not want the
variability associated with the by-`Class` and by-`Child` random effects to affect
the estimates and their uncertainty. This is what I typically want.


{% highlight r %}
cbind(
  d_pred, 
  fitted(m_default, 
         newdata = d_pred, 
         re_formula = NA)
  )
{% endhighlight %}

<pre><code>
                    Group Time      TextType Estimate Est.Error     Q2.5    Q97.5
1  monolingual Portuguese   T1 argumentative 5.254257 0.1275708 5.007925 5.511725
2  monolingual Portuguese   T1     narrative 4.988935 0.1736867 4.632209 5.333172
3  monolingual Portuguese   T2 argumentative 5.819746 0.1370042 5.546781 6.096290
4  monolingual Portuguese   T2     narrative 5.320470 0.1830628 4.948748 5.670897
5  monolingual Portuguese   T3 argumentative 6.166700 0.1551590 5.855077 6.460323
6  monolingual Portuguese   T3     narrative 5.843974 0.1869116 5.465407 6.218007
7       Portuguese-French   T1 argumentative 4.189003 0.1138625 3.969089 4.417871
8       Portuguese-French   T1     narrative 4.066947 0.1600089 3.759097 4.394976
9       Portuguese-French   T2 argumentative 4.206893 0.1211772 3.973083 4.454998
10      Portuguese-French   T2     narrative 4.215198 0.1547604 3.912582 4.526929
11      Portuguese-French   T3 argumentative 4.725361 0.1280175 4.483346 4.985827
12      Portuguese-French   T3     narrative 4.796162 0.1575997 4.487911 5.103481
13      Portuguese-German   T1 argumentative 3.949633 0.1023994 3.748789 4.147540
14      Portuguese-German   T1     narrative 3.870226 0.1504619 3.580507 4.159204
15      Portuguese-German   T2 argumentative 3.883007 0.1130342 3.658081 4.099607
16      Portuguese-German   T2     narrative 4.108290 0.1569674 3.804663 4.411843
17      Portuguese-German   T3 argumentative 4.639510 0.1297738 4.387543 4.887834
18      Portuguese-German   T3     narrative 4.759506 0.1483870 4.470633 5.046205
</code></pre>

So where do these estimates and uncertainty intervals come from?
In the Bayesian approach, every model parameter hasn't got just
one estimate but an entire distribution of estimates. Moreover,
everything that _depends_ on model parameters also has an entire
distribution of estimates associated with it. The mean modelled 
outcome values per cell depend on the model parameters, so they, too, 
have entire distributions associated with them.
The `fitted()` function summarises these distributions for us:
it returns their means as `Estimate`, their standard deviations
as `Est.Error` and their 2.5th and 97.5 percentiles as `Q2.5` and `Q97.5`.
If so inclined, you can generate these distributions yourself 
using the `posterior_linpred()` function:


{% highlight r %}
posterior_fit <- posterior_linpred(m_default, newdata = d_pred, re_formula = NA)
dim(posterior_fit)
{% endhighlight %}

This returns matrix of 4000 rows and 18 columns.
4000 is the number of 'post-warmup samples' (see the output of `summary(m_default)`;
18 is the number of combinations of predictor values in `d_pred`.

The first _column_ of `posterior_fit` contains the distribution associated with the first 
_row_ in `d_pred`. If you compute its mean, standard deviation and 2.5th and 97.5th
percentiles, you end up with the same numbers as above:


{% highlight r %}
mean(posterior_fit[, 1])
sd(posterior_fit[, 1])
quantile(posterior_fit[, 1], probs = c(0.025, 0.975))
{% endhighlight %}

Or similarly for the 10th row of `d_pred` (Portuguese-French, T2, narrative):


{% highlight r %}
mean(posterior_fit[, 10])
sd(posterior_fit[, 10])
quantile(posterior_fit[, 10], probs = c(0.025, 0.975))
{% endhighlight %}

At the moment, using `posterior_linpred()` has no added value, but it's good to know
where these numbers come from.

Let's draw a graph showing these modelled averages and the uncertainty about them.
95% uncertainty intervals are typically used, but they may instill dichotomous thinking.
To highlight that such an interval highlights but two points on a continuum, I'm
tempted to add 80% intervals as well:


{% highlight r %}
# Obtain fitted values + uncertainty
fitted_values <- fitted(m_default, newdata = d_pred, re_formula = NA, 
                        # 95% interval: between 2.5th and 97.5th percentile
                        # 80% interval: between 10th and 90th percentile
                        probs = c(0.025, 0.10, 0.90, 0.975))
# Combine fitted values with predictor values
fitted_values <- cbind(d_pred, fitted_values)
fitted_values
{% endhighlight %}
<pre><code>
                    Group Time      TextType Estimate Est.Error     Q2.5      Q10      Q90    Q97.5
1  monolingual Portuguese   T1 argumentative 5.254257 0.1275708 5.007925 5.093502 5.414252 5.511725
2  monolingual Portuguese   T1     narrative 4.988935 0.1736867 4.632209 4.769862 5.207548 5.333172
3  monolingual Portuguese   T2 argumentative 5.819746 0.1370042 5.546781 5.649066 5.992942 6.096290
4  monolingual Portuguese   T2     narrative 5.320470 0.1830628 4.948748 5.091014 5.553054 5.670897
5  monolingual Portuguese   T3 argumentative 6.166700 0.1551590 5.855077 5.966155 6.361068 6.460323
6  monolingual Portuguese   T3     narrative 5.843974 0.1869116 5.465407 5.607795 6.079387 6.218007
7       Portuguese-French   T1 argumentative 4.189003 0.1138625 3.969089 4.042663 4.332786 4.417871
8       Portuguese-French   T1     narrative 4.066947 0.1600089 3.759097 3.862814 4.270945 4.394976
9       Portuguese-French   T2 argumentative 4.206893 0.1211772 3.973083 4.058347 4.360160 4.454998
10      Portuguese-French   T2     narrative 4.215198 0.1547604 3.912582 4.020499 4.407168 4.526929
11      Portuguese-French   T3 argumentative 4.725361 0.1280175 4.483346 4.567181 4.886452 4.985827
12      Portuguese-French   T3     narrative 4.796162 0.1575997 4.487911 4.596159 4.994741 5.103481
13      Portuguese-German   T1 argumentative 3.949633 0.1023994 3.748789 3.815955 4.079486 4.147540
14      Portuguese-German   T1     narrative 3.870226 0.1504619 3.580507 3.673275 4.059239 4.159204
15      Portuguese-German   T2 argumentative 3.883007 0.1130342 3.658081 3.738352 4.023601 4.099607
16      Portuguese-German   T2     narrative 4.108290 0.1569674 3.804663 3.908339 4.309186 4.411843
17      Portuguese-German   T3 argumentative 4.639510 0.1297738 4.387543 4.471301 4.802937 4.887834
18      Portuguese-German   T3     narrative 4.759506 0.1483870 4.470633 4.572786 4.951090 5.046205
</code></pre>


And now for the graph:

{% highlight r %}
# Move all points apart horizontally to reduce overlap
position_adjustment <- position_dodge(width = 0.3)

ggplot(fitted_values,
       aes(x = Time,
           y = Estimate,
           # Sort Groups from low to high
           colour = reorder(Group, Estimate),
           group = Group)) +
  # Move point apart:
  geom_point(position = position_adjustment) +
  # Move lines apart:
  geom_path(position = position_adjustment) +
  # Add 95% intervals; move them apart, too
  geom_linerange(aes(ymin = Q2.5, ymax = Q97.5), size = 0.4,
                 position = position_adjustment) +
  # Add 80% intervals; move them apart, too
  geom_linerange(aes(ymin = Q10, ymax = Q90), size = 0.9,
                 position = position_adjustment) +
  facet_wrap(~ TextType) +
  # Override default colour
  scale_colour_brewer(name = element_blank(), type = "qual") +
  ylab("Modelled mean Guiraud") +
  theme_bw() +
  theme(legend.position = "bottom")
{% endhighlight %}

![center](/figs/2018-12-20-contrasts-interactions/unnamed-chunk-14-1.png)

> **Figure 2.** The modelled mean Guiraud values and their uncertainty (thick vertical lines: 80% interval; thin vertical lines: 95% interval).

## A model with more sensible coding

### Tailoring the coding of categorical predictors to the research questions
The `summary()` output for `m_default` was difficult to interpret because
treatment coding was used. However, we can override this default behaviour to
end up with estimates that are more readily and more usefully interpretable.

The first thing we can do is to override the default refence level.
Figure 1 showed that the Guiraud values at T2 tend to be somewhere midway
between those at T1 and T3, so we can make the intercept estimate more
representative of the dataset as a whole by making T2 the reference level
of `Time` rather than T1. A benefit of doing so is that we will now have
two parameters, `TimeT1` and `TimeT3` that specify the difference
between T1-T2 and T2-T3, respectively. In other words, the estimated parameters
will directly reflect the progression from data collection to data collection.
(Before, the parameter estimates specified the differences between T1-T2 and _T1_-T3,
so a direct estimate for T2-T3 was lacking.)


{% highlight r %}
# Set T2 as default time; retain treatment coding
d$Time <- relevel(d$Time, "T2")
{% endhighlight %}

Second, there's no reason for preferring `argumentative` or `narrative` texts
as the reference level. If we sum-code this predictor, the intercept reflects
the _grand mean_ of the argumentative and narrative texts (at T2), and the estimated
parameter then specifies how far the mean Guiraud value of each text type 
is removed from this mean:


{% highlight r %}
# Sum (or deviation) coding for TextType (2 levels)
contrasts(d$TextType) <- contr.sum(2)
{% endhighlight %}

Similarly, there are a couple of reasonable ways to choose the reference
level for `Group` when using treatment coding. But you can also sum-code
this predictor so that the intercept reflects the grand mean of the Guiraud
values of texts written by monolingual Portuguese and bilingual Portuguese-French
and Portuguese-German kids (at T2).


{% highlight r %}
# Sum (or deviation) coding for Group (3 levels)
contrasts(d$Group) <- contr.sum(3)
{% endhighlight %}

### Refitting the model
No difference here.


{% highlight r %}
m_recoded <- brm(Guiraud ~ Time*TextType*Group +
                   (1 + TextType + Time|Class) +
                   (1 + TextType + Time|Child),
                 data = d)
{% endhighlight %}

### Interpreting the parameter estimates

{% highlight r %}
# Output edited for legibility
summary(m_recoded)
{% endhighlight %}
<pre><code> Family: gaussian 
  Links: mu = identity; sigma = identity 
Formula: Guiraud ~ Time * TextType * Group + (1 + TextType + Time | Class) + (1 + TextType + Time | Child) 
   Data: d (Number of observations: 1040) 
Samples: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
         total post-warmup samples = 4000

[[...]]

Population-Level Effects: 
                        Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
Intercept                   4.59      0.06     4.47     4.72       1809 1.00
TimeT1                     -0.21      0.06    -0.32    -0.09       2735 1.00
TimeT3                      0.56      0.06     0.44     0.68       2411 1.00
TextType1                   0.05      0.05    -0.05     0.14       1617 1.00
Group1                      0.98      0.10     0.78     1.17       1426 1.00
Group2                     -0.38      0.09    -0.55    -0.19       1332 1.00
TimeT1:TextType1            0.03      0.05    -0.07     0.14       2685 1.00
TimeT3:TextType1           -0.02      0.05    -0.12     0.07       2595 1.00
TimeT1:Group1              -0.24      0.09    -0.41    -0.07       1801 1.00
TimeT3:Group1              -0.13      0.09    -0.31     0.06       1986 1.00
TimeT1:Group2               0.12      0.09    -0.05     0.29       1899 1.00
TimeT3:Group2              -0.01      0.09    -0.18     0.17       2104 1.00
TextType1:Group1            0.21      0.07     0.07     0.34       1446 1.00
TextType1:Group2           -0.04      0.06    -0.17     0.08       1495 1.00
TimeT1:TextType1:Group1    -0.15      0.07    -0.29    -0.01       2201 1.00
TimeT3:TextType1:Group1    -0.07      0.07    -0.20     0.06       2206 1.00
TimeT1:TextType1:Group2     0.03      0.07    -0.11     0.17       2437 1.00
TimeT3:TextType1:Group2    -0.01      0.07    -0.14     0.12       2353 1.00

Family Specific Parameters: 
      Estimate Est.Error l-95% CI u-95% CI Eff.Sample Rhat
sigma     0.60      0.02     0.55     0.65        433 1.01

[[...]]
</code></pre>

Now the `Intercept` reflects the grand mean of the Guiraud values for
both argumentative and narrative texts for all three groups **written at T2**.
The `TimeT1` estimate (-0.21) shows the difference between T1 and T2
averaged over all text types and all groups (0.21 points worse at T1);
the `TimeT3` estimate (0.56) shows the difference between T2 and T3
averaged over all text types and all groups (0.56 points better at T3).

`TextType1` (0.05) shows that the mean Guiraud value of one text type (still written at T2!)
averaged over all groups is 0.05 points higher than the grand mean; and by
implication that the mean Guiraud value of the other text type is 0.05 lower than the grand mean.
To find out which text type is which, use `contrasts()`:


{% highlight r %}
contrasts(d$TextType)
{% endhighlight %}



{% highlight text %}
##               [,1]
## argumentative    1
## narrative       -1
{% endhighlight %}

Since `argumentative` is coded as 1, it's the argumentative texts that have
the higher Guiraud values at T2.

Similarly, `Group1` (0.98) shows that one group has higher-than-average Guiraud values
averaged across text types at T2, whereas `Group2` (-0.38) shows that another group
has a mean Guiraud value that lies 0.38 points below the average at T2. By implication,
the third group's mean Guiraud value lies 0.60 points below average ((0.98-0.38-0.60)/3 = 0).
To see which group is which,  use `contrasts()`:


{% highlight r %}
contrasts(d$Group)
{% endhighlight %}



{% highlight text %}
##                        [,1] [,2]
## monolingual Portuguese    1    0
## Portuguese-French         0    1
## Portuguese-German        -1   -1
{% endhighlight %}

`monolingual Portuguese` is '1' for the purposes of `Group1`, `Portuguese-French` is `1` for
the purposes of `Group2`, and `Portuguese-German` is the third group.

We can double-check these numbers by generating the modelled mean values
for each predictor value combination:


{% highlight r %}
double_check <- cbind(
  d_pred, 
  fitted(m_recoded, 
         newdata = d_pred, 
         re_formula = NA)
  )
double_check
{% endhighlight %}

<pre><code>                    Group Time      TextType Estimate Est.Error     Q2.5    Q97.5
1  monolingual Portuguese   T1 argumentative 5.256561 0.1478317 4.972034 5.555039
2  monolingual Portuguese   T1     narrative 4.989113 0.1653303 4.658477 5.300454
3  monolingual Portuguese   T2 argumentative 5.825202 0.1429521 5.548448 6.111764
4  monolingual Portuguese   T2     narrative 5.317109 0.1593537 4.999305 5.632874
5  monolingual Portuguese   T3 argumentative 6.168232 0.1693523 5.840185 6.509393
6  monolingual Portuguese   T3     narrative 5.843890 0.1743146 5.499537 6.185465
7       Portuguese-French   T1 argumentative 4.186961 0.1300522 3.932579 4.443590
8       Portuguese-French   T1     narrative 4.057777 0.1628389 3.740767 4.376938
9       Portuguese-French   T2 argumentative 4.210701 0.1241935 3.974560 4.464941
10      Portuguese-French   T2     narrative 4.205977 0.1419996 3.941287 4.500929
11      Portuguese-French   T3 argumentative 4.730486 0.1375478 4.471109 5.013081
12      Portuguese-French   T3     narrative 4.790799 0.1532786 4.492967 5.097257
13      Portuguese-German   T1 argumentative 3.949099 0.1160846 3.718169 4.177300
14      Portuguese-German   T1     narrative 3.874875 0.1450871 3.590572 4.162969
15      Portuguese-German   T2 argumentative 3.876068 0.1162319 3.643204 4.101122
16      Portuguese-German   T2     narrative 4.111929 0.1464768 3.823828 4.393865
17      Portuguese-German   T3 argumentative 4.630554 0.1345938 4.361076 4.890592
18      Portuguese-German   T3     narrative 4.750127 0.1408441 4.470444 5.026297
</code></pre>

Some sanity checks:

(1) Intercept = 4.59 = grand mean at T2:


{% highlight r %}
double_check %>% 
  filter(Time == "T2") %>% 
  summarise(mean_est = mean(Estimate))
{% endhighlight %}



{% highlight text %}
##   mean_est
## 1 4.591164
{% endhighlight %}

(2) TimeT3 = 0.56 = T2/T3 difference across texts and groups:


{% highlight r %}
double_check %>% 
  group_by(Time) %>% 
  summarise(mean_est = mean(Estimate)) %>% 
  spread(Time, mean_est) %>% 
  summarise(diff_T2T3 = T3 - T2)
{% endhighlight %}



{% highlight text %}
## # A tibble: 1 x 1
##   diff_T2T3
##       <dbl>
## 1     0.561
{% endhighlight %}

(3) Portuguese-German lies 0.60 below average at T2 across texts:


{% highlight r %}
double_check %>% 
  filter(Time == "T2") %>% 
  group_by(Group) %>% 
  summarise(mean_est = mean(Estimate)) %>% 
  mutate(diff_mean = mean_est - mean(mean_est))
{% endhighlight %}



{% highlight text %}
## # A tibble: 3 x 3
##   Group                  mean_est diff_mean
##   <fct>                     <dbl>     <dbl>
## 1 monolingual Portuguese     5.57     0.980
## 2 Portuguese-French          4.21    -0.383
## 3 Portuguese-German          3.99    -0.597
{% endhighlight %}

I won't plot the modelled averages and their uncertainty, because the result
will be the same as before: Recoding the predictors in this way doesn't affect
the modelled averages per cell; it just makes the summary output easier to parse.

### Homing in on specific comparisons
Finally, let's see how we can target some specific comparisons without
having to refit the model several times. A specific comparison you might be
interested in could be "How large is the difference in Guiraud scores
for narrative texts written by Portuguese-French bilinguals between T1 and T2?"
Or a more complicated one: "How large is the difference in the progression from T1 to T3 for 
argumentative texts between Portuguese-French and Portuguese-German children?"

To answer such questions, we need to generate the distribution of the 
modelled averages per predictor value combination:


{% highlight r %}
posterior_fit <- posterior_linpred(m_recoded, newdata = d_pred, re_formula = NA)
{% endhighlight %}



#### Question 1: Progression T1-T2 for narrative texts, Portuguese-French bilinguals?
This question requires us to compare the modelled average
for narrative texts written by Portuguese-French bilinguals at T2
to that of the narrative texts written by Portuguese-French bilinguals at T1.
The first combination of predictor values can be found in row 10 in `d_pred`,
so the corresponding estimates are in _column_ 10 in `posterior_fit`.
The second combination of predictor values can be found in row 8 in `d_pred`,
so the corresponding estimates are in _column_ 8 in `posterior_fit`.


{% highlight r %}
t2 <- posterior_fit[, 10]
t1 <- posterior_fit[, 8]
df <- data.frame(t2, t1)
{% endhighlight %}

Now compute and plot the pairwise differences:


{% highlight r %}
df <- df %>% 
  mutate(progression = t2 - t1)
ggplot(df,
       aes(x = progression)) +
  geom_histogram(bins = 50, fill = "lightgrey", colour = "black") +
  theme_bw()
{% endhighlight %}

![center](/figs/2018-12-20-contrasts-interactions/unnamed-chunk-30-1.png)

> **Figure 3.** Estimate of the progression in Guiraud values for narrative texts by Portuguese-French bilinguals from T1 to T2.

The mean progression is easily calculated:


{% highlight r %}
mean(df$progression)
{% endhighlight %}



{% highlight text %}
## [1] 0.1482
{% endhighlight %}

The estimated error for this estimate is:


{% highlight r %}
sd(df$progression)
{% endhighlight %}



{% highlight text %}
## [1] 0.1515133
{% endhighlight %}

And its 95% uncertainty interval is:


{% highlight r %}
quantile(df$progression, probs = c(0.025, 0.975))
{% endhighlight %}



{% highlight text %}
##       2.5%      97.5% 
## -0.1520790  0.4435008
{% endhighlight %}

According to the model, there's about a 84% chance that
there's indeed some progression going from T1 to T2.


{% highlight r %}
mean(df$progression > 0)
{% endhighlight %}



{% highlight text %}
## [1] 0.83875
{% endhighlight %}


#### Question 2: T1-T3 progression for argumentative texts, Portuguese-French vs. Portuguese-German?

This question requires us to take into consideration the modelled average
for argumentative texts written by Portuguese-French bilinguals at T1,
that for argumentative texts written by Portuguese-French bilinguals at T3,
and the same for the texts written by Portuguese-German bilinguals.
We need the following columns in `posterior_fit`:

* 7 (Portuguese-French, T1, argumentative)
* 11 (Portuguese-French, T3, argumentative)
* 13 (Portuguese-German, T1, argumentative)
* 17 (Portuguese-German, T3, argumentative)


{% highlight r %}
fr_t1 <- posterior_fit[, 7]
fr_t3 <- posterior_fit[, 11]
gm_t1 <- posterior_fit[, 13]
gm_t3 <- posterior_fit[, 17]
df <- data.frame(fr_t1, fr_t3, gm_t1, gm_t3)
{% endhighlight %}

We compute the progression for the Portuguese-French bilinguals
and that for the Portuguese-German bilinguals. Then we compute the difference
between these progressions:


{% highlight r %}
df <- df %>% 
  mutate(prog_fr = fr_t3 - fr_t1,
         prog_gm = gm_t3 - gm_t1,
         diff_prog = prog_gm - prog_fr)
{% endhighlight %}

The mean progression for the Portuguese-French bilinguals was 0.54
compared to 0.68 for the Portuguese-German bilinguals:


{% highlight r %}
mean(df$prog_fr)
{% endhighlight %}



{% highlight text %}
## [1] 0.5435248
{% endhighlight %}



{% highlight r %}
mean(df$prog_gm)
{% endhighlight %}



{% highlight text %}
## [1] 0.6814545
{% endhighlight %}

The mean difference between these progressions, then, is 0.14 in favour
of the Portuguese-German bilinguals:


{% highlight r %}
mean(df$diff_prog)
{% endhighlight %}



{% highlight text %}
## [1] 0.1379297
{% endhighlight %}

However, there is considerable uncertainty about this difference:


{% highlight r %}
ggplot(df,
       aes(x = diff_prog)) +
  geom_histogram(bins = 50, fill = "lightgrey", colour = "black") +
  theme_bw()
{% endhighlight %}

![center](/figs/2018-12-20-contrasts-interactions/unnamed-chunk-39-1.png)

The probability that the Portuguese-German bilinguals
make more progress than the Portuguese-French bilinguals is 77%,
and according to the model, there's a 95% chance its size is somewhere
between -0.25 and 0.52 points.


{% highlight r %}
mean(df$diff_prog > 0)
{% endhighlight %}



{% highlight text %}
## [1] 0.765
{% endhighlight %}



{% highlight r %}
quantile(df$diff_prog, probs = c(0.025, 0.975))
{% endhighlight %}



{% highlight text %}
##       2.5%      97.5% 
## -0.2545850  0.5184868
{% endhighlight %}


## Summary
By investing some time in recoding your predictors, you can make the parameter estimates 
more relevant to your questions. Any specific comparisons you may be interested in can
additionally be addressed by making use of the entire distribution of estimates. You can
also use these estimate distributions to draw effect plots.

## Further resources

* [R Library Contrast Coding Systems for categorical variables](https://stats.idre.ucla.edu/r/library/r-library-contrast-coding-systems-for-categorical-variables/)
* Matthew Kay. 2018. [Extracting and visualizing tidy draws from brms models](https://mjskay.github.io/tidybayes/articles/tidy-brms.html)
* Daniel J. Schad, Sven Hohenstein, Shravan Vasishth and Reinhold Kliegl. 2018. [How to capitalize on a priori contrasts in linear (mixed) models: A tutorial](https://arxiv.org/abs/1807.10451).
* In simpler models, you can use bootstrapping to generate distributions of estimates. This would be possible for these data, too, but it would take a considerable amount of time.

## References
<p>Audrey Bonvin, Jan Vanhove, Raphael Berthele and Amelia Lambelet. 2018.
<a href="http://tujournals.ulb.tu-darmstadt.de/index.php/zif/article/view/886">Die Entwicklung von produktiven lexikalischen Kompetenzen bei Schüler(innen) mit portugiesischem Migrationshintergrund in der Schweiz</a>.
<i>Zeitschrift für Interkulturellen Fremdsprachenunterricht</i> 23(1). 135-148.
Data and R code available from <a href="http://dx.doi.org/10.6084/m9.figshare.4578991">figshare</a>.</p>

<p>Amelia Lambelet, Raphael Berthele, Magalie Desgrippes, Carlos Pestana and Jan Vanhove. 2017a. Chapter 2: Testing interdependence in Portuguese Heritage speakers in Switzerland: the HELASCOT project. In Raphael Berthele and Amelia Lambelet (eds.), <a href="http://www.multilingual-matters.com/display.asp?k=9781783099030">Heritage and school language literacy development in migrant children: Interdependence or independence?</a>, pp. 26-33. Multilingual Matters.</p>

<p>Amelia Lambelet, Magalie Desgrippes and Jan Vanhove. 2017b. Chapter 5: The development of argumentative and narrative writing skills in Portuguese heritage speakers in Switzerland (HELASCOT project). In Raphael Berthele and Amelia Lambelet (eds.), <a href="http://www.multilingual-matters.com/display.asp?k=9781783099030">Heritage and school language literacy development in migrant children: Interdependence or independence?</a>, pp. 83-96. Multilingual Matters.</p>

<p>Jan Vanhove, Audrey Bonvin, Amelia Lambelet and Raphael Berthele. Forthcoming.
Predicting perceptions of the lexical richness of short French, German, and Portuguese texts.
<i>Journal of Writing Research</i>. Technical report, data (including texts), elicitation materials, and R code available from the <a href="https://osf.io/vw4pc/">Open Science Framework</a>.</p>

## Session info

{% highlight r %}
devtools::session_info()
{% endhighlight %}



{% highlight text %}
## ─ Session info ──────────────────────────────────────────────────────────
##  setting  value                       
##  version  R version 3.4.4 (2018-03-15)
##  os       Ubuntu 18.04.1 LTS          
##  system   x86_64, linux-gnu           
##  ui       RStudio                     
##  language (EN)                        
##  collate  en_US.UTF-8                 
##  ctype    en_US.UTF-8                 
##  tz       Europe/Brussels             
##  date     2018-12-20                  
## 
## ─ Packages ──────────────────────────────────────────────────────────────
##  package        * version date       lib source        
##  abind            1.4-5   2016-07-21 [1] CRAN (R 3.4.2)
##  assertthat       0.2.0   2017-04-11 [1] CRAN (R 3.4.2)
##  backports        1.1.2   2017-12-13 [1] CRAN (R 3.4.2)
##  base64enc        0.1-3   2015-07-28 [1] CRAN (R 3.4.2)
##  bayesplot        1.6.0   2018-08-02 [1] CRAN (R 3.4.4)
##  bindr            0.1.1   2018-03-13 [1] CRAN (R 3.4.4)
##  bindrcpp       * 0.2.2   2018-03-29 [1] CRAN (R 3.4.4)
##  bridgesampling   0.6-0   2018-10-21 [1] CRAN (R 3.4.4)
##  brms           * 2.6.0   2018-10-23 [1] CRAN (R 3.4.4)
##  Brobdingnag      1.2-6   2018-08-13 [1] CRAN (R 3.4.4)
##  broom            0.4.3   2017-11-20 [1] CRAN (R 3.4.2)
##  callr            2.0.2   2018-02-11 [1] CRAN (R 3.4.2)
##  cellranger       1.1.0   2016-07-27 [1] CRAN (R 3.4.2)
##  cli              1.0.1   2018-09-25 [1] CRAN (R 3.4.4)
##  coda             0.19-2  2018-10-08 [1] CRAN (R 3.4.4)
##  colorspace       1.3-2   2016-12-14 [1] CRAN (R 3.4.2)
##  colourpicker     1.0     2017-09-27 [1] CRAN (R 3.4.2)
##  crayon           1.3.4   2017-09-16 [1] CRAN (R 3.4.2)
##  crosstalk        1.0.0   2016-12-21 [1] CRAN (R 3.4.2)
##  debugme          1.1.0   2017-10-22 [1] CRAN (R 3.4.2)
##  desc             1.2.0   2018-05-01 [1] CRAN (R 3.4.4)
##  devtools         2.0.1   2018-10-26 [1] CRAN (R 3.4.4)
##  digest           0.6.18  2018-10-10 [1] CRAN (R 3.4.4)
##  dplyr          * 0.7.8   2018-11-10 [1] CRAN (R 3.4.4)
##  DT               0.4     2018-01-30 [1] CRAN (R 3.4.2)
##  dygraphs         1.1.1.6 2018-07-11 [1] CRAN (R 3.4.4)
##  evaluate         0.10.1  2017-06-24 [1] CRAN (R 3.4.2)
##  fansi            0.4.0   2018-10-05 [1] CRAN (R 3.4.4)
##  forcats        * 0.3.0   2018-02-19 [1] CRAN (R 3.4.4)
##  foreign          0.8-71  2018-07-20 [1] CRAN (R 3.4.4)
##  fs               1.2.6   2018-08-23 [1] CRAN (R 3.4.4)
##  ggplot2        * 3.1.0   2018-10-25 [1] CRAN (R 3.4.4)
##  ggridges         0.5.1   2018-09-27 [1] CRAN (R 3.4.4)
##  glue             1.3.0   2018-07-17 [1] CRAN (R 3.4.4)
##  gridExtra        2.3     2017-09-09 [1] CRAN (R 3.4.2)
##  gtable           0.2.0   2016-02-26 [1] CRAN (R 3.4.2)
##  gtools           3.8.1   2018-06-26 [1] CRAN (R 3.4.4)
##  haven            1.1.1   2018-01-18 [1] CRAN (R 3.4.2)
##  highr            0.6     2016-05-09 [1] CRAN (R 3.4.2)
##  hms              0.4.1   2018-01-24 [1] CRAN (R 3.4.2)
##  htmltools        0.3.6   2017-04-28 [1] CRAN (R 3.4.2)
##  htmlwidgets      1.3     2018-09-30 [1] CRAN (R 3.4.4)
##  httpuv           1.4.5   2018-07-19 [1] CRAN (R 3.4.4)
##  httr             1.3.1   2017-08-20 [1] CRAN (R 3.4.2)
##  igraph           1.2.2   2018-07-27 [1] CRAN (R 3.4.4)
##  inline           0.3.14  2015-04-13 [1] CRAN (R 3.4.2)
##  jsonlite         1.5     2017-06-01 [1] CRAN (R 3.4.2)
##  knitr          * 1.19    2018-01-29 [1] CRAN (R 3.4.2)
##  labeling         0.3     2014-08-23 [1] CRAN (R 3.4.2)
##  later            0.7.5   2018-09-18 [1] CRAN (R 3.4.4)
##  lattice          0.20-35 2017-03-25 [4] CRAN (R 3.4.2)
##  lazyeval         0.2.1   2017-10-29 [1] CRAN (R 3.4.2)
##  loo              2.0.0   2018-04-11 [1] CRAN (R 3.4.2)
##  lubridate        1.7.2   2018-02-06 [1] CRAN (R 3.4.2)
##  magrittr         1.5     2014-11-22 [1] CRAN (R 3.4.2)
##  markdown         0.8     2017-04-20 [1] CRAN (R 3.4.2)
##  Matrix           1.2-14  2018-04-09 [1] CRAN (R 3.4.4)
##  matrixStats      0.54.0  2018-07-23 [1] CRAN (R 3.4.4)
##  memoise          1.1.0   2017-04-21 [1] CRAN (R 3.4.2)
##  mime             0.5     2016-07-07 [1] CRAN (R 3.4.2)
##  miniUI           0.1.1.1 2018-05-18 [1] CRAN (R 3.4.4)
##  mnormt           1.5-5   2016-10-15 [1] CRAN (R 3.4.2)
##  modelr           0.1.1   2017-07-24 [1] CRAN (R 3.4.2)
##  munsell          0.5.0   2018-06-12 [1] CRAN (R 3.4.4)
##  mvtnorm          1.0-8   2018-05-31 [1] CRAN (R 3.4.2)
##  nlme             3.1-137 2018-04-07 [1] CRAN (R 3.4.4)
##  pillar           1.3.0   2018-07-14 [1] CRAN (R 3.4.4)
##  pkgbuild         1.0.2   2018-10-16 [1] CRAN (R 3.4.4)
##  pkgconfig        2.0.2   2018-08-16 [1] CRAN (R 3.4.4)
##  pkgload          1.0.2   2018-10-29 [1] CRAN (R 3.4.4)
##  plyr             1.8.4   2016-06-08 [1] CRAN (R 3.4.2)
##  prettyunits      1.0.2   2015-07-13 [1] CRAN (R 3.4.4)
##  promises         1.0.1   2018-04-13 [1] CRAN (R 3.4.2)
##  psych            1.7.8   2017-09-09 [1] CRAN (R 3.4.2)
##  purrr          * 0.2.5   2018-05-29 [1] CRAN (R 3.4.4)
##  R6               2.3.0   2018-10-04 [1] CRAN (R 3.4.4)
##  RColorBrewer     1.1-2   2014-12-07 [1] CRAN (R 3.4.2)
##  Rcpp           * 1.0.0   2018-11-07 [1] CRAN (R 3.4.4)
##  readr          * 1.1.1   2017-05-16 [1] CRAN (R 3.4.2)
##  readxl           1.0.0   2017-04-18 [1] CRAN (R 3.4.2)
##  remotes          2.0.2   2018-10-30 [1] CRAN (R 3.4.4)
##  reshape2         1.4.3   2017-12-11 [1] CRAN (R 3.4.2)
##  rlang            0.3.0.1 2018-10-25 [1] CRAN (R 3.4.4)
##  rprojroot        1.3-2   2018-01-03 [1] CRAN (R 3.4.2)
##  rsconnect        0.8.8   2018-03-09 [1] CRAN (R 3.4.2)
##  rstan            2.17.3  2018-01-20 [1] CRAN (R 3.4.2)
##  rstantools       1.5.1   2018-08-22 [1] CRAN (R 3.4.4)
##  rstudioapi       0.7     2017-09-07 [1] CRAN (R 3.4.2)
##  rvest            0.3.2   2016-06-17 [1] CRAN (R 3.4.2)
##  scales           1.0.0   2018-08-09 [1] CRAN (R 3.4.4)
##  sessioninfo      1.1.0   2018-09-25 [1] CRAN (R 3.4.4)
##  shiny            1.1.0   2018-05-17 [1] CRAN (R 3.4.2)
##  shinyjs          1.0     2018-01-08 [1] CRAN (R 3.4.2)
##  shinystan        2.5.0   2018-05-01 [1] CRAN (R 3.4.2)
##  shinythemes      1.1.1   2016-10-12 [1] CRAN (R 3.4.2)
##  StanHeaders      2.17.2  2018-01-20 [1] CRAN (R 3.4.2)
##  stringi          1.2.4   2018-07-20 [1] CRAN (R 3.4.4)
##  stringr        * 1.3.1   2018-05-10 [1] CRAN (R 3.4.4)
##  testthat         2.0.0   2017-12-13 [1] CRAN (R 3.4.2)
##  threejs          0.3.1   2017-08-13 [1] CRAN (R 3.4.2)
##  tibble         * 1.4.2   2018-01-22 [1] CRAN (R 3.4.2)
##  tidyr          * 0.8.2   2018-10-28 [1] CRAN (R 3.4.4)
##  tidyselect       0.2.5   2018-10-11 [1] CRAN (R 3.4.4)
##  tidyverse      * 1.2.1   2017-11-14 [1] CRAN (R 3.4.2)
##  usethis          1.4.0   2018-08-14 [1] CRAN (R 3.4.4)
##  utf8             1.1.4   2018-05-24 [1] CRAN (R 3.4.4)
##  withr            2.1.2   2018-03-15 [1] CRAN (R 3.4.4)
##  xml2             1.2.0   2018-01-24 [1] CRAN (R 3.4.2)
##  xtable           1.8-3   2018-08-29 [1] CRAN (R 3.4.4)
##  xts              0.11-1  2018-09-12 [1] CRAN (R 3.4.4)
##  zoo              1.8-4   2018-09-19 [1] CRAN (R 3.4.4)
## 
## [1] /home/jan/R/x86_64-pc-linux-gnu-library/3.4
## [2] /usr/local/lib/R/site-library
## [3] /usr/lib/R/site-library
## [4] /usr/lib/R/library
{% endhighlight %}

