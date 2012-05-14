% COMPUTE_FEATURE_LABAVG    Return the average CIE-Lab of the image
%                           segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_labavg (img, nimg, labimg, segment)      
  
  % Calculate the average Lab of the segment.  
  f = segmentop(segment, @mean, labimg);
