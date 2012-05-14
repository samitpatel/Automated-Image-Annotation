% GET_IMAGE_SEGMENTS    Get the segments from disk.
%    SEGIMG = GET_IMAGE_SEGMENTS(FILE) returns an H x W matrix where H
%    is the height of the image, W is the width of the image and each
%    entry is a value M indicating membership to the Mth segment.
%
%    The segmentation FILE should be located in the current directory. It
%    is a bug.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function segimg = get_image_segments (file)
  
  % Initialize the data.
  segimg = [];
  
  % Load the segmentation
  % ---------------------
  % Load the segmented image information. Should be located in the
  % current directory.
  try
    segimg = importdata(file);
  catch
    return;
  end;
  
  segimg = segimg + 1;
