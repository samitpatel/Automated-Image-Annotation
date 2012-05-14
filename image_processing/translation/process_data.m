% PROCESS_DATA    Do some general processing of the data for
%                 image translation. 
%    DATA = PROCESS_DATA(DATA, BLOBSMEAN, BLOBSSTD, BLOBAREATHRESH,
%    MAXNUMBLOBS, FEATURESEL) returns the modified data. BLOBSMEAN and
%    BLOBSSTD are two F x 1 matrices used to normalize the data, where F
%    is the number of features. For information on parameters
%    BLOBAREATHRESH, MAXNUMBLOBS and FEATURESEL see
%    /GENERAL/DATA/LOAD_MODEL_PARAMS. DATA is obtained from
%    /GENERAL/DATA/LOAD_DATA. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function data = process_data (data, blobsMean, blobsStd, ...
			      blobAreaThresh, maxNumBlobs, featureSel)

  % Function constants.
  noFeatureSel     = 'all';
  noBlobAreaThresh = 'none';
  noMaxNumBlobs    = 'all';
  areaFeatureName  = 'area';

  % Prune small blobs
  % -----------------
  % First, prune the blobs that are too small. This operation can only be
  % performed if we have the feature "area". If we don't have this
  % feature, we report an error.
  if ~strcmp(blobAreaThresh, noBlobAreaThresh) & blobAreaThresh > 0,
    
    % First locate the "area" feature.
    found = 0;
    for f = 1:length(data.featureNames),
      if strcmp(areaFeatureName, data.featureNames{f}),
	found = 1;
	break;
      end;
    end;
    
    if ~found,
      error(['Cannot do thresholding of blobs by area because the "area"' ...
	     ' feature was not computed in the feature set.']);
    end;
    
    % Repeat for each image, and then for each blob in the image.
    for i = 1:data.numImages,
      blobsToKeep = ...
	  find(data.imageBlobs(f,1:data.imageBlobCounts(i),i) ...
	       >= blobAreaThresh);
      
      % Remove the selected blobs.
      if length(blobsToKeep) < data.imageBlobCounts(i),
	data = removeBlobs(data, i, blobsToKeep);
      end;
    
      % Reduce the size of the matrix.
      data.imageBlobs = data.imageBlobs(:,1:max(data.imageBlobCounts),:);
    end;
  end;
  
  % Prune too many blobs
  % --------------------
  if ~strcmp(noMaxNumBlobs, maxNumBlobs),
    data.imageBlobCounts = min(data.imageBlobCounts, maxNumBlobs);
    data.imageBlobs = ...
	data.imageBlobs(:,1:min(maxNumBlobs,size(data.imageBlobs,2)),:);
    for i = 1:data.numImages,
      m = min(data.imageBlobCounts(i), maxNumBlobs);
      data.adjacencies{i} = data.adjacencies{i}(1:m,1:m);
    end;
  end;
  
  % Prune features
  % --------------
  % Lastly, select only the features deemed useful for training (unless
  % the user has chosen "all" features).
  if ~strcmp(featureSel, 'all'),
    data.imageBlobs = data.imageBlobs(featureSel,:,:);
    blobsMean       = blobsMean(featureSel);
    blobsStd        = blobsStd(featureSel);
  end;

  % Normalize blobs
  % ---------------
  data.imageBlobs = normalize_blobs(data.imageBlobs, data.imageBlobCounts, ...
				    blobsMean, blobsStd);

% ---------------------------------------------------------------------
function data = removeBlobs (data, img, blobsToKeep)
  
  % Update imageBlobs and imageBlobCounts.
  data.imageBlobs(:,1:length(blobsToKeep)) = ...
      data.imageBlobs(:,blobsToKeep,img);
  data.imageBlobs(:,length(blobsToKeep)+1:data.imageBlobCounts(img),img) = 0; 
  data.imageBlobCounts(img) = length(blobsToKeep);
  
  % Update adjacencies.
  data.adjacencies{img} = data.adjacencies{img}(blobsToKeep,blobsToKeep);

  