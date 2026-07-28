library(shiny)
library(bslib)
library(corrplot)

# Stationary kernel functions --------------------------------------------------
rbf <- function(D, length_scale = 1, scaling_factor = 1) {
  scaling_factor * exp(-D^2 / (2 * length_scale^2))
}
powerexp <- function(D, length_scale = 1, scaling_factor = 1) {
  scaling_factor * exp(-(D^2 / (2 * length_scale^2))^0.5)
}
matern12 <- function(D, length_scale = 1, scaling_factor = 1) {
  scaling_factor * exp(-D / (2 * length_scale))
}
matern32 <- function(D, length_scale = 1, scaling_factor = 1) {
  r <- sqrt(3) * D / (2 * length_scale)
  scaling_factor * (1 + r) * exp(-r)
}
matern52 <- function(D, length_scale = 1, scaling_factor = 1) {
  r <- sqrt(5) * D / (2 * length_scale)
  scaling_factor * (1 + r + r^2 / 3) * exp(-r)
}

kernel_list <- list(
  "Squared exponential" = rbf,
  "Power exponential (κ = 0.5)" = powerexp,
  "Matérn 1/2"          = matern12,
  "Matérn 3/2"          = matern32,
  "Matérn 5/2"          = matern52
)

# GP conditional distribution --------------------------------------------------
cond_dist <- function(x, x0, y0, noise_var = 1e-6, kernel, ...) {
  mean_y <- mean(y0)
  y0 <- y0 - mean_y
  n  <- length(x)
  n0 <- length(x0)
  D  <- outer(c(x, x0), c(x, x0), "-") |> abs()
  K  <- kernel(D, ...)
  K11 <- K[seq_len(n), seq_len(n)]
  K12 <- K[seq_len(n), (n + 1):(n + n0)]
  K22 <- K[(n + 1):(n + n0), (n + 1):(n + n0)] + noise_var * diag(n0)
  L   <- tryCatch(chol(K22), error = function(e) NULL)
  if (is.null(L)) return(NULL)
  alpha <- backsolve(L, forwardsolve(t(L), y0))
  mu    <- as.vector(K12 %*% alpha)
  v     <- forwardsolve(t(L), t(K12))
  Sigma <- K11 - t(v) %*% v
  list(y = mu + mean_y, se = pmax(sqrt(diag(Sigma)), 0))
}

# Hyperparameter optimisation --------------------------------------------------
# Just BFGS without gradients for now.
find_gpr_hyperparameters <- function(x0, y0, kernel, runs = 10) {
  n <- length(y0)
  # Centre y at 0
  y_train <- y0 - mean(y0)
  D <- outer(x0, x0, "-") |> abs()
  # Obtain median distance between elements as useful length-scale init
  med_d <- median(D[upper.tri(D)])

  nll <- function(log_params) {
    va      <- exp(log_params[1])
    ls      <- exp(log_params[2])
    lambda2 <- exp(log_params[3])
    K <- kernel(D, length_scale = ls, scaling_factor = va) + lambda2 * diag(n)
    U <- tryCatch(chol(K), error = function(e) NULL)
    if (is.null(U)) return(Inf)
    a <- backsolve(U, backsolve(U, y_train, transpose = TRUE))
    drop(0.5 * crossprod(y_train, a) + sum(log(diag(U))) + n / 2 * log(2 * pi))
  }

  best <- NULL
  for (i in seq_len(runs)) {
    init <- c(
      scaling_factor     = runif(1, log(0.1), log(10)),
      length_scale = runif(1, log(med_d * 0.1), log(med_d * 10)),
      lambda2      = runif(1, -10, -2)
    )
    fit <- tryCatch(
      optim(init, nll, method = "BFGS"),
      error = function(e) NULL
    )
    if (!is.null(fit) && (is.null(best) || fit$value < best$value)) {
      best <- fit
    }
  }

  if (is.null(best)) return(NULL)
  list(
    scaling_factor     = exp(best$par[1]),
    length_scale = exp(best$par[2]),
    lambda2      = exp(best$par[3]),
    nll          = best$value
  )
}

