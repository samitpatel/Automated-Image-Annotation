% LOAD_IMAGE_INDEX   Load the image index from disk.
%    IMG_INDEX = LOAD_IMAGE_INDEX(D,F) loads the image index with file
%    name F from directory D. The IMG_INDEX is returned with the
%    following fields:
%       - imgSuffix     The suffix for the images
%       - imgSubdir     The subdirectory containing the images
%       - segSubdir     The subdirectory containing the segment information
%       - segimgSubdir  The subdirectory containing the segmented images
%       - blobimgSubdir The subdirectory containing the blob images.
%       - images        A N x 1 cell array of the list of images, where N
%                       is the number of images.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function img_index = load_image_index (d, f)

  % Open image index file
  % ---------------------
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to read file %s', filename));
  end;
    
  % Read in image suffix
  % --------------------
  img_index.imgSuffix = fgetl(infile);
  
  % Read in images subdirectory
  % ---------------------------
  img_index.imgSubdir = fgetl(infile);
  
  % Read in segments subdirectory
  % -----------------------------
  img_index.segSubdir = fgetl(infile);
  
  % Read in segmented images subdirectory
  % -------------------------------------
  img_index.segimgSubdir = fgetl(infile);
  
  % Read in blob images subdirectory
  % --------------------------------
  img_index.blobimgSubdir = fgetl(infile);
  
  % Read in list of images
  % ----------------------
  i = 0;
  while 1,
    i = i + 1;
    s = fgetl(infile);
    if ischar(s),
      img_index.images{i,1} = s;
    else, 
      break; 
    end;
  end;
  
  % Close the file.
  fclose(infile);