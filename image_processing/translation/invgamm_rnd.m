function gb = invgamm_rnd (nrow, ncol, alpha, beta)
  
  gb = ones(nrow, ncol) ./ gamm_rnd(nrow, ncol, alpha, beta);