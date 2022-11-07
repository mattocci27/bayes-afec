data {
  int<lower=1> I; // number of species
  array[I] int<lower=0> suv; // number of survivors
  array[I] int<lower=0> N; // number of individuals
  array[I] int<lower=1, upper=I> ii; // integer
}

parameters {
  real mu;
  real<lower=0> sigma;
  vector[I] z_tilde;
}

transformed parameters {
  vector[I] z;
  z = mu + sigma * z_tilde;
}

model {
  mu ~ normal(0, 5);
  z_tilde ~ std_normal();
  sigma ~ std_normal();
  for (i in 1:I)
    suv[i] ~ binomial_logit(N[i], z[ii[i]]);
}

generated quantities {
  vector[I] log_lik;
  vector[I] p = inv_logit(z);
  for (i in 1:I)
    log_lik[i] = binomial_logit_lpmf(suv[i] | N[i], z[ii[i]]);
}
