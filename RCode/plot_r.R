#
# plot_r
# 
# Given a correlation coefficient and a sample size, 
# this function draws 16 scatterplots
# whose shapes differ greatly 
# but all of which are consistent with the correlation coefficient.
#
# jan.vanhove@unifr.ch
# http://janhove.github.io
#
# Last change: 19 November 2016

plot_r <- function(r = 0.6, n = 50, showdata = FALSE) {
  
  # Function for computing y vector.
  # Largely copy-pasted from
  # http://stats.stackexchange.com/questions/15011/generate-a-random-variable-with-a-defined-correlation-to-an-existing-variable/15040#15040
  
  compute.y <- function(x, y, r) {
    theta <- acos(r)
    X     <- cbind(x, y)                              # matrix
    Xctr  <- scale(X, center = TRUE, scale = FALSE)   # centered columns (mean 0)
    
    Id   <- diag(n)                                   # identity matrix
    Q    <- qr.Q(qr(Xctr[, 1, drop = FALSE]))         # QR-decomposition, just matrix Q
    P    <- tcrossprod(Q)          # = Q Q'           # projection onto space defined by x1
    x2o  <- (Id - P) %*% Xctr[, 2]                    # x2ctr made orthogonal to x1ctr
    Xc2  <- cbind(Xctr[, 1], x2o)                     # bind to matrix
    Y    <- Xc2 %*% diag(1 / sqrt(colSums(Xc2 ^ 2)))  # scale columns to length 1
    
    y <- Y[, 2] + (1 / tan(theta)) * Y[, 1]     # final new vector
    return(y)
  }
  
  
  # Graph settings
  op <- par(no.readonly = TRUE)
  par(
    las = 1,
    mfrow = c(4, 4),
    xaxt = "n",
    yaxt = "n",
    mar = c(1, 1.5, 2, 1.5),
    oma = c(0, 0, 3.5, 0),
    cex.main = 1.1
  )
  
  # Case 1: Textbook case with normal x distribution and normally distributed residuals
  x <- rnorm(n)           # specify x distribution
  y <- rnorm(n)           # specify y distribution
  y <- compute.y(x, y, r) # recompute y to fit with x and r
  plot(                   # plot
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(1) Normal x, normal residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df1 <- data.frame(x, y) # store x and y to data frame
 
  
  # Case 2: Textbook case with uniform x distribution and normally distributed residuals
  x <- runif(n, 0, 1)
  y <- rnorm(n)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(2) Uniform x, normal residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df2 <- data.frame(x, y)
  
  # Case 3: Skewed x distribution (positive): A couple of outliers could have high leverage.
  x <- rlnorm(n, 5)
  y <- rnorm(n)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(3) +-skewed x, normal residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df3 <- data.frame(x, y)
  
  # Case 4: Skewed x distribution (negative): Same as 4.
  x <- rlnorm(n, 5) * -1 + 5000
  y <- rnorm(n)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(4) --skewed x, normal residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df4 <- data.frame(x, y)
  
  # Case 5: Skewed residual distribution (positive), similar to 3-4
  x <- rnorm(n)
  y <- rlnorm(n, 5)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(5) Normal x, +-skewed residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df5 <- data.frame(x, y)
  
  # Case 6: Skewed residual distribution (negative), same as 5
  x <- rnorm(n)
  y <- rlnorm(n, 5)
  y <- y * -1
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(6) Normal x, --skewed residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df6 <- data.frame(x, y)
  
  # Case 7: Variance increases with x. Correlation coefficient under/oversells predictive power depending on scenario.
  # Also, significance may be affected.
  x <- rnorm(n)
  x <- sort(x, decreasing = FALSE) + abs(min(x))
  variance <- 10*x # spread increases with x
  y <- rnorm(n, 0, sqrt(variance)) # error term has larger variance with x
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(7) Increasing spread", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df7 <- data.frame(x, y)
  
  # Case 8: Same as 7, but variance decreases with x
  x <- rnorm(n)
  x <- x + abs(min(x))
  a <- 10 * (max(x)) # calculate intercept of x-standard deviation function
  variance <- a - 10*x
  y <- rnorm(n, 0, sqrt(variance))
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(8) Decreasing spread", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df8 <- data.frame(x, y)
  
  # Case 9: Nonlinearity (quadratic trend).
  x <- rnorm(n)
  y <- x ^ 2 + rnorm(n, sd = 0.2)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(9) Quadratic trend", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df9 <- data.frame(x, y)
  
  # Case 10: Sinusoid relationship
  x <- runif(n,-2 * pi, 2 * pi)
  y <- sin(x) + rnorm(n, sd = 0.2)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(10) Sinusoid relationship", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df10 <- data.frame(x, y)
  
  # Case 11: A single positive outlier can skew the results.
  x <- rnorm(n - 1)
  x <- c(sort(x), 10)
  y <- c(rnorm(n - 1), 15)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(11) A single positive outlier", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df11 <- data.frame(x, y)
  
  # Regression without outlier
  group1 <- x[1:(n - 1)]
  y1 <- y[1:(n - 1)]
  
  xseg1 <- seq(
    from = min(group1),
    to = max(group1),
    length.out = 50
  )
  pred1 <- predict(lm(y1 ~ group1), newdata = data.frame(group1 = xseg1))
  lines(xseg1, pred1, lty = 2, col = "firebrick2")
  
  # Case 12: A single negative outlier - same as 11 but the other way.
  x <- rnorm(n - 1)
  x <- c(sort(x), 10)
  y <- c(rnorm(n - 1),-15)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(12) A single negative outlier", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df12 <- data.frame(x, y)
  
  # Regression line without outlier
  group1 <- x[1:(n - 1)]
  y1 <- y[1:(n - 1)]
  
  xseg1 <- seq(
    from = min(group1),
    to = max(group1),
    length.out = 50
  )
  pred1 <- predict(lm(y1 ~ group1), newdata = data.frame(group1 = xseg1))
  lines(xseg1, pred1, lty = 2, col = "firebrick2")
  
  # Case 13: Bimodal y: Actually two groups (e.g. control and experimental). Better to model them in multiple regression model.
  x <- rnorm(n)
  y <- c(rnorm(floor(n / 2), mean = -3), rnorm(ceiling(n / 2), 3))
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(13) Bimodal residuals", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df13 <- data.frame(x, y)
  
  # Case 14: Two groups
  # Create two groups within each of which
  # the residual XY relationship is contrary to the overall relationship.
  # This will often produce examples of Simpson's paradox.
  x <- c(rnorm(floor(n / 2),-3), rnorm(ceiling(n / 2), 3))
  y <- -sign(r)* 10 * x + rnorm(n, sd = 0.5) + c(rep(0, floor(n / 2)), rep(3 * sign(r), ceiling(n / 2)))   
  
  # Symbols / colours for each group
  colour <- c(rep("blue", floor(n / 2)), rep("red", ceiling(n / 2)))
  symbol <- c(rep(1, floor(n / 2)), rep(4, ceiling(n / 2)))
  
  y <- compute.y(x, y, r)
  
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    pch = symbol,
    main = paste("(14) Two groups", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df14 <- data.frame(x, y)
  
  # Also add lines of regression within each group
  
  # Divide up y variable
  group1 <- x[colour == "blue"]
  group2 <- x[colour == "red"]
  y1 <- y[colour == "blue"]
  y2 <- y[colour == "red"]
  
  xseg1 <- seq(
    from = min(group1),
    to = max(group1),
    length.out = 50
  )
  pred1 <- predict(lm(y1 ~ group1), newdata = data.frame(group1 = xseg1))
  lines(xseg1, pred1, lty = 2, col = "firebrick2")
  
  xseg2 <- seq(
    from = min(group2),
    to = max(group2),
    length.out = 50
  )
  pred2 <- predict(lm(y2 ~ group2), newdata = data.frame(group2 = xseg2))
  lines(xseg2, pred2, lty = 2, col = "firebrick2")
  
  # Case 15: Sampling at the extremes - this would overestimate correlation coefficient based on all data.
  x <- sort(rnorm(6 * n, sd = 3))
  x1 <- x[1:floor((n / 2))]
  x2 <- x[floor(5.5 * n + 1):(6 * n)]
  x <- c(x1, x2)
  y <- rnorm(n)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(15) Sampling at the extremes", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df15 <- data.frame(x, y)
  
  # Case 16: Lumpy x/y data, as one would observe for questionnaire items
  x <- sample(1:5, n, replace = TRUE, prob = sample(c(5, 4, 3, 2, 1))) # unequal proportions for each answer just for kicks
  y <- sample(1:7, n, replace = TRUE)
  y <- compute.y(x, y, r)
  plot(
    x,
    y,
    ylab = "",
    xlab = "",
    main = paste("(16) Coarse data", sep = "")
  )
  abline(lm(y ~ x), col = "dodgerblue3")
  df16 <- data.frame(x, y)
  
  # Overall title
  title(
    paste("All correlations: r(", n, ") = ", r, sep = ""),
    outer = TRUE,
    cex.main = 2
  )
  par(op)
  
  # Define data frame with numeric output
  df <- list(plot = 1:16, data = list(df1, df2, df3, df4,
                                     df5, df6, df7, df8,
                                     df9, df10, df11, df12,
                                     df13, df14, df15, df16))
  df <- structure(df, class = c("tbl_df", "data.frame"), row.names = 1:16)
  
  # Show numeric output depending on setting
  if(!(showdata %in% c(NULL, TRUE, FALSE, 1:16, "all"))) {
    warning("'showdata' must be TRUE, FALSE, 'all', or a number between 1 and 16.")
  } else if(showdata %in% c(TRUE, "all")) {
    return(df)
  } else if(showdata %in% 1:16) {
    return(df$data[[showdata]])
  }
}
