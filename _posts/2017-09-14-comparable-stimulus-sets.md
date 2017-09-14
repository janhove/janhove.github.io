---
layout: post
title: "Creating comparable sets of stimuli"
category: [Design]
tags: [R, design features, organisation]
---

When designing a study, you sometimes have a pool of candidate stimuli
(words, sentences, texts, images etc.) that is too large to present to
each participant in its entirety. If you want data for all or at least
most stimuli, a possible solution is to split up the pool of stimuli
into sets of overseeable size and assign each participant to one of the
different sets. Ideally, you'd want the different sets to be as comparable
as possible with respect to a number of relevant characteristics so that
each participant is exposed to about the same diversity of stimuli during
the task. For instance, when presenting individual words to participants,
you may want for each participant to be confronted with a similar distribution
of words in terms of their frequency, length, and number of adverbs. 
In this blog post I share some `R` code that I used to split up two 
types of stimuli into sets that are comparable with respect to one or several
variables---in the hopes that you can easily adapt them for your own needs.

<!--more-->

Fair warning: There's lots of `R` code below, but it's mainly a matter
of copy-pasting the same lines and changing one or two things.
If the `R` is poorly organised on your screen, you can copy-paste it
into RStudio.

# Creating sets that are identical with respect to one categorical variable
I have a list of 144 sentences that I want to use as stimuli in an experiment.
I categorised these sentences into five different-sized plausibility categories myself.
The categories themselves don't matter here, but before running the experiment
itself I want to make sure that my categorisation agrees with people's 
intuitions about the plausibility of these sentences. To that end, I will 
run a validation study in which people rate their plausibility. The way the 
validation study is designed, it would take about half an hour to rate the
plausibility of all 144 sentences. This isn't that long, but when I can't pay
the participants, I prefer to keep the task's duration at 10 minutes or so.
To that end, I split up the pool of 144 sentences into 3 sets of 48 each.
But rather than constructing these sets completely at random, 
I ensured that the plausibility categories (as I had defined them)
were distributed identically in each set,
so that each participant would be confronted with roughly the same
variation in terms of the sentences' plausibility. This is just a matter
of randomly splitting up each of the categories into 3 sets, but the code
below automises this.

First, you need a dataframe that lists the stimuli and their categories.
Below, I just create this dataframe in `R`, but you can also read in a
spreadsheet with the candidate stimuli.


{% highlight r %}
# I'll be using the tidyverse suite throughout.
# Use 'install.packages("tidyverse")' if you don't have it installed.
library(tidyverse)

# Create a dataframe with the sentence IDs and each sentence's category:
stimuli <- data.frame(ID = 1:144,
                      Category = rep(x = c("PNR", "INR", "PR", "IR", "SYM"),
                                     times = c(24, 18, 18, 36, 48)))

# Number of sentences per category in the entire pool
table(stimuli$Category)
{% endhighlight %}

In this case, the numbers of stimuli per category are all divisible
by the number of sets (3), but the code below will also work when this isn't
the case (e.g., when the number of INR items would be 16 and the number of IR items 38).
In such cases, the algorithm will create comparable equal-sized sets and a handful
of items will remain unassigned. You can try this yourself by changing the number
of stimuli per category above, or by setting `n_sets` below to, say, 5.


{% highlight r %}
# Get number of categories
categories <- unique(stimuli$Category)
# Set number of desired sets
n_sets <- 5

# Creata a column that will specify the set the stimulus was assigned to
stimuli$Set <- NA

# For each category...
for (i in 1:length(categories)) {
  # Get number of stimuli in this category
  n_in_category <- stimuli %>% 
    filter(., Category == categories[i]) %>% 
    nrow()
  
  # Throw warning if n_in_category isn't divisible by n_sets
  if ((n_in_category %% n_sets) > 0) {
    warning(paste("The number of items in category ", categories[i], " is ", n_in_category, 
               ", which isn't divisible by ", n_sets, ". ", 
               n_in_category %% n_sets, " items in this category will remained unassigned.\n",
               sep = ""))
  }
  
  # Assign items randomly to sets (equal number of items per set).
  # If n_in_category isn't divisible by n_sets, mod(n_in_category, n_sets) items will
  # remain unassigned ('NA').
  stimuli$Set[stimuli$Category == categories[i]] <- c(rep(LETTERS[1:n_sets], 
                                                          each = floor(n_in_category/n_sets)), 
                                                      rep(NA, 
                                                          times = n_in_category %% n_sets)) %>% 
    sample()
}
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category PNR is 24, which isn't divisible by 5. 4 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category INR is 18, which isn't divisible by 5. 3 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category PR is 18, which isn't divisible by 5. 3 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category IR is 36, which isn't divisible by 5. 1 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category SYM is 48, which isn't divisible by 5. 3 items in this category will remained unassigned.
{% endhighlight %}

