% MODEL1GAUSSML_TRAIN    Train model 1 Gaussian ML.
%   The function call is [MODEL,VAL] = MODEL1GAUSSML_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,EMTOLERANCE,DIAGCOV,RANDINIT). The
%   model-specific parameters are:
%     - KMITER       The maximum number of iterations to run K-Means.
%     - EMITER       The maximum number of iterations ro run EM.
%     - EMTOLERANCE  Stop the EM algorithm when the difference in error
%                    between two steps is less than EMTOLERANCE.
%     - DIAGCOV      Optional parameter. Either 'yes' or 'no' as to
%                    whether the covariances should be restricted to
%                    diagonal matrices. The default is 'no'.
%     - RANDINIT     Optional parameter. By default, the value of this
%                    parameter is 'no' which means that the cluster means
%                    are initialized using K-Means. If this parameter is
%                    'yes', they are initialized by sampling randomly
%                    from a N(O,I) distribution. If RANDINIT is set to
%                    'yes' then the parameter KMITER is irrelevant.
%
%   In MODEL we will return the following information:
%     - mu   F x W matrix of Gaussian means, where F is the number of
%            features and W is the number of word tokens.
%     - sig  F x F x W matrix of Gaussian covariances.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function [model, val] = model1gaussML_train ...
      (B, W, A, M, L, numwords, KMiter, EMiter, EMtol, varargin)
  
  % Function constants.
  numReqdArgs = 9;
  
  % Default arguments.
  defaultDiagCov  = 'no';  
  defaultRandInit = 'no';
  
  % Check to make sure there's enough arguments to run the function.
  if nargin < numReqdArgs,
    error('Not enough input arguments for function. See help for details');
  end;
  
  % Set up function parameters
  % --------------------------
  defargs = { defaultDiagCov; 
              defaultRandInit };
  [ diagCov ...
    randInit ] = manage_vargs(varargin, defargs);
  clear defargs varargin numReqdArgs defaultDiagCov defaultRandInit
  
  % Set up variables.
  F     = size(B,1);
  N     = length(M);
  maxM  = max(M);
  maxL  = max(L);
  noise = 1e-10 * eye(F,F);

  % Initialize mu and sigma
  % -----------------------
  if strcmp(randInit,'yes'),
    
    % Randomly initialize the cluster means from an N(O,I)
    % distribution. 
    proglog('a.) Randomly finding cluster means.');
    mu = randn(F,numwords);
  else,
    
    % Run k-means on blobs to find clusters centers and blob-cluster
    % membership.
    proglog('a.) Running k-means.');
    sB = smash_blobs(B, M);
    [clusterCenters blobsInClusters] = ...
	do_kmeans(sB', 0, KMiter, 1, numwords);
    mu = clusterCenters';
    clear sB blobsInClusters clusterCenters
  end;
  
  % Initialize sigma.
  proglog('b.) Initializing model parameter values.');
  sig = repmat(eye(F,F),[1 1 numwords]);
  
  % Reserve storage for indicators.
  indicator = zeros(maxM,maxL,N);
  
  % Run EM
  % ------
  proglog('c.) Running EM.');
  likelihoods = [];
  for iter = 1:EMiter,
    
    % E step
    % ------
    % Compute p(a_si=j|b_sj,w_si).
    % Repeat for each sentence.
    for s = 1:N,
      ms = M(s);
      ls = L(s);
      
      for i = 1:ls,
	w = W(s,i);
	u = (B(:,1:ms,s) - repmat(mu(:,w),[1 ms]))';
	indicator(1:ms,i,s) = ...
	    exp((-0.5)*dot(u*inv(sig(:,:,w)),u,2)) ...
	    / (sqrt(det(sig(:,:,w))));
      end;
      
      % For each blob, normalize over all words in the sentence.
      z  = sum(indicator(1:ms,1:ls,s),2);
      f  = find(z);
      fn = find(~z);
      if length(f),
	indicator(f,1:ls,s) = ...
	    indicator(f,1:ls,s) ./ repmat(z(f),[1 ls]);
      end;
      indicator(fn,1:ls,s) = 1 / ls;
    end;    
    
    % M step
    % ------
    % Update mu and sigma.
    A1 = zeros(1, numwords);
    A2 = zeros(F, numwords);
    A3 = zeros(F, F, numwords);
    
    % Repeat for each sentence.
    for s = 1:N,
      ms = M(s);
      ls = L(s);
      
      % Repeat for each word in the sentence.
      for i = 1:ls,
	w = W(s,i);
	b = B(:,1:ms,s);
	u = b - repmat(mu(:,w),[1 ms]);
	
	A1(w)     = A1(w) + sum(indicator(1:ms,i,s));
	A2(:,w)   = A2(:,w) + ...
	    sum(repmat(indicator(1:ms,i,s)',[F 1]) .* b,2);
	A3(:,:,w) = A3(:,:,w) + ...
	    (u.*repmat(indicator(1:ms,i,s)',[F 1]))*u';
      end;
    end;
    
    % Now that we have A1, A2 and A3, update the parameters mu and
    % sigma. 
    f = find(A1);
    mu(:,f) = A2(:,f) .* repmat(1 ./ A1(f), [F 1]);
    sig(:,:,f) = A3(:,:,f) ...
	.* repmat(reshape(1 ./ A1(f), [1 1 length(f)]), [F F 1]) ...
	+ repmat(noise, [1 1 length(f)]);
    
    % Check to see if we are restricting the covariance to be
    % diagonal. 
    if strcmp(diagCov,'yes'),
      for w = 1:numwords,
	sig(:,:,w) = diag(diag(sig(:,:,w)));
      end;
    end;
      
    % Compute the log-likelihood
    % --------------------------
    l = 0;
    for s = 1:N,
      ms = M(s);
      ls = L(s);
      z  = zeros(ls,ms);
      
      for i = 1:ls,
	w         = W(s,i);
	z1        = 1 / sqrt(det(2*pi*sig(:,:,w)));
	u         = (B(:,1:ms,s) - repmat(mu(:,w),[1 ms]))';
	z(i,1:ms) = z1 * exp((-0.5)*dot(u*inv(sig(:,:,w)),u,2))';
      end;
      
      l = l + sum(log(sum(z,1) / ls));
    end;
    
    % Compute the error.
    if iter > 1,
      err = l - likelihoods(iter-1);
      if err < EMtol,
	break;
      end;
    end;
    
    proglog('   EM iteration %i - log likelihood = %f', iter, l);
    likelihoods = [likelihoods l];
  end; % Repeat EM.
  
  % Return the model and the model's value.
  val       = likelihoods(length(likelihoods));
  model.mu  = mu;
  model.sig = sig;