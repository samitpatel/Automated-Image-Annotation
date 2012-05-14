% RGB2LAB    Convert an image's RGB pixels to CIE-Lab.
%    LABIMG = RGB2LAB(IMG) takes a S x 3 RGB image and outputs a
%    matrix of the same dimensions but in CIE-Lab space.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function labimg = rgb2lab (img)

  % The RGB to CIE XYZ transform. Y = XT where Y is the matrix in CIE XYZ
  % space, X is the matrix in RGB space and T is the transform
  % matrix. This is based on the algorithm provided by Nan C. Schaller at
  % www.cs.rit.edu/~ncs/color/t_convert.html
  T = [ 0.412453   0.212671   0.019334
        0.357580   0.715160   0.119193
        0.180423   0.072169   0.950227 ];
  
  % Based on D65 standard. See
  % http://vision.stanford.edu/~ruzon/software/rgblab.html for more
  % information. 
  Xn = 0.950456;
  Yn = 1.000000;
  Zn = 1.088754;
  
  % Threshold.
  k = 0.008856;
  
  % Change range of RGB values to [0,1] and compute the CIE XYZ
  % transform. 
  img = (img / 255) * T;  
  X = img(:,1);
  Y = img(:,2);
  Z = img(:,3);
  
  % Compute the CIE La*b* transform. This is based on the algorithm
  % provided by Nan C. Schaller at
  % www.cs.rit.edu/~ncs/color/t_convert.html 
  dXn = X / Xn;
  dYn = Y / Yn;
  dZn = Z / Zn;
  
  L = (dYn >  k) .* (116.0*(dYn.^(1/3)) - 16.0) + ...
      (dYn <= k) .* (903.3 * dYn);

  fXn = (dXn >  k) .* dXn.^(1/3) + ...
	(dXn <= k) .* (7.787*dXn + 16/116);
  fYn = (dYn >  k) .* dYn.^(1/3) + ...
	(dYn <= k) .* (7.787*dYn + 16/116);
  fZn = (dZn >  k) .* dZn.^(1/3) + ...
	(dZn <= k) .* (7.787*dZn + 16/116);
  
  a = 500 * (fXn - fYn);
  b = 200 * (fYn - fZn);
  
  labimg = [L a b];