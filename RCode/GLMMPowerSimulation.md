---
title: 'Power for covariate-adjusted logistic mixed models'
author: "Jan Vanhove"
date: "02.09.2015"
output: html_document
---

**Accompanying R code for [Covariate adjustment in logistic mixed models: Is it worth the effort?](http://janhove.github.io/archive.html)**

# The general idea

The settings for the simulations were derived from a model fitted to the dataset collected for an earlier 
[study](http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Vanhove_CorrespondenceRules.pdf).
This dataset -- a shortened version of the original dataset -- contains a binary dependent variable (`CorrectVowel`) 
that for 21 `Item`s with Dutch _oe_ shown to 80 `Subject`s.
The participants differed in their German vocabulary scores (_Wortschatztest_ or _WST_), which was centred about the sample mean (`c.WSTRight`).
The other relevant variable is the self-explanatory `LearningCondition`, also a between-subject variable.
The distribution of the `c.WSTRight` variable is shown in the histogram below.



![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2-1.png) 

`lme4` aficionados can glean the model specification and parameter estimates from the output below,
`LearningCondition` was sum-coded (-0.5, 0.5):


```r
summary(mod)
```

```
## Generalized linear mixed model fit by maximum likelihood (Laplace
##   Approximation) [glmerMod]
##  Family: binomial  ( logit )
## Formula: CorrectVowel ~ LearningCondition + c.WSTRight + (1 | Subject) +  
##     (1 + LearningCondition | Item)
##    Data: dat_oe
## Control: glmerControl(optimizer = "bobyqa")
## 
##      AIC      BIC   logLik deviance df.resid 
##   1699.4   1737.3   -842.7   1685.4     1673 
## 
## Scaled residuals: 
##     Min      1Q  Median      3Q     Max 
## -2.9740 -0.5675 -0.2277  0.5891  5.5588 
## 
## Random effects:
##  Groups  Name              Variance Std.Dev. Corr
##  Subject (Intercept)       0.7545   0.8686       
##  Item    (Intercept)       2.9498   1.7175       
##          LearningCondition 0.0795   0.2820   0.71
## Number of obs: 1680, groups:  Subject, 80; Item, 21
## 
## Fixed effects:
##                   Estimate Std. Error z value Pr(>|z|)
## (Intercept)       -0.93321    0.39605  -2.356 0.018459
## LearningCondition  0.95299    0.25502   3.737 0.000186
## c.WSTRight         0.11892    0.04595   2.588 0.009656
## 
## Correlation of Fixed Effects:
##             (Intr) LrnngC
## LernngCndtn  0.169       
## c.WSTRight  -0.002  0.232
```

There wasn't any by-item variability in the covariate effect in this dataset, so I didn't include a random slope for `c.WSTRight`.
I don't know to what extent such variability would alter the results presented here.

On the basis of this model, new datasets were generated using the `simulate()` function.
The random effects for the items and participants were generated anew,
and the scores for the `c.WSTRight` variable were sampled with replacement from the original dataset.

For each simulated dataset, two model comparisons were run (function `newdata.fnc()` below).
The first model comparison tested the fixed effect of learning condition without considering the between-subject covariate of `c.WSTRight`.
The second comparison also tested the fixed effect of learning condition but accounted for `c.WSTRight` by means of a fixed effect.
I didn't run model comparisons in which the covariate was modelled using a random by-item slope,
though that could be interesting when substantial by-item variability in the covariate effect is expected.
In addition to the p-values resulting from these two model comparisons,
the parameter estimates for the fixed effect of learning condition were returned.

For each combination of parameters tested,
500 simulated datasets were generated and 
the number of p-values lower than 0.05 (_power_) as well as the mean parameter estimate were calculated (function `power.fnc()`).
500 isn't a huge number, but fitting logistic mixed-effect models takes a _lot_ of time.

Incidentally, the simulations produced a lot warning messages that the `glmer` crowd will be familiar with. 
I don't know to what extent this influences the results.

<img src = "http://homeweb.unifr.ch/VanhoveJ/Pub/Images/warningMessagesSimulation.png", alt = "Lots of warnings", width = "433", height = "277"/>

# R code

```r
#############################################################################################################
### Power simulation GLMM:                                                                                ###
### Does controlling for between-subject covariates improve power in between-subject, within-item design? ###
#############################################################################################################

################
## Preliminaries
################

# Read in data
# Accompanying article: http://homeweb.unifr.ch/VanhoveJ/Pub/papers/Vanhove_CorrespondenceRules.pdf
dat_oe <- read.csv("http://homeweb.unifr.ch/VanhoveJ/Pub/Data/correspondences_shortened_oe.csv")

# Summarise by participant (needed for simulation)
library(plyr)
perPart <- ddply(dat_oe, .(Subject), summarise,
                 c.EnglishScore = mean(c.EnglishScore),
                 c.WSTRight = mean(c.WSTRight))

# Recode LearningCondition as numeric (-0.5, 0.5) (sum coding)
dat_oe$LearningCondition <- as.numeric(dat_oe$LearningCondition) - 1.5

# Fit model on real data
library(lme4)
mod <- glmer(CorrectVowel ~ LearningCondition + c.WSTRight +
               (1 | Subject) + (1 + LearningCondition | Item), 
             data = dat_oe, family = binomial, control = glmerControl(optimizer="bobyqa"))

# Extract random effects
thetas <- getME(mod,"theta")

# Extract fixed effects
betas <- fixef(mod)

# betas[1]: Intercept
# betas[2]: LearningCondition (effect of condition)
# betas[3]: c.WSTRight (effect of covariate)

######################################
## Function for simulating new data ##
######################################

# Function for simulating new data
newdata.fnc <- function(         k = 80, # no. participants
                                 m = 24, # no. items/participant
                                 # these are the original estimates:
                                 Intercept = -0.9332077, 
                                 eff.Condition =  0.9529923,
                                 eff.Covariate = 0.1189162,
                                 # multiplicator factor covariate scores
                                 # (not relevant here)
                                 covariate.multiple = 1) {
  
  betas[1] <- Intercept
  betas[2] <- eff.Condition
  betas[3] <- eff.Covariate
  
  ### Generate new data set with k participants and m items
  
  # First generate k new participants,
  # randomly assign them to the experimental/control conditions,
  # and assign a covariate score to them.
  # The covariate scores are drawn with replacement from the original study's
  # covariate distribution and multiplied by the factor 'covariate.multiple'.
  parts <- data.frame(Subject = factor(1:k),
                      LearningCondition = sample(c(rep(-0.5, k/2), # not really needed in this case
                                                   rep(0.5, k/2))),
                      c.WSTRight = sample(covariate.multiple*perPart$c.WSTRight, k, replace = TRUE))
  
  # Then generate m new items.
  items <- data.frame(Item = factor(1:m))
  
  # Fully cross participants and items.
  newdat <- expand.grid(Subject = factor(1:k),
                        Item = factor(1:m))
  newdat <- merge(newdat, parts, by = "Subject")
  
  # Generate new data
  newdat$New <- factor(unlist(simulate(mod,
                                       newdata = newdat,
                                       allow.new.levels = TRUE,
                                       newparams = list(theta = thetas, beta = betas))))
  
  ### Run models for model comparison WITHOUT covariate
  mod1 <- glmer(New ~  (1 | Subject) + (1 + LearningCondition | Item), 
                data = newdat, family = binomial, 
                control = glmerControl(optimizer="bobyqa"))
  mod2 <- update(mod1, . ~ . + LearningCondition)
  
  ### Run models for model comparison with FIXED covariate
  mod3 <- glmer(New ~ c.WSTRight + (1 | Subject) + (1 + LearningCondition | Item), 
                data = newdat, family = binomial, 
                control = glmerControl(optimizer="bobyqa"))
  mod4 <- update(mod3, . ~ . + LearningCondition)
  
  # Compare mod1 and mod2 and return p-value
  pvalue.nocovar <- anova(mod1, mod2)[2, 8]
  
  # Compare mod3 and mod4 and return p-value
  pvalue.fixedcovar <- anova(mod3, mod4)[2, 8]
  
  # Save estimate and se of mod2
  est.nocovar <- summary(mod2)$coef[2,1]
  se.nocovar <- summary(mod2)$coef[2,2]
  
  # Save estimate and se of mod4
  est.fixedcovar <- summary(mod4)$coef[3,1]
  se.fixedcovar <- summary(mod4)$coef[3,2]
  
  # Return p-values, estimates and standard errors
  return(list(pvalue.nocovar, pvalue.fixedcovar,
              est.nocovar, est.fixedcovar, 
              se.nocovar, se.fixedcovar, 
              eff.Condition,
              eff.Covariate))
}

#################################################################################################
## Function for running above simulation 100 times and return power (%p < 0.05), average/sd ES ##
#################################################################################################

power.fnc <- function(runs = 500, # number of simulation runs
                      k = 60, 
                      m = 20,
                      Intercept = -0.9332077,
                      eff.Condition =  0.9529923,
                      eff.Covariate = 0.1,
                      covariate.multiple = 1) {
  
  # Run newdata.fnc a couple of times
  sim <- replicate(runs, 
                   newdata.fnc(k = k, 
                               m = m,
                               Intercept = Intercept,
                               eff.Condition =eff.Condition,
                               eff.Covariate =  eff.Covariate,
                               covariate.multiple = covariate.multiple))
  
  # And compute power
  power.nocovar <- mean(unlist(sim[1, ]) <= 0.05)
  power.fixedcovar <- mean(unlist(sim[2, ]) <= 0.05)
  
  # Compute average effect
  mean.est.nocovar <- mean(unlist(sim[3,]))
  mean.est.fixedcovar <- mean(unlist(sim[4,]))
  
  # Standard deviation of effect (not reported)
  sd.est.nocovar <- sd(unlist(sim[5,]))
  sd.est.fixedcovar <- sd(unlist(sim[6,]))
  
  return(list(power.nocovar = power.nocovar,
              power.fixedcovar = power.fixedcovar,
              mean.est.nocovar = mean.est.nocovar,
              mean.est.fixedcovar = mean.est.fixedcovar,
              sd.est.nocovar = sd.est.nocovar,
              sd.est.fixedcovar = sd.est.fixedcovar,
              k = k,
              m = m, 
              eff.Condition = eff.Condition,
              eff.Covariate = eff.Covariate,
              covariate.multiple = covariate.multiple))
}

# Run simulation
power.fnc(k = 60, m = 20, eff.Covariate = 0.1, runs = 500)
```
