% WRITE_BLOB_ADJACENCIES   Write the blob adjacency information to disk.
%    WRITE_BLOB_ADJACENCIES(D,F,BLOBS) writes the struct BLOBS to the
%    file F in the directory D. BLOBS has the following fields:
%       - images         M x 1 cell array of image names where M is the
%                        number of images
%       - counts         M x 1 matrix containing the number of blobs for
%                        each image
%       - adjacencies    M x 1 cell array of adjacency matrices, where
%                        entry m is an Bm x Bm matrix, where Bm is the
%                        number of blobs in image m.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function write_blob_adjacencies (d, f, blobs)

  % Create blob-adjacencies file.
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to open file %s for writing', filename));
  end;
    
  [numFeatures ans ans] = size(blobs.features);
  
  % Repeat for each image.
  for i = 1:length(blobs.images),
    fprintf(outfile, '%s\n%i\n', blobs.images{i}, blobs.counts(i));
    
    % Repeat for each blob in the image.
    for b1 = 1:blobs.counts(i),
      for b2 = 1:blobs.counts(i),
	fprintf(outfile, '%i ', blobs.adjacencies{i}(b1,b2));
      end;
      fprintf(outfile, '\n');
    end;
    
    % Write a blank line.
    fprintf(outfile, '\n');
  end;  
  
  % Close the file.
  fclose(outfile);
  