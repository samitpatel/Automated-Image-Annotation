% MODEL1GAUSSMLONLINE_TRAIN    Train model 1 Gaussian ML.
%   The function call is MODEL = MODEL1GAUSSMLONLINE_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,LSA,LSB,DIAGCOV,RANDINIT). The model-specific
%   parameters are: 
%     - KMITER       The maximum number of iterations to run K-Means.
%     - EMITER       The maximum number of iterations ro run EM.
%     - LSA          The parameter "a" in the learning schedule.
%     - LSB          A vector of the parameters "b2" and "b3" in the
%                    learning schedule, where b2 corresponds to
%                    sufficient statistic 2 (means) and b3 corresponds to
%                    sufficient statistic 3 (covariances). If LSB is a
%                    scalar, then b2 and b3 are the same. To calculate
%                    bi, bi = LSB(i) * N, where N is the number of
%                    documents in the training set.
%     - DIAGCOV      Optional parameter. Either 'yes' or 'no' as to
%                    whether the covariances should be restricted to
%                    diagonal matrices. The default is 'no'.
%     - RANDINIT     Optional parameter. By default, the value of this
%                    parameter is 'no' which means that the cluster means
%                    are initialized using K-Means. If this parameter is
%                    'yes', they are initialized by sampling randomly
%                    from a N(O,I) distribution. If RANDINIT is 'yes'
%                    then the parameter KMITER is irrelevant.
%
%   In MODEL we will return the following information:
%     - mu   F x W matrix of Gaussian means, where F is the number of
%            features and W is the number of word tokens.
%     - sig  F x F x W matrix of Gaussian covariances.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function [model, val] = model1gaussMLOnline_train ...
      (B, W, A, M, L, numwords, KMiter, EMiter, LSa, LSb, varargin)
  
  % Function constants.
  numReqdArgs = 10;
  
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
  imageBlobs  = B;
  F           = size(B,1);
  N           = length(M);
  maxM        = max(M);
  maxL        = max(L);
  noise       = 1e-10 * eye(F,F);
  
  % Set up the learning schedule. We set the "b2" and "b3" to the 2nd and
  % 3rd entries of the array just to make it more readable to the
  % programmer. 
  LSb = round(LSb * N);
  if length(LSb) < 2,
    LSb([3 2]) = LSb([1 1]);
  else,
    LSb(3) = LSb(2);
    LSb(2) = LSb(1);
  end;

  % Reserve storage for the indicators.
  indicator = zeros(maxM,maxL);    
  
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
    sB = smash_blobs(imageBlobs, M);
    [clusterCenters blobsInClusters] = ...
	do_kmeans(sB', 0, KMiter, 1, numwords);
    mu = clusterCenters';
    clear sB blobsInClusters clusterCenters
  end;
  
  % Initialize sigma.
  proglog('b.) Initializing model parameter values.');
  sig = repmat(eye(F,F),[1 1 numwords]);
  
  % We're going to keep track of three sufficient statistics, and we'll 
  % call them SS1, SS2 and SS3. Here we create the storage for the
  % sufficient statistics and initialize them. Since we have two
  % different learing rates for SS2 and SS3, in actual fact we have to
  % keep track of two different versions of SS1.
  proglog('c. Initializing sufficient statistics.');
  SS1_2 = ones(1, numwords);
  SS1_3 = SS1_2;
  SS2   = mu;
  SS3   = sig;
  
  % Run EM
  % ------
  % At each iteration, we add a new document to be analysed.
  proglog('d.) Running EM.');
  for time = 1:ceil(N*EMiter),
    
    % Note to self: there was evidence of a bug in my code but after a
    % couple trials I can't seem to regenerate it. I'm not sure what the
    % cause was, but in case it happens again I've left a few debugging
    % lines in my code. (Jan 31, 2003)
    try
      lastwarn('');
      
      % Get the document number we just added.
      s  = 1+mod(time-1,N);
      ls = L(s);
      ms = M(s);
      
      P = 'a';
      
      % E step
      % ------
      % Compute p(a_si=j|b_sj,w_si).
      for i = 1:ls,
	w = W(s,i);
	u = (B(:,1:ms,s) - repmat(mu(:,w),[1 ms]))';
	indicator(1:ms,i) = ...
	    exp((-0.5)*dot(u*inv(sig(:,:,w)),u,2)) ...
	    / (sqrt(det(sig(:,:,w))));
      end;
	
      P = 'b';
      
      % For each blob, normalize over all words in the sentence.
      z  = sum(indicator(1:ms,1:ls),2);
      f  = find(z);
      fn = find(~z);
      if length(f),
	indicator(f,1:ls)  = indicator(f,1:ls) ./ repmat(z(f),[1 ls]);
      end;
      indicator(fn,1:ls) = 1 / ls;
      
      P = 'c';
      
      % M step
      % ------
      % Update the learning schedule.
      eta2 = 1 / (LSa*time + LSb(2));
      eta3 = 1 / (LSa*time + LSb(3));
      
      P ='d';
      
      % These are some intermediate variables used for calculating the
      % sufficient statistics.
      A1 = zeros(1, numwords);
      A2 = zeros(F, numwords);
      A3 = zeros(F, F, numwords);

      % Repeat for each word in the sentence.
      for i = 1:ls,
	w = W(s,i);
	b = B(:,1:ms,s);
	u = b - repmat(mu(:,w),[1 ms]);
	
	A1(w)     = A1(w) + sum(indicator(1:ms,i));
	A2(:,w)   = A2(:,w) + sum(repmat(indicator(1:ms,i)',[F 1]).*b,2);
	A3(:,:,w) = A3(:,:,w) + (u.*repmat(indicator(1:ms,i)',[F 1]))*u';
      end;	
      
      P = 'e';
      
      % Now that we have A1, A2 and A3, it's a simple matter to calculate
      % the new sufficient statistics. We have to add noise to SS3
      % because of ill-conditioning.
      SS1_2 = SS1_2 + eta2*(A1 - SS1_2);
      SS1_3 = SS1_3 + eta3*(A1 - SS1_3);
      SS2   = SS2   + eta2*(A2 - SS2);
      SS3   = SS3   + eta3*(A3 - SS3);

      P = 'f';
      
      % Calculate the model parameters, mu and sigma. We have to add
      % noise due to ill-conditioning. 
      f  = find(SS1_2);
      fn = find(~SS1_2);
      if length(f),
	mu(:,f)  = SS2(:,f) .* repmat(1 ./ SS1_2(f), [F 1]);
      end;
      mu(:,fn) = 0;
      
      f  = find(SS1_3);
      fn = find(~SS1_3);
      if length(f),
	sig(:,:,f) = SS3(:,:,f) ...
	    .* repmat(reshape(1 ./ SS1_3(f), [1 1 length(f)]), [F F 1]) ...
	    + repmat(noise, [1 1 length(f)]);
      end;
      sig(:,:,fn) = repmat(noise, [1 1 length(fn)]);

      P = 'g';
      
      % Check to see if we are restricting the covariance to be
      % diagonal. 
      if strcmp(diagCov,'yes'),
	for w = 1:numwords,
	  sig(:,:,w) = diag(diag(sig(:,:,w)));
	end;
      end;
      
      P = 'h';
      
      if strcmp(lastwarn,'Divide by zero'),
	error(lastwarn);
      end;
      
    catch,
      disp(lasterr);
      error(lasterr);
    end;
  end; % Repeat EM.

  % Compute the log-likelihood
  l = 0;
  for s = 1:N,
    ms = M(s);
    ls = L(s);
    
    for j = 1:ms,
      b = B(:,j,s);
      x = 0;
      for i = 1:ls,
	w = W(s,i);
	u = b - mu(:,w);
	x = x + 1 / sqrt(det(2*pi*sig(:,:,w))) * ...
	    exp((-0.5)*u'*inv(sig(:,:,w))*u);
      end;
      l = l + log(x / ls);
    end;
  end;
  proglog('   Online EM - log likelihood = %f', l);
  
  % Return the model and the model's value.
  val       = l;
  model.mu  = mu;
  model.sig = sig;