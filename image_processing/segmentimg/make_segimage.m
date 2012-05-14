% MAKE_SEGIMAGE    Add white edges surrounding the image segments.
%    MAKE_SEGIMAGE(IMG,SEGIMG,BOUNDARY) returns a new image with edges
%    added to it, corresponding to the segment boundaries. IMG is the
%    original image matrix, SEGIMG is the segmented image matrix.
%    BOUNDARY is an optional argument specifying the width of the
%    edges. By default it is 2.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function edgesimg = make_segimage (img, segimg, boundary)
  
  % Specify optional parameters.
  if nargin < 3, 
    boundary = 2; 
  end;
  
  % Find the edges
  % --------------
  % The edges are the boundaries of the segments.
  edges = 256 * make_edges(segimg, boundary);
  
  % Make the edges image
  % --------------------
  % Make the new image with the edges added to it.
  edgesimg = img;
  C = size(img,3);
  for c = 1:C,
    edgesimg(:,:,c) = edgesimg(:,:,c) .* (edges == 0) + edges;
  end;
