data{
  int<lower=1> N; // number of samples
  int<lower=1> J; // number of sp
  int<lower=1> K; // number of tree-level preditors (i.e, CONS, HETS,...)
  int<lower=1> L; // number of sp-level predictors (i.e., interecept, SLA,...)
  matrix[N, K] x; // tree-level predictor
  matrix[L, J] u; // sp-level predictor
  array[N] int<lower=0, upper=1> suv; // 1 or 0
  array[N] int<lower=1, upper=J> sp; // integer
}

parameters{
  matrix[K, L] gamma;
  matrix[K, J] z;
  cholesky_factor_corr[K] L_Omega;
  vector<lower=0, upper=pi() / 2>[K] tau_unif;
}

transformed parameters{
  matrix[K, J] beta;
  vector<lower=0>[K] tau;
  for (k in 1:K) tau[k] = 2.5 * tan(tau_unif[k]);
  beta = gamma * u + diag_pre_multiply(tau, L_Omega) * z;
}

model {
  vector[N] mu;
  to_vector(z) ~ std_normal();
  L_Omega ~ lkj_corr_cholesky(2);
  to_vector(gamma) ~ normal(0, 2.5);
  for (n in 1:N) {
    mu[n] = x[n, ] * beta[, sp[n]];
  }
  suv ~ bernoulli_logit(mu);
}

// generated quantities {
//   vector[N] log_lik;
//   corr_matrix[K] Omega;
//   Omega = multiply_lower_tri_self_transpose(L_Omega);
//   for (n in 1:N) {
//     log_lik[n] = bernoulli_logit_lpmf(suv[n] | x[n, ] * beta[, sp[n]] +
//       phi[plot[n]] + xi[census[n]] + psi[tag[n]]);
//   }
}
