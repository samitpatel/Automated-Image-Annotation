% MODEL1GAUSSMAP_WRITE
%
%    Writes the following files to disk:
%      - sigma
%      - mu
%      - tau
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function model1gaussMAP_write (d, model)
  
  write_matrix(d, 'sigma', model.sig);
  write_matrix(d, 'mu', model.mu);
  write_matrix(d, 'tau', model.tau);
