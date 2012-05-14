% LAB2RGB    Convert an image's CIE-Lab pixels to RGB.
%    IMG = LAB2RGB(LABIMG) takes a S x 3 image and outputs a
%    matrix of the same dimensions but in RGB space.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science. Based on code by Mark Ruzon.

function img = lab2rgb (labimg)

  % Thresholds
  t1 = 0.008856;
  t2 = 0.206893;  
  
  Tinv = [ 3.240479 -0.969256  0.055648;
	  -1.537150  1.875992 -0.204043;
	  -0.498535  0.041556  1.057311 ];

  L = labimg(:,1);
  a = labimg(:,2);
  b = labimg(:,3);

  % Compute Y
  fY = ((L + 16) / 116) .^ 3;
  YT = fY > t1;
  fY = (~YT) .* (L / 903.3) + YT .* fY;
  Y  = fY;

  % Alter fY slightly for further calculations
  fY = YT .* (fY .^ (1/3)) + (~YT) .* (7.787 .* fY + 16/116);

  % Compute X
  fX = a / 500 + fY;
  XT = fX > t2;
  X = (XT .* (fX .^ 3) + (~XT) .* ((fX - 16/116) / 7.787));
  
  % Compute Z
  fZ = fY - b / 200;
  ZT = fZ > t2;
  Z = (ZT .* (fZ .^ 3) + (~ZT) .* ((fZ - 16/116) / 7.787));
  
  X = X * 0.950456;
  Z = Z * 1.088754;

  img = [X Y Z];
  img = img * Tinv;
  img = round(max(min(img,1),0)*255);