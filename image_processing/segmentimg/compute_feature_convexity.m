% COMPUTE_FEATURE_CONVEXITY    Return the convexity of the segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_convexity (img, nimg, labimg, segment)

  % Find the width & height of the segment.
  [h w ans] = find(segment == 1);
  height = max(h) - min(h) + 1;
  width  = max(w) - min(w) + 1;
  maxC = height * width;
  
  % Calculate the convexity of the segment.
  s = segment(min(h):max(h),min(w):max(w));
  C = sum(sum(s));
  
  f = 1 - C/maxC;
  