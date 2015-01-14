---
title: "Overaccuracy and false precision"
layout: post
tags: [statistics]
category: [stats 101]
---

I once attended a talk at a conference where the speaker underscored his claim by showing us a Pearson correlation coefficient -- reported with 9-digit (give or take) precision….
Five years later, I can neither remember what the central claim was nor could I ball-park the correlation coefficient -- I only recall that it consisted of nine or so digits.
Hence the take-home message of this post: ask yourself how many digits are actually meaningful.

<!--more-->

### Overaccuracy
I'm currently reading Jeff Siegel's [_Second Dialect Acquisition_](http://www.cambridge.org/ch/academic/subjects/languages-linguistics/applied-linguistics-and-second-language-acquisition/second-dialect-acquisition).
So far I find it to be a well written summary of an interesting topic, combining as it does the subject matter of the class I'll be teaching next semester (Second Language Acquisition) with a field I was rather fond of as an undergrad (dialectology) and the general theme of my thesis (closely related languages).
But I also stumbled upon a couple of sentences like these:

> For example, when his [= Donn Bayard's] son was 8 years old, he used the NZE [New Zealand English] R-lessness variant 68.3 per cent of the time when talking to NZE-speaking friends, but only 34.2 per cent of the time when speaking to his NAE [North American English]-speaking parents.
> In other words, he maintained his D1 [native dialect] feature of non-prevocalic /r/ to some extent, using it 65.8 per cent of the time with his parents but repressing it with his peers, using it only 31.7 per cent of the time. (pp. 68-69)

I don't doubt that this is an accurate description of Bayard's findings, which appeared in the 1995 volume of the [_New Zealand English Newsletter_](http://www.arts.canterbury.ac.nz/linguistics/nzej/nzejback-issues.shtml).
Quite the contrary: I think it's _too_ accurate a description of his research findings.
**Overaccuracy** is only a minor pet peeve of mine, but it ties in with my feeling that we can do with [fewer](http://janhove.github.io/silly%20significance%20tests/2014/10/15/tautological-tests/) [tests](http://janhove.github.io/silly%20significance%20tests/2014/09/26/balance-tests/) when reporting research findings, so here goes.

Without having read Bayard's paper (it's unavailable), it's necessarily true that its results were based on a sample of linguistic behaviour -- if you were to run the same study again in a parallel universe, you'd be unlikely to come up with the exact same numbers (**sampling error**).
Reporting these frequencies with one-in-thousand precision, however,
projects more certainty about the child's preferences than you really have.
Of course, readers with some research experience under their belt will be aware 
that you can't really know this sort of thing with per-mille precision.
These readers will probably mentally transform the numbers reported to mean "roughly two in three" (68.3 and 65.8%) and "about one in three" (34.2 and 31.7%) and consider that to be the paper's take-home message.
But if that's the (quite elegant, I think) take-home message, why not just say it like that?
Admittedly, "about two thirds of the time" doesn't _sound_ very scientific, though I do think it's an accurate summary of the trends in the data that also gives a fairer if rough estimate of the uncertainty surrounding that summary.

Another way to look at this involves computing a confidence interval around these frequencies.
Assuming that Bayard's son produced 1,000 relevant tokens when talking to his NZE-speaking friends (I don't know as I don't have access to the original study), out of which 683 were R-less, we can compute a 95% confidence interval around this proportion as follows:


{% highlight r %}
prop.test(683, 1000)$conf.int
{% endhighlight %}



{% highlight text %}
## [1] 0.6529967 0.7115785
## attr(,"conf.level")
## [1] 0.95
{% endhighlight %}

Confidence intervals are trickier to interpret than you'd think (I'm not sure whether I've entirely figured them out myself), 
but at the very least this interval (65-71%) helps to put the third digit in perspective: it's scientifically -- as well as rhetorically -- meaningless at best and mentally cluttering at worst.
There's an argument to be made for reporting such intervals to counter overaccuracy, and you could question whether the second digit conveys any useful information,
but I'd already be happy with the in-between solution of reporting such relative frequencies by rounding them up to the nearest percentage (i.e. 68, 66, 34 and 32%).
Incidentally, I don't want to single out Siegel's rendition of Bayard's findings:
examples of over-accurate reporting abound in the scientific literature ([Andrew Gelman](http://andrewgelman.com) occassionally discusses some cases, too).

### False precision
An issue more basic than overaccuracy is **false precision**. An example of false precision is the following state of affairs.
Researchers working with response latencies (measured in milliseconds) often tabulate the mean response latency as well as its standard deviation for each experimental group -- and do so with one ten-thousandth of a second's percision. For instance, when the latencies measured are 378, 512 and 483 ms, the mean and standard deviation will often be reported as 457.7 and 70.5 ms.

The problem with this isn't that it's an inaccurate summary of the data.
Rather, the problem is that reporting a mean as being 457.7 milliseconds suggests that your instruments allow you to make measurements precise to one ten-thousandth of a second rather than to one thousandth of a second -- an order-of-magnitude difference.
This **false precision** is a slightly different problem from overaccuracy, e.g. reporting relative frequencies with per-mille precision.
My issue with the overaccurate reporting of relative frequencies is that it portrays a greater degree of certainty about the 'true' proportion (i.e. the _population_ parameter) than the data allow;
the problem with false precision is that it conveys a level of confidence in the descriptive statistics (i.e. the _sample_ estimate) and the instruments used that is off by one or more orders of magnitude.

The rule of thumb (instilled into my mind by my physics teachers) is 
to avoid reporting more [**significant figures**](http://en.wikipedia.org/wiki/Significant_figures) in numerical summaries than the measurements themselves had.
In other words, since the measurements were made with millisecond precision, descriptive statistics should be reported with -- at most -- millisecond precision, too.
While this is a useful principle, I doubt that its wholesale adoption in applied linguistics is around the corner.
But it's something to keep in mind.

### Conclusion
The introductory example featured a 9-digit correlation coefficient. I don't remember anything about the study itself, but let's say the correlation coefficient reported was 0.228526687.
Even with 10,000 observations, the 95% confidence interval around this coefficient is [0.21, 0.25]. (With 100 observations, it's [0.0 - 0.4]. Confidence intervals around correlation coefficients are _huge_!)
Thus, in terms of telling us something about the patterns in the population, the last 7 digits don't buy us _anything_. 
If we additionally consider the coarseness of the measurements in social science research and in the humanities (e.g. questionnaire data), it's doubtful whether even the second digit contains any _meaningful_ information about the patterns in the _sample_.

I don't have any clear-cut guidelines to offer, but asking yourself how many digits actually contribute meaningful information seems like a good place to start.
There's nothing unscientific or sloppy about reporting '_r_ = 0.23' or even '_r_ = 0.2' if that better reflects the precision of the measurements and the uncertainty of the inferences.
