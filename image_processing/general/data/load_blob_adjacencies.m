% LOAD_BLOB_ADJACENCIES    Load the blob adjacency information from disk.
%    ADJACENCIES = LOAD_BLOB_ADJACENCIES(D,F) loads the blob adjacency
%    information from file F in directory D. The return struct
%    ADJACENCIES has the following fields: 
%       - images         M x 1 cell array of image names where M is the
%                        number of images
%       - counts         M x 1 matrix containing the number of blobs for
%                        each image
%       - c              M x 1 cell array of adjacency matrices, where
%                        entry m is an Bm x Bm matrix, where Bm is the
%                        number of blobs in image m.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function adjacencies = load_blob_adjacencies (d, f)

  % Load file for reading
  % ---------------------
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to open file %s for reading', filename));
  end;
    
  % Read in the blob adjacencies in the images
  % ------------------------------------------
  % Repeat for each image.
  numImages = 0;
  while 1,
    
    s = fgetl(infile);
    if ischar(s),
      
      % Get the image name.
      numImages = numImages + 1;
      adjacencies.images{numImages,1} = s;
      
      % Get the number of blobs in the image.
      numBlobs = sscanf(fgetl(infile), '%i');
      adjacencies.counts(numImages,1) = numBlobs;
      
      % Get the adjacencies for each blob.
      adjacencies.c{numImages,1} = zeros(numBlobs, numBlobs);
      for b = 1:numBlobs,
	s = fgetl(infile);
	
	% Repeat for each feature.
	adjacencies.c{numImages,1}(:,b) = sscanf(s,'%f');
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