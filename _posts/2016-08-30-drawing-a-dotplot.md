---
layout: post
title: "Tutorial: Drawing a dot plot"
category: [Reporting]
tags: [tutorial, graphics]
---

In the fourth tutorial on drawing useful plots with `ggplot2`, we're taking a closer look at **dot plots** -- a useful and more flexible alternative to bar and pie charts.

<!--more-->

### What's a dot plot?
The three panels below show a same data in a pie chart, a bar chart and a dot plot.
For data like these, the bar chart and the dot plot
allow us to compare the sales of different kinds of pie about equally well.
The dot plot has a higher [data-ink ratio](http://www.infovis-wiki.net/index.php/Data-Ink_Ratio), but I don't think that's too decisive a factor.

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-1-1.png)

Where dot plots excel is when you want to display 
data with more than two dimensions.
In the plots above, the data had two dimensions: the kind of pie and the proportion of sales.
In the dot plot below, you find an additional dimension: year (2015 vs. 2016).
You couldn't display this additional dimension in a single pie chart,
and you'd need side-by-side bars to do it in a bar chart, which usually looks cluttered.

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-2-1.png)

### Tutorial: Drawing a dotchart in ggplot2

#### What you'll need
* The free program R, the graphical user interface RStudio, and the add-on package `ggplot2`.
* A dataset. The data we'll use were collected in a project on language transfer ([download](http://homeweb.unifr.ch/VanhoveJ/Pub/Data/GermanArticleChoices.csv)).
About 200 native speakers of Dutch from The Netherlands and Belgium (`Country`)
were asked to pick a German gender-marked definite article (_der_, _die_ or _das_) for 44 German nouns (`Stimulus`).
These nouns all had cognates in Dutch (`DutchCognate`), which had either common or neuter gender (`DutchGender`).
The expectation is that Dutch speakers from either country will tend to assign the neuter German article (_das_)
to German words with neuter Dutch cognates compared to words with common-gender Dutch cognates.
The dataset also lists the German words' actual gender (`GermanGender`).

#### Preliminaries


{% highlight r %}
# Read in data
germart <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/GermanArticleChoices.csv", encoding = "UTF-8")
{% endhighlight %}


{% highlight r %}
# Load the ggplot2 package
library(ggplot2)
{% endhighlight %}

I don't like `ggplot2`'s default grey background, so let's change the default theme to black and white:


{% highlight r %}
# Set black and white theme, font size 16
theme_set(theme_bw(16))
{% endhighlight %}



#### A first attempt
Let's plot the proportion of neuter article (_das_) choices by both the Belgian and the Dutch participants for each German noun.
Dot plots show the numeric information along the _x_-axis
and the categorical information (labels) along the _y_-axis,
so we specify those mappings in second and third lines.
In the fourth line, we specify that the data points need to be plotted as points or dots,
and lastly we customise the axis labels.


{% highlight r %}
ggplot(germart,                 # name of the dataset
       aes(x = NeuterResponses, # x-variable
           y = Stimulus,        # y-variable 
           shape = Country)) +  # different symbols by Country
  geom_point() +                # plot as dots/points
  xlab("Proportion of neuter (das) choices") +
  ylab("German noun")
{% endhighlight %}

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-6-1.png)

#### Facetting
The main comparison is between German words that have neuter Dutch cognates and those that have common-gender Dutch cognates.
To highlight this comparison, we can plot the data for both word categories in different panels.
Using the `facet_grid` layer, we can specify that the words with common and with neuter Dutch gender are to be plotted on different rows of a grid (`x ~ .`). 
(`. ~ x` would've plotted them in different columns, but having them in different rows but the same column makes for an easier comparison.)

Setting the `scales` and `space` arguments to `"free_y"` ensures that items for which data is available in only one panel aren't shown in the other panels as well (`scales`) and that the size of the panels is proportionate to the number of items in them (`space`).
If you set these arguments to `"fixed"`, you'll see what I mean.


{% highlight r %}
ggplot(germart,
       aes(x = NeuterResponses,
           y = Stimulus,
           shape = Country)) +
  geom_point() +
  xlab("Proportion of neuter (das) choices") +
  ylab("German noun") +
  facet_grid(DutchGender ~ .,   # different vertical panels
             scales = "free_y", # flexible y-axis
             space = "free_y")
{% endhighlight %}

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-7-1.png)

This plot strongly suggests that the gender of the German words' Dutch cognates has a major effect
on how often Dutch speakers pick _das_ as their article: with the exception of one word, _Boot_,
the ranges in the two panels don't even overlap.

However, the German words are ordered alphabetically.
While we're at it, we might as well sort them more meaningfully -- 
for instance, according to the average proportion of _das_ responses per word.
Additionally, I don't find the default filled circle and triangle symbols that represent the Belgian and Dutch responses very distinctive, so we'll change these, too.

