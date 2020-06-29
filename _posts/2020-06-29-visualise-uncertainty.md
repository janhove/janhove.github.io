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
[Visualising statistical uncertainty using model-based graphs](https://janhove.github.io/visualise_uncertainty).

<!--more-->

Contents:

<ol>
<li>Why plot models, and why visualise uncertainty?</li>
<li>The principle: An example with simple linear regression</li>
	<ol>
		<li>Step 1: Fit the model</li>
		<li>Step 2: Compute the conditional means and confidence intervals</li>
		<li>Step 3: Plot!</li>
	</ol>
<li>Predictions about individual cases vs. conditional means</li>
<li>More examples</li>
	<ol>
		<li>Several continuous predictors</li>
		<li>Dealing with categorical predictors</li>
		<li>t-tests are models, too</li>
		<li>Dealing with interactions</li>
		<li>Ordinary logistic regression</li>
		<li>Mixed-effects models</li>
		<li>Logistic mixed effects models</li>
	</ol>
<li>Caveats</li>
	<ol>
		<li>Other things may not be equal</li>
		<li>Your model may be misspecified</li>
		<li>Other models may yield different pictures</li>
	</ol>

</ol>
