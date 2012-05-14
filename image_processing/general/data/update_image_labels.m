% UPDATE_IMAGE_LABELS    Update or initialize image labels struct.
%    IMAGE_LABELS = UPDATE_IMAGE_LABELS(BLOB_FEATURES) creates a new
%    image labels struct given the information from BLOB_FEATURES. For
%    more information on this parameter, see
%    /GENERAL/DATA/LOAD_BLOB_FEATURES. 
%
%    IMAGE_LABELS = UPDATE_IMAGE_LABELS(BLOB_FEATURES,IMAGE_LABELS)
%    updates the information in IMAGE_LABELS to take into account the
%    images listed in BLOB_FEATURES. For more information on
%    IMAGE_LABELS, see /GENERAL/DATA/LOAD_IMAGE_LABELS.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function image_labels = update_image_labels (blob_features, varargin)

  % Set up function parameters
  % --------------------------
  defargs = { struct([]) };
  [old_image_labels] = manage_vargs(varargin, defargs);
  clear varargin defargs
  
  % Get information from image index.
  image_labels.images = blob_features.images;
  numImages = length(image_labels.images);

  % Initialize new image labels struct
  % ----------------------------------
  % Create an empty set of labels.
  image_labels.imageWords    = cell(numImages,0);
  image_labels.blobWords     = cell(numImages,0,0);
  image_labels.wordCounts    = zeros(numImages,1);
  image_labels.correspCounts = zeros(numImages,0);
  
  % Fill in new image labels with info from old image labels
  % --------------------------------------------------------
  % Check to see if we have been given any information from the previous
  % labels. If not, we fill in the image_labels with empty fields.
  if length(old_image_labels),
    
    [ans maxNumBlobs] = size(old_image_labels.correspCounts);
    numOldImages = length(old_image_labels.images);
    for i = 1:numOldImages,
      
      % Check to see if it is in the current labels.
      j = find(strcmp(image_labels.images, old_image_labels.images{i}));
      if j,
	
	% Assign the labels and correspondences to that image.
	for w = 1:old_image_labels.wordCounts(i),
	  image_labels.imageWords{j,w} = old_image_labels.imageWords{i,w};
	end;
	image_labels.wordCounts(j,1) = old_image_labels.wordCounts(i);
	
	% Repeat for each blob.
	for b = 1:maxNumBlobs,
	  % Repeat for each word for that blob.
	  for w = 1:old_image_labels.correspCounts(i,b),
	    image_labels.blobWords{j,b,w} = ...
		old_image_labels.blobWords{i,b,w};
	  end;
	  image_labels.correspCounts(j,b) = ...
	      old_image_labels.correspCounts(i,b);
	end;
      end;
    end; %for..numOldImages
  end; %if..length(old_image_labels);
  
  % Adjust correspondence counts
  % ----------------------------
  % Fill up the correspondence counts so that it maches the maximum
  % number of blobs in an image.
  image_labels.correspCounts = ...
      [image_labels.correspCounts ...
       zeros(numImages, size(blob_features.features,2) - ...
	     size(image_labels.correspCounts,2))];
