% SMASH_BLOBS    Change the size of the blobs matrix from a F x D
%                matrix to a F x B x N matrix, where D is the total
%                number of blobs in all the documents.
%    The function call is IMAGEBLOBS = UNSMASH_BLOBS(BLOBS,
%    IMAGEBLOBCOUNTS). For more information on the function parameters,
%    see /GENERAL/DATA/LOAD_DATA.
%    
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function imageBlobs = unsmash_blobs (blobs, imageBlobCounts)

  [F B] = size(blobs);  
  N     = size(imageBlobCounts,1);
  
  imageBlobs = [];
  n = 0;
  for i = 1:N,
    c = imageBlobCounts(i);
    imageBlobs(1:F,1:c,i) = blobs(:,n+1:n+c);
    n = n + c;
  end;
