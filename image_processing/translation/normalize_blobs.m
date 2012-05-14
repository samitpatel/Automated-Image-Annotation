% NORMALIZE_BLOBS    Normalize the blobs.
%    BLOBS = NORMALIZE_BLOBS(BLOBS,BLOBCOUNTS,BLOBS_MEAN,BLOBS_STD)
%    normalizes the blobs according to F x 1 matrices BLOBS_MEAN and
%    BLOBS_STD, where F is the number of features. BLOBS is a F x B x N
%    matrix and BLOBCOUNTS is a N x 1 matrix, both obtained from
%    /GENERAL/DATA/LOAD_DATA. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function blobs = normalize_blobs (blobs, blobCounts, blobs_mean, blobs_std)
  
  [F B N] = size(blobs);
  
  % This matrix has ones only where there are blobs.
  m = zeros(F,B,N);
  for i = 1:N,
    m(:,1:blobCounts(i),i) = 1;
  end;
  
  % Normalize the blobs.
  blobs = blobs -  repmat(blobs_mean, [1 B N]) .* m; 
  blobs = blobs ./ repmat(blobs_std, [1 B N]);
