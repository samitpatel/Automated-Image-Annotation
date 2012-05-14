% MODEL1MRFGAUSSMAP_TRANS
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = model1MRFgaussMAP_trans (B, M, A, model)

  N        = length(M);
  maxM     = max(M);
  F        = size(model.mu,1);
  numwords = size(model.mu,2);  

  % Repeat for each sentence.
  for s = 1:N,
    ms = M(s);
      
    % Build the MS x W matrix "t", where MS is the number of blobs in
    % the image and W is the total number of word tokens. Thus, each
    % entry t(j,i) is the probability of generating blob Bsj from word
    % Wi.
    tMAP = zeros(numwords,ms);
    for b = 1:M(s),
      for w = 1:numwords,
	% Find the unnormalized translation probability p(b|w).
	u = B(:,b,s) - model.mu(:,w);
	tMAP(w,b) = exp((-0.5)*u'*inv(model.sig(:,:,w))*u) ...
	            / (sqrt(det(model.sig(:,:,w))));
      end;
      
      % Normalize the translation probabilities.
      z = sum(tMAP(:,b));
      if z,
	tMAP(:,b) = tMAP(:,b) / z;
      else,
	tMAP(:,b) = 1 / numwords;
      end;
    end;
      
    % Run loopy belief propagation, grabbing the potentials only for
    % the words in the image's label. 
    if ms > 1,
      
      % Build the potentials matrix.
      % pot = zeros(numwords,numwords,ms,ms);
      % for bi = 1:ms,
      %	  for bj = 1:ms,
      %     if A{s}(bi,bj),
      %	      pot(:,:,bi,bj) = model.psi{A{s}(bi,bj)};
      %	    end;
      %	  end;
      % end;
      pot = model.psi{1};
      
      % Run loopy belief propagation.
      t(:,1:ms,s) = bpmrf2(A{s} > 0, pot, tMAP', model.sp, ...
			   model.BPtol, model.BPiter*ms, 0)';
    else,
      t(:,1,s) = tMAP;
    end;
    
    % Normalize again, over all the words.
    z  = sum(t(:,:,s),1);
    f  = find(z);
    fn = find(~z);
    if length(f),
      t(:,f,s) = t(:,f,s) ./ repmat(z(f), [numwords 1]);
    end;
    t(:,fn,s) = 1 / numwords;
  end;  
  
