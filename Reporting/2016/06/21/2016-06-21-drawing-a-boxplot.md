---
layout: post
title: "Tutorial: Drawing a boxplot"
category: [Reporting]
tags: [graphics, tutorial, R]
---

In the two previous blog posts,
you learnt to draw simple but informative [**scatterplots**]({% post_url 2016-06-02-drawing-a-scatterplot %})
and [**line charts**]({% post_url 2016-06-13-drawing-a-linechart %}).
This time, you'll learn how to draw **boxplots**.

<!--more-->

### What's a boxplot?
A boxplot is a graphical display of a sample's **five-number summary**:
the minimum, the maximum, the **median** (i.e., the middle value if you sort the data from high to low),
and the 25th and 75th **percentiles**.
The 25th percentile is the value below which 25% of the data lie;
the 75th percentile is the value below which 75% of the data lie.
The range between the 25th and 75th percentiles contains 50% of the sample and
is known as the **inter-quartile range**.

A boxplot might look like the one below--the median is highlighted by a thick line, the 25th and 75th are displayed by a box, and the minimum and maximum are plotted as 'whiskers':

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-1-1.png)

Often, though, you'll also see some points that lie beyond the whiskers.
These are values that lie too far from the bulk of data,
and they're commonly referred to as **outliers**.
Here's an example:

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-2-1.png)

It's important to note, however, that these outliers may be perfectly valid observations,
so you shouldn't remove them from the data set just because they show up in a boxplot.

### When to use boxplots, and when there are better choices
Boxplots are often a good choice when you want to compare two or more groups.
In particular, I'll take a boxplot over the ubiquitous 'average-only' barplot [any day]({% post_url 2015-01-07-some-alternatives-to-barplots %}).
The plot belows illustrates the problem with barplots:
the 'average-only' barplots on the left make a crisp impression,
but we have no way of knowing how large the 0.6-point difference between the means is in practical terms. (Error bars only slightly alleviate this for me.)
Additionally, we don't know how the data are really distributed---knowing
this is usually important when interpreting the results.
The boxplots on the right, by contrast, show that---relative to the spread of the data---a 0.6-point difference is tiny.
Moreover, they show that both samples have a skewed distribution: the lower 50% of the data is restricted to a small range, whereas the upper 50% is spread out much more.

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-3-1.png)

That said, there are situations where boxplots aren't optimal.
One such situation is when the median is actually fairly atypical of the data.
From the left panel below, we would correctly gather 
that the sample median is slightly higher than 0.4
and that 50% of the data lies between 0.1 and 0.9.
A moment's thought shows that this means that
a quarter of the data lies squished between 0 and 0.1
and another quarter between 0.9 and 1, but this may not be something
you consciously think of when leafing through a paper---what you focus on is the big white box and the thick line.
In this case, the histogram on the right does a much better job of highlighting the interesting patterns in the data---viz., that the distribution is strongly bimodal.

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-4-1.png)

My point is this: Boxplots are much better than your run-of-the-mill barplots showing the group means,
but be willing to look for alternatives when
you need to---or ought to---highlight particular aspects of the data.


### Tutorial: Drawing boxplots in ggplot2

#### What you'll need

