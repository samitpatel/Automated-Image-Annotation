% CALCULATE_FEATURES   Calculate an image blob's features.
%    FEATURES = CALCULATE_FEATURES(IMG,NIMG,LABIMG,SEGMENT,WHICHFEATURES, 
%    FEATURETABLE) returns a 1 x N of feature values where N is the 
%    number of features. IMG is the original RGB image, NIMG is the
%    normalized image, LABIMG is the CIE-Lab image and SEGMENT is a 0/1
%    matrix where 1 indicates that the pixel is a member of the
%    blob. WHICHFEATURES is a cell array containing the feature names to
%    compute. If this is an empty cell array, it will calculate all the
%    features. FEATURETABLE is the struct obtained from the function
%    LOAD_FEATURE_TABLE. For more information on this parameter, see the
%    help for this function.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function features = calculate_features (img, nimg, labimg, segment, ...
					whichFeatures, featureTable)
  
  % Figure out which features we're going to grab.
  if ~length(whichFeatures),
    % Use all the features.
    whichFeatures = [1:featureTable.num];
  end;
  
  % For each feature selected, generate that feature.
  numFeatures = length(whichFeatures);
  features = [];
  for i = 1:numFeatures,
    f = feval(featureTable.functions{whichFeatures(i)}, img, nimg, ...
	      labimg, segment);
    features = [features f];
  end;
  clear f
  