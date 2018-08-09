# Explanation

if(!require("tidyverse")) {
  install_tidyverse <- paste0("Please install the tidyverse suite:", "\n",
                              "'install.packages(\"tidyverse\")'")
  stop(install_tidyverse)
}

parade <- function(model, full_data = NULL) {
  # This function generates a parade (= 'lineup'
  #   in the nullabor package) that hides the fitted values
  #   and residuals of the true model among the fitted values
  #   and residuals of 19 similar models fitted on simulated 
  #   outcome data. The simulated outcome data were generated 
  #   by means of parametric bootstrapping from the true model.
  # 'model' is the name of the statistical model;
  #   this needs to be an lm() or a gam() model.
  # Use 'full_data' if you want to include variables
  #   in the output parade that aren't part of the model.
  #   This can be useful to check if any residual patterns
  #   can be accounted for using additional variables. If
  #   'full_data' isn't specified, only the variables that
  #   are included in 'model' are output.
  
  if (!(class(model)[1] %in% c("lm", "gam"))) {
    stop(paste0("This function currently only works with lm() and gam() models. ",
                "The class of the model you tried to fit was ",
                class(model), "."))
  }
  
  # Get data frame with all variables in model
  df <- model.frame(model)
  
  # Get the name of the outcome variable
  outcome_var <- colnames(df)[1]
  
  # Simulate 19 vectors of outcome data from the model
  simulated_data <- data.frame(simulate(model, n = 19))
  
  # Check if full_data was specified, and if so,
  # if it was correctly specified.
  if (is.null(full_data)) {
    # OK: use model frame to generate data frame for parade
    # Get all the variable names.
    other_vars <- colnames(df)[-1]
    var_names <- c(other_vars, outcome_var)
    df <- cbind(simulated_data, df)
      
  } else if (!is.data.frame(full_data)) {
    # full_data needs to be a data frame (tibbles also work)
    stop(paste0("You supplied an object to 'full_data' that isn't a data frame. ",
                "Its class is ", class(full_data), "."))
    
  } else if (!(all(colnames(df) %in% colnames(full_data)))) {
    # Not all variables in the model occur in full_data
    stop(paste0("The data frame supplied to 'full_data' needs to contains ",
                "all variables used in the model supplied to 'model'."), "\n",
         paste0("The following variables are missing in 'full_data': "), "\n",
         paste(shQuote(colnames(df)[!(colnames(df) %in% colnames(full_data))]), collapse = ", "), "\n",
         paste0("Did you specify the correct data frame?"))
    
  } else if (nrow(df) != nrow(full_data)) {
    # Different datasets?
    stop(paste0("The dataset on which the model was fitted and the one passed to 'full_data' ",
                "contain a different number of observations. ",
                "If you're sure you supplied to correct data frame and model, ",
                "check if full_data contains missing data in the outcome or predictors ",
                "and remove these if necessary."))
  } else if (!is.null(full_data)) {
    # OK: use full_data to generate date frame
    other_vars <- colnames(full_data)[!(colnames(full_data) %in% outcome_var)]
    # Get all the variable names
    var_names <- c(other_vars, outcome_var)
    df <- cbind(simulated_data, df[, outcome_var], full_data[, other_vars])
  }

  
  # Rename the columns with the simulated and true outcome variable
  colnames(df)[1:20] <- c(paste("..sample", 1:20))
  
  # Convert df to the long format. For now, ..sample 20 contains
  # the true data.
  df <- df %>% 
    gather(key = "..sample",
           value = "outcome",
           starts_with("..sample "))
  
  # Rename the column with the true and simulated outcomes appropriately
  colnames(df)[ncol(df)] <- outcome_var
  
  # Refit the model to each vector of simulated and true
  # outcomes. For more complex models, it may save some time
  # to not refit the last model, but I'll leave that to someone
  # with 1337 R skillz.
  df <- df %>% 
    group_by(..sample) %>% 
    # Refit the original model to each sample (using update()),
    # output the fitted and residual values (using augment()),
    # and retain dfs variables (using data = .):
    do(broom::augment(update(model, data = .), data = .)) %>% 
    # Add transformed residuals
    mutate(.abs_resid = abs(.resid)) %>% 
    mutate(.sqrt_abs_resid = sqrt(abs(.resid))) %>% 
    # augment() outputs some additional info;
    # only retain variables, fitted values and residuals here
    select("..sample", var_names, ".fitted", ".resid", ".abs_resid", ".sqrt_abs_resid") %>% 
    ungroup()
  
  # Generate a random number between 1 and 20. This will be
  # the position of the true data in the parade.
  pos <- sample(1:20, 1)
  
  # This ugly bit moves the true data to position 'pos':
  df_sample <- data.frame(
    .sample2 = paste("..sample", 1:20),
    .sample = c((1:20)[-pos], pos)
  )
  df_sample$.sample2 <- as.character(df_sample$.sample2)
  df <- df %>% 
    left_join(df_sample, by = c("..sample" = ".sample2")) %>% 
    select(-..sample)
  
  # Add the true data's position as an attribute to the parade.
  attr(df, "position") <- pos
  
  # Add the names of the variables by category
  attr(df, "outcome_var") <- outcome_var
  attr(df, "other_vars") <- other_vars
  attr(df, "predictor_vars") <- colnames(model.frame(model)[-1])
  
  # Output the parade
  return(df)
}

