# ============================================================
#  geom_pava.R
#
#  A ggplot2 stat + geom for isotonic (or antitonic) regression
#  via the Pool-Adjacent-Violators Algorithm (PAVA).
#
#  Usage:
#    source("geom_pava.R")
#    ggplot(d, aes(x, y)) + geom_pava()
#    ggplot(d, aes(x, y)) + geom_pava(decreasing = TRUE)
#
#  Arguments passed to geom_pava():
#    decreasing  logical; fit a non-increasing curve (default FALSE)
#    n           integer or NULL; if set, interpolate the step function
#                to n evenly spaced x-values (useful for dense grids)
#    ...         further aesthetics / parameters forwarded to GeomStep
#                (colour, linewidth, linetype, alpha, …)
# ============================================================

library(ggplot2)

# ---- core PAVA ---------------------------------------------
# Returns a named numeric vector: names are unique x values (as strings),
# values are the isotonic fitted means.
.pava_fit <- function(x, y, decreasing = FALSE) {
  if (decreasing) y <- -y
  
  ord <- order(x)
  x   <- x[ord]
  y   <- y[ord]
  
  xu <- unique(x)
  ym <- as.numeric(tapply(y, x, mean))   # weighted group means
  wt <- as.numeric(tapply(x, x, length)) # group sizes (= weights)
  m  <- length(ym)
  
  # --- PAVA main loop ---
  k <- 0L; b <- 0L
  s <- integer(m)   # end index of each block
  g <- numeric(m)   # weighted mean of each block
  v <- numeric(m)   # total weight of each block
  
  while (k < m) {
    k    <- k + 1L
    Gnew <- wt[k] * ym[k]
    vnew <- wt[k]
    
    # absorb immediately following non-increases into this block
    while (k < m && ym[k + 1L] <= ym[k]) {
      k    <- k + 1L
      Gnew <- Gnew + wt[k] * ym[k]
      vnew <- vnew + wt[k]
    }
    
    b    <- b + 1L
    s[b] <- k
    g[b] <- Gnew / vnew
    v[b] <- vnew
    
    # back-merge while the new block violates isotonicity
    while (b > 1L && g[b] <= g[b - 1L]) {
      s[b - 1L] <- k
      vt        <- v[b - 1L] + v[b]
      g[b - 1L] <- (v[b - 1L] * g[b - 1L] + v[b] * g[b]) / vt
      v[b - 1L] <- vt
      b         <- b - 1L
    }
  }
  
  # expand blocks back to one value per unique x
  f  <- numeric(m)
  st <- 1L
  for (a in seq_len(b)) { f[st:s[a]] <- g[a]; st <- s[a] + 1L }
  
  if (decreasing) f <- -f
  setNames(f, as.character(xu))
}

# ---- StatPava ----------------------------------------------
StatPava <- ggproto(
  "StatPava", Stat,
  
  required_aes = c("x", "y"),
  
  compute_group = function(data, scales, decreasing = FALSE, n = NULL) {
    fit <- .pava_fit(data$x, data$y, decreasing = decreasing)
    xu  <- as.numeric(names(fit))
    
    if (!is.null(n) && n > length(xu)) {
      # interpolate (step-constant) to n evenly spaced points
      out <- approx(xu, fit, xout = seq(min(xu), max(xu), length.out = n),
                    method = "constant", f = 0, rule = 2)
      data.frame(x = out$x, y = out$y)
    } else {
      data.frame(x = xu, y = as.numeric(fit))
    }
  }
)

# ---- geom_pava ---------------------------------------------
#' Isotonic (or antitonic) regression via PAVA
#'
#' Fits a non-decreasing (or non-increasing) step function to the data
#' using the Pool-Adjacent-Violators Algorithm. Repeated x values are
#' averaged before fitting. The result is drawn as a step function via
#' \code{GeomStep}, which faithfully represents the piecewise-constant fit.
#'
#' @param mapping   Set of aesthetic mappings (see \code{\link[ggplot2]{aes}}).
#' @param data      Data to use; if \code{NULL} inherits from the plot.
#' @param decreasing  Logical. If \code{TRUE}, fit a non-increasing
#'   (antitonic) regression. Default \code{FALSE}.
#' @param n         Integer or \code{NULL}. If supplied, the step function
#'   is interpolated to \code{n} evenly spaced x-values. Useful when you
#'   want a denser step grid. Default \code{NULL} (one point per unique x).
#' @param na.rm     Logical. Silently remove \code{NA}s? Default \code{FALSE}.
#' @param show.legend Logical. Should this layer appear in legends?
#' @param inherit.aes Logical. Inherit aesthetics from the plot? Default \code{TRUE}.
#' @param ...       Additional parameters forwarded to \code{GeomStep}
#'   (e.g. \code{colour}, \code{linewidth}, \code{linetype}, \code{alpha}).
#'
#' @examples
#' d <- data.frame(x = c(1, 2, 3, 4, 5), y = c(1, 3, 2, 5, 4))
#' ggplot(d, aes(x, y)) + geom_point() + geom_pava()
#' ggplot(d, aes(x, y)) + geom_point() + geom_pava(decreasing = TRUE)
geom_pava <- function(mapping     = NULL,
                      data        = NULL,
                      position    = "identity",
                      decreasing  = FALSE,
                      n           = NULL,
                      na.rm       = FALSE,
                      show.legend = NA,
                      inherit.aes = TRUE,
                      ...) {
  layer(
    geom        = GeomStep,
    stat        = StatPava,
    data        = data,
    mapping     = mapping,
    position    = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params      = list(
      decreasing = decreasing,
      n          = n,
      na.rm      = na.rm,
      direction  = "hv",   # step direction for GeomStep
      ...
    )
  )
}