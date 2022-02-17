#####################################################
# Compute Levenshtein distance between two texts
# using words rather than letters as the unit of comparison. 
# Insertions, deletions,
# substitutions, mergers (e.g. 'on to ' to 'onto') and 
# splits (e.g., 'onto' to 'on to') are considered.
# The function also outputs a data frame listing 
# the changes that were made. Note that sometimes,
# different alignments produce the same number of changes.
# This script tries to maximise the number of substitutions
# over mergers and splits.
#
# 2022-01-19, jan.vanhove@unifr.ch
# Last change: optimised decision criteria for "merger" and "split"

###############################################################
# Input: two strings to be compared.
# Output: Number of changes (on word level); data frame with changes.

obtain_edits <- function(textA, textB) {
  #############################################################
  # Define the costs. Here: All changes incur 1 point.
  COST <- 1
  COST_INSERTION <- COST
  COST_DELETION <- COST
  COST_SUBSTITUTION <- COST
  COST_SPLIT <- COST
  COST_MERGER <- COST
  
  # Insertion:
  cost_west <- function(i, j) {
    costs[i, j-1] + COST_INSERTION
  }
  
  # Deletion
  cost_north <- function(i, j) {
    costs[i - 1, j] + COST_DELETION
  }
  
  # Split up a word into two words.
  cost_split <- function(i, j, lstA, lstB) {
    if (j <= 2) {
      return(Inf)
    }
    
    if (lstA[[i - 1]] == paste0(lstB[[j - 2]], lstB[[j - 1]])) {
      cost <- cost <- costs[i - 1, j - 2] + COST_SPLIT
    } else {
      cost <- Inf
    }
    cost
  }
  
  # Merge two words into one.
  cost_merge <- function(i, j, lstA, lstB) {
    if (i <= 2) {
      return(Inf)
    }
    
    if (paste0(lstA[[i - 2]], lstA[[i - 1]]) == lstB[[j - 1]]) {
      cost <- costs[i - 2, j - 1] + COST_MERGER
    } else {
      cost <- Inf
    }
    cost
  }
  
  # Substitution
  cost_nowe <- function(i, j, lstA, lstB) {
    cost <- costs[i - 1, j - 1]
    if (lstA[[i - 1]] != lstB[[j - 1]]) {
      cost <- cost + COST_SUBSTITUTION
    }
    cost
  }
  
  #############################################################
  # Get rid of punctuation, then split up strings 
  # into words (by space).
  a <- gsub("[[:punct:][:blank:]]+", " ", textA)
  b <- gsub("[[:punct:][:blank:]]+", " ", textB)
  lstA <- strsplit(a, " ", perl = TRUE)[[1]]
  lstB <- strsplit(b, " ", perl = TRUE)[[1]]
  
  #############################################################
  # Compute costs using Levenshtein algorithm
  costs <- matrix(nrow = length(lstA) + 1,
                  ncol = length(lstB) + 1)
  costs[, 1] <- 0:length(lstA)
  costs[1, ] <- 0:length(lstB)
  rownames(costs) <- c("", lstA)
  colnames(costs) <- c("", lstB)
  
  for (i in 2:nrow(costs)) {
    for (j in 2:ncol(costs)) {
      
      costs[i, j] <- min(c(cost_north(i, j),
                           cost_west(i, j),
                           cost_nowe(i, j, lstA, lstB),
                           cost_merge(i, j, lstA, lstB),
                           cost_split(i, j, lstA, lstB)))
    }
  }
  
  #############################################################
  # Obtain data frame with edits
  check_change <- function(costs, i, j) {
    if (i == 1) {
      # Go west if in top row
      return(list("insertion", i, j - 1))
    }
    
    if (j == 1) {
      # Go north if in left column
      return(list("deletion", i-1, j))
    }
    
    # Include check that a split/merger was effected.
    if (j >= 3 &&
          costs[i, j] == costs[i - 1, j - 2] + COST &&
          lstA[[i - 1]] == paste0(lstB[[j - 2]], lstB[[j - 1]])) {
      # Knight move left
      return(list("split", i - 1, j - 2))
    }
    
    if (i >= 3 && 
          costs[i, j] == costs[i - 2, j - 1] + COST &&
          paste0(lstA[[i - 2]], lstA[[i - 1]]) == lstB[[j - 1]]) {
      # Knight move north
      return(list("merger", i - 2, j - 1))
    }
    
    if (costs[i - 1, j - 1] <= min(c(costs[i, j - 1], costs[i - 1, j]))) {
      # Go north-west
      if (costs[i - 1, j - 1] == costs[i, j]) {
        return(list("no change", i - 1, j - 1))
      } else {
        return(list("substitution", i - 1, j - 1))
      }
    }
    
    if (costs[i - 1, j] <= costs[i, j - 1]) {
      # Go north
      return(list("deletion", i - 1, j))
    }
    
    # Otherwise go west
    return(list("insertion", i, j - 1))
  }
  
  i <- nrow(costs)
  j <- ncol(costs)
  counter <- 1
  # The following assumes that all changes incur a cost of 1 point.
  change_position <- integer(length = costs[i, j])
  change_type <- character(length = costs[i, j])
  change_from <- change_type
  change_to <- change_type
  
  # The algorithm ends when we've reached the first cell.
  while (i > 1 | j > 1) {
    change <- check_change(costs, i, j)
    
    i <- change[[2]][[1]]
    j <- change[[3]][[1]]
    
    if (change[[1]][[1]] == "split") {
      change_position[[counter]] <- i
      change_type[[counter]] <- change[[1]][[1]]
      change_from[[counter]] <- lstA[[i]]
      change_to[[counter]] <- paste(lstB[[j]], lstB[[j + 1]])
      counter <- counter + 1
    } else if (change[[1]][[1]] == "merger") {
      change_position[[counter]] <- i
      change_type[[counter]] <- change[[1]][[1]]
      change_from[[counter]] <- paste(lstA[[i]], lstA[[i + 1]])
      change_to[[counter]] <- lstB[[j]]
      counter <- counter + 1
    } else if (change[[1]][1] == "substitution") {
      change_position[[counter]] <- i
      change_type[[counter]] <- change[[1]][[1]]
      change_from[[counter]] <- lstA[[i]]
      change_to[[counter]] <- lstB[[j]]
      counter <- counter + 1
    } else if (change[[1]][1] == "insertion") {
      change_position[[counter]] <- i
      change_type[[counter]] <- change[[1]][[1]]
      change_to[[counter]] <- lstB[[j]]
      counter <- counter + 1
    } else if (change[[1]][1] == "deletion") {
      change_position[[counter]] <- i
      change_type[[counter]] <- change[[1]][[1]]
      change_from[[counter]] <- lstA[[i]]
      counter <- counter + 1
    }
  }
  
  #############################################################
  # Output
  return(
    list(
      costs[nrow(costs), ncol(costs)],
      data.frame(
        change_position, change_type, change_from, change_to
      )
    )
  )
  
}

###############################################################
# Example
# original  <- "Check howmany changes need be made in order to change the first tekst in to the second one."
# corrected <- "Check how many changes need to be made in order to change the first text into the second one."
# obtain_edits(original, corrected)
