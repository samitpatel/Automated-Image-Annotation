% MAKE_AVGIMAGE    Create an image where the pixels are averaged over
%                  each segment.
%    MAKE_AVGIMAGE(IMG,SEGIMG) returns a new image where the pixels
%    from IMG are averaged over the segment information. See
%    LOAD_SEGMENT_INFO for information on the parameter SEGIMG.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function avgimg = make_avgimage (img, segimg)
  
  segments = find_segments(segimg);
  [h w C]  = size(img);
  [h w S]  = size(segments);
  
  % Find the average colours (RGB) for each segment
  % -----------------------------------------------
  segColours = zeros(S,C);
  for s = 1:S,
    
    t1 = sum(sum(segments(:,:,s)));
    for c = 1:C,
      t2 = sum(sum(segments(:,:,s) .* img(:,:,c)));
      segColours(s,c) = t2 / t1;
    end;
  end;
  clear t1 t2
    
  % Make coloured segmented image
  % -----------------------------
  avgimg = zeros(h,w,C);
  for s = 1:S,
    for c = 1:C,
      avgimg(:,:,c) = avgimg(:,:,c) + segColours(s,c) * segments(:,:,s);
    end;
  end;

