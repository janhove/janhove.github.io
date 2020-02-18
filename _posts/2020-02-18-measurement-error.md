---
title: "Baby steps in Bayes: Incorporating reliability estimates in regression models"
layout: post
mathjax: true
tags: [R, Stan, Bayesian statistics, measurement error, correlational studies, reliability]
category: [Analysis]
---

Researchers sometimes calculate reliability indices such as Cronbach's 
$\alpha$ or Revelle's $\omega_T$, but their statistical models rarely
take these reliability indices into account.
Here I want to show you
how you can incorporate information about the reliability about your 
measurements in a statistical model so as to obtain more honest and more
readily interpretable parameter estimates. 

<!--more-->



## Reliability and measurement error

This blog post is the sequel to the 
[previous](https://janhove.github.io/analysis/2020/01/21/statistical-control-measurement-error) 
one, where I demonstrated how imperfectly measured control variables undercorrect
for the actual confounding in observational studies (also see 
Berthele & Vanhove 2017; Brunner & Austin 2009; Westfall & Yarkoni 2016).
A model that doesn't account for measurement error on the confounding variable---and
hence implicitly assumes that the confound was measured perfectly---may confidently
conclude that the variable of actual interest is related to the outcome even
when taking into account the confound. From such a finding, researchers typically
infer that the variable of actual interest is causally related to the outcome
even in absence of the confound. But once this measurement error is duly
accounted for, you may find that the evidence for a causal link between
the variable of interest and the outcome is more tenuous than originally believed.

So especially in observational studies, where confounds abound, it behooves
researchers to account for the measurement error in their variables so that
they don't draw unwarranted conclusions from their data too often. 
The amount of measurement error on your variables is usually unknown. 
But if you've calculated some reliability
estimate such as Cronbach's $\alpha$ for your variables, you can use this to
obtain an estimate of the amount of measurement error.

To elaborate, in classical test theory, the reliability $\rho_{XX'}$ of a measure
is equal to the ratio of the variance of the (error-free) true scores to 
the variance of the observed scores. The latter is the sum of the variance
of the true scores and the error variance:

$$\rho_{XX'} = \frac{\textrm{true score variance}}{\textrm{true score variance} + \textrm{measurement error variance}} = \frac{\sigma^2_T}{\sigma^2_T + \sigma^2_E}$$

Rearranging, we get

$$\sigma^2_E = \sigma^2_T\left(\frac{1}{\rho_{XX'}}-1\right)$$

None of these values are known, but they can be estimated based on the sample. 
Specifically, $\rho_{XX'}$ can be estimated by a reliability index such
as Cronbach's $\alpha$ and the sum $\sigma^2_T + \sigma^2_E$ can be estimated
by computing the variable's sample variance. 

## A simulated example

Let's first deal with a simulated dataset. The main advantage of analysing
simulated data is that you check that what comes out of the model
corresponds to what went into the data. In preparing this blog post, I 
was able to detect an arithmetic error in my model code in this way as 
one parameter was consistently underestimated. Had I applied the model
immediately to the real data set, I wouldn't have noticed anything wrong.
But we'll deal with real data afterwards.

Run these commands to follow along:


{% highlight r %}
library(rstan) # for fitting Bayesian models, v. 2.19.2
# to avoid unnecessary recompiling
rstan_options(auto_write = TRUE) 
# Distribute work over multiple CPU cores
options(mc.cores = parallel::detectCores())

# For drawing scatterplot matrices
source("https://janhove.github.io/RCode/scatterplot_matrix.R")

# Set random seed for reproducibility
set.seed(2020-02-13, kind = "Mersenne-Twister")
{% endhighlight %}

### Generating the construct scores

The scenario we're going to simulate is one in which you have two
correlated 
predictor variables (`A` and `B`) and one outcome variable (`Z`).
Unbeknownst to the analyst, `Z` is causally affected by `A` but not
by `B`. Moreover, the three variables are measured with some degree
of error, but we'll come to that later. Figure 1 depicts the scenario
for which we're going to simulate data.

![center](/figs/2020-02-18-measurement-error/unnamed-chunk-3-1.png)

> **Figure 1.** Graphical causal model for the simulated data.
> A set of unobserved factors $U$ gives rise to a correlation
> between `A` and `B`. Even though only `A` causally affects
> `Z`, an association between `B` and `Z` will be found unless 
> `A` is controlled for.

The first thing we need are two correlated predictor variables.
I'm going to generate these from a bivariate normal distribution.
`A` has a mean of 3 units and a standard deviation of 1.5 units,
 and `B` has mean -4 and standard deviation 0.8 units.
The correlation between them is $\rho = 0.73$.
To generate a sample from this bivariate normal distribution,
you need to construct the variance-covariance matrix from the 
standard deviations and correlation, which I do in the code below:


{% highlight r %}
# Generate correlated constructs
n <- 300
rho <- 0.73
mean_A <- 3
mean_B <- -4
sd_A <- 1.5
sd_B <- 0.8

# Given the correlation and the standard deviations,
# construct the variance-covariance matrix for the constructs like so:
latent_covariance_matrix <- rbind(c(sd_A, 0), c(0, sd_B)) %*% 
  rbind(c(1, rho), c(rho, 1)) %*% 
  rbind(c(sd_A, 0), c(0, sd_B))

# Draw data from the multivariate normal distribution:
constructs <- MASS::mvrnorm(n = n, mu = c(mean_A, mean_B), 
                            Sigma = latent_covariance_matrix)

# Extract variables from object
A <- constructs[, 1]
B <- constructs[, 2]
{% endhighlight %}

Next, we need to generate the outcome. In this simulation, `Z`
depends linearly on `A` but not on `B` (hence '$0 \times B_i$').

$$Z_i = 2 + 0.7 \times A_i + 0 \times B_i + \varepsilon_i$$

The error term $\varepsilon$ is drawn from a normal distribution with
standard deviation 1.3. Importantly, this error term does _not_ express
the measurement error on `Z`; it is the part of the true score variance in `Z` 
that isn't related to either `A` or `B`:

$$\varepsilon_i \sim \textrm{Normal}(0, 1.3)$$


{% highlight r %}
# Create Z
intercept <- 2
slope_A <- 0.7
slope_B <- 0
sigma_Z.AB <- 1.3
Z <- intercept + slope_A*A + slope_B*B + rnorm(n, sd = sigma_Z.AB)
{% endhighlight %}

Even though `B` isn't causally related to `Z`, we find that
`B` and `Z` are correlated thanks to `B`'s correlation to `A`.


{% highlight r %}
scatterplot_matrix(cbind(Z, A, B))
{% endhighlight %}

![center](/figs/2020-02-18-measurement-error/unnamed-chunk-6-1.png)

> **Figure 2.** `B` is causally unrelated to `Z`, but these
> two variables are still correlated because `B` correlates
> with `A` and `A` and `Z` are causally related.

A multiple regression model is able to tease apart the effects
of `A` and `B` on `Z`:


{% highlight r %}
summary(lm(Z ~ A + B))$coefficients
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)   2.1224     0.7130   2.977 3.15e-03
## A             0.6876     0.0706   9.742 1.22e-19
## B             0.0196     0.1340   0.146 8.84e-01
{% endhighlight %}

The confound `A` is significantly related to `Z` and its 
estimated regression parameter is close to
its true value of 0.70 ($\widehat{\beta_A} = 0.69 \pm 0.07$). The
variable of interest `B`, by contrast, isn't significantly
related to `Z` when `A` has been accounted for 
($\widehat{\beta_B} = 0.02 \pm 0.13$). This is all as it should be.


### Adding measurement error

Now let's add measurement error to all variables.
The `A` values that we actually observe will then be distorted versions
of the true `A` values:

$$\textrm{observed } A_i = \textrm{true } A_i + \varepsilon_{Ai}$$

The 'noise' $\varepsilon_{A}$ is commonly assumed to be normally distributed:

$$\varepsilon_{Ai} \sim \textrm{Normal}(0, \tau_A)$$

That said, you can easily imagine situations where the noise likely has
a different distribution. For instance, when measurements
are measured to the nearest integer (e.g., body weights in kilograms),
the noise is likely uniformly distributed (e.g., a reported body weight of 66 kg
means that the true body weight lies between 65.5 and 66.5 kg).

To make the link with the analysis more transparant, I will express the 
amount of noise in terms of the variables' reliabilities. For the confound
`A`, I set the reliability at 0.70. Since `A`'s standard deviation was 1.5 units,
this means that the standard deviation of the noise is $\sqrt{1.5^2\left(\frac{1}{0.70} - 1\right)} = 0.98$
units. I set the reliability for `B`, the variable of actual interest at 0.90.
Its standard deviation is 0.8, so the standard deviation of the noise is
$\sqrt{0.8^2\left(\frac{1}{0.90} - 1\right)} = 0.27$ units.


{% highlight r %}
# Add measurement error on A and B
obs_A <- A + rnorm(n = n, sd = sqrt(sd_A^2*(1/0.70 - 1))) # reliability 0.70
obs_B <- B + rnorm(n = n, sd = sqrt(sd_B^2*(1/0.90 - 1))) # reliability 0.90
{% endhighlight %}

The same logic applies to adding measurement noise to `Z`.
The difficulty here lies in obtaining the population standard deviation (or variance)
of `Z`. I don't want to just plug in `Z`'s sample standard deviation since I want
to have exact knowledge of the population parameters.
While we specified a `sigma_Z.AB` above, this is _not_ the 
total population standard deviation of `Z`: it's the population standard deviation of `Z` once
`Z` has been controlled for `A` and `B`. To obtain the _total_ standard deviation
of `Z` (here admittedly confusingly labelled $\sigma_Z$), we need to add in
the variance in `Z` due to `A` and `B`:

$$\sigma_Z = \sqrt{(\beta_A\sigma_A)^2 + (\beta_B\sigma_B)^2 + 2\beta_A\beta_B\sigma_A\sigma_B\rho_{AB} + \sigma_{Z.AB}^2}$$

Since $\beta_B = 0$, this simplifies to $\sigma_Z = \sqrt{(\beta_A\sigma_A)^2 + \sigma_{Z.AB}^2}$,
but if you want to simulate your own datasets, the full formula may be useful.

The population standard deviation of `Z` is thus
$\sqrt{(0.7 \times 1.5)^2 + 1.3^2} = 1.67$. Setting `Z`'s reliability to 0.70,
we find that the standard deviation of the noise is 
$\sqrt{1.67^2\left(\frac{1}{0.70} - 1\right)} = 1.09$.


{% highlight r %}
# Measurement error on Z
sd_Z <- sqrt((slope_A*sd_A)^2 + (0*slope_B)^2 + 2*(slope_A * slope_B * latent_covariance_matrix[1,2]) + sigma_Z.AB^2)
obs_Z <- Z + rnorm(n = n, sd = sqrt(sd_Z^2*(1/0.70 - 1))) # reliability 0.70
{% endhighlight %}

Figure 3 shows the causal diagram for the actually observed simulated data.

![center](/figs/2020-02-18-measurement-error/unnamed-chunk-10-1.png)

> **Figure 3.** Graphical causal model for the simulated data.
> `A`, `B` and `Z` are now unobserved (latent) variables,
>  but so-called 'descendants' of them were measured. These
> reflect their latent constructs imperfectly. Crucially, controlling
> for `obs_A` will _not_ entirely control for the confound:
> the path between `obs_B` and `obs_Z` stays open.


As Figure 4 shows, the observed variables are all correlated with
each other.


{% highlight r %}
scatterplot_matrix(cbind(obs_Z, obs_A, obs_B))
{% endhighlight %}

![center](/figs/2020-02-18-measurement-error/unnamed-chunk-11-1.png)

> **Figure 4.**

Crucially, controlling for `obs_A` in a regression model
doesn't entirely eradicate the confound and we find that
`obs_B` is significantly related to `obs_Z` even after
controlling for `obs_A` ($\widehat{\beta_{B_{\textrm{obs}}}} = 0.40 \pm 0.15$).
Moreover, the regression model on the observed variables
underestimates the strength of the relationship 
between the true construct scores ($\widehat{\beta_{A_{\textrm{obs}}}} = 0.40 \pm 0.07$, whereas $\beta_A = 0.7$).


{% highlight r %}
summary(lm(obs_Z ~ obs_A + obs_B))$coefficients
{% endhighlight %}



{% highlight text %}
##             Estimate Std. Error t value Pr(>|t|)
## (Intercept)    4.498     0.7588    5.93 8.49e-09
## obs_A          0.402     0.0737    5.45 1.05e-07
## obs_B          0.404     0.1470    2.75 6.41e-03
{% endhighlight %}

### Statistical model

The statistical model, written below in Stan code, corresponds
to the data generating mechanism above and tries to infer
its parameters from the observed data and some prior information.

The `data` block specifies the input that the model should handle.
I think this is self-explanatory. Note that the latent variable scores
`A`, `B` and `Z` aren't part of the input as we wouldn't have directly observed
these.

The `parameters` block first defines the parameters needed for the 
regression model with the unobserved latent variables (the one we used to
generate `Z`). It then defines the parameters needed to generate the 
true variables scores for `A` and `B` as well as the parameters needed
to generate the observed scores from the true scores (viz., the true
scores themselves and the reliabilities). Note that it is crucial to allow
the model to estimate a correlation between `A` and `B`, otherwise it won't
'know' that `A` confounds the `B`-`Z` relationship.

The `transformed parameters` block contains, well, transformations of these
parameters. For instance, the standard deviations of `A` and `B` and
the correlation between `A` and `B` are used to generate a variance-covariance
matrix. Moreover, the standard deviations of the measurement noise are 
computed using the latent variables' standard deviation and their reliabilities.

The `model` block, finally, specifies how we think the observed data and
the (transformed or untransformed) parameters fit together and what plausible
a priori values for the (transformed or untransformed) parameters are.
These prior distributions are pretty abstract in this example: we generated
context-free data ourselves, so it's not clear what motivates these priors.
The real example to follow will hopefully make more sense in this respect.
You'll notice that I've also specified a prior for the reliabilities.
The reason is that you typically don't know the reliability of an observed
variable with perfect precision but that you have sample estimate with some
inherent uncertainty. The priors reflect this uncertainty. Again, this will
become clearer in the real example to follow.


{% highlight r %}
meas_error_code <- '
data { 
  // Number of observations
  int<lower = 1> N;

  // Observed outcome
  vector[N] obs_Z;

  // Observed predictors
  vector[N] obs_A;
  vector[N] obs_B;
}

parameters {
  // Parameters for regression
  real intercept;
  real slope_A;
  real slope_B;
  real<lower = 0> sigma; 

  // Latent predictors (= constructs):
  // standard deviations and means
  real<lower = 0> sigma_lat_A; 
  real<lower = 0> sigma_lat_B;
  row_vector[2] latent_means;

  // Correlation between latent predictors
  real<lower = -1, upper = 1> latent_rho;

  // Latent variables (true scores)
  matrix[N, 2] latent_predictors;
  vector[N] lat_Z; // latent outcome

  // Unknown but estimated reliabilities
  real<lower = 0, upper = 1> reliability_A;
  real<lower = 0, upper = 1> reliability_B;
  real<lower = 0, upper = 1> reliability_Z;
} 

transformed parameters {
  vector[N] mu_Z;  // conditional mean of outcome
  vector[N] lat_A; // latent variables, separated out
  vector[N] lat_B;

  real error_A; // standard error of measurement
  real error_B;
  real error_Z;

  // standard deviations of latent predictors, in matrix form
  matrix[2, 2] sigma_lat; 
  // correlation and covariance matrix for latent predictors 
  cov_matrix[2] latent_cor; 
  cov_matrix[2] latent_cov;

  // standard deviation of latent outcome
  real<lower = 0> sigma_lat_Z;
  sigma_lat_Z = sd(lat_Z);

  // Express measurement error in terms of 
  // standard deviation of constructs and reliability
  error_A = sqrt(sigma_lat_A^2*(1/reliability_A - 1));
  error_B = sqrt(sigma_lat_B^2*(1/reliability_B - 1));
  error_Z = sqrt(sigma_lat_Z^2*(1/reliability_Z - 1));

  // Define diagonal matrix with standard errors of latent variables
  sigma_lat[1, 1] = sigma_lat_A;
  sigma_lat[2, 2] = sigma_lat_B;
  sigma_lat[1, 2] = 0;
  sigma_lat[2, 1] = 0;

  // Define correlation matrix for latent variables
  latent_cor[1, 1] = 1;
  latent_cor[2, 2] = 1;
  latent_cor[1, 2] = latent_rho;
  latent_cor[2, 1] = latent_rho;

  // Compute covariance matrix for latent variables
  latent_cov = sigma_lat * latent_cor * sigma_lat;

  // Extract latent variables from matrix
  lat_A = latent_predictors[, 1];
  lat_B = latent_predictors[, 2];

  // Regression model for conditional mean of Z
  mu_Z = intercept + slope_A*lat_A + slope_B*lat_B;
}

model {
  // Priors for regression parameters
  intercept ~ normal(0, 2);
  slope_A ~ normal(0, 2);
  slope_B ~ normal(0, 2);
  sigma ~ normal(0, 2);

  // Prior for latent standard deviations
  sigma_lat_A ~ normal(0, 2);
  sigma_lat_B ~ normal(0, 2);

  // Prior for latent means
  latent_means ~ normal(0, 3);

  // Prior expectation for correlation between latent variables.
  // Tend towards positive correlation, but pretty vague.
  latent_rho ~ normal(0.4, 0.3);

  // Prior for reliabilities.
  // These are estimated with some uncertainty, i.e.,
  // they are not point values but distributions.
  reliability_A ~ beta(70, 30);
  reliability_B ~ beta(90, 10);
  reliability_Z ~ beta(70, 30);

  // Distribution of latent variable
  for (i in 1:N) {
    latent_predictors[i, ] ~ multi_normal(latent_means, latent_cov);
  }

  // Generate latent outcome
  lat_Z ~ normal(mu_Z, sigma);

  // Add noise to latent variables
  obs_A ~ normal(lat_A, error_A);
  obs_B ~ normal(lat_B, error_B);
  obs_Z ~ normal(lat_Z, error_Z);
}

'
{% endhighlight %}

Put the data in a list and fit the model:


{% highlight r %}
data_list <- list(
  obs_Z = obs_Z,
  obs_A = obs_A,
  obs_B = obs_B,
  N = n
)
{% endhighlight %}


{% highlight r %}
meas_error_model <- stan(model_code = meas_error_code,  
  data = data_list, iter = 2000, warmup = 1000,
  control = list(adapt_delta = 0.99, max_treedepth = 15))
{% endhighlight %}

### Results




{% highlight r %}
print(meas_error_model, probs = c(0.025, 0.975),
  par = c("intercept", "slope_A", "slope_B", "sigma",
          "sigma_lat_A", "sigma_lat_B", "sigma_lat_Z",
          "latent_means", "latent_rho",
          "reliability_A", "reliability_B", "reliability_Z",
          "error_A", "error_B", "error_Z"))
{% endhighlight %}



{% highlight text %}
## Inference for Stan model: b2389cae1ee0f483df28a5894e50c1b7.
## 4 chains, each with iter=3000; warmup=1000; thin=1; 
## post-warmup draws per chain=2000, total post-warmup draws=8000.
## 
##                  mean se_mean   sd  2.5% 97.5% n_eff Rhat
## intercept        0.67    0.06 1.53 -2.63  3.38   677 1.01
## slope_A          0.86    0.01 0.17  0.56  1.25   628 1.00
## slope_B         -0.20    0.01 0.26 -0.75  0.27   765 1.00
## sigma            1.17    0.00 0.12  0.91  1.40   757 1.01
## sigma_lat_A      1.40    0.00 0.07  1.25  1.54  2405 1.00
## sigma_lat_B      0.80    0.00 0.03  0.73  0.87  5190 1.00
## sigma_lat_Z      1.59    0.00 0.07  1.46  1.72  1907 1.00
## latent_means[1]  3.06    0.00 0.10  2.87  3.25  4984 1.00
## latent_means[2] -4.02    0.00 0.05 -4.12 -3.92  7327 1.00
## latent_rho       0.78    0.00 0.05  0.68  0.87   851 1.01
## reliability_A    0.69    0.00 0.04  0.61  0.77   985 1.00
## reliability_B    0.90    0.00 0.03  0.83  0.95   424 1.01
## reliability_Z    0.70    0.00 0.04  0.61  0.78  1110 1.01
## error_A          0.92    0.00 0.07  0.79  1.06  1077 1.00
## error_B          0.26    0.00 0.04  0.19  0.35   399 1.01
## error_Z          1.05    0.00 0.08  0.88  1.21  1205 1.00
## 
## Samples were drawn using NUTS(diag_e) at Thu Feb 13 14:39:44 2020.
## For each parameter, n_eff is a crude measure of effective sample size,
## and Rhat is the potential scale reduction factor on split chains (at 
## convergence, Rhat=1).
{% endhighlight %}

The model recovers the true parameter values pretty well (Table 1)
and, on the basis of this model, you wouldn't erroneously conclude
that `B` is causally related to `Z` (see the parameter estimate for `slope_B`).

> **Table 1.** Comparison of the true parameter values and their
> estimates. Parameters prefixed with '*' are transformations of
> other parameters. The estimated reliability parameters aren't really estimated
> from the data: they just reflect the prior distributions put on them.

| Parameter   |     True value      |  Estimate |
|----------|-------------:|------:|
| intercept |  2.00 | $0.67 \pm 1.53$ |
| slope_A |    0.70   | $0.86 \pm 0.17$ |
| slope_B | 0.00 |    $-0.20 \pm 0.26$ |
| sigma_Z.AB | 1.30 |    $1.17 \pm 0.12$ |
| sd_A | 1.50 |    $1.40 \pm 0.07$ |
| sd_B | 0.80 |    $0.80 \pm 0.03$ |
| mean_A | 3.00 |    $3.06 \pm 0.10$ |
| mean_B | -4.00 |    $-4.02 \pm 0.05$ |
| rho    | 0.73 | $0.78 \pm 0.05$ |
| reliability_A    | 0.70 | $0.69 \pm 0.04$ |
| reliability_B    | 0.90 | $0.90 \pm 0.03$ |
| reliability_Z    | 0.70 | $0.70 \pm 0.04$ |
| *sd_Z | 1.67 |    $1.59 \pm 0.07$ |
| *error_A | 0.98 |    $0.92 \pm 0.07$ |
| *error_B | 0.27 |    $0.26 \pm 0.04$ |
| *error_Z | 1.09 |    $1.05 \pm 0.08$ |

In the previous blog post, I've shown that such a model also estimates the
latent true variable scores and that these estimates correspond more closely
to the actual true variable scores than do the observed variable scores.
I'll skip this step here.

## Real-life example: Interdependence
Satisfied that our model can recover the actual parameter values
in scenarios such as those depicted in Figure 3, we now turn to a real-life
example of such a situation. The example was already described in
the previous blog post; here I'll just draw the causal model that assumes
that reflects the null hypothesis that a child's Portuguese skills at T2 (`PT.T2`)
don't contribute to their French skills at T3 (`FR.T3`), but that 
due to common factors such as intelligence, form on the day etc. ($U$), 
French skills and Portuguese skills at T2 are correlated across children.
What is observed are test scores, not the children's actual skills.

![center](/figs/2020-02-18-measurement-error/unnamed-chunk-18-1.png)

> **Figure 5.**

### Data

The command below is pig-ugly, but allows you to easily read in the data.


{% highlight r %}
skills <- structure(list(Subject=c("A_PLF_1","A_PLF_10","A_PLF_12","A_PLF_13","A_PLF_14","A_PLF_15","A_PLF_16","A_PLF_17","A_PLF_19","A_PLF_2","A_PLF_3","A_PLF_4","A_PLF_5","A_PLF_7","A_PLF_8","A_PLF_9","AA_PLF_11","AA_PLF_12","AA_PLF_13","AA_PLF_6","AA_PLF_7","AA_PLF_8","AD_PLF_10","AD_PLF_11","AD_PLF_13","AD_PLF_14","AD_PLF_15","AD_PLF_16","AD_PLF_17","AD_PLF_18","AD_PLF_19","AD_PLF_2","AD_PLF_20","AD_PLF_21","AD_PLF_22","AD_PLF_24","AD_PLF_25","AD_PLF_26","AD_PLF_4","AD_PLF_6","AD_PLF_8","AD_PLF_9","AE_PLF_1","AE_PLF_2","AE_PLF_4","AE_PLF_5","AE_PLF_6","C_PLF_1","C_PLF_16","C_PLF_19","C_PLF_30","D_PLF_1","D_PLF_2","D_PLF_3","D_PLF_4","D_PLF_5","D_PLF_6","D_PLF_7","D_PLF_8","Y_PNF_12","Y_PNF_15","Y_PNF_16","Y_PNF_17","Y_PNF_18","Y_PNF_2","Y_PNF_20","Y_PNF_24","Y_PNF_25","Y_PNF_26","Y_PNF_27","Y_PNF_28","Y_PNF_29","Y_PNF_3","Y_PNF_31","Y_PNF_32","Y_PNF_33","Y_PNF_34","Y_PNF_36","Y_PNF_4","Y_PNF_5","Y_PNF_6","Y_PNF_7","Y_PNF_8","Y_PNF_9","Z_PLF_2","Z_PLF_3","Z_PLF_4","Z_PLF_5","Z_PLF_6","Z_PLF_7","Z_PLF_8"),FR_T2=c(0.6842105263,0.4736842105,1,0.4210526316,0.6842105263,0.6842105263,0.8947368421,0.5789473684,0.7368421053,0.7894736842,0.4210526316,0.5263157895,0.3157894737,0.5263157895,0.6842105263,0.8421052632,0.3684210526,0.8421052632,0.7894736842,0.7894736842,0.6842105263,0.6315789474,0.6315789474,0.3684210526,0.4736842105,0.2631578947,0.4736842105,0.9473684211,0.3157894737,0.5789473684,0.2631578947,0.5263157895,0.5263157895,0.7368421053,0.6315789474,0.8947368421,0.6315789474,0.9473684211,0.7368421053,0.6315789474,0.7894736842,0.7894736842,0.4736842105,0.4736842105,0.9473684211,0.7894736842,0.3157894737,0.9473684211,1,0.7368421053,0.5789473684,0.8421052632,0.8421052632,0.7368421053,0.5789473684,0.6842105263,0.4736842105,0.4210526316,0.6842105263,0.8947368421,0.6842105263,0.7368421053,0.5263157895,0.5789473684,0.8947368421,0.7894736842,0.5263157895,0.6315789474,0.3157894737,0.7368421053,0.5789473684,0.6842105263,0.7368421053,0.5789473684,0.7894736842,0.6842105263,0.6315789474,0.6842105263,0.5789473684,0.7894736842,0.5789473684,0.7368421053,0.4736842105,0.8947368421,0.8421052632,0.7894736842,0.6315789474,0.6842105263,0.8947368421,0.6842105263,0.9473684211),PT_T2=c(0.7368421053,0.5789473684,0.9473684211,0.5263157895,0.6315789474,0.5789473684,0.9473684211,0.4736842105,0.8421052632,0.5263157895,0.2631578947,0.6842105263,0.3684210526,0.3684210526,0.4736842105,0.8947368421,0.4210526316,0.5263157895,0.8947368421,0.8421052632,0.8947368421,0.8947368421,0.6315789474,0.3684210526,0.0526315789,0.3684210526,0.4210526316,0.9473684211,0.3157894737,0.4736842105,0.3157894737,0.5789473684,0.4736842105,0.7894736842,0.5263157895,0.8947368421,0.6315789474,0.7894736842,0.7368421053,0.5789473684,0.6842105263,0.7368421053,0.3684210526,0.7894736842,0.7368421053,0.4736842105,0.5263157895,1,0.8947368421,0.8947368421,0.4736842105,0.8421052632,1,0.6315789474,0.5263157895,0.5789473684,0.5789473684,0.5789473684,0.5263157895,0.9473684211,0.5263157895,0.6315789474,0.5789473684,0.6315789474,0.9473684211,0.7894736842,0.8421052632,0.5263157895,0.7894736842,0.4736842105,0.6842105263,0.3684210526,0.7894736842,0.7368421053,0.6315789474,0.9473684211,0.4210526316,0.5789473684,0.3684210526,0.8947368421,0.6315789474,0.8421052632,0.5789473684,0.5263157895,0.9473684211,0.8947368421,0.7368421053,0.4736842105,0.8421052632,0.7894736842,0.9473684211),FR_T3=c(0.9473684211,0.3157894737,0.9473684211,0.5789473684,0.5789473684,0.6842105263,0.8421052632,0.6842105263,0.7368421053,0.8421052632,0.4210526316,0.5789473684,0.4736842105,0.6842105263,0.5789473684,0.7894736842,0.7368421053,0.7894736842,1,0.8421052632,0.8947368421,0.4210526316,0.8947368421,0.4736842105,0.5263157895,0.4736842105,0.5789473684,1,0.7368421053,0.8421052632,0.2631578947,0.7894736842,0.6842105263,0.8947368421,0.5263157895,0.8947368421,0.6842105263,0.9473684211,0.9473684211,0.5263157895,0.9473684211,0.8421052632,0.4736842105,0.8947368421,0.9473684211,0.7368421053,0.5263157895,0.8421052632,0.9473684211,0.7894736842,0.8947368421,0.8421052632,0.8421052632,0.8947368421,0.5789473684,0.7368421053,0.6842105263,0.4736842105,0.6842105263,0.8947368421,0.4736842105,0.8421052632,0.7894736842,0.5789473684,0.7368421053,0.7894736842,0.8947368421,0.6842105263,0.6842105263,0.9473684211,0.7894736842,0.5263157895,0.7368421053,0.6842105263,0.8421052632,0.7368421053,0.7368421053,0.5789473684,0.4736842105,0.8947368421,0.4210526316,0.8947368421,0.6842105263,1,0.8421052632,0.8421052632,0.6315789474,0.6315789474,0.8947368421,0.6315789474,0.9473684211),PT_T3=c(0.8421052632,0.3684210526,0.9473684211,0.3157894737,0.5789473684,0.7894736842,1,0.5263157895,0.8421052632,0.7894736842,0.3157894737,0.6315789474,0.4210526316,0.5263157895,0.6842105263,0.8421052632,0.8947368421,0.6842105263,0.9473684211,0.8947368421,0.9473684211,0.8421052632,0.8421052632,0.5263157895,0.6842105263,0.5263157895,0.8421052632,0.9473684211,0.4210526316,0.7894736842,0.7894736842,0.8421052632,0.7368421053,1,0.6842105263,1,0.7894736842,0.8421052632,0.9473684211,0.6842105263,0.7894736842,0.7894736842,0.3157894737,0.7894736842,NA,0.6315789474,0.6842105263,0.9473684211,1,0.9473684211,0.7368421053,0.8947368421,0.8421052632,0.8421052632,0.5789473684,0.6315789474,0.6315789474,0.8421052632,0.7894736842,0.8421052632,0.5789473684,0.8421052632,0.7368421053,0.6842105263,0.8421052632,0.8421052632,0.9473684211,0.4736842105,0.8421052632,0.7894736842,0.7368421053,0.2105263158,0.7894736842,0.7894736842,0.7368421053,0.6315789474,0.6315789474,0.4210526316,0.6315789474,0.8421052632,0.6842105263,0.9473684211,0.5789473684,0.5263157895,0.7894736842,0.7894736842,0.7894736842,0.6842105263,0.8421052632,0.8421052632,0.8947368421)),row.names=c(NA,-91L),class=c("tbl_df","tbl","data.frame"))
{% endhighlight %}

## Statistical model

The only thing that's changed in the statistical model compared to the example
with the simulated data is that I've renamed the parameters and that the prior
distributions are better motivated. Let's consider each prior distribution in turn:

* `intercept ~ normal(0.2, 0.1);`: The intercept is the average true French skill score at T3 for
children whose true French and Portuguese skill scores at T2 are 0. This is the lowest possible
score (the theoretical range of the data is [0, 1]), so we'd expect such children to perform
poorly at T3, too. A `normal(0.2, 0.1)` distribution puts 95% probability on such children
having a true French score at T3 between 0 and 0.4.

* `slope_FR ~ normal(0.5, 0.25);`: This parameter expresses the difference between
the average true French skill score at T3 for children with a true French skill score of 1 at T2
(the theoretical maximum)
vs. those with a true French skill score of 0 at T2 (the theoretical minimum).
This is obviously some value between -1 and 1, and presumably it's going to be positive.
A `normal(0.5, 0.25)` puts 95% probability on this difference lying between 0 and 1, which I
think is reasonable.

* `slope_PT ~ normal(0, 0.25);`: The slope for Portuguese is bound to be smaller than the
one for French. Moreover, it's not a given that it will be appreciably different from zero.
Hence a prior centred on 0 that still gives the data a chance to pull the estimate in 
either direction.

* `sigma ~ normal(0.15, 0.08);`:  If neither of the T2 variables predicts T3, uncertainty
is highest when the mean T3 score is 0.5. Since these scores
are bounded between 0 and 1, the standard deviation could not 
be much higher than 0.20. But French T2 is bound to be a predictor,
so let us choose a slightly lower value (0.15).

* `latent_means ~ normal(0.5, 0.1);`: These are the prior expectations for the
true score means of the T2 variables. 0.5 lies in the middle of the scale;
the `normal(0.5, 0.1)` prior puts 95% probability on these means to lie
between 0.3 and 0.7.

* `sigma_lat_FR_T2 ~ normal(0, 0.25);`, `sigma_lat_FR_T2 ~ normal(0, 0.25);`: The
standard deviations of the latent T2 variables. If these truncated normal 
distributions put a 95% probability of the latent standard deviations to be lower
than 0.50.

* `latent_rho ~ normal(0.4, 0.3);`: The a priori expected correlation 
between the latent variables `A` and `B`. These are bound to be positively
correlated.

* `reliability_FR_T2 ~ beta(100, 100*0.27/0.73);` The prior distribution for the reliability
of the French T2 variable. Cronbach's $\alpha$ for this variable was 0.73 (95% CI: [0.65, 0.78]). 
This roughly corresponds to a `beta(100, 100*0.27/0.73)` distribution:


{% highlight r %}
qbeta(c(0.025, 0.975), 100, 100*0.27/0.73)
{% endhighlight %}



{% highlight text %}
## [1] 0.653 0.801
{% endhighlight %}

* `reliability_PT_T2 ~ beta(120, 120*0.21/0.79);` Similarly, Cronbach's $\alpha$ for the Portuguese
T2 variable was 0.79 (95% CI: [0.72, 0.84]), which roughly corresponds to a `beta(120, 120*0.21/0.79)`
distribution:


{% highlight r %}
qbeta(c(0.025, 0.975), 120, 120*0.21/0.79)
{% endhighlight %}



{% highlight text %}
## [1] 0.722 0.851
{% endhighlight %}

* `reliability_FR_T3 ~ beta(73, 27);`: The estimated reliability for the French
T3 data was similar to that of the T2 data, so I used the same prior.


{% highlight r %}
interdependence_code <- '
data { 
  // Number of observations
  int<lower = 1> N;

  // Observed outcome
  vector[N] FR_T3;

  // Observed predictors
  vector[N] FR_T2;
  vector[N] PT_T2;
}

parameters {
  // Parameters for regression
  real intercept;
  real slope_FR;
  real slope_PT;
  real<lower = 0> sigma; 

  // standard deviations of latent predictors (= constructs)
  real<lower = 0> sigma_lat_FR_T2; 
  real<lower = 0> sigma_lat_PT_T2;

  // Means of latent predictors
  row_vector[2] latent_means;

  // Unknown correlation between latent predictors
  real<lower = -1, upper = 1> latent_rho;

  // Latent variables
  matrix[N, 2] latent_predictors;
  vector[N] lat_FR_T3; // latent outcome

  // Unknown but estimated reliabilities
  real<lower = 0, upper = 1> reliability_FR_T2;
  real<lower = 0, upper = 1> reliability_PT_T2;
  real<lower = 0, upper = 1> reliability_FR_T3;
} 

transformed parameters {
  vector[N] mu_FR_T3;  // conditional mean of outcome
  vector[N] lat_FR_T2; // latent variables, separated out
  vector[N] lat_PT_T2;

  real error_FR_T2; // standard error of measurement
  real error_PT_T2;
  real error_FR_T3;

  // standard deviations of latent predictors, in matrix form
  matrix[2, 2] sigma_lat; 
  // correlation and covariance matrix for latent predictors 
  cov_matrix[2] latent_cor; 
  cov_matrix[2] latent_cov;

  // standard deviation of latent outcome
  real<lower = 0> sigma_lat_FR_T3;
  sigma_lat_FR_T3 = sd(lat_FR_T3);

  // Express measurement error in terms of 
  // standard deviation of constructs and reliability
  error_FR_T2 = sqrt(sigma_lat_FR_T2^2*(1/reliability_FR_T2 - 1));
  error_PT_T2 = sqrt(sigma_lat_PT_T2^2*(1/reliability_PT_T2 - 1));
  error_FR_T3 = sqrt(sigma_lat_FR_T3^2*(1/reliability_FR_T3 - 1));

  // Define diagonal matrix with standard errors of latent variables
  sigma_lat[1, 1] = sigma_lat_FR_T2;
  sigma_lat[2, 2] = sigma_lat_PT_T2;
  sigma_lat[1, 2] = 0;
  sigma_lat[2, 1] = 0;

  // Define correlation matrix for latent variables
  latent_cor[1, 1] = 1;
  latent_cor[2, 2] = 1;
  latent_cor[1, 2] = latent_rho;
  latent_cor[2, 1] = latent_rho;

  // Compute covariance matrix for latent variables
  latent_cov = sigma_lat * latent_cor * sigma_lat;

  // Extract latent variables from matrix
  lat_FR_T2 = latent_predictors[, 1];
  lat_PT_T2 = latent_predictors[, 2];

  // Regression model for conditional mean of Z
  mu_FR_T3 = intercept + slope_FR*lat_FR_T2 + slope_PT*lat_PT_T2;
}

model {
  // Priors for regression parameters
  intercept ~ normal(0.2, 0.1);
  slope_FR ~ normal(0.5, 0.25);
  slope_PT ~ normal(0, 0.25);
  sigma ~ normal(0.15, 0.08);

  // Prior for latent means
  latent_means ~ normal(0.5, 0.1);

  // Prior for latent standard deviations
  sigma_lat_FR_T2 ~ normal(0, 0.25);
  sigma_lat_PT_T2 ~ normal(0, 0.25);

  // Prior expectation for correlation between latent variables.
  latent_rho ~ normal(0.4, 0.3);

  // Prior for reliabilities.
  // These are estimated with some uncertainty, i.e.,
  // they are not point values but distributions.
  reliability_FR_T2 ~ beta(100, 100*0.27/0.73);
  reliability_PT_T2 ~ beta(120, 120*0.21/0.79);
  reliability_FR_T3 ~ beta(100, 100*0.27/0.73);

  // Distribution of latent variable
  for (i in 1:N) {
    latent_predictors[i, ] ~ multi_normal(latent_means, latent_cov);
  }

  // Generate latent outcome
  lat_FR_T3 ~ normal(mu_FR_T3, sigma);

  // Measurement model
  FR_T2 ~ normal(lat_FR_T2, error_FR_T2);
  PT_T2 ~ normal(lat_PT_T2, error_PT_T2);
  FR_T3 ~ normal(lat_FR_T3, error_FR_T3);
}

'
{% endhighlight %}


{% highlight r %}
data_list <- list(
  FR_T2 = skills$FR_T2,
  PT_T2 = skills$PT_T2,
  FR_T3 = skills$FR_T3,
  N = length(skills$FR_T3)
)

interdependence_model <- stan(model_code = interdependence_code,  
                              data = data_list,
                              iter = 8000, warmup = 2000,
                              control = list(adapt_delta = 0.9999, max_treedepth = 15))
{% endhighlight %}

### Results




{% highlight r %}
print(interdependence_model, probs = c(0.025, 0.975),
  par = c("intercept", "slope_FR", "slope_PT", "sigma",
          "latent_rho"))
{% endhighlight %}



{% highlight text %}
## Inference for Stan model: a1ad4cf6e06c11e8aa895df4dcdf87c6.
## 4 chains, each with iter=8000; warmup=2000; thin=1; 
## post-warmup draws per chain=6000, total post-warmup draws=24000.
## 
##            mean se_mean   sd  2.5% 97.5% n_eff Rhat
## intercept  0.19       0 0.05  0.09  0.29  5051    1
## slope_FR   0.71       0 0.16  0.40  1.02  3900    1
## slope_PT   0.11       0 0.14 -0.17  0.38  6456    1
## sigma      0.07       0 0.02  0.03  0.11   833    1
## latent_rho 0.81       0 0.08  0.65  0.95  3575    1
## 
## Samples were drawn using NUTS(diag_e) at Fri Feb 14 13:18:37 2020.
## For each parameter, n_eff is a crude measure of effective sample size,
## and Rhat is the potential scale reduction factor on split chains (at 
## convergence, Rhat=1).
{% endhighlight %}

Unsurprisingly, the model confidently finds a link between
French skills at T2 and at T3, even on the level of the unobserved
true scores ($\widehat{\beta}_{\textrm{French}} = 0.71 \pm 0.16$).
But more importantly, the evidence for an additional effect
of Portuguese skills at T2 on French skills at T3 is flimsy
($\widehat{\beta}_{\textrm{Portuguese}} = 0.11 \pm 0.14$).
The latent T2 variables are estimated to correlate
strongly at $\widehat{\rho} = 0.81 \pm 0.08$. These results
don't change much when a flat prior on $\rho$ is specified (this 
can be accomplished by not specifying any prior at all for $\rho$).

Compared to the model in the previous blog post (Table 2),
little has changed. The only appreciable difference is that
the estimate for `sigma` is lower. The reason is that, unlike the previous
model, the current model partitions the variance in the French T3 scores into 
true score variance and measurement error variance. In this model, `sigma` captures the
true score variance that isn't accounted for by T2 skills, whereas in the
previous model, `sigma` captured the _total_ variance that wasn't accounted for
by T2 skills. But other than that, the current model doesn't represent a huge
change from the previous one.

> **Table 2.** Comparison of parameter estimates between the model
> fitted in this blog post and the model fitted in the previous one.
> In the previous model, the outcome was assumed to be perfectly
> reliable.

| Parameter   |     Current estimate      |  Previous estimate |
|----------|-------------:|------:|
| intercept | $0.19 \pm 0.05$ | $0.19 \pm 0.05$ |
| slope_FR | $0.71 \pm 0.16$ | $0.71 \pm 0.16$ |
| slope_PT | $0.11 \pm 0.14$ | $0.10 \pm 0.14$ |
| sigma    | $0.07 \pm 0.02$ | $0.12 \pm 0.01$ |
| latent_rho | $0.81 \pm 0.08$ | $0.81 \pm 0.08$ |

A couple of things still remain to be done. First, the French test at T3
was the same as the one at T2 so it's likely that the measurement errors
on both scores won't be completely independent of one another. I'd like to 
find out how correlated measurement errors affect the parameter estimates.
Second, I'd like to get started with prior and posterior predictive checks:
the former to check if the priors give rise to largely possible data patterns,
and the latter to check if the full model tends to generate data sets similar to
the one actually observed.

## References

Berthele, Raphael and Jan Vanhove. 2017. 
[What would disprove interdependence? Lessons learned from a study on biliteracy in Portuguese heritage language speakers in Switzerland.](https://doi.org/10.1080/13670050.2017.1385590) 
_International Journal of Bilingual Education and Bilingualism_.

Brunner, Jerry and Peter C. Austin. 2009. 
[Inflation of Type I error rate in multiple regression when independent variables are measured with error.](https://doi.org/10.1002/cjs.10004) 
_Canadian Journal of Statistics_ 37(1). 33–46.

<!-- McElreath, Richard. 2016. -->
<!-- _Statistical rethinking: A Bayesian course with examples in R and Stan._ -->
<!-- Boca Raton, FL: CRC Press. -->

<!-- Berthele, Raphael and Amelia Lambelet (eds.). 2017.  -->
<!-- _Heritage and school language literacy development in migrant children: Interdependence or independence?_ -->
<!-- Multilingual Matters. -->

<!-- Carlos Pestana, Amelia Lambelet and Jan Vanhove. 2017.  -->
<!-- Chapter 4: Reading comprehension development in Portuguese heritage speakers in Switzerland (HELASCOT project).  -->
<!-- In Raphael Berthele and Amelia Lambelet (eds.),  -->
<!-- _Heritage and school language literacy development in migrant children: Interdependence or independence?_, pp. 58-82.  -->
<!-- Multilingual Matters. -->

<!-- Vanhove, Jan and Raphael Berthele. 2017.  -->
<!-- Chapter 6: Testing the interdependence of languages (HELASCOT project).  -->
<!-- In Raphael Berthele and Amelia Lambelet (eds.), _Heritage and school language literacy development in migrant children: Interdependence or independence?_, pp. 97-118.  -->
<!-- Multilingual Matters. -->

Westfall, Jacob and Tal Yarkoni. 2016. 
[Statistically controlling for confounding constructs is harder than you think.](https://doi.org/10.1371/journal.pone.0152719).
_PLOS ONE_ 11(3). e0152719.
