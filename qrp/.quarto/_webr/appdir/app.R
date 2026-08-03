library(shiny)
library(shinythemes)
library(ggplot2)
library(dplyr)
library(MASS)
library(gridExtra)

theme_jv <- function(font_size = 9) {
  theme_bw(base_size = font_size) %+replace%
    theme(
      panel.grid = element_blank(),
      axis.ticks = element_line(colour = "black"),
      axis.text = element_text(colour = "black")
    )
}
theme_set(theme_jv(14))

situation_AB.fnc <- function(
    min_n = 20, max_n = 30, add = 10, r = 0.50, 
    check_interaction = FALSE
) {
  group <- rep(c(-0.5, 0.5), times = max_n)
  sex <- rep(c(-0.5, 0.5), each = max_n)
  sex <- sample(sex)
  
  outcomes <- mvrnorm(
    n = 2 * max_n,
    mu = c(0, 0),
    Sigma = matrix(c(1, r, r, 1), nrow = 2)
  )
  
  average <- rowMeans(outcomes)
  
  df <- data.frame(
    group = group,
    sex = sex,
    outcome1 = outcomes[, 1],
    outcome2 = outcomes[, 2],
    average = average
  )
  
  n <- min_n
  p_value <- Inf
  
  repeat {
    if (p_value <= 0.05) break
    if (n > max_n) break
    
    no_interaction <- summary(
      lm(cbind(outcome1, outcome2, average) ~ group,
         data = df[1:(2 * n), ])
      )
    
    p_1 <- no_interaction[[1]]$coefficients[2, 4]
    p_2 <- no_interaction[[2]]$coefficients[2, 4]
    p_3 <- no_interaction[[3]]$coefficients[2, 4]
    
    p_value <- min(c(p_1, p_2, p_3))
    
    if (check_interaction) {
      interaction <- summary(
      lm(cbind(outcome1, outcome2, average) ~ sex*group,
         data = df[1:(2 * n), ])
      )
      p_4 <- tryCatch(
        {
          interaction[[1]]$coefficients[4, 4]
        },
        error = function(msg) { 1 }
      )
      p_5 <- tryCatch(
        {
          interaction[[2]]$coefficients[4, 4]
        },
        error = function(msg) 1
      )
      p_6 <- tryCatch(
        {
          interaction[[3]]$coefficients[4, 4]
        },
        error = function(msg) 1
      )
      p_value <- min(c(p_value, p_4, p_5, p_6))
    }
    
    n <- n + add
    
    if (add <= 0) break
    if (max_n <= min_n) break
  }
  
  p_value
}

ui <- fluidPage(
  theme = shinytheme("united"),
  titlePanel("False-positive psychology"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "min_n",
        "Minimum number of participants in each group:",
        min = 5, max = 100, value = 20, step = 1
      ),
      sliderInput(
        "max_add",
        "Maximum number of additional participants in each group:",
        min = 0, max = 50, value = 10, step = 1
      ),
      sliderInput(
        "n_add",
        "After how many new participants per group should the data be analysed again?",
        min = 0, max = 50, value = 10, step = 1
      ),
      sliderInput(
        "r",
        "Correlation between the dependent variables:",
        min = -1, max = 1, step = 0.05, value = 0.5
      ),
      checkboxInput(
        "check_interaction",
        "Check for interaction of condition with sex?",
        value = FALSE
      ),
      numericInput(
        "n_sims",
        "Number of simulations:",
        min = 100, value = 1000, step = 100
      ),
      actionButton("go", "Simulate!")
    ),
    
    mainPanel(
      plotOutput("pValueDistribution", width = "450px", height = "350px")
    )
  )
)

server <- function(input, output) {
  generate_p_values <- eventReactive(input$go, {
    n_sims <- input$n_sims
    p_values <- numeric(n_sims)
    
    withProgress(message = "Simulating experiments", value = 0, {
      for (i in seq_len(n_sims)) {
        p_values[i] <- situation_AB.fnc(
          min_n = input$min_n,
          max_n = input$min_n + input$max_add,
          add = input$n_add,
          r = input$r,
          check_interaction = input$check_interaction
        )
        incProgress(1 / n_sims)
      }
    })
    
    p_values
  })
  
  output$pValueDistribution <- renderPlot({
    p_values <- generate_p_values()
    df <- data.frame(p_values)
    false_positive_rate <- mean(p_values < 0.05)
    margin_of_error <-
      1.96 * sqrt(false_positive_rate * (1 - false_positive_rate) / length(p_values))
    
    p1 <- ggplot(df, aes(x = p_values, fill = factor(p_values < 0.05))) +
      geom_histogram(colour = "black", breaks = seq(0, 1, by = 0.05)) +
      scale_fill_manual(values = c("#2b83ba", "#d7191c")) +
      geom_hline(yintercept = nrow(df) * 0.05, linetype = "dashed") +
      xlab("p-value") +
      ylab("Number of simulations") +
      labs(
        title = paste("p-values obtained in", nrow(df), "experiments"),
        subtitle = paste(
          "Type I error:", round(false_positive_rate, 2),
          "\u00B1", round(margin_of_error, 2)
        )
      ) +
      theme(legend.position = "none")
    
    print(p1)
  })
}

shinyApp(ui = ui, server = server)
