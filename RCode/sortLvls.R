#######################################
# Functions for sorting factor levels #
# (janhove.github.io)                 #
#######################################

# Sort factor levels by the factor level mean of another covariate
sortLvlsByVar.fnc <- function(oldFactor, sortingVariable, ascending = TRUE) {
  
  require("dplyr")
  require("magrittr")
  
  # Combine into data frame
  df <- data.frame(oldFactor, sortingVariable)
  
  ###
  ### If you want to sort the levels by, say, the median, sd etc. instead of the mean,
  ### just change 'mean(sortingVariable)' below to, say, 'median(sortingVariable)'.
  ###
  
  # Compute average of sortingVariable and arrange (ascending)
  if (ascending == TRUE) {
    df_av <- df %>% group_by(oldFactor) %>% summarise(meanSortingVariable = mean(sortingVariable)) %>% 
      arrange(meanSortingVariable)
  }
  
  # Compute average of sortingVariable and arrange (descending)
  if (ascending == FALSE) {
    df_av <- df %>% group_by(oldFactor) %>% summarise(meanSortingVariable = mean(sortingVariable)) %>% 
      arrange(desc(meanSortingVariable))
  }
  
  # Return factor with new level order
  newFactor <- factor(oldFactor, levels = df_av$oldFactor)
  return(newFactor)
}

# Sort factor levels by their frequency of occurrence
sortLvlsByN.fnc <- function(oldFactor, ascending = TRUE) {

  require("magrittr")
  
  # Return factor with new level order
  newFactor <- factor(oldFactor, levels = table(oldFactor)  %>% sort(., decreasing = !ascending)  %>% names())
  return(newFactor)
}

# Sort factor levels arbitrarily
sortLvls.fnc <- function(oldFactor, levelOrder) {
  if(!is.factor(oldFactor)) stop("The variable you want to reorder isn't a factor.")
  
  if(!is.numeric(levelOrder)) stop("'order' should be a numeric vector.")
  
  if(max(levelOrder) > length(levels(oldFactor))) stop("The largest number in 'order' can't be larger than the number of levels in the factor.")
  
  if(length(levelOrder) > length(levels(oldFactor))) stop("You can't have more elements in 'order' than there are levels in the factor.")
  
  if(length(levelOrder) == length(levels(oldFactor))) {
    reorderedFactor <- factor(oldFactor, levels = levels(oldFactor)[levelOrder])
  }
  
  if(length(levelOrder) < length(levels(oldFactor))) {
    levelOrderAll <- c(levelOrder, (1:length(levels(oldFactor)))[-levelOrder])
    reorderedFactor <- factor(oldFactor, levels = levels(oldFactor)[levelOrderAll])
  }
  
  return(reorderedFactor)
}