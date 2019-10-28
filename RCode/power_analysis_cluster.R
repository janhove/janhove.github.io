################################################################################
# Power and Type-I error simulation for different approaches                   #
#   to analysing cluster-randomised experiments                                #
#                                                                              #
# Jan Vanhove (jan.vanhove@unifr.ch)                                           #
# Last change: October 28, 2019                                                #
################################################################################

# Simulation function
compute_clustered_power <- function(n_sim = 10000, n_per_class, ICC, effect, reliability_post, reliability_pre) {
  
  require("lme4")
  require("tidyverse")
  require("lmerTest")
  require("cannonball")
  
  # Allocate matrix for p-values
  pvals <- matrix(nrow = n_sim, ncol = 5)
  
  # Allocate matrix for estimates
  estimates <- matrix(nrow = n_sim, ncol = 5)
  
  # Allocate matrix for standard errors
  stderrs <- matrix(nrow = n_sim, ncol = 5)
  
  # Allocate matrix for lower bound of confidence interval
  cilo <- matrix(nrow = n_sim, ncol = 5)
  
  # Allocate matrix for upper bound of confidence interval
  cihi <- matrix(nrow = n_sim, ncol = 5)
  
  # Start looping
  for (i in 1:n_sim) {
    # Generate data; rerandomise the class sizes to the conditions
    d <- clustered_data(n_per_class = sample(n_per_class), 
                        ICC = ICC, 
                        rho_prepost = NULL, 
                        effect = effect,
                        reliability_post = reliability_post, 
                        reliability_pre = reliability_pre)
    
    # Compute residuals
    d$Residual <- resid(lm(outcome ~ pretest, data = d))
    
    # Summarise per cluster
    d_per_class <- d %>% 
      group_by(class, condition) %>% 
      summarise(mean_outcome = mean(outcome),
                mean_residual = mean(Residual),
                mean_pretest = mean(pretest))
    
    # First analysis: ignore covariate in cluster-mean analysis
    cluster_ignore <- lm(mean_outcome ~ condition, data = d_per_class)
    
    pvals[i, 1] <- summary(cluster_ignore)$coefficients[2, 4]
    estimates[i, 1] <- coef(cluster_ignore)[[2]]
    stderrs[i, 1] <- summary(cluster_ignore)$coefficients[2, 2]
    cilo[i, 1] <- confint(cluster_ignore)[2, 1]
    cihi[i, 1] <- confint(cluster_ignore)[2, 2]
    
    # Second analysis: ignore covariate in multilevel model (Satterthwaite)
    multi_ignore <- lmer(outcome ~ condition + (1|class), data = d)
    
    pvals[i, 2] <- summary(multi_ignore)$coefficients[2, 5]
    estimates[i, 2] <- fixef(multi_ignore)[[2]]
    stderrs[i, 2] <- summary(multi_ignore)$coefficients[2, 2]
    cilo[i, 2] <- estimates[i, 2] + qt(0.025, df = summary(multi_ignore)$coefficients[2, 3]) * stderrs[i, 2]
    cihi[i, 2] <- estimates[i, 2] + qt(0.975, df = summary(multi_ignore)$coefficients[2, 3]) * stderrs[i, 2]
    
    # Third analysis: analyse mean residual
    cluster_residual <- lm(mean_residual ~ condition, data = d_per_class)
    
    pvals[i, 3] <- summary(cluster_residual)$coefficients[2, 4]
    estimates[i, 3] <- coef(cluster_residual)[[2]]
    stderrs[i, 3] <- summary(cluster_residual)$coefficients[2, 2]
    cilo[i, 3] <- confint(cluster_residual)[2, 1]
    cihi[i, 3] <- confint(cluster_residual)[2, 2]
    
    # Fourth analysis: mean outcome with mean covariate
    cluster_mean <- lm(mean_outcome ~ condition + mean_pretest, data = d_per_class)
    
    pvals[i, 4] <- summary(cluster_mean)$coefficients[2, 4]
    estimates[i, 4] <- coef(cluster_mean)[[2]]
    stderrs[i, 4] <- summary(cluster_mean)$coefficients[2, 2]
    cilo[i, 4] <- confint(cluster_mean)[2, 1]
    cihi[i, 4] <- confint(cluster_mean)[2, 2]
    
    # Fifth analysis: include covariate in multilevel model (Satterthwaite)
    multi_covariate <- lmer(outcome ~ condition + pretest + (1|class), data = d)
    
    pvals[i, 5] <- summary(multi_covariate)$coefficients[2, 5]
    estimates[i, 5] <- fixef(multi_covariate)[[2]]
    stderrs[i, 5] <- summary(multi_covariate)$coefficients[2, 2]
    cilo[i, 5] <- estimates[i, 2] + qt(0.025, df = summary(multi_covariate)$coefficients[2, 3]) * stderrs[i, 2]
    cihi[i, 5] <- estimates[i, 2] + qt(0.975, df = summary(multi_covariate)$coefficients[2, 3]) * stderrs[i, 2]
  }
  
  # Output
  pvals <- as.data.frame(pvals)
  estimates <- as.data.frame(estimates)
  stderrs <- as.data.frame(stderrs)
  cilo <- as.data.frame(cilo)
  cihi <- as.data.frame(cihi)
  
  colnames(pvals) <- paste0("pvals_", c("cluster_ignore", "multi_ignore", "cluster_residual", "cluster_mean", "multi_covariate"))
  colnames(estimates) <- paste0("estimates_", c("cluster_ignore", "multi_ignore", "cluster_residual", "cluster_mean", "multi_covariate"))
  colnames(stderrs) <- paste0("stderrs_", c("cluster_ignore", "multi_ignore", "cluster_residual", "cluster_mean", "multi_covariate"))
  colnames(cilo) <- paste0("cilo_", c("cluster_ignore", "multi_ignore", "cluster_residual", "cluster_mean", "multi_covariate"))
  colnames(cihi) <- paste0("cihi_", c("cluster_ignore", "multi_ignore", "cluster_residual", "cluster_mean", "multi_covariate"))
  
  output_simulation <- cbind(pvals, estimates, stderrs, cilo, cihi)
  output_simulation
}

