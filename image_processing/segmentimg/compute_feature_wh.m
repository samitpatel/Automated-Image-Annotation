% COMPUTE_FEATURE_WH    Return the normalized width and height of the
%                       image segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_wh (img, nimg, labimg, segment)
  
  % Calculate the width & height of the segment.
  [tHeight tWidth] = size(segment);
  [h w ans] = find(segment == 1);
  height = max(h) - min(h) + 1;
  width  = max(w) - min(w) + 1;
  f = [(width / tWidth) (height / tHeight)];
  