% MODEL1DISCRETEONLINE_TRAIN    Train model 1 discrete ML using online EM. 
%   The function call is [MODEL,VAL] = MODEL1DISCRETEONLINE_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,LSA,LSB). The model-specific
%   parameters are:
%     - KMITER       The maximum number of iterations to run K-Means.
%     - EMITER       The maximum number of iterations ro run EM.
%     - LSA          The parameter "a" in the learning schedule.
%     - LSB          To calculate the parameter "b" for the learning
%                    schedule, b = LSB * N, where N is the number of
%                    documents in the training set.
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

function [model, val] = model1discreteOnline_train ...
      (B, W, A, M, L, numwords, KMiter, EMiter, LSa, LSb)

  imageBlobs  = B;
  N           = length(M);
  maxM        = max(M);
  maxL        = max(L);
  numclusters = numwords;
  ts          = zeros(N,1);

  % Set up the learning schedule.
  LSb = round(LSb * N);
  
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
  proglog('b.) Initializing model parameters.');
  t = ones(numclusters, numwords) ./ numclusters;
  
  % We're going to keep track of two sufficient statistics,
  % and we'll call them SS1 and SS2. SS1 are the unnormalized
  % translation probabilities. SS2 are the translation probabilities
  % marginalized over the blobs. Here we create storage for the
  % sufficient statistics and then initialize them. We need to
  % initialize them in case b is greater than 0.
  proglog('c.) Initializing sufficient statistics.');
  SS1 = t;
  SS2 = ones(1, numwords);

  % Run EM
  % ------
  % At each iteration, we add a new document to be analysed.
  proglog('d.) Running EM.');
  for time = 1:ceil(N*EMiter),
    
    % Get the document number we just added.
    s  = 1+mod(time-1,N);
    ls = L(s);
    ms = M(s);
    
    % E step
    % ------
    % We're going to skip this because we don't need it!
    
    % M step
    % ------
    % Update the learning schedule.
    eta = 1 / (LSa*time + LSb);
    
    % Calculate the new estimate for the sufficient statistics.
    tc = zeros(numclusters, numwords);
    for b = 1:numclusters,
      
      % Calculate the t's for each sentence marginalized over the
      % words.
      ts = sum(t(b,W(s,1:ls)));
      
      % Compute the probability t(b|w).
      if ts,
	for w = 1:numwords,
	  tc(b,w) = t(b,w) * ...
		    sum(B(s,1:ms) == b).* sum(W(s,1:ls) == w) / ts;
	end;
      else,
	tc(b,:) = 0;
      end;
    end;
    
    % Now that we have the "tc's", or the translation counts, it's a
    % simple matter to calculate the new sufficient statistics.
    SS1 = SS1 + eta*(tc - SS1);
    SS2 = SS2 + eta*(sum(tc,1) - SS2);
    
    % Calculate the translation probabilities.
    f = find(SS2);
    t(:,f) = SS1(:,f) ./ repmat(SS2(f),[numclusters 1]);
  end; % Repeat EM.
    
  % Compute the log likelihood.
  l = 0;
  for s = 1:N,
    l = l + sum(log(sum(t(B(s,1:M(s)),W(s,1:L(s))),2) / L(s)));
  end;
  proglog('   Online EM - log likelihood = %f', l);
  
  % Return the model and model value.
  val                  = l;
  model.t              = t;
  model.clusterCenters = clusterCenters;