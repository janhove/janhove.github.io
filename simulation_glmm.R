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
library(tidyverse)
perPart <- dat_oe |> 
  group_by(Subject) |> 
  summarise(
    c.EnglishScore = mean(c.EnglishScore),
    c.WSTRight = mean(c.WSTRight)
  )

# Recode LearningCondition as numeric (-0.5, 0.5) (sum coding)
dat_oe$LearningCondition <- ifelse(dat_oe$LearningCondition == "ij-ei", -0.5, 0.5)

# CorrectVowel is factor
dat_oe$CorrectVowel <- factor(dat_oe$CorrectVowel)

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
                               eff.Condition = eff.Condition,
                               eff.Covariate = eff.Covariate,
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
parameter_combinations <- expand.grid(m = c(5, 20),
                                      eff.Covariate = c(0.1, 1.0))
library(parallel)
results <- mcmapply(
  power.fnc
  , m = parameter_combinations$m
  , eff.Covariate = parameter_combinations$eff.Covariate
  , MoreArgs = list(k = 60, runs = 500)
  , mc.cores = 4
)
results <- cbind(parameter_combinations, t(results))
write_csv(results, "simulations_glmm.csv")
