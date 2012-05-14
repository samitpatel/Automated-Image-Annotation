% MAKE_PATCHES_WITH_SEGS    Create the patch grid, taking to account
%                           segmentation information. 
%    SEGIMG = MAKE_PATCHES_WITH_SEGS(PATCHIMG,SEGIMG,ADJACENCIES) creates
%    new patches SEGIMG, an H x W matrix where H 
%    is the height of the image, W is the width of the image and each
%    entry is a value M indicating membership to the Mth segment.
%    PATCHIMG is the value SEGIMG returned from MAKE_PATCHES. ADJACENCIES
%    is returned from MAKE_PATCHES. SEGIMG is the value returned from 
%    LOAD_SEGMENT_INFO. 
%    
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function segimg = make_patches_with_segs (patchimg, segimg, adjacencies)
  
  % Get the patch and segment information.
  patches = find_segments(patchimg);
  segs    = find_segments(segimg);
  
  % Get the number of patches and segments.
  P = size(patches,3);
  S = size(segs,3);

  % Find what segments are in each patch. We will call this variable
  % "pws", which stands for "patches with segments". While we are doing
  % this, we will also find the number of patches for the width and
  % height. "pCoords" is a matrix that contains the coordinates of the
  % (1,1) entry for the pws{p} matrix for patch p.
  pCoords = zeros(P,2);
  
  % Repeat for each patch. 
  for p = 1:P,

    % Find the dimensions of the patch.
    [h w]        = find(patches(:,:,p));
    hMin         = min(h);
    hMax         = max(h);
    wMin         = min(w);
    wMax         = max(w);
    h            = hMax - hMin + 1;
    w            = wMax - wMin + 1;
    pws{p}       = zeros(h,w,S);
    pCoords(p,:) = [hMin wMin];
    
    % Repeat for each segment.
    for s = 1:S,
      pws{p}(:,:,s) = segs(hMin:hMax, wMin:wMax, s);
    end;
  end;
  
  % Get some more information on the segments. The matrix "RLBT" contains
  % entries as to whether the segment touches the top, bottom, left and
  % right of the patch. The R matrix lists the ranks of the segments in
  % terms of how much space they occupy, from most to least.
  RLBT = zeros(4,P,S);
  R    = zeros(P,S);
  for p = 1:P,
    R(p,:)      = computeRanks(pws{p});
    RLBT(:,p,:) = computeRLBTs(pws{p}, adjacencies(p,:));
  end;
    
  % Next what we want to do is calculate the adjacencies for the
  % combinations of the patches and segments. 
  A = zeros(P,P,S);
  for p1 = 1:P,
    for p2 = find(adjacencies(p1,:)),
      for s = R(p1,find(R(p1,:))),
	if length(find(R(p2,:) == s)),
	  a = adjacencies(p1,p2);
	  r1 = RLBT(a,p1,s);
	  r2 = RLBT(adjacencies(p2,p1),p2,s);
	  A(p1,p2,s) = a * (r1 > 0) * (r2 > 0) * ...
	               (max(RLBT(:,p2,s)) == r2);
	end;
      end;
    end;
  end;

  % Now that we have the adjacencies for the patches + segments, let's
  % join them together. What we're going to do is go through all the
  % patches and "attract" adjacent segments. We also need to keep track
  % of adjacencies (or think of them as edges) that get used up.
  usedS = zeros(P,S);
  patchJoined = 1;
  while patchJoined,
    patchJoined = 0;
    
    for p1 = 1:P,
      for p2 = find(adjacencies(p1,:)),
      
	% For all the neigbhouring segments in patches p1 and p2, find the
	% ratios in sizes s1/s2. We will pick the one with the highest
	% ratio, and then only if it is greater than 1. Note that the
	% ratios should never be 0 or inf, thanks to our ingenious
	% preparation before.
	
	% Take all the segments that are adjacent in patches p1 and p2, but
	% don't take the segment that has rank 1 for patch p2. As well,
	% don't take any segments that have already been used in p1. If any
	% segments still remain from the "pruning", then we continue to
	% search for a suitor.
	s = find(reshape(A(p1,p2,:), [1 S]) & ~usedS(p2,:));
	if length(s),
	  [ans ans s] = find(s .* (s ~= R(p2,1)));
	end;
	if length(s),
	  
	  r = sum(sum(pws{p1}(:,:,s),1),2) ./ sum(sum(pws{p2}(:,:,s),1),2);
	  [maxR bS] = max(r);
	  bS        = s(bS);
	  if maxR > 1,
	    patchJoined = 1;
	    
	    % Now that we've chosen the best segment to join, we need to a
	    % few things. First we need to enlarge patch p1. Second, we add
	    % the portion of the segment to the patch p1. Third, we remove
	    % the segment entirely from patch p2.
	    [h w] = find(pws{p2}(:,:,bS));
	    h     = h;
	    w     = w;
	    
	    % Get the coordinates for new patch p1.
	    hMinP2 = min(h);
	    hMaxP2 = max(h);
	    wMinP2 = min(w);
	    wMaxP2 = max(w);	  
	    hMin   = min(pCoords(p1,1), hMinP2+pCoords(p2,1)-1);
	    hMax   = max(pCoords(p1,1)+size(pws{p1},1)-1, ...
			 hMaxP2+pCoords(p2,1)-1);
	    wMin   = min(pCoords(p1,2), wMinP2+pCoords(p2,2)-1);
	    wMax   = max(pCoords(p1,2)+size(pws{p1},2)-1, ...
			 wMaxP2+pCoords(p2,2)-1);
	    h      = hMax - hMin + 1;
	    w      = wMax - wMin + 1;
	    
	    a = pCoords(p1,1) - hMin + 1; 
	    b = a + size(pws{p1},1) - 1;
	    c = pCoords(p1,2) - wMin + 1;
	    d = c + size(pws{p1},2) - 1;
	    
	    % Move the old segments into the new patch through some simple
	    % translation taking into account the new dimensions of the
	    % patch. 
	    newP1            = zeros(h,w,S);
	    newP1(a:b,c:d,:) = pws{p1};
	    
	    % Next move the new segment portion into it's proper location.
	    a = pCoords(p2,1) - hMin + hMinP2;
	    b = pCoords(p2,1) - hMin + hMaxP2;
	    c = pCoords(p2,2) - wMin + wMinP2;
	    d = pCoords(p2,2) - wMin + wMaxP2;
	    newP1(a:b,c:d,bS) = pws{p2}(hMinP2:hMaxP2,wMinP2:wMaxP2,bS);
	    
	    % Change the coordinates of patch p1.
	    pCoords(p1,:) = [hMin wMin];
	    pws{p1}       = newP1;
	    usedS(p1,bS)  = 1;
	    
	    % Remove the segment from patch p2.
	    pws{p2}(:,:,bS) = 0;
	    A(p2,:,bS)      = 0;
	    A(:,p2,bS)      = 0;
	    
	    % Compute the new ranks.
	    R(p1,:) = computeRanks(pws{p1});
	    R(p2,:) = computeRanks(pws{p2});
	  end;
	end;
      end;
    end;
  end;
  
  % Join the patches back together. Note that we we will never end up
  % with less (or more) patches than we started with.
  [h w ans] = size(segs);
  segimg    = zeros(h,w);
  for p = 1:P,
    hMin      = pCoords(p,1);
    wMin      = pCoords(p,2);
    [h w ans] = size(pws{p});
    segimg(hMin:hMin+h-1,wMin:wMin+w-1) = p;
  end;
  
% ---------------------------------------------------------------------
function Rp = computeRanks (s)
  
  S     = size(s,3);
  [y i] = sort(-reshape(sum(sum(s,1),2), [1 S]));
  y     = y < 0;
  Rp    = i .* y;

% ---------------------------------------------------------------------
function RLBTp = computeRLBTs(s, a)
    
  [h w S] = size(s);
  RLBTp   = zeros(4,1,S);
  
  RLBTp(1,1,:) = sum(s(:,w,:),1) / h * length(find(a == 1));
  RLBTp(2,1,:) = sum(s(:,1,:),1) / h * length(find(a == 2));
  RLBTp(3,1,:) = sum(s(h,:,:),2) / w * length(find(a == 3)); 
  RLBTp(4,1,:) = sum(s(1,:,:),2) / w * length(find(a == 4));
