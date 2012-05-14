% COMPUTE_FEATURE_LABSKEW    Return the skewness of the CIE-Lab of the  
%                            image segment. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_labskew (img, nimg, labimg, segment)      
  
  % Calculate the standard deviation of the Lab of the segment.
  
  lastwarn('');
  try
    f = segmentop (segment, @skewness, labimg);
    if length(lastwarn),
      error(lastwarn);
    end;
  catch
    f = zeros(1,3);
  end;