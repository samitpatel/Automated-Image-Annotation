% COMPUTE_FEATURE_AREA    Return the normalized area of the segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_area (img, nimg, labimg, segment)

  % Calculate the area of the segment.
  [height width] = size(segment);
  totalArea = height * width;
  area = sum(sum(segment));
  f = area / totalArea;
