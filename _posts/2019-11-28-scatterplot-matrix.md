---
title: "Adjusting for a covariate in cluster-randomised experiments"
layout: post
mathjax: true
tags: [R, graphics, correlational studies, non-linearities, multiple regression]
category: [Reporting]
---

This is just a quick blog post to share a function with which
you can draw scatterplot matrices.

<!--more-->

Scatterplot matrices are useful for displaying the intercorrelation between
several continuous variables. Based on the help page for the `pairs()` function
in `R`, I put together a function for quickly drawing scatterplot matrices
that also show the Pearson correlation coefficients for the bivariate relationships
as well as the number of observations that go into them: `scatterplot_matrix()`.
Here's how you'd use it:


{% highlight r %}
# Read in the function
source("https://janhove.github.io/RCode/scatterplot_matrix.R")

# Example: airquality is a built-in dataset in R
data(airquality)

scatterplot_matrix(
  x = subset(airquality, select = c(Ozone, Wind, Temp, Solar.R, Month)),
  labels = c("Ozone", "Wind", "Temperature", "Solar radiation", "Month")
)
{% endhighlight %}

![center](/figs/2019-11-28-scatterplot-matrix/unnamed-chunk-35-1.png)

Use:

* `x` contains the vectors (= columns in a dataset) containing the continuous variables you want to plot in the order you want to plot them. To the extent possible, try to arrange the variables in such an order that the earlier variables are more likely to be influenced by the later variables than vice versa. I'm hardly an expert on meteorology, so the order in which I put the variables may not be optimal -- but `Month` is evidently more likely to influence `Temp`erature than vice versa, so put `Month` somewhere after `Temp`. Similarly, if you collected your participants' age, L1 vocabulary skills, and their results on a cognate translation test in L2, put age last, L1 vocabulary skills second and the translation test results first.

* `labels` contains the readable names of the variables, in that same order. If you leave out this argument, the column names will serve as labels.

Output:

* Main diagonal: Histograms for each variable as well as the number of available data points for that variable.

* Upper triangle: Scatterplots for the bivariate relationships between the variables, with a nonlinear scatterplot smoother. In the example above, the scatterplot in the first row, third column, shows the relationship between the Temperature (the third variable, on the x-axis) and Ozone (the first variable, on the y-axis). The scatterplot in the second row, fifth column, shows the relationship between Month (the fifth variable, on the x-axis) and Wind (the second variable, on the y-axis).

* Lower triangle: Pearson correlation coefficients for the bivariate relationships between the variables and the number of observations on which it is based. In the example above, the correlation coefficient in the third row, first column, concerns the relationship between the Temperature and Ozone (the first variable). The correlation coefficient in the second row, fifth column, shows the relationship between Month (the fifth variable) and Wind (the second variable).


Functions you can use instead of this one are
`pairscor.fnc()` in the `languageR` package,
and `ggscatmat()` and `ggpairs()` in the `GGally` package.