The column `Set` now specifies which set each item was assigned to,
and all sets have the same distribution of `Category`.


{% highlight r %}
head(stimuli)
xtabs(~ Set + Category, stimuli)
{% endhighlight %}

If the numbers of stimuli per category aren't all divisible by the
number of sets, some stimuli will remained unassigned. If you want
to have data on all stimuli, you could randomly assign these remaining
stimuli to the sets. The sets won't be identically distributed with
regard to the categories, but depending on what you want, it may be
good enough.

# Creating similar sets with respect to several categorical variables

For another study, we had 1,065 short texts for which we wanted to
collect human lexical richness ratings. Some of the texts were
narrative, others argumentative; some were written by bilingual children
and others by children in a monolingual control group; and some
were written when the children were 8, 9 or 10 years old.
You can't expect volunteers to rate 1,065 texts, so we decided
to split them up into 20 sets of 53 texts each.
(In reality, each set contained only 50 texts as we excluded a bunch of
very short texts.) The sets were constructed so as to be 
maximally similar in terms of narrative vs. argumentative texts,
texts written by bi- vs. monolingual children, 
and texts written by 8-, 9- and 10-year-olds.
Below is the commented `R` code used to construct them.

First read in a dataframe containing the `TextID`s
and info regarding bi- vs. monolingual (`ControlGroup`),
`TextType` and the children's age (`Time`: 1, 2, 3).
The dataframe for this example is available from http://homeweb.unifr.ch/VanhoveJ/Pub/Data/french_texts.csv.


{% highlight r %}
texts <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/french_texts.csv")
summary(texts)
{% endhighlight %}



{% highlight text %}
##      TextID     ControlGroup    TextType        Time      
##  Min.   :   1   Mode :logical   arg :559   Min.   :1.000  
##  1st Qu.: 267   FALSE:632       narr:506   1st Qu.:1.000  
##  Median : 533   TRUE :433                  Median :2.000  
##  Mean   : 533   NA's :0                    Mean   :2.009  
##  3rd Qu.: 799                              3rd Qu.:3.000  
##  Max.   :1065                              Max.   :3.000
{% endhighlight %}

Here's how many texts there are for each combination of the three
variables:


{% highlight r %}
xtabs(~ ControlGroup + TextType + Time, texts)
{% endhighlight %}



{% highlight text %}
## , , Time = 1
## 
##             TextType
## ControlGroup arg narr
##        FALSE 113  100
##        TRUE   78   50
## 
## , , Time = 2
## 
##             TextType
## ControlGroup arg narr
##        FALSE 109  108
##        TRUE   82   74
## 
## , , Time = 3
## 
##             TextType
## ControlGroup arg narr
##        FALSE 101  101
##        TRUE   76   73
{% endhighlight %}

There are 2×2×3 = 12 combinations of these three variables.
Create a new variable that specifies which of these combinations
each text belongs to:


{% highlight r %}
# Paste the grouping variables together
texts$Combined <- paste(texts$ControlGroup, texts$TextType, texts$Time, 
                        sep = "")

# Breakdown of texts per combination
table(texts$Combined)
{% endhighlight %}



{% highlight text %}
## 
##  FALSEarg1  FALSEarg2  FALSEarg3 FALSEnarr1 FALSEnarr2 FALSEnarr3 
##        113        109        101        100        108        101 
##   TRUEarg1   TRUEarg2   TRUEarg3  TRUEnarr1  TRUEnarr2  TRUEnarr3 
##         78         82         76         50         74         73
{% endhighlight %}

To divide up these texts evenly into 20 sets, we'll need at least the
following numbers of texts per combination per batch:


{% highlight r %}
floor(table(texts$Combined)/20)
{% endhighlight %}



{% highlight text %}
## 
##  FALSEarg1  FALSEarg2  FALSEarg3 FALSEnarr1 FALSEnarr2 FALSEnarr3 
##          5          5          5          5          5          5 
##   TRUEarg1   TRUEarg2   TRUEarg3  TRUEnarr1  TRUEnarr2  TRUEnarr3 
##          3          4          3          2          3          3
{% endhighlight %}

