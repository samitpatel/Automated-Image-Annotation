% MODEL1DISCRETE_TRANS
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = model1discrete_trans (B, M, A, model)
  
  N          = length(M);
  maxM       = max(M);
  F          = size(model.clusterCenters,1);
  C          = size(model.clusterCenters,2);
  numwords   = size(model.t, 2);
  blobImages = B;
  
  % Convert the matrix of blobs to a discrete matrix of clusters. In
  % other words, we need to find the membership for each blob.
  B = zeros(N,maxM);
  
  % Repeat for each document.
  for s = 1:N,
    % Repeat for each blob in the document.
    for b = 1:M(s),
      % Find the cluster that best matches the blob.
      [ans c] = min(sum((repmat(blobImages(:,b,s),[1 C]) - ...
			 model.clusterCenters).^2,1));
      B(s,b) = c;
    end;
  end;
  clear blobImages
  
  % Now that we've clustered the blobs, let's build the "t" matrix.
  t = zeros(numwords,maxM,N);
  for s = 1:N,
    x  = model.t(B(s,1:M(s),:),:);
    sx = sum(x,2);
    f  = find(sx);
    fn = find(~sx);
    
    t(:,f,s)  = (x(f,:) ./ repmat(sx(f),[1 numwords]))';
    t(:,fn,s) = 1 / numwords;
  end;
  