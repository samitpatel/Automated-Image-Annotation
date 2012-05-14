% CALCULATE_ADJACENCIES    Find adjacency information between segments.
%    ADJACENCIES = CALCULATE_ADJACENCIES(SEGIMG) returns P x P matrix
%    where P is the number of patches. Each entry (i,j) is one of the
%    following:  
% 
%      0 = i and j are not adjacent
%      1 = i and j are next to each other
%      2 = i is below j
%      3 = i is above j
%
%    In the case of a tie, "next to" wins.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function adjacencies = calculate_adjacencies (segimg)
  
  % Function constants.
  adjThreshold = 0.02;
  
  % Get the segment information.
  segments = find_segments(segimg);
  
  % Get the height, width and number of segments (blobs) in the image. 
  [h w numBlobs] = size(segments);
  adjThreshold   = max(1,floor(adjThreshold * sqrt(h*w)));
  
  % Initialize the adjacency matrix.
  adjacencies = zeros(numBlobs, numBlobs);
  
  % Repeat for each blob in the image.
  for b1 = 1:numBlobs,
    
    % Find the adjacencies for this particular blob. Essentially what
    % we're going to do is translate the segment up, down, left and
    % right and then see if the other segments touch with the translated
    % segment. 
    seg      = segments(:,:,b1);
    transSeg = [seg(:,2:w)  zeros(h,1)]   | ...
	       [zeros(h,1)  seg(:,1:w-1)] | ...
	       [seg(2:h,:); zeros(1,w)]   | ...
	       [zeros(1,w); seg(1:h-1,:)];
    
    % Repeat for all the other blobs.
    for b2 = [1:b1-1 b1+1:numBlobs],
      x = sum(sum(transSeg & segments(:,:,b2))) >= adjThreshold;
      adjacencies(b1,b2) = x;
      adjacencies(b2,b1) = x;
    end;
  end;

  % Calculate the average x,y position for each blob.
  x = zeros(1,numBlobs);
  y = zeros(1,numBlobs);
  for b = 1:numBlobs,
    [h w] = find(segments(:,:,b));
    x(b) = mean(w);
    y(b) = mean(h);
  end;
  
  % Now that we have the adjacencies, let's augment them with spatial
  % information.
  for b1 = 1:numBlobs,
    for b2 = 1:numBlobs,
      if adjacencies(b1,b2),
	xd = abs(x(b1) - x(b2));
	yd = y(b1) - y(b2);
	adjacencies(b1,b2) = 1 * (xd >= abs(yd)) + ...
	    2 * ((xd < abs(yd)) & (yd <= 0)) + ...
	    3 * ((xd < abs(yd)) & (yd >  0));
      end;
    end;
  end;
  
  