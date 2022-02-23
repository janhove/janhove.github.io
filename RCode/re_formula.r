# Obtaining CrI around estimates: re_formula = NA vs. re_formula = NULL.
#
# 2021-12-05
# jan.vanhove@unifr.ch, @janhove
#
# Also see https://janhove.github.io/visualise_uncertainty/

# Load packages
library(tidyverse)
library(lme4)
library(brms)

# Prepare dataset
data(sleepstudy)
sleep <- sleepstudy
sleep$Subject <- as.character(sleep$Subject)

# Raw data
sleepstudy %>% 
  ggplot(aes(x = Days, y = Reaction)) +
  geom_point() +
  geom_smooth(method = "lm") +
  facet_wrap(~ reorder(Subject, Reaction))

# Fit model
sleep.brm <- brm(Reaction ~ 1 + Days + (1 + Days|Subject),
                 data = sleep,
                 warmup = 1000, iter = 3000,
                 cores = 4,
                 control = list(adapt_delta = 0.95)) 

# From this model we can derive answers to a variety of questions.
# (1a) If you obtained a fresh set of observations from a known participant,
#      i.e., one for whom you've already collected data, where are these
#      observations likely to lie?
#
# (1b) If you obtained a fresh set of observations from an unknown participant,
#      i.e., one for whom you haven't got any data, where are these
#      observations likely to lie?
#
# (2a) If you obtained lots and lots of fresh sets of observations from a 
#      known participant, where is the *average* observation bound to lie?
#
# (2b) If you obtained lots and lots of fresh sets of observations from an 
#      unknown participant, where is the *average* observation bound to lie?
#
# (2c) Where is the average observation of the average participant bound to lie?
#
# Which question you're interested in will determine how you generate 
# uncertainty intervals for your estimes. I'll illustrate this below.

# (1a, 1b): Generate data for three known participants and one new one.
new_sleep <- expand.grid(
  Days = 0:9,
  Subject = c("309", "334", "337", "new subject")
)

individual_observations <- predict(sleep.brm, newdata = new_sleep,
                                   re_formula = NULL, allow_new_levels = TRUE) %>% 
  as_tibble() %>% 
  bind_cols(new_sleep, .)

individual_observations %>% 
  ggplot(aes(x = Days, y = Estimate,
             ymin = `Q2.5`, ymax = `Q97.5`)) +
  geom_ribbon(fill = "grey") +
  geom_line() +
  ylim(100, 500) +
  facet_wrap(~ Subject) +
  labs(title = "Prediction interval for known and unknown participants")

# (2a, 2b)
individual_averages <- fitted(sleep.brm, newdata = new_sleep,
                              re_formula = NULL, allow_new_levels = TRUE) %>% 
  as_tibble() %>% 
  bind_cols(new_sleep, .)

individual_averages %>% 
  ggplot(aes(x = Days, y = Estimate,
             ymin = `Q2.5`, ymax = `Q97.5`)) +
  geom_ribbon(fill = "grey") +
  geom_line() +
  ylim(100, 500) +
  facet_wrap(~ Subject) +
  labs(title = "Credible interval (for average) for known and unknown participants")

# Note that the second type of computation yields narrower uncertainty bands.
# The reason is quite simply that individual observations will vary more
# than the average of individual observations.
# Also, the uncertainty bands of participants for whom you've already
# obtained information are narrower. (More information = less uncertainty.)

# (2c): Switching "re_formula = NULL" to NA, viz., 
overall_average <- fitted(sleep.brm, newdata = new_sleep, re_formula = NA) %>% 
  as_tibble() %>%
  bind_cols(new_sleep, .)
overall_average %>% 
  ggplot(aes(x = Days, y = Estimate,
             ymin = `Q2.5`, ymax = `Q97.5`)) +
  geom_ribbon(fill = "grey") +
  geom_line() +
  ylim(100, 500) +
  facet_wrap(~ Subject) +
  labs(title = "Credible interval (for average) for average participant")