#-------------------------------------------------------------------------------
# Now run the simulations corresponding to scenarios 1 through 4.

# HIGHER ICC

# Roughly equal sample sizes, strong covariate, no effect
set.seed(0815)
n_per_class_balanced <- sample(15:25, size = 14, replace = TRUE) # little variability in cluster sizes
ICC <- 0.17
effect <- 0
reliability_post <- 1
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim1 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                 reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, weak covariate, no effect
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim2 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, strong covariate, some effect
effect <- 0.4
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim3 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, weak covariate, some effect 
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim4 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, strong covariate, no effect
n_per_class_different <- 2^seq(1:10)
effect <- 0
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim5 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, weak covariate, no effect
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim6 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, strong covariate, some effect
effect <- 0.4
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim7 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, weak covariate, some effect 
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim8 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# LOWER ICC

# Roughly equal sample sizes, strong covariate, no effect
ICC <- 0.03
effect <- 0
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim9 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                 reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, weak covariate, no effect
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim10 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, strong covariate, some effect
effect <- 0.4
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim11 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Roughly equal sample sizes, weak covariate, some effect 
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim12 <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, strong covariate, no effect
effect <- 0
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim13 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, weak covariate, no effect
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim14 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, strong covariate, some effect
effect <- 0.4
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim15 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                reliability_post = reliability_post, reliability_pre = reliability_pre)

# Wildly different sample sizes, weak covariate, some effect 
expected_correlation <- 0.3
reliability_pre <- expected_correlation^2 / reliability_post
sim16 <- compute_clustered_power(n_per_class = n_per_class_different, ICC = ICC, effect = effect,
                                 reliability_post = reliability_post, reliability_pre = reliability_pre)