That is, we'll need 5 `FALSEarg1` texts, 3 `TRUEarg2` texts etc. per set.
These numbers add up to 48 in this case, which means that 20×48 = 960 out of 1,065
texts can be already be assigned by applying the code from the previous example.
Below I only changed the name of the dataframe (`stimuli` became `texts`)
and of the column containing the categories (`Category` became `Combined`).


{% highlight r %}
# Get category names
categories <- unique(texts$Combined)
# Set desired number of sets
n_sets <- 20
# Create column that'll contain the set names
texts$Set <- NA

# For each category...
for (i in 1:length(categories)) {
  # Get number of stimuli in this category
  n_in_category <- texts %>% 
    filter(., Combined == categories[i]) %>% 
    nrow()
  
  # Throw warning if n_in_category isn't divisible by n_sets
  if ((n_in_category %% n_sets) > 0) {
    warning(paste("The number of items in category ", categories[i], " is ", n_in_category, 
                  ", which isn't divisible by ", n_sets, ". ", 
                  n_in_category %% n_sets, " items in this category will remained unassigned.\n",
                  sep = ""))
  }
  
  # Assign items randomly to sets (equal number of items per set).
  # If n_in_category isn't divisible by n_sets, mod(n_in_category, n_sets) items will
  # remain unassigned ('NA').
  texts$Set[texts$Combined == categories[i]] <- c(rep(LETTERS[1:n_sets], 
                                                      each = floor(n_in_category/n_sets)), 
                                                  rep(NA, 
                                                      times = n_in_category %% n_sets)) %>% 
    sample()
}
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSEarg1 is 113, which isn't divisible by 20. 13 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSEarg2 is 109, which isn't divisible by 20. 9 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSEnarr2 is 108, which isn't divisible by 20. 8 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSEarg3 is 101, which isn't divisible by 20. 1 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSEnarr3 is 101, which isn't divisible by 20. 1 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEarg1 is 78, which isn't divisible by 20. 18 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEarg2 is 82, which isn't divisible by 20. 2 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEarg3 is 76, which isn't divisible by 20. 16 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEnarr1 is 50, which isn't divisible by 20. 10 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEnarr2 is 74, which isn't divisible by 20. 14 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUEnarr3 is 73, which isn't divisible by 20. 13 items in this category will remained unassigned.
{% endhighlight %}

Now each set contains 48 texts and all sets are identically distributed with
regard to each combination of the three structural variables. This leaves
105 texts unassigned. For this project, it wasn't so important that the 
distributions of the structural variables `TextType`, `ControlGroup` and
`Time` were exactly identical in each set, just close enough.

In order to assign the remaining texts to sets, we loosened up the constraints
slightly: to each set, we added as many texts as possible while ensuring
that the joint distribution of `ControlGroup` and `Time` would be identical
across the sets; we didn't insist on equality in terms of `TextType` any more.


{% highlight r %}
# Combine ControlGroup and Time info.
texts$Combined <- paste(texts$ControlGroup, texts$Time,
                         sep = "")

# Retain only unassigned texts
texts_2b_assigned <- texts %>% filter(is.na(Set))

# One 'TRUE1' and one 'TRUE3' will be assigned to each set
# (fewer than 20 texts remaining for the other combinations):
floor(table(texts_2b_assigned$Combined)/20)
{% endhighlight %}



{% highlight text %}
## 
## FALSE1 FALSE2 FALSE3  TRUE1  TRUE2  TRUE3 
##      0      0      0      1      0      1
{% endhighlight %}

We can again copy-paste and slightly adapt the code above.
I've commented all changes:


{% highlight r %}
categories <- unique(texts$Combined)

