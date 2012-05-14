% WRITE_IMAGE_INDEX    Write the image index to disk.
%    WRITE_IMAGE_INDEX(D,F,IMG_INDEX) writes the image index F in
%    directory D using the information IMG_INDEX. IMG_INDEX is a struct
%    with the following fields:
%       - imgSuffix     The suffix for the images
%       - imgSubdir     The subdirectory containing the images
%       - segSubdir     The subdirectory containing the segment information
%       - segimgSubdir  The subdirectory containing the segmented images
%       - blobimg       The subdirectory containing the blob images.
%       - images        A N x 1 cell array of the list of images, where N
%                       is the number of images.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function write_image_index (d, f, img_index)

  % Create image index file.
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to open file %s for writing', filename));
  end;
    
  % Write out the image suffix.
  fprintf(outfile, '%s\n', img_index.imgSuffix);
  
  % Write out the images subdirectory.
  fprintf(outfile, '%s\n', img_index.imgSubdir);
  
  % Write out the segments subdirectory.
  fprintf(outfile, '%s\n', img_index.segSubdir);
  
  % Write out the segmented images subdirectory.
  fprintf(outfile, '%s\n', img_index.segimgSubdir);
  
  % Write out the blob images subdirectory.
  fprintf(outfile, '%s\n', img_index.blobimgSubdir);
  
  % Write out the list of images.
  for i = 1:length(img_index.images),
    fprintf(outfile, '%s\n', img_index.images{i});
  end;
  
  % Close the file.
  fclose(outfile);