% CROP_IMAGE    Reduce the dimensions of the image.
%    IMG  = CROP_IMAGE(IMG,S) cuts off the margins of IMG using the
%    desired dimensions S = [H W].
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function img = crop_image (img, s);

  % Crop the original image to make it the same size as the segments
  % information. Note that the margin should be an integer so the
  % difference in sizes should be even, and should be the same for both
  % the height and the width of the images.
  h = s(1);
  w = s(2);
  [ho wo ans] = size(img);
  marginSize  = (ho - h) / 2;
  img = img(1+marginSize:ho-marginSize, 1+marginSize:wo-marginSize, :);