# save(sim1, sim2, sim3, sim4, sim5, sim6, sim7, sim8,
#      sim9, sim10, sim11, sim12, sim13, sim14, sim15, sim16,
#      file = "power_simulations.RData")

sim1 <- as_tibble(sim1) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0,
         ICC = 0.17,
         rho = 0.7)
sim2 <- as_tibble(sim2) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0,
         ICC = 0.17,
         rho = 0.3)
sim3 <- as_tibble(sim3)  %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0.4,
         ICC = 0.17,
         rho = 0.7)
sim4 <- as_tibble(sim4) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0.4,
         ICC = 0.17,
         rho = 0.3)

sim5 <- as_tibble(sim5) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0,
         ICC = 0.17,
         rho = 0.7)
sim6 <- as_tibble(sim6) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0,
         ICC = 0.17,
         rho = 0.3)
sim7 <- as_tibble(sim7) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0.4,
         ICC = 0.17,
         rho = 0.7)
sim8 <- as_tibble(sim8) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0.4,
         ICC = 0.17,
         rho = 0.3)

sim9 <- as_tibble(sim9) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0,
         ICC = 0.03,
         rho = 0.7)
sim10 <- as_tibble(sim10) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0,
         ICC = 0.03,
         rho = 0.3)
sim11 <- as_tibble(sim11)  %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0.4,
         ICC = 0.03,
         rho = 0.7)
sim12 <- as_tibble(sim12) %>% 
  mutate(cluster_size = "similar cluster sizes",
         effect = 0.4,
         ICC = 0.03,
         rho = 0.3)

sim13 <- as_tibble(sim13) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0,
         ICC = 0.03,
         rho = 0.7)
sim14 <- as_tibble(sim14) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0,
         ICC = 0.03,
         rho = 0.3)
sim15 <- as_tibble(sim15) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0.4,
         ICC = 0.03,
         rho = 0.7)
sim16 <- as_tibble(sim16) %>% 
  mutate(cluster_size = "different cluster sizes",
         effect = 0.4,
         ICC = 0.03,
         rho = 0.3)


simulations <- bind_rows(sim1, sim2, sim3, sim4, sim5, sim6, sim7, sim8,
                         sim9, sim10, sim11, sim12, sim13, sim14, sim15, sim16)

write_csv(simulations, "cluster_power_simulations.csv")

#-------------------------------------------------------------------------------
# Additional simulations: Fewer clusters.

set.seed(0815)
n_small <- sample(15:25, size = 6, replace = TRUE) # little variability in cluster sizes
ICC <- 0.17
effect <- 0
reliability_post <- 1
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim_small <- compute_clustered_power(n_per_class = n_per_class_balanced, ICC = ICC, effect = effect,
                                     reliability_post = reliability_post, reliability_pre = reliability_pre)
sim_small <- as_tibble(sim_small) %>% 
  mutate(cluster_size = "similar cluster sizes, but only six clusters",
         effect = 0,
         ICC = 0.17,
         rho = 0.7)

n_small <- sample(15:25, size = 6, replace = TRUE) # little variability in cluster sizes
ICC <- 0.17
effect <- 0.4
reliability_post <- 1
expected_correlation <- 0.7
reliability_pre <- expected_correlation^2 / reliability_post
sim_small_eff <- compute_clustered_power(n_per_class = n_small, ICC = ICC, effect = effect,
                                         reliability_post = reliability_post, reliability_pre = reliability_pre)
sim_small_eff <- as_tibble(sim_small_eff) %>% 
  mutate(cluster_size = "similar cluster sizes, but only six clusters",
         effect = 0.4,
         ICC = 0.17,
         rho = 0.7)

sim_small <- sim_small %>% 
  bind_rows(sim_small_eff)

write_csv(sim_small, "cluster_power_simulations_few_clusters.csv")