* The [free program R](http://r-project.org),
the graphical user interface [RStudio](http://rstudio.com), and the add-on package `ggplot2`. See my [previous post]({% post_url 2016-06-13-drawing-a-linechart %}) when you need help with this.  
* A dataset. For this tutorial we're going to work with another dataset on [receptive multilingualism](http://ijb.sagepub.com/content/early/2015/03/05/1367006915573338) that you can [download](http://homeweb.unifr.ch/VanhoveJ/Pub/Data/VowelChoices_ij.csv) to your hard disk. The dataset contains three variables; what interests us is whether the proportion of responses to Dutch words with the digraph _ij_ (`PropCorrect`) differs according the `LearningCondition` to which the participants were assigned.

#### Preliminaries
In RStudio, read in the data.


{% highlight r %}
dat <- read.csv(file.choose())
{% endhighlight %}




If the summary looks like this, you're good to go.

{% highlight r %}
summary(dat)
{% endhighlight %}



{% highlight text %}
##     Subject           LearningCondition  PropCorrect    
##  S10    : 1   <ij> participants:43      Min.   :0.0000  
##  S100   : 1   <oe> participants:37      1st Qu.:0.2262  
##  S11    : 1                             Median :0.3333  
##  S12    : 1                             Mean   :0.3685  
##  S14    : 1                             3rd Qu.:0.4762  
##  S15    : 1                             Max.   :0.9048  
##  (Other):74
{% endhighlight %}

Now load the `ggplot2` package we'll be using.


{% highlight r %}
library(ggplot2)
{% endhighlight %}

#### A first attempt
The first three lines of code specify
the data frame that the data are to be read from
and the variables that go on the x- and y-axis.
By setting `LearningCondition` as the x-variable,
we make it clear that we want to compare the
accuracy data between these groups of participants.
The fourth line specifies that these data
should be rendered as boxplots.


{% highlight r %}
ggplot(data = dat,
       aes(x = LearningCondition,
           y = PropCorrect)) +
  geom_boxplot()
{% endhighlight %}

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-9-1.png)

This first attempt already produces a very presentable result.
We would eventually like to label the axes more appropriately and get rid of the grey background,
but all in all, this is pretty decent.

#### Adding the individual data points
One more substantial thing we can add to the graph is the [individual data points](http://dx.doi.org/10.1371/journal.pbio.1002128) that the boxplots are based on.
You don't _have_ to do this, but particularly when the number of observations is fairly small and the data aren't too coarse, it may be interesting to see
how the data are distributed _within_ the boxes and whiskers.

To add the individual data points to the boxplots, simply add a `geom_point()` layer to the previous code.
I've specified that the points should be grey circles, but you can simply use `geom_point()` instead of the fifth line.


{% highlight r %}
ggplot(data = dat,
       aes(x = LearningCondition,
           y = PropCorrect)) +
  geom_boxplot() +
  geom_point(pch = 21, fill = "grey")
{% endhighlight %}

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-10-1.png)

Now, some participants had the same number of correct responses, but from the graph you can't tell which ones: the points are just plotted on top of each other.
To remedy this, we can 'jitter' the position of the data points using the `position_jitter` command.
Note that I set the `height` parameter to 0 as I don't want to render proportions of, say, 0.24 as 0.28; I just want to spread apart the data points horizontally:


{% highlight r %}
ggplot(data = dat,
       aes(x = LearningCondition,
           y = PropCorrect)) +
  geom_boxplot() +
  geom_point(pch = 21, fill = "grey",
             position = position_jitter(width = 0.5, height = 0))
{% endhighlight %}

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-11-1.png)

#### The final product
You'll notice that in the plot above, it appears as though three 'oe' participants have scores of around 62%, whereas in actual fact only two do:
we plotted a symbol to represent the outliers when drawing the boxplots _and_ we drew the data points individually.
When you're plotting the individual data points anyway,
there's no need to also draw the outliers for the boxplots;
you can turn this off by specifying `outlier.shape = NA` in the `geom_boxplot()` call.

Second, the y-axis should be properly labelled,
whereas the label for the x-axis seems to be superfluous 
(the information is already supplied in the tick labels). Change this using the `ylab()` and `xlab()` calls.

Third, personally I prefer white backgrounds. Simply adding `theme_bw()` to the call overrides the grey default. `theme_bw(8)` means that the font size will be slightly smaller, which is okay.

Lastly, we can flip the x- and y-axes using `coord_flip()`. The main advantage here is that doing so saves some vertical space on the page, which means there's more room for other graphs!


{% highlight r %}
ggplot(data = dat,
       aes(x = LearningCondition,
           y = PropCorrect)) +
  geom_boxplot(outlier.shape = NA) +
  geom_point(pch = 21, fill = "grey",
             position = position_jitter(width = 0.5, height = 0)) +
  xlab("") +
  ylab("Proportion of correct vowel choices") +
  theme_bw(8) +
  coord_flip()
{% endhighlight %}

![center](/figs/2016-06-21-drawing-a-boxplot/unnamed-chunk-12-1.png)

#### The cowplot package
Lastly, I want to draw your attention to the [`cowplot`](https://cran.r-project.org/web/packages/cowplot/vignettes/introduction.html) package, which among other things is useful when you want to draw a plot containing several panels.
