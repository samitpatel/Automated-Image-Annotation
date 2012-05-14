% LOAD_BLOB_FEATURES    Load the blob features information from disk.
%    BLOBS = LOAD_BLOB_FEATURES(D,F) loads the blob features from file F
%    in directory D. The return struct BLOBS has the following fields:
%       - featureNames   N x 1 cell array where N is the number of
%                        feature names
%       - featureCounts  N x 1 matrix containing the number of dimensions
%                        associated with each feature name
%       - images         M x 1 cell array of image names where M is the
%                        number of images
%       - counts         M x 1 matrix containing the number of blobs for
%                        each image
%       - features       F x B x M matrix where F is the number of
%                        features for each blob and B is the maximum
%                        number of blobs in an image.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function blobs = load_blob_features (d, f)

  % Load file for reading
  % ---------------------
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to open file %s for reading', filename));
  end;
    
  % Read blob feature names and counts
  % ----------------------------------
  numFeatures = 0;
  blobs.featureNames = {};
  blobs.featureCounts = [];
  while 1,
    s = fgetl(infile);
    if ischar(s) & length(s),
      numFeatures = numFeatures + 1;
      blobs.featureNames{numFeatures,1} = s;
      blobs.featureCounts = [blobs.featureCounts; ...
		             sscanf(fgetl(infile),'%i')];
    else,
      break;
    end;
  end;
  
  % Read in the feature sets for the blobs in the images
  % ----------------------------------------------------
  % Repeat for each image.
  numImages = 0;
  while 1,
    
    s = fgetl(infile);
    if ischar(s),
      
      % Get the image name.
      numImages = numImages + 1;
      blobs.images{numImages,1} = s;
      
      % Get the number of blobs in the image.
      blobs.counts(numImages,1) = sscanf(fgetl(infile), '%i');
      
      % Get the features for each blob.
      for b = 1:blobs.counts(numImages),
	s = fgetl(infile);
	
	% Repeat for each feature.
	blobs.features(:,b,numImages) = sscanf(s,'%f');
      end;
      
      % Get the blank line.
      s = fgetl(infile);
      
    else,
      % There are no more images to look at.
      break;
    end;      
  end;
  
  % Close the file.
  fclose(infile);