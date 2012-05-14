% LOAD_SEGMENT_INFO    Loads the original image and segment information.
%    [IMG SEGIMG] = LOAD_SEGMENT_INFO(IMG_FILE, SEGIMG_FILE) loads the
%    original image IMG_FILE and the segmented information from the
%    Matlab file SEGIMG_FILE. The return value IMG is a standard colour 
%    or grayscale image matrix. SEGIMG is a H x W matrix where H is 
%    the height of the image in pixels, W is the width of the image. Each 
%    entry is a value M indicating membership to the Mth segment.
%
%    Note that IMG is cropped to be the same dimensions as the segment
%    information. 
%
%    The segmentation information should be located in the current
%    directory -- this is a bug with the Matlab import software and I
%    couldn't find another way around it.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto (pcarbo@cs.ubc.ca) and Nando
%    de Freitas (nando@cs.ubc.ca), Department of Computer Science. 

function [img, segimg] = load_segment_info (img_file, segimg_file)
  
  % Initialize data.
  img    = [];
  segimg = [];
  
  % Load original image
  % -------------------
  try
    img = double(imread(img_file));
  catch
    img = [];
    return;
  end;

  % Load segmentation info
  % ----------------------
  % Load the segmented image information. Should be located in the
  % current directory.
  segimg = get_image_segments(segimg_file);
  if isempty(segimg),
    return;
  end;
  
  % Crop original image
  % -------------------
  % Crop the original image to make it the same size as the segments
  % information. Note that the margin should be an integer so the
  % difference in sizes should be even, and should be the same for both
  % the height and the width of the images.
  img = crop_image(img, size(segimg));
