% MODEL1GAUSSMAP_TRAIN    Train model 1 Gaussian MAP.
%   The function call is [MODEL,VAL] = MODEL1GAUSSMAP_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,EMTOL,ALPHA,A,B,RANDINIT). The
%   model-specific parameters are:
%     - KMITER       The maximum number of iterations to run
%                    K-Means. Only valid if RANDINIT is 'no' (see
%                    below). 
%     - EMITER       The maximum number of iterations ro run EM.
%     - EMTOL        Stop the EM algorithm when the difference in error
%                    between two steps is less than EMTOLERANCE.
%     - ALPHA        The degree of freedom parameter for the Inverse
%                    Wishart distribution on the covariance.
%     - A            The shape parameter on the Inverse Gamma
%                    distribution on tau.
%     - B            The scale parameter on the Inverse Gamma
%                    distribution for tau.
%     - RANDINIT     Optional parameter. By default, the value of this
%                    parameter is 'no' which means that the cluster means
%                    are initialized using K-Means. If this parameter is
%                    'yes', they are initialized by sampling randomly
%                    from the prior distribution. If RANDINIT is set to
%                    'yes' then the parameter KMITER is irrelevant.
%      
%   In MODEL we will return the following information:
%     - mu   F x W matrix of Gaussian means, where F is the number of
%            features and W is the number of word tokens.
%     - sig  F x F x W matrix of Gaussian covariances.
%     - tau  F x 1 matrix of feature weights.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function [model, val] = model1gaussMAP_train ...
      (B, W, A, M, L, numwords, KMiter, EMiter, EMtol, alpha, a, b, ...
       varargin)
  
  % Function constants.
  numReqdArgs = 12;
  goodLL      = 1;
  
  % Default arguments.
  defaultRandInit = 'no';

  % Check to make sure there's enough arguments to run the function.
  if nargin < numReqdArgs,
    error('Not enough input arguments for function. See help for details');
  end;

  % Set up function parameters
  % --------------------------
  defargs = { defaultRandInit };
  [ randInit ] = manage_vargs(varargin, defargs);
  clear defargs varargin numReqdArgs defaultRandInit 
  
  F           = size(B,1);
  N           = length(M);
  maxM        = max(M);
  maxL        = max(L);

  % Check to make sure the value for "alpha" is valid.
  if alpha <= F + 1,
    error([ 'Alpha must be greater than F + 1, where F is the ' ...
	    'number of features.' ]);
  end;
  
  % Get the sample mean and variance. 
  sB      = smash_blobs(B, M);
  muStar  = mean(sB')';
  sigStar = eye(F,F) / numwords; %cov(sB')' / numwords;
  clear sB
  
  % Calculate the normalising constants on the Inverse-Wishart
  % distribution for the sigma parameter and on the Inverse-Gamma
  % distribution for the tau parameter.
  zIW = -numwords*(log(2^(0.5*alpha*F) * pi^(0.25*F*(F-1)) * ...
                prod(gamma(0.5*(alpha+1-[1:F])))) ...
            + 0.5*alpha*log(det(alpha*sigStar)));
  zIG = F*log(b^a / gamma(a));

  % Allocate memory for latent variables.
  indicator = zeros(maxM,maxL,N);

  % Initialize the parameters by randomly sampling from their prior
  % distributions. For the means, we have the option of initializing
  % them using k-means. Note that we assume the data is normalised.
  %   - tau is a F x 1 matrix.
  %   - mu is a F x 1 matrix.
  %   - sig is a F x F x C matrix.
  proglog('a.) Initializing model parameter values.');
  
  % Initialize tau.
  tau = invgamm_rnd(F,1,a,b);
  
  % Initialize mu.
  if randInit,
    % Randomly initialize the cluster means from prior distribution.
    proglog('b.) Randomly finding cluster means.');
    mu = diag(sqrt(tau)) * randn(F,numwords) + ...
	 repmat(muStar,[1 numwords]);
  else,
    % Run k-means on blobs to find clusters centers and blob-cluster
    % membership.
    proglog('b.) Running k-means.');
    sB = smash_blobs(B,M);
    [clusterCenters blobsInClusters] = ...
	do_kmeans(sB', 0, KMiter, 1, numwords);
    mu = clusterCenters';
    clear sB blobsInClusters clusterCenters
  end;
  
  % Initialize sigma.
  for w = 1:numwords,
    sig(:,:,w) = invwishirnd(alpha * sigStar, alpha+1+F);
  end;
  
  % Run EM.
  proglog('c.) Running EM.');
  posteriors = [];
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
    % Save the old tau for the mu update step.
    Tau = diag(tau);
    
    % Update mu and sigma.
    A1 = zeros(1,numwords);
    A2 = zeros(F,numwords);
    A3 = zeros(F,F,numwords);
    
    % Repeat for each sentence.
    for s = 1:N,
      ms = M(s);
      ls = L(s);
      
      % Repeat for each word in the sentence.
      for i = 1:ls,
	w   = W(s,i);
	blb = B(:,1:ms,s);
	u   = blb - repmat(mu(:,w),[1 ms]);
	
	A1(w)     = A1(w) + sum(indicator(1:ms,i,s));
	A2(:,w)   = A2(:,w) + ...
	    sum(repmat(indicator(1:ms,i,s)',[F 1]) .* blb,2);
	A3(:,:,w) = A3(:,:,w) + ...
	    (u.*repmat(indicator(1:ms,i,s)',[F 1]))*u';
      end;
    end;
    
    % Update tau, mu and sigma. Note that the order is important!
    % Update tau.
    tau = b/(a + 0.5*numwords + 1) + ...
	  sum((mu - repmat(muStar,[1 numwords])).^2,2) / ...
	  (2*a + numwords + 2);
    
    % Update mu and sigma.
    for w = 1:numwords,
      z          = inv(sig(:,:,w) + Tau*A1(w));
      mu(:,w)    = Tau * z * A2(:,w) + sig(:,:,w) * z * muStar;
      sig(:,:,w) = (A3(:,:,w) + alpha*sigStar) / (A1(w)+alpha+F+1);
    end;
    
    % Compute the log posterior
    % -------------------------
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
    
    % Compute the prior on mu.
    Tau = diag(tau);
    z1  = inv(Tau);
    for w = 1:numwords,
      u = mu(:,w) - muStar;
      l = l - 0.5*u'*z1*u;
    end;
    l = l - 0.5*numwords*log(det(2*pi*Tau));
    
    % Compute the prior on sigma.
    for w = 1:numwords,
      l = l - 0.5*(alpha+F+1)*log(det(sig(:,:,w))) + ...
	  - 0.5*trace(alpha*sigStar*inv(sig(:,:,w)));
    end;
    l = l + zIW;
    
    % Compute the prior on tau.
    l = l + zIG - (a+1)*sum(log(tau)) - b*sum(tau.^(-1));
    
    % Compute the error.
    if iter > 1,
      if (l - posteriors(iter-1)) < EMtol,
	break;
      end;
    end;
    
    proglog('   EM iteration %i - log posterior = %f', iter, l);
    posteriors = [posteriors l];

  end; % Repeat EM.
  
  % Return the model and the model's value.
  val       = posteriors(length(posteriors));
  model.tau = tau;
  model.sig = sig;
  model.mu  = mu;