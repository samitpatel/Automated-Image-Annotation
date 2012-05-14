% DO_KMEANS    Runs the k-means algorithm on the blob data using
%              multiple restarts.
%    [CENTERS, MEMBERSHIP] = DO_KMEANS(BLOBS, TOLERANCE, MAX_ITERATIONS, 
%    NUM_RESTARTS, NUM_CLUSTERS) clusters the matrix BLOBS into a number
%    of clusters specified by NUM_CLUSTERS. The centers of the clusters
%    are returned in CENTERS and the cluster indicies for each blob are
%    stored in the vector MEMBERSHIP. BLOBS must be a N x M matrix where
%    N is the number of blobs and M is the number of features.
%
%    TOLERANCE specifies the minimum error between two iterations in 
%    k-means before the algorithm halts. K-means will also halt if it 
%    reachs MAX_ITERATIONS. NUM_RESTARTS specifies the number of
%    restarts.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 
%
%    Last modified on August 28, 2002.

function [centers, membership] = ...
    do_kmeans (blobs, tolerance, max_iterations, num_restarts, ...
	       num_clusters)
  
  % Get the parameters.
  [num_blobs num_features] = size(blobs);
  
  % Set the options.
  options = [-1 0 tolerance max_iterations 1];
  
  % Allocate memory for centres.
  centers   = zeros(num_clusters, num_features);
  
  % Do multiple restarts, looking for the best error. Also, we want to
  % keep track of the error logs for each restart.
  best_error = 1e99;
  for r = 1:num_restarts,
    
    fprintf('      Restart #%i - ', r);
    
    % Run the k-means algorithm.
    [centers options membership errlog] = ...
	kmeans(centers, blobs, options);
    
    % Grab the final error.
    e = options(8);
    fprintf(' error = %f \n', e);
    
    if e < best_error,
      best_centers    = centers;
      best_membership = membership;
      best_error      = e;
    end;
  end;
  
  % Display results.
  fprintf('      Out of %i restarts, the best error is %f. \n', ...
	  num_restarts, best_error);
  
  % Return results.
  centers = best_centers;
  membership = zeros(num_blobs, 1);
  for b = 1:num_blobs,
    membership(b) = find(best_membership(b,:) == 1);
  end;

