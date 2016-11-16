---
layout: post
title: "R tip: Ordering factor levels more easily"
category: [Analysis]
tags: [R tip, graphics, R]
---

By default, `R` sorts the levels of a factor alphabetically.
When drawing graphs, this results in ['Alabama First'](http://dx.doi.org/10.1080/09332480.2001.10542269) graphs,
and it's usually better to sort the elements of a graph by more meaningful principles than alphabetical order.
This post illustrates three convenience functions you can use to sort factor levels in `R`
according to another covariate, their frequency of occurrence, or manually.

<!--more-->

First you'll need the `dplyr` and `magrittr` packages:


{% highlight r %}
install.packages(c("dplyr", "magrittr"))
{% endhighlight %}

You can download the convenience functions from my [Github page](https://github.com/janhove/janhove.github.io/blob/master/RCode/sortLvls.R) or read them in directly into `R`:


{% highlight r %}
source("https://raw.githubusercontent.com/janhove/janhove.github.io/master/RCode/sortLvls.R")
{% endhighlight %}

### Sorting factor levels by another variable
The code below creates an example dataset with a factor and a covariate:


{% highlight r %}
# Load packages
library(magrittr)
library(dplyr)

# Generate same data
set.seed(18-08-2016)

# Create data frame
df <- data.frame(factorBefore = factor(rep(letters[1:5], 3)),
                 covariate = rnorm(15, 50, 30))

# Current order of factor levels (alphabetically)
levels(df$factorBefore)
{% endhighlight %}



{% highlight text %}
## [1] "a" "b" "c" "d" "e"
{% endhighlight %}



{% highlight r %}
# Covariate mean per factor level
df %>% group_by(factorBefore) %>% summarise(mean(covariate))
{% endhighlight %}



{% highlight text %}
## # A tibble: 5 x 2
##   factorBefore mean(covariate)
##         <fctr>           <dbl>
## 1            a        8.039675
## 2            b       36.881525
## 3            c       45.005219
## 4            d       71.575448
## 5            e       41.889307
{% endhighlight %}

What we want is to sort the levels of the factor by the covariate mean per factor level (i.e., a-b-e-c-d).
The function `sortLvlsByVar.fnc` accomplishes this:


{% highlight r %}
# Reorder
df$factorAfter1 <- sortLvlsByVar.fnc(df$factorBefore, df$covariate)

# New order of factor levels
levels(df$factorAfter1)
{% endhighlight %}



{% highlight text %}
## [1] "a" "b" "e" "c" "d"
{% endhighlight %}

By setting the `ascending` parameter to `FALSE`, the factor levels are sorting descendingly according to the covariate mean:

{% highlight r %}
# Reorder descendingly
df$factorAfter2 <- sortLvlsByVar.fnc(df$factorBefore, df$covariate, ascending = FALSE)
levels(df$factorAfter2)
{% endhighlight %}



{% highlight text %}
## [1] "d" "c" "e" "b" "a"
{% endhighlight %}

How this looks like when graphed:


{% highlight r %}
# 'install.packages("cowplot")' if you haven't already
library(ggplot2); library(cowplot)

# Alphabetical order
p1 <- ggplot(df, aes(x = factorBefore, y = covariate)) +
  geom_boxplot()
# Sorted ascendingly
p2 <- ggplot(df, aes(x = factorAfter1, y = covariate)) +
  geom_boxplot()
# Sorted descendingly
p3 <- ggplot(df, aes(x = factorAfter2, y = covariate)) +
  geom_boxplot()
plot_grid(p1, p2, p3, ncol = 3)
{% endhighlight %}

![center](/figs/2016-08-18-ordering-factor-levels/unnamed-chunk-6-1.png)

You can change the `R` code from the Github page so that the levels are sorted by another summary statistics, e.g., the covariate median per factor level.

### Sorting factor levels by their frequency of occurrence
Again we'll first create some data:


{% highlight r %}
df2 <- data.frame(factorBefore = factor(rep(letters[1:5], c(7, 3, 80, 15, 107))),
                  covariate = rnorm(sum(c(7, 3, 80, 15, 107)), 50, 30))
table(df2$factorBefore)
{% endhighlight %}



{% highlight text %}
## 
##   a   b   c   d   e 
##   7   3  80  15 107
{% endhighlight %}

We want to order these factor levels by their frequency of occurrence in the dataset (i.e., b-a-d-c-e).
`sortLvlsByN.fnc()` accomplishes this:


{% highlight r %}
df2$factorAfter1 <- sortLvlsByN.fnc(df2$factorBefore)
table(df2$factorAfter1)
{% endhighlight %}



{% highlight text %}
## 
##   b   a   d   c   e 
##   3   7  15  80 107
{% endhighlight %}

Or descendingly:

{% highlight r %}
df2$factorAfter2 <- sortLvlsByN.fnc(df2$factorBefore, ascending = FALSE)
table(df2$factorAfter2)
{% endhighlight %}



{% highlight text %}
## 
##   e   c   d   a   b 
## 107  80  15   7   3
{% endhighlight %}

When plotted:

{% highlight r %}
p4 <- ggplot(df2, aes(x = factorBefore, y = covariate)) +
  geom_boxplot(varwidth = TRUE)
p5 <- ggplot(df2, aes(x = factorAfter1, y = covariate)) +
  geom_boxplot(varwidth = TRUE)
p6 <- ggplot(df2, aes(x = factorAfter2, y = covariate)) +
  geom_boxplot(varwidth = TRUE)
plot_grid(p4, p5, p6, ncol = 3)
{% endhighlight %}

![center](/figs/2016-08-18-ordering-factor-levels/unnamed-chunk-10-1.png)

### Customising the order of factor levels
If you want to put the factor levels in a custom order, you can use the `sortLvls.fnc()` function.


{% highlight r %}
# Create data
df3 <- data.frame(factorBefore = factor(rep(letters[1:5], 3)),
                  covariate = rnorm(15, 50, 30))
levels(df3$factorBefore)
{% endhighlight %}



{% highlight text %}
## [1] "a" "b" "c" "d" "e"
{% endhighlight %}

Let's say we, for some reason, want to put the current 5th level (e) first, the current 3rd level (c) second, the 4th 3rd, the 4th 2nd and the 1st last:


{% highlight r %}
df3$factorAfter1 <- sortLvls.fnc(df3$factorBefore, c(5, 3, 4, 2, 1))
levels(df3$factorAfter1)
{% endhighlight %}



{% highlight text %}
## [1] "e" "c" "d" "b" "a"
{% endhighlight %}

You can also just specify which factor levels need to go up front; the order of the other ones stays the same:

{% highlight r %}
# Put the current 3rd and 2nd in front; leave the rest as they were:
df3$factorAfter2 <- sortLvls.fnc(df3$factorBefore, c(3, 2))
levels(df3$factorAfter2)
{% endhighlight %}



{% highlight text %}
## [1] "c" "b" "a" "d" "e"
{% endhighlight %}
