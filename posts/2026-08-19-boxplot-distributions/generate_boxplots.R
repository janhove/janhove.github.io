boxplot_data <- function(
    k,                          
    minv, q1, q2, q3, maxv,    
    s = NULL,                 
    shapes = rep("uniform", 4), 
    margins_lo = c(0.05, 0.05, 0.05, 0.05),
    margins_hi = c(0.05, 0.05, 0.05, 0.05)) {
  # Generate univariate data whose five-number summary matches 
  # specified values. Data between these values follows user-specified
  # distributions.
  
  # k: Integer, k >= 2. Generates n = 4*k observations.
  # minv, q1, q2, q3, maxv: Desired five-number summary in ascending order.
  # s: Numeric vector (length 3) giving the gaps around q1, q2, and q3. 
  #    If NULL, a default gap equal to 10% of the smallest adjacent interval is used.
  # shapes: Character vector (length 4) specifying the distribution shape in each interval.
  # margins_lo, margins_hi: Numeric vectors (length 4) giving lower and upper insets 
  #                         (proportions) that keep generated values away from the interval endpoints.

  if (k < 2) stop("k must be >= 2")
  if (any(c(minv, q1, q2, q3, maxv) != sort(c(minv, q1, q2, q3, maxv)))) {
    stop("five-number summary must be in ascending order.")
  }
  n <- 4 * k
  
  # Symmetric gap around quartiles
  if (is.null(s)) {
    s <- min(q1 - minv, q2 - q1, q3 - q2, maxv - q3) * 0.1
    s <- rep(s, 3)
  }
  
  data <- numeric(n)
  data[1]       <- minv
  data[k]       <- q1 - s[1] # gap around first hinge
  data[k + 1]   <- q1 + s[1]
  data[2 * k]   <- q2 - s[2] # gap around median
  data[2*k + 1] <- q2 + s[2]
  data[3 * k]   <- q3 - s[3] # gap around second hinge
  data[3*k + 1] <- q3 + s[3]
  data[n]       <- maxv
  
  # Squish data into
  squish <- function(x) {
    x <- x - min(x)
    x <- x / max(x)
  }
  right_skewed <- function(m) {
    x <- abs(rnorm(m))
    squish(x)
  }
  left_skewed <- function(m) {
    x <- 1 - right_skewed(m)
    squish(x)
  }
  one_bump <- function(m) {
    x <- rnorm(m)
    squish(x)
  }
  two_bumps <- function(m) {
    x <- c(rnorm(floor(m/2), -5), rnorm(ceiling(m/2), 5))
    squish(x)
  }
  
  
  fill_segment <- function(v0, v1, m, shape, a0, b0) {
    if (m <= 0) return(numeric(0))
    u <- switch(shape,
                uniform    = runif(m),
                right_skew = right_skewed(m),
                left_skew  = left_skewed(m),
                one_bump   = one_bump(m),
                two_bumps  = two_bumps(m),
                stop("unknown shape: ", shape)
    )
    u <- a0 + (1 - a0 - b0) * u   # inset u away from 0/1
    sort(v0 + (v1 - v0) * u)
  }
  
  # Obtain bounds (ranks) for segments
  seg_bounds <- list(c(1, k), c(k+1, 2*k), c(2*k+1, 3*k), c(3*k+1, n))
  for (j in seq_along(seg_bounds)) {
    i0 <- seg_bounds[[j]][1]
    i1 <- seg_bounds[[j]][2]
    m <- i1 - i0 - 1
    if (m <= 0) next
    pts <- fill_segment(data[i0], data[i1], m, shapes[j], a0 = margins_lo[j], b0 = margins_hi[j])
    data[(i0 + 1):(i1 - 1)] <- pts
  }
  
  if (isFALSE(all.equal(fivenum(data), c(minv, q1, q2, q3, maxv)))) {
    warning("Not exact match with desired values.")
  }
  
  data
}

draw_boxplot <- function(x, show_mean = TRUE, main = NULL) {
  # Draw boxplot with horizontally jittered points overlaid,
  # and optionally, the mean.
  boxplot(x, main = main, at = 1)
  points(x = jitter(rep(1, length(x)), 4), y = x)
  if (show_mean) points(x = 1, mean(x), col = "darkred", pch = 8)
}

