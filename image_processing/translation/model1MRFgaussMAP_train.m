% MODEL1MRFGAUSSMAP_TRAIN    Train model 1 MRF Gaussian MAP.
%   The function call is [MODEL,VAL] = MODEL1MRFGAUSSMAP_TRAIN(B,W,M,L,
%   NUMWORDS,KMITER,EMITER,EMTOL,ALPHA,A,B,PSIPRIOR,SP,RANDINIT). The
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
%     - PSIPRIOR     A Dirichlet prior on the inter-alignment
%                    potentials, psi. 0 means no prior.
%     - SP           If it is 'yes', use the sum-product algorithm
%                    (i.e. mean) for inference. Otherwise, use argmax.
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

function [model, val] = model1MRFgaussMAP_train ...
    (B, W, A, M, L, numwords, KMiter, EMiter, EMtol, ...
     alpha, a, b, psiPrior, sp, varargin)

  % Function constants.
  worstPosterior = -1e99;
  numReqdArgs    = 14;
  numPsi         = 1;
  
  % Default arguments.
  % defaultV2     = 'no';
  defaultRandInit = 'no';
  defaultBPtol    = 1e-3;
  defaultBPiter   = 5;

  % Check to make sure there's enough arguments to run the function.
  if nargin < numReqdArgs,
    error('Not enough input arguments for function. See help for details');
  end;
  
  % Set up function parameters
  % --------------------------
  defargs = { defaultRandInit;
              defaultBPtol; 
              defaultBPiter };
  [ randInit ...
    BPtol ...
    BPiter ] = manage_vargs(varargin, defargs);
  clear defargs varargin numReqdArgs defaultRandInit
  clear defaultBPtol defaultBPiter
  
  % Set up some miscellaneous parameters
  F    = size(B,1);
  N    = length(M);
  maxM = max(M);
  maxL = max(L);
  sp   = strcmp('yes',sp);
  
  % Check to make sure the value for "alpha" is valid.
  if alpha <= F + 1,
    error([ 'Alpha must be greater than F + 1, where F is the ' ...
	    'number of features.' ]);
  end;
  
  % Get the sample mean and variance. 
  sB      = smash_blobs(B, M);
  muStar  = mean(sB')';
  sigStar = eye(F,F) / numwords;
  clear sB  
  
  % Calculate the normalising constants on the Inverse-Wishart
  % distribution for the sigma parameter and on the Inverse-Gamma
  % distribution for the tau parameter.
  zIW = -numwords*(log(2^(0.5*alpha*F) * pi^(0.25*F*(F-1)) * ...
                prod(gamma(0.5*(alpha+1-[1:F])))) ...
            + 0.5*alpha*log(det(alpha*sigStar)));
  zIG = F*log(b^a / gamma(a));

  % Make a list of all the edges for each document.
  %   C{s,1} = set of pairs for the "next to" relation
  % These currently are not implemented:
  %   C{s,2} = set of pairs for the "above" relation
  %   C{s,3} = set of pairs for the "below" relation
  C = cell(N, numPsi);
  for s = 1:N,
    for r = 1:numPsi,
      [C1 C2] = find(A{s});
      if length(C1),
	C{s,r}(:,1) = C1;
	C{s,r}(:,2) = C2;
      else,
	C{s,r} = [];
      end;
    end;
  end;
  clear C1 C2
  
  % Find the word co-occurence counts
  % ---------------------------------
  % Initialize the co-occurences table. Note that we never build up the
  % the counts along the diagonal. 
  % cooc = zeros(numwords, numwords);
  % for s = 1:N,
  %  [i j] = find(triu(ones(L(s)),1));
  %  for w = 1:length(i),
  %    cooc(W(s,i(w)),W(s,j(w))) = cooc(W(s,i(w)),W(s,j(w))) + 1;
  %    cooc(W(s,j(w)),W(s,i(w))) = cooc(W(s,j(w)),W(s,i(w))) + 1;
  %  end;
  %  for w = 1:L(s),
  %    cooc(W(s,w),W(s,w)) = cooc(W(s,w),W(s,w)) + 1;
  %  end;
  % end;

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

  % Initialize psi.
  for r = 1:numPsi,
    psi{r} = rand(numwords, numwords);
    psi{r} = psi{r} / (mean(mean(psi{r})) * numwords) + psiPrior;  
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
      
      % Build the MS x LS matrix "t", where MS is the number of blobs in
      % the image and LS is the number of words. Thus, each entry t(j,i)
      % is the probability of generating blob Bsj given that it is
      % aligned to the word Wsi.
      t = zeros(ms,ls);
      for i = 1:ls,
	w = W(s,i);
	u = (B(:,1:ms,s) - repmat(mu(:,w),[1 ms]))';
	t(:,i) = exp((-0.5)*dot(u*inv(sig(:,:,w)),u,2)) ...
		 / (sqrt(det(sig(:,:,w))));
      end;
      
      % For each blob, normalize over all words in the sentence.
      z  = sum(t,2);
      f  = find(z);
      fn = find(~z);
      if length(f),
	t(f,:) = t(f,:) ./ repmat(z(f),[1 ls]);
      end;
      t(fn,:) = 1 / ls;      
      
      % Run loopy belief propagation, grabbing the potentials only for
      % the words in the image's label.
      if ms > 1,
	
	% Build the potentials matrix.
	% if V2,
	%  pot = zeros(ls,ls,ms,ms);
	%  for bi = 1:ms,
	%    for bj = 1:ms,
	%      if A{s}(bi,bj),
	%	pot(:,:,bi,bj) = psi{A{s}(bi,bj)}(W(s,1:ls),W(s,1:ls));
	%      end;
	%    end;
	%  end;
	% else,
	pot = psi{1}(W(s,1:ls),W(s,1:ls));
	% end;
	
	% Run loopy belief propagation.
	indicator(1:ms,1:ls,s) = bpmrf2(A{s} > 0, pot, t, sp, BPtol, ...
					BPiter*ms, 0); 
      else,
	indicator(1,1:ls,s) = t;
      end;
      
      % Normalize again.
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
    
    % Update psi.
    for r = 1:numPsi,
      psi{r} = zeros(numwords, numwords);
      for s = 1:N,
	ms = M(s);
	ls = L(s);      
      
	if ms > 1,
	  x = zeros(numwords, numwords);
	  
	  % Repeat for each pair of words in the image.
	  for u = 1:ls,
	    for v = 1:ls,
	      wu = W(s,u);
	      wv = W(s,v);
	      
	      % Repeat for each clique pair.
	      for i = 1:size(C{s,r},1),
		x(wu,wv) = x(wu,wv) + ...
		    indicator(C{s,r}(i,1),u,s) * ...
		    indicator(C{s,r}(i,2),v,s);
	      end;
	      
	      if x(wu,wv) > 0,
		x(wu,wv) = x(wu,wv) / ...
		    (sum(indicator(C{s,r}(:,1),u,s)) * ...
		     sum(indicator(C{s,r}(:,2),v,s)));
	      end;
	    end;
	  end;
	  
	  % "Normalize" x.
	  % x = x / (mean(mean(x)) * numwords);
	  psi{r} = psi{r} + x;
	end;
      end;
      
      % "Normalize" psi and add the prior.
      psi{r} = psi{r} / sum(M > 1);
      psi{r} = psi{r} + psiPrior;
    end;
    
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
    
    % TO CHANGE.
    for s = 1:N,
      ms = M(s);
      ls = L(s);
      
      for r = 1:numPsi,
	for i = 1:size(C{s,r},1),
	  x = 0;
	  for u = 1:ls,
	    for v = 1:ls,
	      x = x + psi{r}(W(s,u),W(s,v));
	    end;
	  end;
	  l = l + log(x);
	end;
      end;
    end;
    
    % TO CHANGE.
    % Compute the error.
    if iter > 1,
      if abs(l - posteriors(iter-1)) < EMtol,
	break;
      end;
    end;
      
    proglog('   EM iteration %i - log posterior = %f', iter, l);
    posteriors = [posteriors l];
        
  end; % Repeat EM.

  % Return the model.
  model.psi    = psi;
  model.sig    = sig;
  model.mu     = mu;  
  model.tau    = tau;
  model.sp     = sp;
  model.BPtol  = BPtol;
  model.BPiter = BPiter;
  
  % Return the value.
  val = posteriors(length(posteriors));