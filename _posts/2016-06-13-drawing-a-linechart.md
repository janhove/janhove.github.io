---
layout: post
title: "Tutorial: Drawing a line chart"
category: [Reporting]
tags: [graphics, tutorial]
---

Graphs are incredibly useful
both for understanding your own data
and for communicating your insights to your audience.
This is why the next few blog posts
will consist of  tutorials on how to draw 
four kinds of graphs that I find most useful:
[**scatterplots**]({% post_url 2016-06-02-drawing-a-scatterplot %}), **line charts**,
**boxplots** and some variations, and **Cleveland dotplots**.
These tutorials are aimed primarily at the students in our MA programme.
Today's graph: the line chart.

<!--more-->

### What's a linechart?
A line chart is quite simply a graph in which
data points that belong together are connected with a line.
If you want to compare different groups, as we do below,
you can use lines of different colours or different types to highlight differences between the groups.

As an aside, 
line charts are often used to plot the development of a variable over time---the tutorial below is an example of this---and 
I used to think that linecharts should _only_ be used when time was involved, that connecting data points using lines was somehow not kosher otherwise.
But now I'm fine with using line charts even when time isn't involved:
the lines often highlight the patterns in the data much better than a handful of unconnected symbols do.




### Tutorial: Drawing a linechart in ggplot2
In this tutorial, you'll learn how to draw a basic linechart and how you can tweak it.
You'll also learn how to quickly partition a dataset according to several variables and compute summary statistics within each part.
For this, we'll make use of the free statistical program R and the add-on packages `ggplot2`, `magrittr` and `dplyr`.
Working with these programs and packages may be irksome at first if you're used to pull-down menus,
but the trouble is well worth it.

