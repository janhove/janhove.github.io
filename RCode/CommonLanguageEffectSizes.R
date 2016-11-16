# These functions compute the common-language effect size
# as defined by McGraw & Wong (1992, Psychological Bulletin).
#
# cles_comp.fnc() uses McGraw & Wong's algebraic/normal approximation
# for computing the probability that a random X is higher than a random Y.
#
# cles_brute.fnc() provides a brute-force method in which
# a large number of random XY pairs is sampled (with replacement).
# The proportion of XY pairs where X is higher than Y is then computed and output.
# Ties count as 0.5*TRUE.

# Jan Vanhove:
# janhove.github.io
# jan.vanhove@unifr.ch

# Last changed: 16 November 2016

#########################################################
## BRUTE-FORCE METHOD

# runs = how many random samples
# variable = variable for which to compute the CLES
# group = grouping variable (two groups)
# baseline = level in 'group': Probability that a member of this level of group selected at random has a score higher than a member not belonging to this level of group.
# data = dataframe containing variable and group

cles_brute.fnc <- function(runs = 1e5, variable, group, baseline, data) {
  
  # Select the observations for group 1
  x <- data[data[[group]] == baseline, variable]
  
  # Select the observations for group 2
  y <- data[data[[group]] != baseline, variable]
  
  # - Randomly sample one member of group 1 and one member of group2
  #    and see if the member of group 1 has a higher score.
  # - Count ties as half-wins (0.5)
  # - Do this 'runs' number of times.
  
  comparison <- replicate(runs,
                          {s.x <- sample(x, 1)
                           s.y <- sample(y, 1)
                           ifelse(s.x == s.y, 
                                  0.5,
                                  s.x > s.y)})
  
  # Compute the proportion of 'TRUE's and return it
  return(mean(comparison))
}

#########################################################
# McGraw & Wong's (1992) method.


cles_comp.fnc <- function(variable, group, baseline, data) {
  # Select the observations for group 1
  x <- data[data[[group]] == baseline, variable]
  
  # Select the observations for group 2
  y <- data[data[[group]] != baseline, variable]
  
  # Mean difference between x and y
  diff <- (mean(x) - mean(y))
  
  # Standard deviation of difference
  stdev <- sqrt(var(x) + var(y))
  
  # Probability derived from normal distribution
  # that random x is higher than random y -
  # or in other words, that diff is larger than 0.
  p.norm <- 1 - pnorm(0, diff, sd = stdev)
  
  # Return result
  return(p.norm)
}

#########################################################
# Both

cles.fnc <- function(runs = 1e5, variable, group, baseline, data, print = TRUE) {
  cles_brute <- cles_brute.fnc(runs = runs, variable = variable, group = group, baseline = baseline, data = data)
  cles_comp <- cles_comp.fnc(variable = variable, group = group, baseline = baseline, data = data)
  
  results <- list(algebraic = cles_comp,
                  brute = cles_brute,
                  runs = runs)
  
  if(print == TRUE) {
  cat("Common-language effect size:",
      "\n",
      "\nThe probability that a random ", variable, " observation from group ", baseline, "\n",
      "is higher/larger than a random ", variable, " observation from the other group(s):",
      "\n",
      "\n    Algebraic method:   ", round(cles_comp, 2),
      "\n    Brute-force method: ", round(cles_brute, 2), 
      "\n",
      "\n(brute-force method based on ", runs, " runs)\n",
      sep = "")
  }
  
  return(results)
}

#########################################################
## Usage
# df <- data.frame(Height = c(rchisq(50, 3), rnorm(30, mean = 3)),
#                  Group = c(rep("A", 50), rep("B", 30)))
# cles <- cles.fnc(runs = 1e4, variable = "Height", group = "Group", 
#                  baseline = "A", data = df, print = TRUE)
# cles$algebraic
# cles$brute
# cles$runs
