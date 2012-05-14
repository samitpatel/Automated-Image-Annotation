% SMASH_BLOBS    Change the size of the blobs matrix from a F x B x N
%                matrix to a F x D matrix, where D is the total number of
%                blobs in all the documents.
%    The function call is BLOBS = SMASH_BLOBS(IMAGEBLOBS,
%    IMAGEBLOBCOUNTS). For more information on the function parameters,
%    see /GENERAL/DATA/LOAD_DATA.
%    
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function blobs = smash_blobs (imageBlobs, imageBlobCounts)

  [F B N] = size(imageBlobs);  
  
  % Set up the selection.
  s = [];
  for i = 0:N-1,
    s = [s [B*i+1:B*i+imageBlobCounts(i+1)]];
  end;
  
  blobs = reshape(imageBlobs, F, N*B);
  blobs = blobs(:,s);