reveal <- function(parade) {
  # This function reveals the position of the true data
  # in a parade.
  if (is.null(attr(parade, "position"))) {
    stop("The object you supplied doesn't seem to be a parade generated by the parade() function.")
  }
  message(paste0("The true data are in position ",
                 attr(parade, "position"), "."))
}

resid_summary <- function(parade, predictors_only = FALSE) {
  # This function computes the mean residuals and fitted
  # values per cell for all samples in a parade. The cells
  # are defined as the unique combinations of values of 
  # the non-outcome variables in the dataset (default) or 
  # as the unique combinations of the values of the 
  # model's predictor variables (if 'predictors_only = TRUE').
  # I think this function is mainly useful if:
  # - there is a limited number of cells (i.e., no continuous
  #   non-outcome variables);
  # - the outcome variable is pretty categorical (e.g.,
  #   if it was measured on a Likert-scale) so that it will stand
  #   out in standard diagnostic plots like a sore thumb.
  # The function throws warnings if some grouping variables aren't
  # categorical or if the outcome variable isn't all too categorical.
  
  # Check if parade is a parade
  if (is.null(attr(parade, "position"))) {
    stop("The object you supplied doesn't seem to be a parade generated by the parade() function.")
  }
  
  # Throw a warning if the outcome variable isn't very categorical.
  # (Arbitrarily defined as more than 20 unique observations.)
  n_outcome_levels <- parade %>% 
    filter(.sample == attr(parade, "position")) %>% 
    select(attr(parade, "outcome_var")) %>% 
    distinct() %>% 
    nrow()
  if (n_outcome_levels > 19) {
    warning(paste0(attr(parade, "outcome_var"), " contains ",
                   n_outcome_levels, " unique values. ",
                   "Perhaps you can draw standard diagnostic plots ",
                   "instead of averaging the residuals."))
  }
  
  if (predictors_only == FALSE) {
    # Summarise by all variables, 
    # including those not used for fitting model
    grouping_vars <- attr(parade, "other_vars")
  } else if (predictors_only == TRUE) {
    # Summarise by predictor variables only.
    grouping_vars <- attr(parade, "predictor_vars")
  }
  
  # Throw a warning if not all grouping variables
  # are characters or factors.
  if (!(all(sapply(parade[, grouping_vars], class) %in% c("character", "factor")))) {
    warning(paste0("Not all grouping variables are characters or factors. ",
                   "Are you sure you want to use this function?"))
  }
  
  df_summary <- parade %>% 
    group_by(.sample, !!! rlang::syms(grouping_vars)) %>% 
    summarise(.fitted = unique(.fitted),
              .mean_resid = mean(.resid, na.rm = TRUE),
              .mean_abs_resid = mean(.abs_resid, na.rm = TRUE),
              .mean_sqrt_abs_resid = mean(.sqrt_abs_resid, na.rm = TRUE),
              .n = n()) %>% 
    ungroup()

  # Throw a warning if any of the cells hardly contain any data.
  if (min(df_summary$.n) < 5) {
    warning(paste0("Some cells contain only ",
                   min(df_summary$.n), " observation(s)."))
  }
  
  # Add the position of the true data
  attr(df_summary, "position") <- attr(parade, "position")
  
  # Add the names of the variables by category
  attr(df_summary, "outcome_var") <- attr(parade, "outcome_var")
  attr(df_summary, "other_vars") <- attr(parade, "other_vars")
  attr(df_summary, "predictor_vars") <- attr(parade, "predictor_vars")
  
  return(df_summary)
}