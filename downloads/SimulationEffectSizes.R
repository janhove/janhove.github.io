# Load packages
# Use 'install.packages("MASS")' if not available
library(MASS)
library(plyr)

# The function below will randomly generate datasets
# from a bivariate normal distribution.
# First define this distribution's variance-covariance matrix.
Sigma <- matrix(c(6, 1.3, 1.3, 2), 2, 2)

# Now define a simulation function that
# draws a random ample with 2x100 observations 
# from a bivariat normal distribution
# and compute standardised and raw effect sizes
# for the complete dataset and 
# for the dataset with the middle half removed.
simulate.fnc <- function() {
  # Generate 100 pairs of datapoints from a bivariate normal distribution;
  # Output them as a dataframe;
  # and sort them from low to high.
  dat <- arrange(data.frame(mvrnorm(n = 100, rep(3, 2), Sigma)),
                 X1)
  
  # Compute effect sizes
  # Pearson correlation for the whole dataset
  r.full <- with(dat, cor(X1, X2))
  
  # Pearson correlation when the middle part of the dataset isn't considered.
  r.reduced <- with(dat[c(1:20, 81:100),], cor(X1, X2))
  
  # Regression coefficient for the whole dataset
  b.full <- coef(with(dat, lm(X2 ~ X1)))[2]
  
  # Regression coefficient when the middle part of the dataset isn't considered.
  b.reduced <- coef(with(dat[c(1:20, 81:100),], lm(X2 ~ X1)))[2]
  
  # Return these four effect sizes
  return(list(r.full, r.reduced, b.full, b.reduced))
}

# Run the above function 10000 times and save the results
sims <- replicate(10000, simulate.fnc())


# Plot effect sizes
# Two plots side by side (doesn't really matter)
par(mfrow = c(1, 2), las = 1, bty = "l", lty = 1)

# Standardised effect sizes

plot(unlist(sims[1,]), xlim = range(c(unlist(sims[1,]), unlist(sims[2,]))),
     unlist(sims[2,]), ylim = range(c(unlist(sims[1,]), unlist(sims[2,]))),
     xlab = "Pearson's r - random sampling",
     ylab = "Pearson's r - extreme groups",
     pch = ".",
     main = "Standardised effect sizes\n(correlation coefficients)")
abline(a = 0, b = 1, lty = 2)

# Unstandardised effect sizes
plot(unlist(sims[3,]), xlim = range(c(unlist(sims[3,]), unlist(sims[4,]))),
     unlist(sims[4,]), ylim = range(c(unlist(sims[3,]), unlist(sims[4,]))),
     xlab = "Beta coefficient - random sampling",
     ylab = "Beta coefficient - extreme groups",
     pch = ".",
     main = "Unstandardised effect sizes\n(regression coefficients)")
abline(a = 0, b = 1, lty = 2)

## For the second simulation, just replace 'dat[c(1:20, 81:100),]' in the above by 'dat[c(71:100),]'