% WRITE_BLOB_FEATURES    Write the blob features information to disk.
%    WRITE_BLOB_FEATURES(D,F,BLOBS) writes the struct BLOBS to the file F
%    in the directory D. BLOBS has the following fields:
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
%                        number of blobs in an image
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function write_blob_features (d, f, blobs)

  % Create blob-features file.
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to open file %s for writing', filename));
  end;
    
  % Write out the blob feature names and counts.
  for i = 1:length(blobs.featureNames),
    fprintf(outfile, '%s\n%i\n', blobs.featureNames{i}, ...
	    blobs.featureCounts(i));
  end;
  fprintf(outfile, '\n');
  
  [numFeatures ans ans] = size(blobs.features);
  
  % Repeat for each image.
  for i = 1:length(blobs.images),
    fprintf(outfile, '%s\n%i\n', blobs.images{i}, blobs.counts(i));
    
    % Repeat for each blob in the image.
    for b = 1:blobs.counts(i),
      
      % Repeat for each feature in the blob.
      for f = 1:numFeatures,
	fprintf(outfile, '%0.6g ', blobs.features(f,b,i));
      end;
      fprintf(outfile, '\n');
    end;
    
    % Write a blank line.
    fprintf(outfile, '\n');
  end;  
  
  % Close the file.
  fclose(outfile);
  