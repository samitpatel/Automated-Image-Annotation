% COMPUTE_FEATURE_RGBSKEW    Return the skewness of the RGB
%                            values of the image segment.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function f = compute_feature_rgbskew (img, nimg, labimg, segment)      

  % Calculate the standard deviation of the RGB colour of the segment.  
  
  try
    f = segmentop (segment, @skewness, img);
    if length(lastwarn),
      error(lastwarn);
    end;
  catch
    f = zeros(1,3);
  end;


