# ============================================================
#  PAVA Visualisation v2 – "scan and merge" narrative
#  Each frame: walk the current fitted line left→right,
#  highlight the first descent found, merge those blocks,
#  redraw the full fitted line, repeat until isotonic.
# ============================================================
library(magick)

# ---- data --------------------------------------------------
x <- c(3, 5, 6, 7, 9, 9, 12, 13, 15, 17, 19, 20, 22, 23, 23, 26, 26, 26, 26)
y <- c(2, 4, 3, 6, 2, 4,  5, 10,  7,  7,  9, 22, 20, 18, 20, 16, 17, 19, 20)

x_unique <- unique(sort(x))
y_means  <- as.numeric(tapply(y, x, mean))
w        <- as.numeric(tapply(x, x, length))
m        <- length(y_means)

COL_MERGE  <- "#ffb703"   # the two blocks being merged
COL_LINE   <- "darkred"   # current fitted line
COL_ORIG   <- "#888888"   # original group means reference

# ---- helpers -----------------------------------------------

# Given a list of blocks (each: list(indices, mean, weight)),
# build the full fitted y-vector over x_unique
fit_from_blocks <- function(blocks) {
  f <- numeric(m)
  for (blk in blocks) f[blk$indices] <- blk$mean
  f
}

# Draw one frame
# blocks     : current list of blocks
# merge_pair : integer vector of length 2 — which block indices (into `blocks`) are merging
# cursor     : index into blocks up to which we've scanned (all < cursor are "settled")
# label      : title string
# show_line  : draw the fitted line?
draw_frame <- function(blocks, merge_pair = NULL, cursor = 0,
                       label = "", show_line = TRUE) {
  
  ylim <- c(min(y) - 0.8, max(y) + 2.5)
  xlim <- c(min(x) - 1,   max(x) + 1)
  par(mar = c(4, 4, 3.5, 1.5))
  
  plot(x, y,
       pch = 1, cex = 1.0,
       xlim = xlim, ylim = ylim,
       xlab = "x", ylab = "y",
       main = label,
       cex.main = 0.9, font.main = 1,
       las = 1, bty = "l", cex.axis = 0.85)
  
  # original group means reference
  lines(x_unique, y_means, col = COL_ORIG, lty = 2, lwd = 1.2)
  
  # draw blocks
  for (bi in seq_along(blocks)) {
    blk   <- blocks[[bi]]
    xs    <- x_unique[blk$indices]
    ymean <- blk$mean
    
    is_merging <- !is.null(merge_pair) && bi %in% merge_pair
    is_settled <- bi < cursor && !is_merging   # already passed by scan
    
    seg_col <- if      (is_merging) COL_MERGE
               else if (is_settled) NA
               else                 NA
    
    # shaded background
    rect(min(xs) - 0.45, ylim[1], max(xs) + 0.45, ymean,
         col = adjustcolor(seg_col, 0.08), border = NA)
  }
  
  # current fitted line
  if (show_line && length(blocks) > 0) {
    f <- fit_from_blocks(blocks)
    lines(x_unique, f, col = COL_LINE, lwd = 2.2, lty = 1)
  }
  
  # legend
  legend("topleft",
         legend = c("raw data and group means", "current fit"),
         col    = c("black", COL_LINE),
         lty    = c(2, 1),
         lwd    = c(1.2, 2.2),
         pch    = c(1, NA),
         pt.bg  = c("black", COL_LINE),
         pt.cex = 1.2, bty = "n", cex = 0.72, y.intersp = 1.1)
}

# ---- collect frames ----------------------------------------
# Strategy:
#   Start with one block per unique x.
#   Scan left to right; when blocks[i].mean > blocks[i+1].mean:
#     Frame A: highlight those two blocks (before merge)
#     Merge them into one block with weighted mean
#     Frame B: show result with redrawn fit line
#     Reset scan to max(1, i-1) to catch any new violations to the left
#   Repeat until one full pass with no violations found.
#   Final frame: "done" with all blocks settled.

frames <- list()
snap <- function(blocks, merge_pair = NULL, cursor = 0, label = "")
  frames[[length(frames) + 1]] <<-
  list(blocks = blocks, merge_pair = merge_pair, cursor = cursor, label = label)

# initialise: one block per unique-x group
blocks <- lapply(seq_len(m), function(i)
  list(indices = i, mean = y_means[i], weight = w[i]))

# Frame 0: raw group means, no merging yet
snap(blocks, NULL, 1, "Starting point: group means (one block per unique x)")

merge_count <- 0
i <- 1
while (i < length(blocks)) {
  if (blocks[[i]]$mean > blocks[[i + 1]]$mean) {
    merge_count <- merge_count + 1
    
    # Frame A: highlight the violating pair
    snap(blocks, c(i, i + 1), i,
         sprintf("Violation %d: block mean %.2f > %.2f \u2014 merging",
                 merge_count, blocks[[i]]$mean, blocks[[i + 1]]$mean))
    
    # merge block i and i+1
    new_w    <- blocks[[i]]$weight + blocks[[i + 1]]$weight
    new_mean <- (blocks[[i]]$weight * blocks[[i]]$mean +
                   blocks[[i + 1]]$weight * blocks[[i + 1]]$mean) / new_w
    new_idx  <- c(blocks[[i]]$indices, blocks[[i + 1]]$indices)
    merged   <- list(indices = new_idx, mean = new_mean, weight = new_w)
    
    blocks <- c(blocks[seq_len(i - 1)],
                list(merged),
                if (i + 2 <= length(blocks)) blocks[(i + 2):length(blocks)] else list())
    
    # Frame B: show result
    snap(blocks, NULL, i,
         sprintf("After merge %d: new block mean = %.2f", merge_count, new_mean))
    
    # step back to catch any newly created violation to the left
    i <- max(1, i - 1)
  } else {
    i <- i + 1
  }
}

# final frame
snap(blocks, NULL, length(blocks) + 1, "Done: isotonic fit complete")

cat(sprintf("Total frames: %d  (including %d merge events)\n",
            length(frames), merge_count))

# ---- render ------------------------------------------------
png_dir   <- tempdir()
png_files <- character(length(frames))

for (fi in seq_along(frames)) {
  fr    <- frames[[fi]]
  fpath <- file.path(png_dir, sprintf("frame_%03d.png", fi))
  png(fpath, width = 900, height = 620, res = 120)
  draw_frame(fr$blocks, fr$merge_pair, fr$cursor, fr$label, show_line = TRUE)
  dev.off()
  png_files[fi] <- fpath
  cat(sprintf("  frame %d/%d\n", fi, length(frames)))
}

# hold first and last frames longer
all_files <- c(rep(png_files[1], 2),
               png_files,
               rep(png_files[length(png_files)], 2))

imgs <- image_read(all_files)
gif  <- image_animate(imgs, fps = 1, delay = 300, optimize = TRUE)

out <- paste0(getwd(), "/pava_steps.gif")
image_write(gif, out)
cat("GIF saved:", out, "\n")
