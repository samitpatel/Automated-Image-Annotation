% COMPUTE_FEATURE_POSSTD    Return the standard deviation of the
%                           positions of the pixels -- a bit like the
%                           height and width -- for the image segment.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_posstd (img, nimg, labimg, segment)

  % Calculate the x,y position of the segment.
  [th tw] = find(segment | ~segment);    
  [h w ans] = find(segment);
  f = [(std(w) / std(tw)) (std(h) / std(th))];
  