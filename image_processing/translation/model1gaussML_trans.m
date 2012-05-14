% MODEL1GAUSSML_TRANS
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = model1gaussML_trans (B, M, A, model)
  
  N          = length(M);
  maxM       = max(M);
  F          = size(model.mu,1);
  numwords   = size(model.mu,2);
  blobImages = B;
  
  % Build the "t" matrix.
  t = zeros(numwords,maxM,N);
  for s = 1:N,
    for b = 1:M(s),
      for w = 1:numwords,
	% Find the unnormalized translation probability p(b|w).
	u = B(:,b,s) - model.mu(:,w);
	t(w,b,s) = exp((-0.5)*u'*inv(model.sig(:,:,w))*u) ...
	           / (sqrt(det(model.sig(:,:,w))));
      end;
      
      % Normalize the translation probabilities.
      z = sum(t(:,b,s));
      if z,
	t(:,b,s) = t(:,b,s) / z;
      else,
	t(:,b,s) = 1 / numwords;
      end;
    end;
  end;
  
  