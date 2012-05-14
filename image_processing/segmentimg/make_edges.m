% MAKE_EDGES    Create an image of edges.
%    EDGES = MAKE_SEGMENTS(SEGIMG,BOUNDARY) creates a matrix EDGES
%    containing entries of either 0 or 1; 1 if the pixel is on the
%    boundary between two segments. The optional parameter BOUNDARY
%    specifies the width of the edges. The default is 2. SEGIMG is the
%    segment output from NCuts.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function edges = make_edges (segimg, boundary)
  
  % Specify optional parameters.
  if nargin < 2, 
    boundary = 2; 
  end;
  
  [h w] = size(segimg);
  
  % First shift along the width, then the height, then the two diagonal
  % directions.
  xw = [(segimg(:,1:w-1) - segimg(:,2:w)) ~= 0 zeros(h,1)];
  xh = [(segimg(1:h-1,:) - segimg(2:h,:)) ~= 0; zeros(1,w)];
    
  % Add all the edges together.
  x = (xw + xh);
  for i = 1:boundary - 1,
    x = x + [[x(i+1:h,i+1:w); zeros(i,w-i)] zeros(h,i)];
    x = x + [[x(i+1:h,1:w-i); zeros(i,w-i)] zeros(h,i)];
  end;
  
  edges = (x ~= 0);