for (i in 1:length(categories)) {
  # Get number of UNASSIGNED stimuli in this category
  n_in_category <- texts %>% 
    # only the unassigned stimuli
    filter(is.na(Set)) %>% 
    filter(., Combined == categories[i]) %>% 
    nrow()
  
  if ((n_in_category %% n_sets) > 0) {
    warning(paste("The number of items in category ", categories[i], " is ", n_in_category, 
                  ", which isn't divisible by ", n_sets, ". ", 
                  n_in_category %% n_sets, " items in this category will remained unassigned.\n",
                  sep = ""))
  }

  # Note the additional selector ("is.na(texts$Set)"): we only want to assign
  # the stimuli that haven't been assigned yet.
  texts$Set[is.na(texts$Set) & texts$Combined == categories[i]] <- c(rep(LETTERS[1:n_sets], 
                                                                          each = floor(n_in_category/n_sets)), 
                                                                      rep(NA, 
                                                                          times = n_in_category %% n_sets)) %>% 
    sample()
}
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSE1 is 13, which isn't divisible by 20. 13 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSE2 is 17, which isn't divisible by 20. 17 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSE3 is 2, which isn't divisible by 20. 2 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUE1 is 28, which isn't divisible by 20. 8 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUE2 is 16, which isn't divisible by 20. 16 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUE3 is 29, which isn't divisible by 20. 9 items in this category will remained unassigned.
{% endhighlight %}

With 20×2 = 40 additional texts assigned, all sets now contain 50 stimuli
and 65 texts remain unassigned. To assign as many of the remaining texts
as possible, we can again loosen the constraints and only insist that all
sets be identical in terms of their `ControlGroup` distribution (for instance).
Apart from the first line, the code is the same as above:


{% highlight r %}
# Combine ControlGroup
texts$Combined <- paste(texts$ControlGroup, sep = "")

categories <- unique(texts$Combined)

for (i in 1:length(categories)) {
  # Get number of UNASSIGNED stimuli in this category
  n_in_category <- texts %>% 
    # only the unassigned stimuli
    filter(is.na(Set)) %>% 
    filter(., Combined == categories[i]) %>% 
    nrow()
  
  if ((n_in_category %% n_sets) > 0) {
    warning(paste("The number of items in category ", categories[i], " is ", n_in_category, 
                  ", which isn't divisible by ", n_sets, ". ", 
                  n_in_category %% n_sets, " items in this category will remained unassigned.\n",
                  sep = ""))
  }

  # Note the additional selector ("is.na(texts$Set)"): we only want to assign
  # the stimuli that haven't been assigned yet.
  texts$Set[is.na(texts$Set) & texts$Combined == categories[i]] <- c(rep(LETTERS[1:n_sets], 
                                                                          each = floor(n_in_category/n_sets)), 
                                                                      rep(NA, 
                                                                          times = n_in_category %% n_sets)) %>% 
    sample()
}
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category FALSE is 32, which isn't divisible by 20. 12 items in this category will remained unassigned.
{% endhighlight %}



{% highlight text %}
## Warning: The number of items in category TRUE is 33, which isn't divisible by 20. 13 items in this category will remained unassigned.
{% endhighlight %}

Now each set contains 52 texts. The distribution of `ControlGroup`
is the same in each set; the distributions of `TextType` and `Time`
are similar but not identical across sets.


{% highlight r %}
table(texts$Set)
{% endhighlight %}



{% highlight text %}
## 
##  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T 
## 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52 52
{% endhighlight %}

If you want, you randomly assign 20 of the remaining 25 texts to a set;
5 texts will remain unassigned if we insist on each set having the same
number of texts:


{% highlight r %}
# Get number of unallocated stmuli
unallocated <- sum(is.na(texts$Set))

# How many stimuli will remain unallocated?
remain_unallocated <- unallocated %% n_sets

# Allocate whatever texts we still can allocate randomly
allocations <- c(rep(LETTERS[1:n_sets], length.out = unallocated - remain_unallocated), 
                 rep(NA, remain_unallocated))

# randomise these
allocations <- sample(allocations)

# add them to data frame
texts$Set[is.na(texts$Set)] <- allocations
{% endhighlight %}

This way, each set contains 53 texts:


{% highlight r %}
table(texts$Set)
{% endhighlight %}



{% highlight text %}
## 
##  A  B  C  D  E  F  G  H  I  J  K  L  M  N  O  P  Q  R  S  T 
## 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53 53
{% endhighlight %}

While the sets aren't with respect to the structural variables
`ControlGroup`, `TextType` and `Time`, they are highly similar:

![center](/figs/2017-09-14-comparable-stimulus-sets/unnamed-chunk-258-1.png)

# Dealing with numerical variables
I haven't dealt with numerical variables yet
(e.g., constructing word sets that are similar in terms
of their corpus frequency), but I think a reasonable way
of going about it would be to bin the numerical variable
(e.g., convert it to a variable with 10 categories) and
apply the functions above. If too many stimuli remain
unallocated, the remaining stimuli could be allocated
using a wider bin size.

This was probably a bit messy with all the R code, but 
I hope some of you found it useful!
