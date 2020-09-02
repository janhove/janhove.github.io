---
title: "Capitalising on covariates in cluster-randomised experiments"
layout: post
mathjax: true
tags: [R, power, significance, design features, cluster-randomised experiments, preprint]
category: [Design]
---

In cluster-randomised experiments, participants are assigned to the
conditions randomly but not on an individual basis. Instead, entire
batches ('clusters') of participants are assigned in such a way that
each participant in the same cluster is assigned to the same condition.
A typical example would be an educational experiment in which all
pupils in the same class get assigned to the same experimental condition.
Crucially, the analysis should take into account the fact that the
random assignment took place at the cluster level rather than at the
individual level.

Also typically in educational experiments, researchers have some 
information about the participants' performance before the intervention
took place. This information can come in the form of a covariate,
for instance the participants' performance on a pretest or some 
self-assessment of their skills. Even in experiments that use random
assignment, including such covariates in the analysis
is useful as they help to reduce the error variance. Lots of different
methods for including covariates in the analysis of cluster-randomised
experiments are discussed in the literature, but I couldn't find any
discussion about the merits and drawbacks of these different methods.

In order to provide such discussion, I ran a series of simulations to 
compare 25 (!) different ways of including a covariate in the analysis
of a cluster-randomised experiment in terms of their Type-I error and
their power. The **article** outlining these simulations and the findings
is available from [PsyArXiv](https://doi.org/10.31234/osf.io/ef4zc);
the **R code** used for the simulations as well as its output is available
from the [Open Science Framework](https://osf.io/wzjra/). In the remainder
of this post, I'll discuss how these simulations may be useful to you if you're
planning to run a cluster-randomised experiment.

<!--more-->

## So what's the upshot?
Please read pages 1--3 and pages 40--42 of the [article](https://doi.org/10.31234/osf.io/ef4zc) :)

## I know of some analytical method that you didn't consider.
Ah, interesting! It took a long time to run these simulations
(about 36 hours), during which I couldn't use my computer for anything
else, so I'm not exactly gung-ho about rerunning them just to include
one additional analytic method.

But here's what you can do. Go to the [OSF page](https://osf.io/wzjra/)
and download the files `functions/generate_clustered_data.R` and
`scripts/additional_simulations.Rmd`. The latter file 
contains some smaller-scale simulations that don't take as long to run.
Adapt the simulations there and check if the analytical method you 
know of has an acceptable Type-I error rate for a variety 
of parameter settings. (Two examples are available, but if you can't
make sense of them, let me know.) If its Type-I error rate is acceptable,
run another batch of simulations to assess its power and compare it
to the power for the best-performing methods in my simulation.

If your method compares well to these best-performing methods in terms of both its Type-I error rate and its power, drop me a line, and perhaps
I'll get round to rerunning the large-scale simulations. Better still,
download the other functions and scripts, include your method
in `functions/analyse_clustered_data.R`, and adjust the other files
accordingly. Then run the simulation yourself :)

## I don't think your parameter choices are relevant for my study.
Perhaps your study will feature clusters that vary more strongly
in size than was the case in my simulations. Or perhaps you suspect
that the intracluster correlation will be quite different from the
ones that I considered. Or perhaps etc., etc., etc. It'd be better
if the results of the simulations were more directly relevant to 
what you suspect your study will look like.

But here's the beauty. You can go to the 
[OSF page](https://osf.io/wzjra/),
download all the functions and scripts, and tailor the
simulation parameters to your liking. In 
`script/simulation_type_I_error.R` and `script/simulation_power.R`, 
you can change the cluster sizes, the number of clusters,
the strength of the covariate, the ICC, the effect, and the
randomisation scheme. Then run these scripts and figure out
which analysis method will likely retain its nominal Type-I error
while maximising power.

## When generating the data, you're making some assumptions I'm not willing to make.
The assumptions are outlined in the article on pp. 23--24,
and they are made more explicit in the function that generates
the data (`functions/generate_clustered_data.R`). Perhaps they're
unrealistic. For instance, the data are all drawn from normal 
distributions, the covariate is linearly related to the outcome,
etc. If you want to revise these assumptions, you'll have to 
edit this function. (Test the function extensively afterwards!)
Then re-run the simulations, with the simulation parameters tailored
to your study.

## Which journal will this article be published in?
At the moment, I don't intend to submit this article to any journal.
The main reason is that anyone who may be interested in it already
has free access to it. If anyone has any feedback, I'd be happy to
hear it, but I don't currently feel like jumping through a series of
hoops in some drawn-out reviewing process.
