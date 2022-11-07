library(targets)
library(tarchetypes)
library(tidyverse)
library(stantargets)
library(cmdstanr)
library(furrr)


source("R/functions.R")

# parallel computing on local or on the same node
plan(multicore)
options(clustermq.scheduler = "multicore")

tar_option_set(packages = c(
  "tidyverse",
  "bayesplot",
  "ggrepel",
  "patchwork",
  "janitor",
  "loo"
))

list(
  tar_target(
    dummy_simple,
    generate_dummy_simple(n_sp = 8, sig = 0.2, seed = 500)
  ),
  tar_target(
    dummy_simple_stan,
    generate_dummy_simple_stan(dummy_simple)
  ),

  tar_stan_mcmc(
    simple,
    "stan/logistic.stan",
    data = dummy_simple_stan,
    seed = 123,
    chains = 4,
    parallel_chains = getOption("mc.cores", 4),
    iter_warmup = 1000,
    iter_sampling = 1000,
    refresh = 0
  ),
  tar_target(
    dummy_simple_re,
    add_p(dummy_simple, simple_summary_logistic)
  ),


  tar_quarto(
    main,
    "main.qmd"
  ),

  NULL
)
