% MODEL1GAUSSML_WRITE
%
%    Writes the following files to disk:
%      - mu
%      - sigma
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function model1gaussML_write (d, model)
  
  % Write out the Gaussian cluster means.
  write_matrix(d, 'mu', model.mu);
    
  % Write out the Gaussian cluster covariances.
  write_matrix(d, 'sigma', model.sig);
  
  
  