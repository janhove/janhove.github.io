---
title: "Tutorial: Visualising statistical uncertainty using model-based graphs"
layout: post
mathjax: true
tags: [R, graphics, logistic regression, mixed-effects models, multiple regression, Bayesian statistics, brms]
category: [Reporting]
---

I wrote a tutorial about visualising the statistical uncertainty in 
statistical models for a conference that took place a couple of months ago,
and I've just realised that I've never advertised this tutorial in this blog.
You can find the tutorial here: 
[Visualising statistical uncertainty using model-based graphs(https://janhove.github.io/visualise_uncertainty).

<!--more-->

Contents:

1. Why plot models, and why visualise uncertainty?
2. The principle: An example with simple linear regression
		2.1. Step 1: Fit the model
		2.2. Step 2: Compute the conditional means and confidence intervals
					+ The analytic approach
					+ Extra: More about the analytic approach
					+ Extra: The brute-force approach
		2.3. Step 3: Plot!
3. Predictions about individual cases vs. conditional means
4. More examples
		4.1. Several continuous predictors
					+ How-to
					+ Comments and caveats
		4.2. Dealing with categorical predictors
					+ A categorical predictor as the focal predictor
					+ A categorical predictor as a non-focal predictor
		4.3. t-tests are models, too
		4.4. Dealing with interactions
					+ Between categorical variables
					+ Between a categorical and a continuous variable
					+ Between continuous variables
		4.5. Ordinary logistic regression
		4.6. Mixed-effects models
					+ lmer()
					+ brm()
		4.7. Logistic mixed effects models
					+ glmer()
					+ Extra: brm()
5. Caveats
		5.1. Other things may not be equal
		5.2. Your model may be misspecified
		5.3. Other models may yield different pictures
6. References
