% COMPUTE_FEATURE_RGBSTD    Return the standard deviation of the RGB
%                           values of the image segment.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_rgbstd (img, nimg, labimg, segment)      

  % Calculate the standard deviation of the RGB colour of the segment.  
  f = segmentop (segment, @std, img);
  
