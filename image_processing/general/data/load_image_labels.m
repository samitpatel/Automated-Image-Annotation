% LOAD_IMAGE_LABELS    Load the image labels information from disk.
%    IMAGE_LABELS = LOAD_IMAGE_LABELS(D,F) grabs information from the
%    file F in the directory D. The return value IMAGE_LABELS is a struct
%    with the following fields:
%       - images        N x 1 cell array of names of images where N is
%                       the number of images. 
%       - imageWords    N x W cell array of words (i.e. labels) where W
%                       is the maximum size of an image label.
%       - wordCounts    N x 1 vector listing the size of each image
%                       label. 
%       - blobWords     N x B x WB cell array of words
%                       (i.e. correspondences) where B is the
%                       maximum number of blobs in an image and WB is the
%                       maximum number of words associated with a single
%                       blob. 
%       - correspCounts N x B matrix of word counts, one for each blob.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function image_labels = load_image_labels (d, f)

  % Load the image index file.
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to open file %s for reading', filename));
  end;

  % Get the maximum number of blobs.
  maxNumBlobs = str2num(fgetl(infile));
  
  % Initialize struct entries
  % -------------------------
  labels.images        = {};
  labels.imageWords    = cell(0,0);
  labels.wordCounts    = [];
  labels.blobWords     = cell(0,maxNumBlobs,0);
  labels.correspCounts = zeros(0,maxNumBlobs);
  
  % Repeat for each image.
  i = 0;
  while 1,
    
    s = fgetl(infile);
    if ischar(s),
      
      % Get image name
      % --------------
      i = i + 1;
      image_labels.images{i,1} = s;
      
      % Get image label
      % ---------------
      s = fgetl(infile);
      wrds = parse_string(s);
      image_labels.wordCounts(i,1) = length(wrds);
      for w = 1:image_labels.wordCounts(i),
        image_labels.imageWords{i,w} = wrds{w};
      end;
      
      % Get blob correspondences
      % ------------------------
      % Initialize the correspondence counts for that image.
      image_labels.correspCounts(i,:) = 0;
      
      % Get the correspondences between the blobs and words.
      while 1,
	s = fgetl(infile);
	if ischar(s) & length(s),
	  
	  % We haven't reached the end of the image, so let's figure out
          % what words are associated with this blob. The first element
          % of "wrds" is the number of the blob.
	  wrds = parse_string(s);
	  b = str2num(wrds{1});
	  image_labels.correspCounts(i,b) = length(wrds) - 1;
	  for w = 1:image_labels.correspCounts(i,b),
	    image_labels.blobWords{i,b,w} = wrds{w+1};
	  end;
	else,
	  
	  % We've reached the end of the correspondences, so go to the
          % next image.  
	  break;
	end;
      end;
      
    else,
      break;
    end; %if ischar(s)
    
  end; %for..each image.
  
  % Close the file.
  fclose(infile);  