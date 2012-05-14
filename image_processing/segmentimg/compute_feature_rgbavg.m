% COMPUTE_FEATURE_RGBAVG    Return the average of the RGB values of the
%                           image segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_rgbavg (img, nimg, labimg, segment)
  
  % Calculate the average RGB colour of the segment.
  f = segmentop (segment, @mean, img);
  