# Define panel with correlation coefficients
panel.cor <- function(x, y, ...) {
  par(usr = c(0, 1, 0, 1))
  txt <- as.character(sprintf("%.2f", cor(x,y, use = "p"))) # round to two decimal places
  text(0.5, 0.5, txt, cex = 1.8)
  text(0.5, 0.3, paste("n =", length(x[!is.na(x) & !is.na(y)])))
  text(0.5, 0.1, paste("missing:", length(x[is.na(x) | is.na(y)])))
}

# Scatterplot with lowess scatterplot smoother
panel.smooth <- function(x, y, span=2/3, iter=3, ...) {
  if (is.numeric(x) && is.numeric(y)) {
    points(x, y, pch = 1, col = "grey70", bg = "white", cex = 1.5)
    ok <- is.finite(x) & is.finite(y)
    if (any(ok)) 
      lines(stats::lowess(x[ok], y[ok], f = span, iter = iter), 
            col = "#377EB8", lwd = 2, ...)
  }
}

panel.scatter <- function(x, y, ...) {
  if (is.numeric(x) && is.numeric(y)) {
    points(x, y, pch = 1, col = "grey40", bg = "white", cex = 1.5)
  }
}

# Histograms
panel.hist <- function(x, ...) {
  usr <- par("usr"); on.exit(par(usr))
  par(usr = c(usr[1:2], 0, 1.5) )
  h <- hist(x, plot = FALSE)
  breaks <- h$breaks; nB <- length(breaks)
  y <- h$counts; y <- y/max(y)
  rect(breaks[-nB], 0, breaks[-1], y, col="grey", ...)
}

myScatterMatrix <- function(..., cex.labels = 1.8, top = panel.scatter, bottom = panel.cor, middle = panel.hist, las = 1) {
  pairs(..., upper.panel = top, lower.panel = bottom, diag.panel = middle, las = las, cex.labels = cex.labels)
}