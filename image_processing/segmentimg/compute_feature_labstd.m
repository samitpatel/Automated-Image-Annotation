% COMPUTE_FEATURE_LABSTD    Return the standard deviation of the CIE-Lab
%                           of the image segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_labstd (img, nimg, labimg, segment)      
  
  % Calculate the standard deviation of the Lab of the segment.
  f = segmentop (segment, @std, labimg);

