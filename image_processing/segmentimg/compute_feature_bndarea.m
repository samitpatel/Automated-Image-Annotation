% COMPUTE_FEATURE_BNDAREA    Return the ratio between the boundary and
%                            the area of the segment.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_bndarea (img, nimg, labimg, segment)   
  
  % Add a white rim around the segment.
  [h w] = size(segment);
  S     = [zeros(h+2,1) [zeros(1,w); segment; zeros(1,w)] zeros(h+2,1)];
  h     = h + 2;
  w     = w + 2;
  
  % Calculate the boundary of the segment.
  xw = [(S(:,1:w-1) - S(:,2:w)) ~= 0];
  xh = [(S(1:h-1,:) - S(2:h,:)) ~= 0];
  
  x = ((segment .* (xw(2:h-1,1:w-2) + xw(2:h-1,2:w-1) + ...
		    xh(1:h-2,2:w-1) + xh(2:h-1,2:w-1))) > 0);
  boundary = sum(sum(x));
  
  % Calculate the area of the segment.
  area = sum(sum(segment));
  f = boundary / area;
  