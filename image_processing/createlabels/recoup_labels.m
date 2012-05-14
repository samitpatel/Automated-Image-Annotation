% RECOUP_LABELS    Converts the labels from one segmentation to another.
%    Say, for instance, you have the situation where you have labeled the
%    images of a data set but then you want to re-segment the images
%    using a (possibly) different method. Rather than throw out the old
%    segmentations, you can furnish approximate labelings for the images
%    using RECOUP_LABELS(DATA_DIR, OLDSEG_DIR, SEGTHRESH). DATA_DIR is
%    the directory that contains your set of images. OLDSEG_DIR is the
%    directory containing the previous segmentation data (usually, this
%    is DATA_DIR/segments). SEGTHRESH defines the number of pixels
%    required in the intersection of the old and new blob to add that
%    word to the blob annotation. Note that the file "labels" must exist
%    in DATA_DIR, and will be replaced by a new version upon termination
%    of this routine.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function recoup_labels (data_dir, oldseg_dir, segThresh)  

  % Function constants.
  generalPath         = '../general';  
  imageIndexFileName  = 'image_index';
  blobsFileName       = 'blob_features';  
  imageLabelsFileName = 'labels';  
  
  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs

  % Load set image information
  % --------------------------
  try
    % Load the image index from the data directory.
    imgIndex = load_image_index(data_dir, imageIndexFileName);
    
  catch
    disp(lasterr);
    return;
  end;

  % Load the old image labels
  % -------------------------
  try
    labels = load_image_labels(data_dir, imageLabelsFileName);
  catch
    % If we've hit this point, that means that we were unsuccessful in
    % loading the image labels file. Report an error and quit.
    disp(lasterr);
    return;
  end;  
  
  % Initialize the new image labels.
  newLabels.images        = labels.images;
  newLabels.wordCounts    = labels.wordCounts;
  newLabels.imageWords    = labels.imageWords;
  
  % Repeat for each image.
  numImages = length(imgIndex.images);
  segDir    = [data_dir '/' imgIndex.segSubdir];
  for i = 1:numImages,
    
    % Get the image name.
    imgName = imgIndex.images{i};
    fprintf('Processing image "%s". \n', imgName);
    
    % Load the old segmentation information.
    fn = [oldseg_dir '/' imgName '.mat'];
    [oldSeg ans] = get_image_segments(fn);
    oldS         = size(oldSeg,3);
    
    % Load the new segmentation information.
    fn = [segDir '/' imgName '.mat'];
    [newSeg ans] = get_image_segments(fn);
    newS         = size(newSeg,3);

    % Initialize the correspondence counts information for that image. 
    newLabels.correspCounts(i,1:newS) = 0;
    
    % Repeat for each new segment.
    for s = 1:newS,
      sic = find(sum(sum(oldSeg & repmat(newSeg(:,:,s), [1 1 oldS]),1),2) ...
	    >= segThresh);
      
      % Repeat for each segment we found that's within our new segment. 
      for t = sic',
	if t <= size(labels.correspCounts,2),
	  for w = 1:labels.correspCounts(i,t),
	    % Check to see if this word is already in the new
	    % correspondence. If not, add it.
	    wrd = labels.blobWords{i,t,w};
	    if ~newLabels.correspCounts(i,s) | ...
		  ~length(find(strcmp(newLabels.blobWords(i,s,:),wrd))),
	      newLabels.correspCounts(i,s) = ...
		  newLabels.correspCounts(i,s) + 1;
	      newLabels.blobWords{i,s,newLabels.correspCounts(i,s)} = wrd;
	    end;
	  end;
	end;
      end;
    end;
  end;

  % Save the newly created labels to disk.
  write_image_labels(data_dir, imageLabelsFileName, newLabels);
  
  % Restore the old path.
  path(oldPath);