plot_boxplots <- function(k = 15, five_numbers = c(0, 7, 17, 40, 55), 
  show_mean = TRUE, show_data = FALSE) {
  # Plot 6 identical boxplots with different underlying distributions.
  
  five_numbers <- sort(five_numbers)
  minv <- five_numbers[1]
  maxv <- five_numbers[5]
  q1 <- five_numbers[2]
  q2 <- five_numbers[3]
  q3 <- five_numbers[4]
  
  if (minv < q1 - 1.5*(q3 - q1)) {
    minv <- q1 - 1.5*(q3 - q1)
    warning(paste0("Minimum value too far from box. Was reset to ", minv, "."))
  }
  if (maxv > q3 + 1.5*(q3 - q1)) {
    maxv <- q3 + 1.5*(q3 - q1)
    warning(paste0("Maximum value too far from box. Was reset to ", maxv, "."))
  }

  op <- par(no.readonly = TRUE)
  par(mfrow = c(2, 3), las = 1)
  
  # Spread out
  d1 <- boxplot_data(k, minv, q1, q2, q3, maxv, 
    shapes = c("uniform", "uniform", "uniform", "uniform"))
  draw_boxplot(d1, main = "Spread out data")
  
  # Gap around median
  d2 <- boxplot_data(k, minv, q1, q2, q3, maxv,  
    shapes = c("left_skew", "right_skew", "left_skew", "right_skew"),
    s = c(min(q1 - minv, 0.01), 0.7*min(q2 - q1, q3 - q2), min(maxv - q3, 0.01)))
  draw_boxplot(d2, main = "Gap around median")
  
  # Five numbers typical
  d3 <- boxplot_data(k, minv, q1, q2, q3, maxv,  
    shapes = c("two_bumps", "two_bumps", "two_bumps", "two_bumps"),
    s = rep(0, 3),
    margins_lo = rep(0, 4),
    margins_hi = rep(0, 4))
  draw_boxplot(d3, main = "Five modes")
  
  # All quartiles atypical
  d4 <- boxplot_data(k, minv, q1, q2, q3, maxv,  
    shapes = c("uniform", "uniform", "uniform", "uniform"),
    s = 0.5*c(min(q1 - minv, q2 - q1), min(q2 - q1, q3 - q2), min(q3 - q2, maxv - q3)),
    margins_lo = c(0.5, 0.5, 0.5, 0.5),
    margins_hi = c(0.5, 0.5, 0.5, 0.5))
  draw_boxplot(d4, main = "Quartiles atypical")
  
  # 5) Nearly empty box
  d5 <- boxplot_data(k, minv, q1, q2, q3, maxv,  
    shapes = c("uniform", "uniform", "uniform", "uniform"),
    s = c(0, min(q2 - q1, q3 - q2), 0),
    margins_lo = c(0, 0, 1, 0),
    margins_hi = rep(0, 4))
  draw_boxplot(d5, main = "Nearly empty box")
  
  # 6) Nearly empty whiskers
  d6 <- boxplot_data(k, minv, q1, q2, q3, maxv,  
    shapes = c("left_skew", "uniform", "uniform", "right_skew"),
    s = c(0, 0, 0),
    margins_lo = c(1, 0, 0, 0),
    margins_hi = c(0, 0, 0, 1))
  draw_boxplot(d6, main = "Nearly empty whiskers")
  
  par(op)
  
  if (show_data) {
    d <- data.frame(
      x = c(d1, d2, d3, d4, d5, d6),
      plot = rep(1:6, each = 4*k)
    )
    return(d)
  }
}

d <- plot_boxplots(show_data = TRUE)
tapply(d$x, d$plot, mean)

d <- plot_boxplots(five_numbers = c(0, 0, 1, 3, 5), show_data = TRUE)
tapply(d$x, d$plot, mean)

d <- plot_boxplots(five_numbers = c(0, 0, 0, 3, 17))
d <- plot_boxplots(five_numbers = c(0, 0.1, 5, 10, 10.1))