#### What you'll need
* The [free program R](http://r-project.org).
* The graphical user interface [RStudio](http://rstudio.com) -- also free. Download and install R first and only then RStudio.

I'm going to assume some familiarity with these programs.
Specifically, 
I'll assume that you know how to enter commands in RStudio
and import datasets stored in the CSV file format.
If you need help with this, 
see [Chapter 1](http://homeweb.unifr.ch/VanhoveJ/Pub/Statistikkurs/StatistischeGrundlagen.pdf#page=11) of my introduction to statistics (in German)
or Google _importing data R_.

* The `ggplot2`, `magrittr` and `dplyr` add-on packages for R. 
To install them, simply enter the following command at the prompt in RStudio.

{% highlight r %}
install.packages(c("ggplot2", "magrittr", "dplyr"))
{% endhighlight %}

* A dataset. For this tutorial, we'll use a dataset
on the acquisition of morphological cues to agency
that my students compiled.
It consists of the responses of 70 learners (`SubjectID`) 
who were assigned to one of three learning conditions (`BiasCondition`) -- the details don't matter much for our purposes.
All learners completed three kinds of tasks (`Task`):
understanding sentences in an unknown languages,
judging the grammaticality of sentences in the same languages,
and producing sentences in this language.
These tasks occurred in `Block`s.
The learners' responses were tracked throughout the experiment (`ResponseCorrect`).
[Download](http://homeweb.unifr.ch/VanhoveJ/Pub/Data/Seminarprojekt2016.csv) this dataset to your hard disk.

#### Preliminaries
In RStudio, read in the data.


{% highlight r %}
semproj <- read.csv(file.choose())
{% endhighlight %}

If the summary looks like this, you're good to go.

{% highlight r %}
summary(semproj)
{% endhighlight %}



{% highlight text %}
##                             SubjectID           BiasCondition 
##  0krwma8qskny4r4d1za1gqsp3hp78y4s:  96   RuleBasedInput:2496  
##  0pmm7rhegvxjttmjla7zyv0qrfwlv0a0:  96   StrongBias    :2112  
##  0qyn6np5fgyrmqjfbqjq68fcvs61y2gu:  96   WeakBias      :2112  
##  0uet846f755xvnm9ow9phkusz2zbhgac:  96                        
##  0vm3nrrqdd5mnbncnmon7sjp5f7fz4z8:  96                        
##  12athefgbh4zetjy4y2tn2148p713c6x:  96                        
##  (Other)                         :6144                        
##      Block      ResponseCorrect            Task     
##  Min.   :1.00   no :1670        Comprehension:4480  
##  1st Qu.:1.75   yes:5050        GJT          :1120  
##  Median :2.50                   Production   :1120  
##  Mean   :2.50                                       
##  3rd Qu.:3.25                                       
##  Max.   :4.00                                       
## 
{% endhighlight %}

Now load the packages we'll be using.
You may get a message that some 'objects are masked', but that's nothing to worry about.


{% highlight r %}
library(ggplot2)
library(magrittr)
library(dplyr)
{% endhighlight %}


#### Summarising a data frame
We want to compare how response accuracy develops block by block
in the different experimental conditions.
To that end, we need to calculate the proportion of correct
responses by each learner in each block and for each task.
The `dplyr` and `magrittr` packages make doing so easy.

The following lines of code create a new data frame called `semproj_perParticipant`
that was constructed by taking the dataset `semproj` (first line),
grouping it by the variables `SubjectID`, `BiasCondition`, `Block` and `Task` (second line),
and within each 'cell' calculating the proportion of entries in `ResponseCorrect` that read `"yes"` (third line).



{% highlight r %}
semproj_perParticipant <- semproj %>%
  group_by(SubjectID, BiasCondition, Block, Task) %>%
  summarise(ProportionCorrect = mean(ResponseCorrect == "yes"))
{% endhighlight %}

Type the name of the new data frame at the prompt. If you see something like this,
everything's fine.


{% highlight r %}
semproj_perParticipant
{% endhighlight %}


{% highlight text %}
##                          SubjectID BiasCondition Block          Task
## 1 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     1 Comprehension
## 2 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     1           GJT
## 3 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     1    Production
## 4 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     2 Comprehension
## 5 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     2           GJT
## 6 0krwma8qskny4r4d1za1gqsp3hp78y4s    StrongBias     2    Production
##   ProportionCorrect
## 1            0.6875
## 2            0.5000
## 3            0.0000
## 4            0.3750
## 5            0.5000
## 6            0.0000
{% endhighlight %}

Now that we've computed the proportion of correct responses
by each participant for each block and task,
we can compute the average proportion of correct responses
per block and task according to the experimental condition the participants
were assigned to.
The code works similarly to before:
a new data frame called `semproj_perCondition` is created
by taking the `semproj_perParticipant` data frame we constructed above (line 1),
grouping it by `BiasCondition`, `Block` and `Task` (line 2), and
computing the mean proportion of correct responses (line 3).


{% highlight r %}
semproj_perCondition <- semproj_perParticipant %>%
  group_by(BiasCondition, Block, Task) %>%
  summarise(MeanProportionCorrect = mean(ProportionCorrect))
{% endhighlight %}

The result should look like this---you can see that those in the 'rule-based input' learning condition score an average of 69% on the first comprehension block,
59% on the first grammaticality judgement task (GJT) block,
and 13% on the first production block.

{% highlight r %}
semproj_perCondition
{% endhighlight %}



{% highlight text %}
## Source: local data frame [36 x 4]
## Groups: BiasCondition, Block [?]
## 
##     BiasCondition Block          Task MeanProportionCorrect
##            (fctr) (int)        (fctr)                 (dbl)
## 1  RuleBasedInput     1 Comprehension             0.6923077
## 2  RuleBasedInput     1           GJT             0.5865385
## 3  RuleBasedInput     1    Production             0.1346154
## 4  RuleBasedInput     2 Comprehension             0.8461538
## 5  RuleBasedInput     2           GJT             0.7307692
## 6  RuleBasedInput     2    Production             0.5096154
## 7  RuleBasedInput     3 Comprehension             0.8798077
## 8  RuleBasedInput     3           GJT             0.8076923
## 9  RuleBasedInput     3    Production             0.5480769
## 10 RuleBasedInput     4 Comprehension             0.8966346
## ..            ...   ...           ...                   ...
{% endhighlight %}

#### A first attempt: Development in comprehension
To start off with a simple example,
let's plot the mean proportion of correct responses
in the four comprehension blocks for the three experimental conditions
and connect them with a line.

First, we create another new data frame that contains the averages
for the comprehension task only.
The new data frame `semproj_perCondition_Comprehension` is constructed
by taking the data frame `semproj_perCondition` we constructed above
and retaining (filtering) the rows for which the `Task` variable reads `Comprehension`.


{% highlight r %}
semproj_perCondition_Comprehension <- semproj_perCondition %>%
  filter(Task == "Comprehension")
semproj_perCondition_Comprehension
{% endhighlight %}



{% highlight text %}
## Source: local data frame [12 x 4]
## Groups: BiasCondition, Block [12]
## 
##     BiasCondition Block          Task MeanProportionCorrect
##            (fctr) (int)        (fctr)                 (dbl)
## 1  RuleBasedInput     1 Comprehension             0.6923077
## 2  RuleBasedInput     2 Comprehension             0.8461538
## 3  RuleBasedInput     3 Comprehension             0.8798077
## 4  RuleBasedInput     4 Comprehension             0.8966346
## 5      StrongBias     1 Comprehension             0.7329545
## 6      StrongBias     2 Comprehension             0.8011364
## 7      StrongBias     3 Comprehension             0.8125000
## 8      StrongBias     4 Comprehension             0.8920455
## 9        WeakBias     1 Comprehension             0.7897727
## 10       WeakBias     2 Comprehension             0.8295455
## 11       WeakBias     3 Comprehension             0.8977273
## 12       WeakBias     4 Comprehension             0.9261364
{% endhighlight %}

To plot these averages, use the following code.
The first line specifies the data frame the graph should be based on,
the second line specifies that `Block` (1-2-3-4) should go on the x-axis,
the third that `MeanProportionCorrect` should go on the y-axis,
and the fourth that the different experimental conditions
should be rendered using different colours.
The fifth line, finally, specifies that the data should be plotted as lines.


{% highlight r %}
ggplot(data = semproj_perCondition_Comprehension,
       aes(x = Block,
           y = MeanProportionCorrect,
           colour = BiasCondition)) +
  geom_line()
{% endhighlight %}

![center](/figs/2016-06-13-drawing-a-linechart/unnamed-chunk-12-1.png)

This is decent enough for a start: 
it's clear from this graph that,
contrary to what we'd expected,
those in the weak bias condition actually
seem to perform better than the other participants, for instance.
We could go on and draw similar graphs
for the other two tasks---comprehension and production---but there's a better option:
draw them all at once so that
the results can more easily be compared.

#### Several linecharts in one plot
For this plot, we use the `semproj_perCondition` data frame
that contains the averages for all three tasks, split up by block and experimental condition.
The code is otherwise the same as before,
but I've added one additional line:
`facet_wrap` splits up the
data according to a variable (here `Task`)
and plots a separate plot for each part.
By default, the axes of the different subplots
span the same range so that 
differences in overall performance 
can easily be compared between the three tasks.
So not only is this quicker than drawing three separate graphs,
it also saves (vertical) space _and_ the side-by-side plots are easier to compare with one another than
three separate plots would be.


{% highlight r %}
ggplot(data = semproj_perCondition,
       aes(x = Block,
           y = MeanProportionCorrect,
           colour = BiasCondition)) +
  geom_line() +
  facet_wrap(~ Task)
{% endhighlight %}

![center](/figs/2016-06-13-drawing-a-linechart/unnamed-chunk-13-1.png)

#### A printer-friendly version
If you prefer a printer-friendly version,
you can add the `theme_bw()` command to the ggplot call (10th line)
and specify that the different experimental conditions
should be distinguished using different linetypes (solid, dashed, dotted) rather than different colours (4th line).
Since the difference between dashed and dotted lines may not be immediately obvious,
it can be a good idea to also plot the averages using different symbols (lines 5 and 6).


{% highlight r %}
ggplot(data = semproj_perCondition,
       aes(x = Block,
           y = MeanProportionCorrect,
           linetype = BiasCondition,
           shape = BiasCondition)) +
  geom_point() +
  geom_line() +
  facet_wrap(~ Task) +
  theme_bw()
{% endhighlight %}

![center](/figs/2016-06-13-drawing-a-linechart/unnamed-chunk-14-1.png)

#### With customised legends and labels
The plot above is okay, but you can go the extra mile
by customising the axis and legend labels rather than using the defaults---even if they are comprehensible, it just makes a better impression to do so:

1. The `xlab` and `ylab` commands change the names of the x- and y-axes. Note that `\n` starts a new line. 
2. With `scale_shape_manual`, I changed the `labels` of the legend for the different symbols. I also changed the symbols themselves (`values`) as I thought the default symbols were difficult to tell apart. 
The values 1, 2 and 3 work fine for this graph, I think, but you can try out different values ([handy list with symbol numbers](http://sape.inf.usi.ch/quick-reference/ggplot2/shape)). 
3. If you customise the labels and symbols for the `shape` parameter, you need to do the same for the `linetype` parameters---otherwise, R gets confused. This is what I did in `scale_linetype_manual`. Note that the `labels` must occur in the same order as the labels in `scale_shape_manual`. ([handy list with linetypes](http://sape.inf.usi.ch/quick-reference/ggplot2/linetype))
4. In both `scale_shape_manual` and `scale_linetype_manual`, I set `name` to `"Learning condition"`.
This changes the title of the legend, and by using the same title twice, you tell R to combine the two
legends into one.
5. In `theme`, `legend_position` specifies where the legend should go (on top rather than on the right),
and `legend_direction` whether the keys should be plotted next to (horizontal) or under (vertical) each other.
6. The lines with `panel.grid` draw horizontal grid lines to facilitate the comparison between tasks and suppress any vertical grid lines ggplot may draw.


{% highlight r %}
ggplot(data = semproj_perCondition,
       aes(x = Block,
           y = MeanProportionCorrect,
           linetype = BiasCondition,
           shape = BiasCondition)) +
  geom_point() +
  geom_line() +
  xlab("Experimental block") +
  ylab("Mean proportion\nof correct responses") +
  facet_wrap(~ Task) +
  theme_bw() +
  scale_shape_manual(values = c(1, 2, 3),
                     labels = c("rule-based",
                                "strongly biased",
                                "weakly biased"),
                     name = "Learning condition") +
  scale_linetype_manual(values = c("solid", "dotted", "dotdash"),
                        labels = c("rule-based",
                                   "strongly biased",
                                   "weakly biased"),
                        name = "Learning condition") +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        panel.grid.major.y = element_line(colour = "grey65"),
        panel.grid.minor.y = element_line(colour = "grey85", size = 0.2),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank())
{% endhighlight %}

![center](/figs/2016-06-13-drawing-a-linechart/unnamed-chunk-15-1.png)
