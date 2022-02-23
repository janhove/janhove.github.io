---
title: "An R function for computing Levenshtein distances between texts using the word as the unit of comparison"
layout: post
mathjax: true
tags: [R]
category: [Programming]
---

For a new research project, we needed a way to tabulate
the changes that were made to a text when correcting it.
Since we couldn't find a suitable tool, I wrote an 
R function that uses the Levenshtein algorithm to determine
both the smallest number of words that need to be changed
to transform one version of a text into another
and what these changes are.

<!--more-->

You can download the `obtain_edits()` function from https://janhove.github.io/RCode/obtainEdits.R
or source it directly:


{% highlight r %}
source("https://janhove.github.io/RCode/obtainEdits.R")
{% endhighlight %}

The function recognises words that were deleted or inserted,
words that were substituted for other words, and cases
where one word was split into two words or where two words
were merged to one word. All these changes count as one operation.
The algorithm determines both the smallest number of operations
needed to transform one version of the text into the other
and outputs a data frame that lists what these operations are.

Here's an example:

{% highlight r %}
original  <- "Check howmany changes need be made in order to change the first tekst in to the second one."
corrected <- "Check how many changes need to be made in order to change the first text into the second one."
obtain_edits(original, corrected)
{% endhighlight %}



{% highlight text %}
## [[1]]
## [1] 4
## 
## [[2]]
##   change_position  change_type change_from change_to
## 1              14       merger       in to      into
## 2              13 substitution       tekst      text
## 3               5    insertion                    to
## 4               2        split     howmany  how many
{% endhighlight %}

Note that while the minimal operation count is uniquely determined,
the list of changes that were made isn't. Consider this example:


{% highlight r %}
textA <- "first secondthird"
textB <- "second third"
obtain_edits(textA, textB)
{% endhighlight %}



{% highlight text %}
## [[1]]
## [1] 2
## 
## [[2]]
##   change_position change_type change_from    change_to
## 1               2       split secondthird second third
## 2               1    deletion       first
{% endhighlight %}

The algorithm identifies the difference from `textA` to `textB`
as a matter of deleting 'first' and splitting up 'secondthird'.
But we could also consider it a matter of substituting 'second' for 'first'
and 'third' for 'secondthird'.

Nothing about stats or research design in this post, but perhaps this 
function is useful to someone somewhere!
