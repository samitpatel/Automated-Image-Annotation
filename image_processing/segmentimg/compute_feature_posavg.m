% COMPUTE_FEATURE_POSAVG    Return the moment of inertia (the average of
%                           the positions of the pixels) for the image
%                           segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_posavg (img, nimg, labimg, segment)

  % Calculate the x,y position of the segment.
  [tHeight tWidth] = size(segment);    
  [h w ans] = find(segment);
  f = [(mean(w) / tWidth) (mean(h) / tHeight)];
  