# Preset functions -------------------------------------------------------------
preset_fns <- list(
  "smooth function"  = "x*sin(x)^2",
  "jagged function"  = "-0.05*x^2 + sin(x) + abs(x %% 1 - 1/2)",
  "Custom…"             = NULL
)

# UI ---------------------------------------------------------------------------
ui <- page_sidebar(
  title = "Gaussian process regression with a stationary kernel",
  theme = bs_theme(bootswatch = "yeti"),

  sidebar = sidebar(
    width = 310,

    accordion(
      open = FALSE,
      accordion_panel(
        "Data-generating mechanism",
        selectInput("preset_fn", "True function:",
                    choices = names(preset_fns), 
                    selected = names(preset_fns)[1]),
        conditionalPanel(
          "input.preset_fn === 'Custom…'",
          textInput("custom_fn", "f(x) =", value = "sin(x)",
                    placeholder = "e.g., sin(x) + 0.5*x")
        ),
        sliderInput("x_range", "x range:",
                    min = -10, max = 10, value = c(-10, 10), step = 0.5),
        numericInput("noise", "Observation noise σ²:",
                     value = 0.5, min = 0, step = 0.1)
      )
    ),

    accordion(
      open = FALSE,
      accordion_panel(
        "Observations",
        radioButtons("x0_mode", "Specify points:",
                     choices = c("Random" = "random", "Manual" = "manual"),
                     inline = TRUE,
                     selected = "manual"),
        conditionalPanel(
          "input.x0_mode === 'random'",
          sliderInput("n_pts", "Number of points:", 1, 50, 25, 
                      step = 1, ticks = FALSE),
          actionButton("resample", "Resample", class = "btn-primary w-100",
                       icon  = icon("dice"))
        ),
        conditionalPanel(
          "input.x0_mode === 'manual'",
          textInput("manual_x0", "x positions (comma-separated):", 
            value = "-9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9")
        )
      )
    ),

    accordion(
      open = FALSE,
      accordion_panel(
        "Kernel",
        selectInput("kernel", "Kernel function", choices = names(kernel_list)),
        uiOutput("hp_inputs"),
        hr(),
        tags$p("Optimise hyperparameters by maximising the 
               log marginal likelihood."),
        sliderInput("opt_runs", "Restarts:",
                    min = 5, max = 50, value = 30, step = 1, ticks = FALSE),
        actionButton("optimise", "Optimise hyperparameters",
                     class = "btn-primary w-100",
                     icon  = icon("wand-magic-sparkles")),
        uiOutput("opt_status")
      )
    )
  ),

  layout_columns(
    col_widths = 12,
    card(
      card_header("GP posterior"),
      plotOutput("gp_plot", height = "420px")
    ),
    card(
      card_header("Kernel covariance  k(x, x₀)"),
      plotOutput("kernel_plot", height = "200px")
    ),
    card(
      card_header("Correlation matrix"),
      plotOutput("corr_plot")
    )
  ),
)

# Server -----------------------------------------------------------------------
server <- function(input, output, session) {

  opt_msg     <- reactiveVal(NULL)
  opt_trigger <- reactiveVal(0)
  opt_params  <- reactiveVal(list(length_scale = 1, scaling_factor = 5, 
                                  log_noise_var = -0.3))

  # Show hyperparameter inputs
  output$hp_inputs <- renderUI({
    p <- opt_params()
    tagList(
      numericInput("length_scale", "Length scale ℓ",
                   value = round(p$length_scale, 4), min = 0.01, step = 0.1),
      numericInput("scaling_factor", "Scaling factor s²",
                   value = round(p$scaling_factor, 4), min = 0.01, step = 0.1),
      numericInput("log_noise_var", "Noise variance η² (log-10 scale)",
                   value = round(p$log_noise_var, 2), step = 0.5)
    )
  })

  # Parse target function
  f <- reactive({
    expr_str <- if (input$preset_fn == "Custom…") input$custom_fn
                else preset_fns[[input$preset_fn]]
    tryCatch(
      eval(parse(text = paste0("function(x) ", expr_str))),
      error = function(e) NULL
    )
  })

  # Observation x locations
  x0_vals <- reactive({
    input$resample
    if (input$x0_mode == "random") {
      set.seed(input$resample)
      sort(runif(input$n_pts, input$x_range[1], input$x_range[2]))
    } else {
      vals <- suppressWarnings(
        as.numeric(trimws(strsplit(input$manual_x0, ",")[[1]])))
      sort(vals[!is.na(vals)])
    }
  })

  # Observations
  obs <- reactive({
    fn <- f()
    if (is.null(fn)) return(NULL)
    x0 <- x0_vals()
    y0 <- fn(x0) + rnorm(length(x0), sd = sqrt(input$noise))
    list(x0 = x0, y0 = y0)
  })

  # Prediction grid
  x_grid <- reactive({
    seq(input$x_range[1], input$x_range[2], length.out = 201)
  })

  # Step 1: show spinner and fire trigger
  observeEvent(input$optimise, {
    xy0 <- obs()
    if (is.null(xy0) || length(xy0$x0) < 3) {
      opt_msg(tags$span("⚠ Need at least 3 observations to optimise."))
      return()
    }
    opt_trigger(isolate(opt_trigger()) + 1)
  })

  # Step 2: run optimisation in a new flush
  observeEvent(opt_trigger(), {
    req(opt_trigger() > 0)
    xy0  <- isolate(obs())
    kern <- kernel_list[[isolate(input$kernel)]]

    result <- tryCatch(
      find_gpr_hyperparameters(xy0$x0, xy0$y0, kernel = kern,
                               runs = isolate(input$opt_runs)),
      error = function(e) NULL
    )

    if (is.null(result)) {
      opt_msg(tags$span("✗ Optimisation failed. Try different settings."))
      return()
    }

    opt_params(list(
      length_scale = result$length_scale,
      scaling_factor     = result$scaling_factor,
      log_noise_var   = max(log10(result$lambda2), -30)
    ))

    opt_msg(tags$span(
      style = "color:#27ae60; font-size:0.82rem;",
      sprintf("✓ Done.  ℓ = %.2f,  s² = %.2f,  η² = 10^%.1f  (NLL = %.1f)",
              result$length_scale, result$scaling_factor,
              log10(result$lambda2), result$nll)
    ))
  }, ignoreInit = TRUE)

  output$opt_status <- renderUI({ opt_msg() })

  # Active hyperparameters: opt_params when set, else input values
  hp <- reactive({
    p  <- opt_params()
    ls <- if (!is.null(input$length_scale)) input$length_scale 
                                       else p$length_scale
    sf <- if (!is.null(input$scaling_factor)) input$scaling_factor 
                                         else p$scaling_factor
    nv <- if (!is.null(input$log_noise_var)) input$log_noise_var  
                                        else p$log_noise_var
    list(length_scale = ls, scaling_factor = sf, log_noise_var = nv)
  })

  # GP fit
  gp_fit <- reactive({
    fn  <- f()
    if (is.null(fn)) return(NULL)
    xy0  <- obs()
    kern <- kernel_list[[input$kernel]]
    p    <- hp()
    req(p$length_scale, p$scaling_factor, p$log_noise_var)
    fit  <- cond_dist(x_grid(), xy0$x0, xy0$y0,
                      noise_var = 10^p$log_noise_var,
                      kernel = kern,
                      length_scale = p$length_scale,
                      scaling_factor = p$scaling_factor)
    list(fit = fit, x0 = xy0$x0, y0 = xy0$y0)
  })

  # GP posterior plot
  output$gp_plot <- renderPlot({
    fn  <- f()
    obj <- gp_fit()
    fit <- obj$fit
    x0  <- obj$x0
    y0  <- obj$y0
    x   <- x_grid()

    par(mar = c(4, 4, 1, 1), bg = "white", family = "sans")
    y_fn <- if (!is.null(fn)) fn(x) else rep(0, length(x))

    ylim_base <- if (!is.null(fit)) {
      range(c(fit$y + 2.5 * fit$se, fit$y - 2.5 * fit$se, y_fn), na.rm = TRUE)
    } else {
      range(y_fn, na.rm = TRUE)
    }
    ylim <- ylim_base + diff(ylim_base) * c(-0.05, 0.05)

    plot(NULL, xlim = input$x_range, ylim = ylim,
         xlab = "x", ylab = "y", bty = "l", las = 1)
    grid(col = "grey90", lty = 1)

    if (!is.null(fit)) {
      ord <- order(x)
      px  <- x[ord]
      pmu <- fit$y[ord]
      pse <- fit$se[ord]
      
      valid <- is.finite(pmu) & is.finite(pse)
      px  <- px[valid]
      pmu <- pmu[valid]
      pse <- pse[valid]
      
      poly_x <- c(px, rev(px))
      poly_y <- c(pmu + 2 * pse, rev(pmu - 2 * pse))
      polygon(poly_x, poly_y, col = adjustcolor("#2c7bb6", 0.15), border = NA)
      lines(px, pmu, col = "#2c7bb6", lwd = 2.5, lty = 1)
    }
    if (!is.null(fn)) {
      lines(x, y_fn, col = "#d7191c", lwd = 1.5, lty = 2)
    }
    points(x0, y0, pch = 21, bg = "white", col = "#333", cex = 1.6, lwd = 2)
    legend("topright", bty = "n", cex = 0.85,
           legend = c("Posterior mean", "±2 SE", "True function", "Observations"),
           lty    = c(1, NA, 2, NA),
           pch    = c(NA, 15, NA, 21),
           lwd    = c(2.5, NA, 1.5, NA),
           col    = c("#2c7bb6", adjustcolor("#2c7bb6", 0.3), "darkred", "#333"),
           pt.cex = c(NA, 2, NA, 1.6))
  })

  # Kernel covariance plot -----------------------------------------------------
  output$kernel_plot <- renderPlot({
    kern  <- kernel_list[[input$kernel]]
    p     <- hp()
    req(p$length_scale, p$scaling_factor)
    d_seq <- seq(0, max(abs(input$x_range)), length.out = 300)
    k_val <- kern(d_seq,
                  length_scale = p$length_scale,
                  scaling_factor     = p$scaling_factor)

    par(mar = c(4, 4, 0.5, 1), bg = "white", family = "sans")
    plot(d_seq, k_val, type = "l", col = "#2c7bb6", lwd = 2,
         xlab = "|x - x₀|", ylab = "k(x, x₀)", bty = "l", las = 1,
         ylim = c(0, p$scaling_factor * 1.05))
    grid(col = "grey90", lty = 1)
    abline(h = p$scaling_factor, lty = 3, col = "grey60")
  })
  
  # Implied correlation matrix -------------------------------------------------
  output$corr_plot <- renderPlot({
    x0 <- obs()$x0 |> sort()
    kern <- kernel_list[[input$kernel]]
    p <- hp()
    req(p$length_scale, p$scaling_factor, p$log_noise_var)
    D <- outer(x0, x0, "-") |> abs()
    M <- kern(D, 
              length_scale = p$length_scale, scaling_factor = p$scaling_factor)
    cor_mat <- cov2cor(M)
    corrplot(cor_mat,
         method = "color",
         col = colorRampPalette(c("red", "white", "blue"))(200),
         tl.col = "black",   
         tl.cex = 0.8,       
         addCoef.col = NULL,
         cl.lim = c(-1, 1))
  }, height = 380, width = 380)
}

shinyApp(ui, server)
