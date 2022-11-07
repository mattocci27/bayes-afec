# generate_dummy_simple <- function(beta1 = -0.2, beta0_hat = 0, seed = 123) {
#   set.seed(seed)
#   n_sp <- 30
#   n_rep <- 200
#   beta0 <- rnorm(n_sp, beta0_hat, 0.5)

#   y_fun <- function(beta0, beta1) beta0 + beta1 * xx
#   xx <- seq(-3, 3, length = n_rep)
#   z <- map(as.list(beta0), y_fun, beta1) |> unlist()

#   tmp <- tibble(z,
#                 x = rep(xx, n_sp),
#                 sp = rep(paste0("sp", 1:n_sp), each = n_rep))
#   tmp
# }

logistic <- function(z) 1 / (1 + exp(-z))

logit <- function(p) log(p / (1 - p))

generate_dummy_simple <- function(n_sp = 8, sig = 0.3, seed = 123) {
  set.seed(seed)
  n_rep <- sample(15:50, n_sp, replace = TRUE)
  p0 <- 0.3

  z <- logit(p0) + rnorm(n_sp, 0, sig)
  p <- logistic(z)

  suv <- rbinom(n_sp, n_rep, p)

  tibble(
    sp = LETTERS[1:n_sp],
    n = n_rep,
    suv = suv,
    p_like = round(suv / n_rep, 2),
    p_true = p |> round(2)
  )
}


generate_dummy_simple_stan <- function(dummy_simple) {
  list(
    I = nrow(dummy_simple),
    ii = 1:nrow(dummy_simple),
    suv = dummy_simple$suv,
    N = dummy_simple$n
  )
}

add_p <- function(dummy_simple, summary) {
  p <- summary |>
    filter(str_detect(variable, "p")) |>
    filter(variable != "lp__") |>
    pull(median)
  dummy_simple |>
    mutate(p_bayes = p)
}
