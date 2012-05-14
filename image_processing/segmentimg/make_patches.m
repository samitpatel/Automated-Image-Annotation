% MAKE_PATCHES    Creates a grid of patches for an image of specified
%                 dimensions. 
%    [SEGIMG,ADJACENCIES] = MAKE_PATCHES(IMGSIZE,PATCHSIZE) is
%    the function call. IMGSIZE is [H W] where H is the height of the
%    image and W is the width. PATCHSIZE is [A B], where A is the desired
%    height of a single patch and B is the width. MAKE_PATCHES finds a
%    compromise between the desired patch size and the dimensions of the
%    image.
%
%    The function returns two values. SEGIMG is an H x W matrix where H 
%    is the height of the image, W is the width of the image and each
%    entry is a value M indicating membership to the Mth segment. 
%    ADJACENCIES is a P x P matrix where P is the number of patches. Each
%    entry (i,j) is one of the following: 
% 
%       0   Patches i and j are not adjacent
%       1   Patch i is to the left of patch j
%       2   Patch i is to the right of patch j
%       3   Patch i is above patch j
%       4   Patch i is below patch j
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function [segimg, adjacencies] = make_patches (imgSize, patchSize)

  % Get the image dimensions.
  if length(imgSize) == 1,
    h = imgSize;
    w = imgSize;
  else,
    h = imgSize(1);
    w = imgSize(2);
  end;

  % Get the patch dimensions.
  if length(patchSize) == 1,
    a = patchSize;
    b = patchSize;
  else,
    a = patchSize(1);
    b = patchSize(2);
  end;
  
  % Note that we're allowed to adjust the dimensions of the patches a
  % little bit if it means we get more uniform coverage over all the
  % patches. "rh" is what is left over in height after we cover the area
  % with patches. "rw" is the analogous value for the width. "nh" and
  % "nw" are the number of patches we can generate along the height and
  % width of the image, respectively.
  [a nh rh] = findBestSize(h,a);
  [b nw rw] = findBestSize(w,b);
  
  % Now that we have the exact dimensions of the patches and their
  % numbers, let's find the patches! Note that the last one of each row
  % is special because we have to add on that extra amount (rh,rw). "S"
  % is the total number of segments. At the same time, let's also
  % calculate the adjacencies.
  S           = nh*nw;
  segimg      = zeros(h,w);
  segments    = zeros(h,w,S);
  adjacencies = zeros(S,S);
  s           = 0;
  for i = 1:nh,
    for j = 1:nw;
      s = s + 1;
      uh = (i == nh)*h + (i < nh)*i*a;
      uw = (j == nw)*w + (j < nw)*j*b;
      segimg((i-1)*a+1:uh, (j-1)*b+1:uw)      = s;
      segments((i-1)*a+1:uh, (j-1)*b+1:uw, s) = 1;
      
      % Add a horizontal adjacencies only if we are not the last patch in
      % the row, and similarly for vertical adjacencies.
      if j < nw,
	adjacencies(s,s+1) = 1;
	adjacencies(s+1,s) = 2;
      end;
      if i < nh,
	adjacencies(s,s+nw) = 3;
	adjacencies(s+nw,s) = 4;
      end;
    end;
  end;
  
% ----------------------------------------------------------------------
% The objective is to lower "r" as much as possible, which is the
% difference in size between most of the patches and the last patch. At
% the same time, we also want to minimize "p" as much as possible, which
% is the amount we are adding (or taking away) to each of the patches
% when compared with the desired dimension. The function parameters are
% the size of the image and the size of the patch, "s" and "ps"
% respectively.  
function [ps, n, r] = findBestSize (s, ps)
  
  % If the size of the image is less than the patch size, the answer is
  % easy. 
  if s < ps,
    ps = s;
    n  = 1;
    r  = 0;
    return;
  end;
  
  % What we're going to do is try two different ways of fitting the
  % patches into the image. The first is to increase the patch size, and
  % the second is to decrease it.
  
  % Trial 1.
  r1 = mod(s,ps);
  n1 = floor(s / ps);
  p1 = floor(r1 / n1);
  r1 = mod(s,ps+p1);

  % Trial 2.
  r2  = mod(s,-ps);
  n2o = floor(s / ps);
  p2  = floor(r2 / (n2o + 1));
  n2  = floor(s / (ps+p2));
  r2  = mod(s,ps+p2);
  
  if max(r1,p1) < max(r2,-p2)+n2-n2o,
    n  = n1;
    r  = r1;
    ps = ps + p1;
  else,
    n  = n2;
    r  = r2;
    ps = ps + p2;
  end;
  