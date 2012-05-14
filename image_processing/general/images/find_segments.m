% FIND_SEGMENTS    Converts the original segment data.
%    SEGMENTS = FIND_SEGMENTS(SEGIMG) returns an H x W x S matrix where H
%    is the height of the image, W is the width of the image and S is the
%    number of segments, and an entry of 1 indicates membership of that
%    pixel in the segment. SEGIMG is a H x W matrix where H is the height
%    of the image in pixels, W is the width of the image. Each entry is a
%    value M indicating membership to the Mth segment. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function segments = find_segments (segimg)

  % Set up segments
  n        = max(max(segimg));
  [h w]    = size(segimg);
  segments = zeros(h,w,n);
  for s = 1:n,
    segments(:,:,s) = segimg == s;
  end;  
    
