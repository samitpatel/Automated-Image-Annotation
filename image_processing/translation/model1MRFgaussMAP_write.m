% MODEL1GAUSSMAP_WRITE
%
%    Writes the following files to disk:
%      - sigma
%      - mu
%      - tau
%      - psi{1,...,n}
%      - misc
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function model1MRFgaussMAP_write (d, model)
  
  % Write out "sp", "BPtol" and "BPiter".
  write_matrix(d, 'misc', [model.sp model.BPtol model.BPiter]);

  % Write out the potentials psi.
  for r = 1:length(model.psi),
    write_matrix(d, sprintf('psi%i', r), model.psi{r});
  end;
  
  % Write out the Gaussian cluster means.
  write_matrix(d, 'mu', model.mu);
    
  % Write out the Gaussian cluster covariances.
  write_matrix(d, 'sigma', model.sig);
  
  % Write out tau.
  write_matrix(d, 'tau', model.tau);
  