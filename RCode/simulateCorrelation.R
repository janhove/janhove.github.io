simulateCorrelation.fnc <- function(n = 50, r = 0.5, trend.line = TRUE) {
  ### Check whether MASS is available
  if(require(MASS) == FALSE) {
    stop("Install MASS package first. Type 'install.packages(\"MASS\")' at prompt.")
  }
  
  ### Simulate data
  # Create variance/covariance matrix
  Sigma <- matrix(r, nrow = 2, ncol = 2) + diag(2)*(1-r)
  # Simulate data (force empirical)
  simdat <- mvrnorm(n,
                    mu = c(0, 0),
                    Sigma = Sigma,
                    empirical = TRUE)
  
  ### Plot data
  plot(simdat, 
       xlim = c(-3.5, 3.5), ylim = c(-3.5, 3.5),
       xlab = "Variable 1 (st. dev.)", ylab = "Variable 2 (st. dev.)")
  
  ### Add regression line if needed
  if(trend.line == TRUE) {
    # Compute regression model
    mod <- lm(simdat[,2] ~ simdat[,1])
    
    # Compute predicted values (min/max)
    min.x <- min(simdat[,1])
    max.x <- max(simdat[,1])
    min.pred.y <- coef(mod) %*% c(1, min.x)
    max.pred.y <- coef(mod) %*% c(1, max.x)
    
    # Add regression line to plot
    segments(x0 = min.x, x1 = max.x,
             y0 = min.pred.y, y1 = max.pred.y,
             col = "#225EA8",
             lwd = 2.5)
  }
}