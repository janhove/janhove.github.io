---
layout: post
title: "Thinking about graphs"
thumbnail: /figs/thumbnails/2015-02-21-thinking-about-graphs.png
category: [Graphics]
tags: [statistics, pretest/posttest design, graphics]
---

I firmly believe that research results are best communicated graphically.
Straightforward scatterplots, for instance, tend to be much more informative than correlation coefficients to both novices and dyed-in-the-wool scholars alike.
Often, however, it's more challenging to come up with a graph that highlights the patterns (or lack thereof) that you want to highlight in your discussion 
and that your readership will understand both readily and accurately.
In this post, I ask myself whether I could have presented the results from an experiment I carried out last year any better in a paper to be published soon.

<!--more-->

### The plot
 
Earlier this week, I received the page proofs of an article in which I report on a learning experiment in a context of receptive multilingualism ([preprint](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Vanhove_CorrespondenceRules.pdf)).
In the experiment, 80 speakers of German were asked to translate words from a closely related language, viz. Dutch.
One of the goals of the experiment was to find out whether the participants could translate certain words ('ij cognates' and 'oe cognates'; it doesn't matter much for this blog post) more accurately when they occurred in the last part of the experiment ('Block 3') compared to in the first part ('Block 1').
Here is the code that you can use to reproduce the plot showing the results ('Figure 2'):


{% highlight r %}
# Read in data from my institutional webpage:
dat <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/CorrespondenceRules_Blocks.csv")

# 'Block' contains number but it's more useful to consider it a factor here:
dat$Block <- factor(dat$Block)
{% endhighlight %}


{% highlight r %}
# Load the ggplot2 package for graphics
library(ggplot2)

# Draw plot of 'CorrectVowel' by 'Block':
ggplot(dat, aes(x = Block, y = CorrectVowel)) + 
  # draw boxplot, but don't draw outliers
  # because next line plots all datapoints individually
  geom_boxplot(outlier.shape = NA) + 
  # add individual datapoints and label them
  # and jitter them horizontally (less overlap)
  geom_text(size = 5, aes(label = Item),  
            position = position_jitter(height = 0, width = 0.3)) + 
  # separately for each category
  facet_wrap(~ Category) +
  # label axis
  scale_y_continuous(name = "Correct vowel choices (%)") 
{% endhighlight %}



{% highlight text %}
## Warning: Removed 1 rows containing missing values (geom_point).
{% endhighlight %}



{% highlight text %}
## Warning: Removed 1 rows containing missing values (geom_point).
{% endhighlight %}



{% highlight text %}
## Warning: Removed 1 rows containing missing values (geom_point).
{% endhighlight %}

![center](/figs/2015-02-21-thinking-about-graphs/unnamed-chunk-2-1.png) 

{% highlight r %}
# Warning messages refer to suppressed outliers,
# which would otherwise have been plotted twice.
{% endhighlight %}

> **Figure 2:** Percentage of correct vowel choices for each ‹ij› and ‹oe› cognate depending on whether it occurred in Block 1 or 3.
> The boxplots mark the quartiles of each distribution. 
> Only answers on untrained correspondences were considered, i.e., ‹ij› cognates for ‹oe› participants and vice versa.

Some of the labels overlap, and I used a vector graphics editor ([Inkscape](http://inkscape.org)) to move the labels horizontally to sort that out.
I think that this plot contains a lot of useful information, [especially compared to a run-of-the-mill barplot]({% post_url 07-01-2015-some-alternatives-to-barplots %}):
not only are the individual datapoints plotted, they are also labelled so that it's relatively easy to see that _schoen_ was a particulary difficult word and that _wijze_ saw a 10pp-increase in accuracy from Block 1 to Block 3.

### Other options?

'Relatively' is the operative word in the preceeding paragraph, though:
I don't think I drew an _awful_ plot, 
but I now think I could've presented my readership with some better alternatives.
For instance, how about plotting the 'before' and 'after' scores in a slightly embellished scatterplot?


{% highlight r %}
# We need the data in a slightly different format;
# use dcast from the reshape2 package:
library(reshape2)
# see http://seananderson.ca/2013/10/19/reshape.html
dat2 <- dcast(dat,
              Item + Category ~ Block,
              value.var = "CorrectVowel")
# Rename the columns
colnames(dat2) <- c("Item", "Category", "Block1", "Block3")
# dat2 # uncomment to see the results

# Scatterplot 
ggplot(dat2, aes(x = Block1, y = Block3)) +
  # label the datapoints
  geom_text(size = 5, aes(label = Item)) + 
  # separate scatterplots for each category
  facet_wrap(~ Category) +
  # label axes
  scale_x_continuous(name = "Correct vowel choices (%) in Block 1") + 
  scale_y_continuous(name = "Correct vowel choices (%) in Block 3") +
  # add 'x = y' line
  geom_abline(intercept = 0, slope = 1, linetype = "dashed") 
{% endhighlight %}

![center](/figs/2015-02-21-thinking-about-graphs/unnamed-chunk-3-1.png) 

The dashed line divides the scatterplot such that stimuli appearing above the line
are translated more accurately in Block 3 than in Block 1 and those that appear below it are translated less accurately in Block 3 than in Block 1.
This can give a rough-and-ready impression of how many items showed an increase in accuracy
as well as by what margin (vertical distance to the dashed line).

Instead of plotting the two stimulus categories separately,
we could of course also plot them in the same graph.
Here's the R code to draw such a plot (plot not displayed here).


{% highlight r %}
ggplot(dat2, aes(x = Block1, y = Block3, colour = Category)) +
  geom_text(size = 5, aes(label = Item)) +
  scale_x_continuous(name = "Correct vowel choices (%) in Block 1") +
  scale_y_continuous(name = "Correct vowel choices (%) in Block 3") +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed")
{% endhighlight %}

I think these scatterplots are a step up from the original boxplot comparisons,
but they can still be criticised.
First, I think that the dashed 'x = y' line might somehow come across as the fit line from a linear regression. We could obviously spell it out in the caption that this isn't the case, but it'd be better if it were immediately obvious.
Second, it is difficult to gauge distances with respect to a diagonal line:
the _vertical_ distance from the word _groet_ to the dashed line is fairly large, but
its _perpendicular_ distance to the line is necessarily smaller, which might convey a false impression.
Again, we could spell this out in the caption, but it'd be better if we didn't have to.

<!-- Such a plot could also be useful for identifying patterns in the data that aren't immediately obvious from boxplot comparisons.
For instance, these scatterplots show that _ijzer_, _schijf_, _hijt_ (left) and _schoen_ (right) are as difficult to translate in Block 3 as they were in Block 1.
Th -->

In view of these two criticisms, 
the following graph shows the _improvement_ in accuracy in Block 3 compared to Block 1 plotted against the baseline accuracies.



{% highlight r %}
# Calculate difference between 3 and 1
dat2$Difference <- dat2$Block3 - dat2$Block1

# Draw scatterplot of baseline vs improvement
ggplot(dat2, aes(x = Block1, y = Difference)) +
  geom_text(size = 5, aes(label = Item)) +
  facet_wrap(~ Category) +
  scale_x_continuous(name = "Correct vowel choices (%) in Block 1") +
  scale_y_continuous(name = "Improvement in vowel choice accuracy (pp)\nin Block 3 compared to Block 1") +
  geom_abline(intercept = 0, slope = 0, linetype = "solid")
{% endhighlight %}

![center](/figs/2015-02-21-thinking-about-graphs/unnamed-chunk-5-1.png) 

The solid line again divides the stimuli that showed an improvement in accuracy and those that showed a decrease, but I think that a perfectly horizontal line is less readily mistaken for a regression fit line.
Additionally, the improvement in accuracy for each item can be gauged straightforwardly as the distance to the dividing line -- without the need to specify that it's the vertical distance rather than the perpendicular distance that's important (they're both the same).

An additional benefit of this plot is that it can readily reveal peculiar patterns that might merit further investigation.
For instance, the effect of 'Block' on accuracy seems to depend on baseline accuracy (i.e. it doesn't seem to be additive): there is a decreasing shape to the scatterplot.
We could highlight this trend by adding scatterplot smoothers to the panels, as in the graph below.


{% highlight r %}
ggplot(dat2, aes(x = Block1, y = Difference)) +
  geom_text(size = 5, aes(label = Item)) +
  facet_wrap(~ Category) +
  scale_x_continuous(name = "Correct vowel choices (%) in Block 1") +
  scale_y_continuous(name = "Improvement in vowel choice accuracy (pp)\nin Block 3 compared to Block 1") +
  geom_abline(intercept = 0, slope = 0, linetype = "solid") +
  # add loess scatterplot smoother; suppress confidence bands
  geom_smooth(method = "loess", se = FALSE) 
{% endhighlight %}

![center](/figs/2015-02-21-thinking-about-graphs/unnamed-chunk-6-1.png) 




A last alternative that I'll mention is to plot boxplots of the accuracy improvements rather than of the raw accuracy scores separately for Blocks 1 and 3:

{% highlight r %}
ggplot(dat2, aes(x = Category, y = Difference)) +
  geom_boxplot(outlier.shape = NA) +
  geom_text(aes(label = Item), size = 5, position = position_jitter(height=0, width=0.3)) +
  scale_y_continuous(name = "Improvement in vowel choice accuracy (pp)\nin Block 3 compared to Block 1")
{% endhighlight %}

![center](/figs/2015-02-21-thinking-about-graphs/unnamed-chunk-8-1.png) 

I don't really like this plot as it throws away much of the information we could have gained by using scatterplots.
That said, highlighting a measure of the central tendency of the increases could be useful, 
so perhaps a combination of the scatterplots above and these boxplots could serve both purposes.

### Open questions
This blog posts merely serves as an illustration of how the same data can be visualised in sundry ways
and what factors go into choosing one graphic rather than the other options.
One hugely important factor that perhaps isn't always fully considered is **how the graph is likely to be perceived by the audience**.

This entails anticipating misinterpretations that result from a cursory reading of the caption and the surrounding text (as I've tried to show above),
but on a more basic level it means taking into account the statistical literacy of your audience.
[Quantile--quantile plots](http://www.itl.nist.gov/div898/handbook/eda/section3/qqplot.htm), for instance, are useful for comparing two samples,
but I don't think the concept of quantiles is presently common currency for most readers.

What is sorely lacking in this discussion is concrete **evidence** about how easily and accurately graphical displays are interpreted by their intended audiences.
For instance, while I _think_ that a diagonal line in a scatterplot showing pre- and post-test data is often interpreted as a regression fit, I don't actually know.
This lack of empirical data is also the reason why I'm hesitant to make sweeping recommendations about 'best practices' when it comes to drawing graphs.
A [Bland--Altman (or Tukey mean-difference) plot](http://dx.doi.org/10.1111/test.12032), for instance, is easy enough to draw and explain (and similar to my second scatterplot; see R code below) and seems to be pretty common in the biomedical sciences.
But I don't recall ever coming across one when when reading journals in linguistics, applied linguistics or psychology,
so most readers aren't going to be familiar with it.
It might turn out that readers of applied linguistics journals can readily and accurately interpret Bland--Altman plots --
but it's also possible that the additional -- if simple -- step of plotting differences against means rather than against baseline scores creates some sort of cognitive barrier.

Actual studies on how applied linguists, educators, policy-makers etc. interpret common and not-so-common visualisations could only serve to improve the communicative quality of our research papers, and it's something I might look into in the months to come.



{% highlight r %}
# A Bland-Altmann plot plots the mean of two paired observations
# against the difference between them.

# First compute mean:
dat2$Mean <- (dat2$Block1 + dat2$Block3)/2

# Then plot Bland-Altmann
ggplot(dat2, aes(x = Mean, y = Difference)) +
  geom_text(size = 5, aes(label = Item)) +
  facet_wrap(~ Category) +
  scale_x_continuous(name = "Overall correct vowel choices (mean %) in Blocks 1 and 3") +
  scale_y_continuous(name = "Improvement in vowel choice accuracy (pp)\nin Block 3 compared to Block 1") +
  geom_abline(intercept = 0, slope = 0, linetype = "solid") +
  ggtitle("Tukey mean-difference plot")
{% endhighlight %}
