% MODEL1DISCRETE_WRITE
%
%    Writes the following files to disk:
%      - clusters
%      - t
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function model1discrete_write (d, model)
  
  % Write out the cluster centers.
  write_matrix(d, 'clusters', model.clusterCenters);
  
  % Write out the translation matrix.
  write_matrix(d, 't', model.t);
