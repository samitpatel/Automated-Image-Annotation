% SEGMENT_IMAGES    Segment images using Normalized Cuts.
%    [BLOBCOUNTS,BLOBFEATURES,ADJACENCIES] =
%    SEGMENT_IMAGES(IMG_DIR,FEATURE_TABLE,WHICH_FEATURES,
%    PATCH_TYPE,PATCH_SIZE,NCUTS,PARAMS_FILE,CROPPED_PIXELS,
%    KEEP_SEGMENTS,SEG_DIR,SEGIMG_DIR,BLOBIMG_DIR,IMG_SUFFIX,IMG_LIST)
%    segments the images located in the directory IMG_DIR. IMG_DIR is the
%    main directory where the data is located and FEATURE_TABLE is a
%    struct containing the feature information used by the function. For
%    more information on this parameter, see the function
%    LOAD_FEATURE_TABLE. The remaining parameters are described below.
%
%    The return value BLOBCOUNTS is a N x 1 vector containing the number
%    of blobs for each image, where N is the number of images. 
%    BLOBFEATURES is an F x B x N vector where F is the number of 
%    features and B is the maximum number of blobs in a document. 
%    ADJACENCIES is a N x 1 cell array and each entry is a Bn x Bn is
%    matrix, where Bn is the number of blobs in image n. This matrix
%    contains entries (i,j) with the following values: 
% 
%      0 = i and j are not adjacent
%      1 = i and j are next to each other
%      2 = i is below j
%      3 = i is above j
%
%    In addition to the regular output, this function also saves a
%    considerable amount of data to disk as specified by the
%    parameters. Under normal circumstances (i.e. default values for the
%    parameters), SEGMENT_IMAGES will produce the following files for
%    each image:
%       - The segmentation information produced by NCuts in the form of a
%         Matlab data file. Located in the directory SEG_DIR.
%       - The segmentation information with the segment boundaries
%         removed. Also located in SEG_DIR. This is the same as the
%         previous file, except that the entries which do not belong to
%         any segment are -1.
%       - A segmented image saved in the directory SEGIMG_DIR. The
%         image is in JPEG format. 
%       - Another segmented image, only this time each segment only shows
%         the RGB colour averaged over all the pixels contained in the
%         segment. This image is located in the BLOBIMG_DIR. We refer to
%         it as the "blob image".
%
%    The optional parameters are:
%      - WHICH_FEATURES   A vector of feature indices. By default, this is
%                         an empty list which means that all features
%                         will be calculated for each blob.
%
%      - PATCH_TYPE       The type of patches to make. There are three
%                         possible values for this parameter: "ncuts",
%                         which uses the Normalized Cuts segmentation
%                         information to make the patches; "grid", which
%                         creates a uniform patch grid of specified size;
%                         and "grid+ncuts", which creates a uniform
%                         square patch grid but tweaks the square patches
%                         by taking into account the segmentation 
%                         information. The default is "ncuts".
%
%      - PATCH_SIZE       This parameter is only applicable if the
%                         PATCH_TYPE is set to "grid" or
%                         "grid+ncuts". Otherwise, you can ignore 
%                         this. This is a number specifying the
%                         approximate size of a patch (both the height
%                         and width are always the same). The default is
%                         32. Note that the height and width may be
%                         tweaked slightly to compensate for the size of
%                         the image.
%
%      - NCUTS            The pathname of the Normalized Cuts
%                         program. Note that the pathname should be
%                         specified in absolute terms. This option is not
%                         applicable if the PATCH_TYPE is set to "grid"
%                         or the function does not need to regenerate the
%                         NCuts segmentations because KEEP_SEGMENTS is
%                         set to 1 and all the segmentation information
%                         has been previously generated. The default
%                         pathname is '/bin/ncuts'.
%
%      - PARAMS_FILE      The name of the parameter file used by
%                         Normalized Cuts. It should be located in the
%                         directory IMG_DIR.
%
%      - CROPPED_PIXELS   This is only necessary if the BLOB_TYPE is
%                         set to "grid". Otherwise, the pixel cropping
%                         information is gathered from the Normalized
%                         Cuts segmentations. This sets a border to be
%                         ignored around the image. The default is 0.
%
%      - KEEP_SEGMENTS    This is only applicable if PATCH_TYPE is set to
%                         "ncuts" or "ncuts+grid". If KEEP_SEGMENTS is
%                         set to 1, check to see if the previous
%                         segmentations have been stored in the
%                         SEG_SUBDIR directory. This may happen when
%                         this function has been run previously, but the
%                         image index has been deleted. If so, don't run
%                         NCuts.) By default, KEEP_SEGMENTS is set to 1. 
%
%      - SEG_DIR          The directory where the segment Matlab files
%                         will be stored. The default is
%                         IMG_DIR/segments. 
%
%      - SEGIMG_DIR       The directory where the segmented images
%                         will be stored. The default is
%                         IMG_DIR/segimages.
%
%      - BLOBIMG_DIR      The directory where the "blob images" will be
%                         stored. These are images that show the
%                         segmentations and the averaged colours. The
%                         default is 'blobimages'. The default is
%                         IMG_DIR/blobimages. 
%
%      - IMG_SUFFIX       The suffix of the images. By default it is
%                         ".jpg". 
%
%      - IMG_LIST         If IMG_LIST is left unspecified or if it is a
%                         cell array of size zero, then the function will
%                         automatically find a list of all the images in
%                         the IMG_DIR directory with the proper suffix. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function [blobCounts, blobFeatures, adjacencies] = ...
      segment_images (img_dir, feature_table, varargin)
  
  % Notes:
  %   - The words "patch", "blob" and "segment" are all pretty much
  %     synonymous. 

  % Function constants.
  numReqdArgs          = 2;
  boundaryWidth        = 2;
  segmentsWEdgesSuffix = '_edges';
  segmentsOrigSuffix   = '_orig';
  normLuminance        = 76.1895;
  
  % Default function arguments.
  defargs = { [];                   % Which features to use
	      'ncuts';              % Patch type
	      32;                   % Patch size
	      '/bin/ncuts';         % Pathname for Normalized Cuts
	      'ncuts.txt';          % Parameter file for Normalized Cuts
	      0;                    % Number of pixels to crop
	      1;                    % Whether to keep the segments or not
	      [img_dir '/segments'];   % Segment subdirectory
	      [img_dir '/segimages'];  % Segmented image subdirectory
	      [img_dir '/blobimages']; % Blob image subdirectory
	      '.jpg';               % Image suffix
	      [] };                 % List of which images to process
                                    % (the default is all) 
  
  try 
    
    % Set up function parameters
    % --------------------------
    % Check to make sure there's enough arguments to run the function.
    if nargin < numReqdArgs,
      error('Not enough input arguments for function. See help for details');
    end;

    % Set up the optional arguments.
    [ whichFeatures, patchType, patchSize, ncuts, ncutsParamsFile, ...
      croppedPixels, keepSegments, segDir, segimgDir, blobimgDir, ...
      imgSuffix, imgList ] = ...
	manage_vargs(varargin, defargs);
    clear nargin varargin defargs
    
    % Get list of images to process
    % -----------------------------
    % If "imgList" is not specified, we have to get a list of the images
    % from the "img_dir" directory.
    if ~length(imgList),
      imgList = get_file_list(img_dir, imgSuffix);
      if ~length(imgList),
	error(['No images to process. This is either because you ' ...
	       'already processed all the images, as indicated in ' ...
	       '"image_index", or because the directory ' mainDir ...
	       ' does not exist.']);
      end;
    end;
    
    % Get list of feature indices to process
    % --------------------------------------
    % Manage the list of features.
    if ~length(whichFeatures),
      whichFeatures = [1:feature_table.num];
    end;
    
    % Print out current progress.
    fprintf('Segment images:\n');
    fprintf('-------------- \n');
    fprintf('Patch type:                %s\n', patchType);
    fprintf('Feature table:             %s\n', feature_table.file);
    fprintf('Segment info directory:    %s\n', segDir);
    fprintf('Segmented image directory: %s\n', segimgDir);
    fprintf('Blob image directory:      %s\n\n', blobimgDir);
    fprintf('Feature set:\n');
    for i = 1:length(whichFeatures),
      fprintf('  %s (%i)\n', feature_table.names{whichFeatures(i)}, ...
	      feature_table.counts(whichFeatures(i)));
    end;
    numImages = length(imgList);
    fprintf('\nWe will segment the following images: \n');
    for i = 1:numImages,
      fprintf('  %s \n', imgList{i});
    end;
    fprintf('\n');
    
    % Initialise patch information.
    blobCounts    = zeros(numImages,1);
    blobFeatures  = zeros(0,0,numImages);
    featureCounts = zeros(numImages,1);
    adjacencies   = cell(numImages,1);
    
    % Patch types:
    %   1  ncuts
    %   2  grid
    %   3  grid+ncuts
    if strcmp(patchType,'ncuts'),
      patchType = 1;
    elseif strcmp(patchType,'grid'),
      patchType = 2;
    else,
      patchType = 3;
    end;
    
    % Segment images and save information to disk
    % -------------------------------------------
    % Repeat for each image.
    for i = 1:numImages,
      
      % Get the image pathname.
      imgName     = imgList{i};
      imgPathname = [img_dir '/' imgName imgSuffix];
      fprintf('- Segmenting image "%s".\n', imgName);
      
      % Run NCuts, locate previous segmentation data or create patches
      % --------------------------------------------------------------
      if patchType == 1,
	% Create the NCuts segmentation and load it.
	[img segimg] = ...
	    createNCutsSegmentation(ncuts, ncutsParamsFile, imgName, ...
				    imgPathname, segmentsOrigSuffix, ...
				    segDir, keepSegments);
	
      elseif patchType == 2,
	fprintf(['  1.) Skipping NCuts run because we don''t need the' ...
		 ' segmentation information. \n']);
	
	% Load the image.
	img = double(imread([img_dir '/' imgName imgSuffix]));
	if isempty(img),
	  error(fprintf(['Unable to load image %s. \n'], imgName));
	end;
	
	% Crop the image.
	img = crop_image(img, size(img)-croppedPixels*2);
	
	% Create the patches.
	[segimg ans] = make_patches(size(img), patchSize); 
	
      else,
	% Create the NCuts segmentation and load it.
	[img segimg] = ...
	    createNCutsSegmentation(ncuts, ncutsParamsFile, imgName, ...
				    imgPathname, segmentsOrigSuffix, ...
				    segDir, keepSegments, img_dir);
	
	% Create the patches.
	[patchimg patchadj] = make_patches(size(img), patchSize); 
	segimg = make_patches_with_segs(patchimg, segimg, patchadj);
		
	clear patchimg patchadj
      end; 
      
      % Create the adjacencies
      % ----------------------
      adjacencies{i} = calculate_adjacencies(segimg);

      % Save the segments matrix to disk
      % --------------------------------
      segimg_t = segimg - 1;
      save([imgName '.mat'], 'segimg_t');
      clear segimg_t
      
      % Create segmented image
      % ----------------------
      fprintf('  2.) Creating the segmented image. \n');
      edgesimg = make_segimage(img, segimg, boundaryWidth);
      
      % Create averaged segmented image
      % -------------------------------
      fprintf('  3.) Creating the averaged colour segmented image. \n');
      edgesavgimg = make_segimage(make_avgimage(img, segimg), ...
				  segimg, boundaryWidth);
      
      % Create and save segments width edges removed
      % --------------------------------------------
      % Create the segments with the edges removed from them.
      fprintf('  4.) Creating segments with edges. \n');
      edges = make_edges(segimg, boundaryWidth);
      segimgWEdges = (~edges) .* segimg - 1;
      clear edges
     
      % Save these "edge segments" to disk.
      fprintf('  5.) Saving segments with edges to disk. \n');
      save([imgName segmentsWEdgesSuffix], 'segimgWEdges');
      
      % Save images to disk
      % -------------------
      % Save the newly created images to disk.
      fprintf('  6.) Saving images to disk. \n');
      imwrite_(segimgDir, [imgName imgSuffix], edgesimg);
      imwrite_(blobimgDir, [imgName imgSuffix], edgesavgimg);

      % Move the Matlab files
      % ---------------------
      fprintf('  7.) Moving generated Matlab files. \n');
      f1 = [imgName '.mat'];
      f2 = [imgName segmentsWEdgesSuffix '.mat'];
      f3 = ['m_' imgName '_seg.mat'];
      f4 = [imgName segmentsOrigSuffix '.mat'];
      if length(segDir),
	err1 = system(['mv ' f1 ' ' segDir '/' f1]);
	err2 = system(['mv ' f2 ' ' segDir '/' f2]);
	if patchType ~= 2,
	  err3 = system(['mv ' f3 ' ' segDir '/' f4]);
	else,
	  err3 = 0;
	end;
        if err1 | err2 | err3, % Error checking.
	  error('Cannot move generated Matlab segment files.');
        end;
      else,
	try 
	  system(['rm -f ' f1]); 
	  system(['rm -f ' f2]);
	  system(['rm -f ' f3]);
	end;
      end;    
      clear f1 f2 f3 err1 err2 err3
      
      % Normalize the image
      % -------------------
      % We can consider "img" to be the unnormalized RGB image. We will
      % also compute "labimg", the CIE-Lab image, and "nimg", the RGB
      % image normalized over luminance.
      [h w ans] = size(img);
      labimg    = rgb2lab(reshape(img, [h*w 3]));
      nimg      = labimg;
      nimg(:,1) = normLuminance;
      nimg      = reshape(lab2rgb(nimg), [h w 3]);
      labimg    = reshape(labimg, [h w 3]);
      
      % Calculate blob features
      % -----------------------
      % Add information to blobs. First figure out how many blobs there
      % are, then calculate the features for each blob.
      fprintf('  8.) Calculating blob features. \n');
      segments = find_segments(segimg);
      numBlobs = size(segments,3);
      blobCounts(i) = numBlobs;
      for b = 1:numBlobs,   
	f = calculate_features(img, nimg, labimg, segments(:,:,b), ...
			       whichFeatures, feature_table);
        blobFeatures(1:length(f),b,i) = f';
      end;
      
    end; %for .. numImages
    
  catch
    error(lasterr);
  end; %try/catch
  
