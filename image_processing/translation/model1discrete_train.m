% MODEL1DISCRETE_TRAIN    Train model 1 discrete ML.
%   The function call is [MODEL,VAL] = MODEL1DISCRETE_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,EMTOLERANCE). The model-specific parameters
%   are: 
%     - KMITER       The maximum number of iterations to run K-Means.
%     - EMITER       The maximum number of iterations ro run EM.
%     - EMTOLERANCE  Stop the EM algorithm when the difference in error
%                    between two steps is less than EMTOLERANCE.
%
%   In MODEL we will return the following information: 
%     - clusterCenters  F x W matrix where F is the number of features
%                       and W is the number of clusters (i.e. the number
%                       of words), indicating the centres of the
%                       normalized clusters.
%     - t               W x W matrix where W is the number of
%                       words. Entry t(b,w) is the probability of
%                       generating blob b from word w.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function [model, val] = model1discrete_train ...
      (B, W, A, M, L, numwords, KMiter, EMiter, EMtol)

  imageBlobs  = B;
  N           = length(M);
  maxM        = max(M);
  maxL        = max(L);
  numclusters = numwords;
  ts          = zeros(N,1);
  W_          = W + 1;
  
  % Run k-means
  % -----------
  % Run k-means on blobs to find clusters centers and blob-cluster
  % membership. 
  proglog('a.) Running k-means.');
  sB = smash_blobs(imageBlobs, M);
  [clusterCenters blobsInClusters] = ...
      do_kmeans(sB', 0, KMiter, 1, numclusters);
  clusterCenters  = clusterCenters';
  blobsInClusters = blobsInClusters';
  
  % Create the new blob matrix
  B = reshape(unsmash_blobs(blobsInClusters, M),[maxM N])';
  clear sB blobsInClusters
  
  % Initialize the translation probabilities.
  % t is an n x m matrix, where n = number of blob clusters
  %                             m = number of words
  % The (i,j) entry represents the translation probability t(bi | wj).
  % Initially, the translation probabilities are uniform.
  t  = ones(numclusters, numwords) ./ numclusters;
  
  % Run EM
  % ------
  proglog('b.) Running EM.');
  likelihoods = [];
  for iter = 1:EMiter,
    
    % E step
    % ------
    % We're going to skip this because we don't need it!
    
    % M step
    % ------
    % Calculate the new estimates for the parameters t(bi | wj).
    t_ = [zeros(numclusters,1) t];
    for b = 1:numclusters,
      
      % Calculate the t's for each sentence marginalized over the words.
      % Repeat for each document. Note that we assume the W entries
      % that are beyond the word counts are 0.
      ts = sum(reshape(t_(b, W_),[N maxL]),2);
	
      % Compute the probability t(b|w).
      f = find(ts);
      if length(f),
	for w = 1:numwords,
	  tc(b,w) = t(b,w) * ...
		    sum(sum(B(f,:) == b,2).*sum(W(f,:) == w,2) ./ ts(f));
	end;
      else,
	tc(b,:) = 0;
      end;
    end;
    
    % Now that we've found the translation counts, normalize them.
    % "z" is the normalization factor, summed over all the blobs.
    % If the normalization factor is 0, then there are no instances
    % of the word "w" in the training set and we will retain a 
    % uniform distribution.
    z = sum(tc,1);
    f = find(z);
    t(:,f) = tc(:,f) ./ repmat(z(f),[numclusters 1]);
    
    % Compute the log likelihood.
    % --------------------------
    l = 0;
    for s = 1:N,
      l = l + sum(log(sum(t(B(s,1:M(s)),W(s,1:L(s))),2) / L(s)));
    end;
    proglog('   EM iteration %i - log likelihood = %f', iter, l);
    likelihoods = [likelihoods l];
    
    % Compute the error.
    if iter > 1,
      err = l - likelihoods(iter-1);
      if err < EMtol,
	break;
      end;
    end;
  end; % Repeat EM.
  
  % Return the model and value of the model.
  val                  = likelihoods(length(likelihoods));
  model.t              = t;
  model.clusterCenters = clusterCenters;