#### Sorting the items by their average value
In my [previous post]({% post_url 2016-08-18-ordering-factor-levels %}), I introduced a custom function
for sorting the levels of a factor according to
the average value of another variable per level.
Here we use this function to sort the levels of `Stimulus`
according to their average value of `NeuterResponses`.
We also use another custom function to put the words with neuter cognates in the top instead of in the bottom panel.


{% highlight r %}
# Download sorting function
source("https://raw.githubusercontent.com/janhove/janhove.github.io/master/RCode/sortLvls.R")

# Sort Stimulus by NeuterResponses
germart$Stimulus <- sortLvlsByVar.fnc(germart$Stimulus, germart$NeuterResponses)

# Put DutchGender == neuter above DutchGender == common
germart$DutchGender <- sortLvls.fnc(germart$DutchGender, 2)
{% endhighlight %}

To change the default symbols, we use `scale_shape_manual()`.
For black and white plots, I prefer empty circles and crosses,
which are known internally as symbols 1 and 3, respectively:


{% highlight r %}
ggplot(germart,
       aes(x = NeuterResponses,
           y = Stimulus,
           shape = Country)) +
  geom_point() +
  xlab("Proportion of neuter (das) choices") +
  ylab("German noun") +
  scale_shape_manual(values = c(1, 3)) + # custom symbols
  facet_grid(DutchGender ~ .,
             scales = "free_y",
             space = "free_y")
{% endhighlight %}

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-9-1.png)

The difference between responses to words with neuter cognates and to those with common-gender cognates is now particularly clear.
Nevertheless, there is a substantial degree of variation between the items, particularly in to words with neuter cognates.
Aficionados of the German language may've noticed, however, that the top words within each panel all have neuter gender in German, i.e., the article _das_ is the correct choice for these words.
The bottom words, by contrast, all have masculine or feminine gender in German.
As this factor -- whether the word actually is neuter in German or not -- can straightforwardly account for some variation within each panel due to people having learnt the correct gender, 
it makes sense to include this information in the plot, too.


#### Adding another facetting variable
First we create a new variable that specifies whether the German word actually has neuter gender or not.

{% highlight r %}
germart$GermanNeuter <- factor(germart$GermanGender == "neuter",
                               levels = c("TRUE", "FALSE"))
{% endhighlight %}

Then we add this new variable to the `facet_grid` layer.


{% highlight r %}
ggplot(germart,
       aes(x = NeuterResponses,
           y = Stimulus,
           shape = Country)) +
  geom_point() +
  xlab("Proportion of neuter (das) choices") +
  ylab("German noun") +
  scale_shape_manual(values = c(1, 3)) +
  facet_grid(DutchGender + GermanNeuter~ ., # another facetting variable
             scales = "free_y",
             space = "free_y")
{% endhighlight %}

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-11-1.png)

Adding this additional facetting variable may be useful for making it immediately clear
to the casual reader that the study featured a mixture of both congruent (neuter--neuter and non-neuter--common) and incongruent (neuter--common and non-neuter--neuter) cognates

Additionally, it shows that while the Dutch participants consistently and correctly choose more neuter responses
than the Belgians for neuter--neuter cognates,
they don't pick the correct neuter article more often for neuter--common cognates,
nor do they choose the neuter article less often than the Belgians for non-neuter words. 
To me, this suggests that the actual knowledge of German gender didn't
greatly differ between the Belgian and the Dutch participants.

Lastly, the word standing out in all of this is _Boot_,
for which most participants correctly picked neuter _das_ even though
its highly transparent cognate in Dutch, _boot_, is common-gender.

![](https://upload.wikimedia.org/wikipedia/en/a/a3/Das_boot_ver1.jpg)

#### Finishing touches: facet labels
Finally, as a courtesy to the reader, we'll give the facet labels more transparent titles.
For this, we need to map the current default labels to more descriptive labels using [`as_labeller()`](http://docs.ggplot2.org/current/as_labeller.html):


{% highlight r %}
labels <- as_labeller(
  c(`common` = "Du.: common",
    `neuter` = "Du.: neuter",
    `TRUE`   = "Gm.: neuter",
    `FALSE`  = "Gm.: non-neuter")
)
{% endhighlight %}

Then, we add these labels to the `facet_grid()` call.


{% highlight r %}
ggplot(germart,
       aes(x = NeuterResponses,
           y = Stimulus,
           shape = Country)) +
  geom_point() +
  xlab("Proportion of neuter (das) choices") +
  ylab("German noun") +
  scale_shape_manual(values = c(1, 3)) +
  facet_grid(DutchGender + GermanNeuter ~ .,
             scales = "free_y",
             space = "free_y",
             labeller = labels) # add labels
{% endhighlight %}

![center](/figs/2016-08-30-drawing-a-dotplot/unnamed-chunk-13-1.png)