% ---------------------------------------------------------------
  
function imwrite_ (dir, file, img)
  
  oldpwd = pwd;
  cd(dir);
  imwrite(uint8(img), file, 'jpeg');
  cd(oldpwd);

% ---------------------------------------------------------------
function [img, segimg] = ...
      createNCutsSegmentation (ncuts, paramsFile, imgName, ...
			       imgPathname, segmentsOrigSuffix, ...
			       segDir, keepSegments)
  
  % It should create a Matlab file located in the working
  % directory. Note that if we want to keep the data from the old run
  % of NCuts, check in the segments directory to see if the Matlab
  % data is still there.
  f1 = [imgName segmentsOrigSuffix '.mat'];
  f2 = ['m_' imgName '_seg.mat'];
  
  % Check to see if the NCuts segmentation already exists and we want to
  % keep it.
  [err output] = system(['ls ' segDir '/' f1]);
  if keepSegments & ~err,
    
    % We want to copy the "original segmentation" file.
    fprintf(['  1.) Locating image segmentation data from ' ...
		   'previous NCuts ouput. \n']);
    err = system(['cp -f ' segDir '/' f1 ' ' f2]);
    if err, % Error checking.
      error('Cannot copy previously generated Matlab segment file.');
    end;
  
  else,
	
    % Run NCuts.
    fprintf('  1.) Running the program NCuts. \n');
    [err output] = system([ncuts ' ' imgPathname ' ' paramsFile]);
    if err, % Error checking.
      error(['Unable to run Normalized Cuts for image ' imgPathname ...
	     ' using parameter file ' paramsFile '.']);
    end;
  end;
  
  % Load the segmentation information.
  [img segimg] = ...
      load_segment_info(imgPathname, ['m_' imgName '_seg.mat']);
  if isempty(img) | isempty(segimg),
    error(fprintf(['Unable to load segment information for ' ... 
		   'image %s. \n'], imgName));
  end;
