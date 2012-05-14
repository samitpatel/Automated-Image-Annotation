% CREATE_SEGMENT_DATA    Process the images to create segment info. 
%    ERR = CREATE_SEGMENT_DATA(IMG_DIR,OPTIONS) processes and segments
%    the images located in directory IMG_DIR. Note that to avoid
%    problems, all pathnames and directories (but not subdirectories)
%    should be specified as absolute values; Matlab often has trouble
%    resolving relative pathnames. It creates three main data files,
%    "image_index", "blob_features" and "adjacencies", saving them in the
%    directory IMG_DIR. 
%
%    It also creates some other files. It stores the files "NAME.mat",
%    "NAME_edges.mat" and "NAME_orig.mat" in the subdirectory specified by
%    the option SEG_SUBDIR, which are Matlab data files containing
%    respectively the patches, the patches taking into account edges
%    (this is only used for display) and the Ncuts segments. Note that
%    NAME is the name of the image, excluding the suffix. The
%    subdirectory SEGIMG_SUBDIR contains images showing the edges between
%    the patches, again for display only. BLOBIMG_SUBDIR contains images
%    showing the edges between patches and the patches with averaged
%    colour. 
%
%    This function returns 1 if the process was not completed
%    successfully, otherwise it returns 0.
%
%    OPTIONS is a cell array with the entries {PATCH_TYPE,PATCH_SIZE,
%    CROPPED_PIXELS,NCUTS,KEEP_SEGMENTS,WHICHFEATURES,IMG_SUBDIR,
%    SEG_SUBDIR,SEGIMG_SUBDIR,BLOBIMG_SUBDIR,IMG_SUFFIX,IMAGES}. The
%    optional parameters, in order, are: 
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
%      - CROPPED_PIXELS   This is only necessary if the BLOB_TYPE is
%                         set to "grid". Otherwise, the pixel cropping
%                         information is gathered from the Normalized
%                         Cuts segmentations. This sets a border to be
%                         ignored around the image. The default is 0.
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
%      - KEEP_SEGMENTS    This is only applicable if PATCH_TYPE is set to
%                         "ncuts" or "ncuts+grid". If KEEP_SEGMENTS is
%                         set to 1, check to see if the previous
%                         segmentations have been stored in the
%                         SEG_SUBDIR directory. This may happen when
%                         this function has been run previously, but the
%                         image index has been deleted. If so, don't run
%                         NCuts.) By default, KEEP_SEGMENTS is set to 1. 
% 
%      - WHICHFEATURES    The features to extract for each
%                         blob. WHICHFEATURES can either be a cell array
%                         of feature names to process (as denoted by
%                         the first column in the "features.txt" file), a
%                         vector of indices corresponding to the row
%                         numbers in the "features.txt" file, or an empty
%                         value which means it will compute all the
%                         features. By default, WHICHFEATURES is set to
%                         empty.
%
%      - IMG_SUBDIR       The subdirectory where the images for input are 
%                         located. By default, 'clrimages'. Note that if
%                         the file "image_index" already exists, all
%                         these parameters will be overridden by the
%                         values set in this file. 
%
%      - SEG_SUBDIR       The subdirectory where the segment Matlab files
%                         will be stored. The default is 'segments'.
%
%      - SEGIMG_SUBDIR    The subdirectory where the segmented images
%                         will be stored. The default is 'segimages'.
%
%      - BLOBIMG_SUBDIR   The subdirectory where the "blob images" will be
%                         stored. These are images that show the
%                         segmentations and the averaged colours. The
%                         default is 'blobimages'. 
%
%      - IMG_SUFFIX       The suffix for the images. By default, '.jpg'.
%
%      - IMAGES           The number of images to process from the
%                         directory. Make it empty if you want to
%                         process all the images in the directory, which
%                         is the default. Alternatively, IMAGES can be a
%                         cell array of image names to process. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function err = create_segment_data (img_dir, options)

  % Notes:
  %   - The words "patch", "blob" and "segment" are all pretty much
  %     synonymous. 

  % Function constants.
  numReqdArgs          = 1;
  generalPath          = '../general';
  imageIndexFileName   = 'image_index';
  blobsFileName        = 'blob_features';
  adjFileName          = 'adjacencies';
  paramsFileName       = 'ncuts.txt';
  featureTableFileName = 'features.txt';
  
  % Default function arguments.
  defopts = { 'ncuts';      % Patch type
	      32;           % Patch size
	      0;            % Number of cropped pixels
	      '/bin/ncuts'; % Normalized Cuts pathname
	      1;            % Do we keep previous segmentation
                            % information? 
	      [];           % The features to generate (in the default
                            % case, all). 
	      'clrimages';  % Input images subdirectory.
	      'segments';   % Segment info subdirectory.
	      'segimages';  % Segmented images subdirectory.
	      'blobimages'; % Blob images subdirectory.
	      '.jpg';       % Image suffix.
	      [] };         % Which images to process (in the default
                            % case, all). 

  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs
  
  try
    
    % Check to make sure there's enough arguments to run the function.
    if nargin < numReqdArgs,
      error('Not enough input arguments for function. See help for details');
    end;

    % Set up default arguments
    % ------------------------
    if nargin <= numReqdArgs,
      options = {};
    end;
    [ patchType, patchSize, croppedPixels, ncuts, keepSegments, ...
      whichFeatures, imgSubdir, segSubdir, segimgSubdir, ...
      blobimgSubdir, imgSuffix, images ] ...
	= manage_options(options, defopts);
    clear nargin options defopts
    
    % Load image index
    % ----------------
    % Load the image index, patch feature information and patch adjacency
    % information. Remove any images from the list if they are
    % already listed in the index. This will avoid duplicating effort.
    try
      imgIndex    = load_image_index(img_dir, imageIndexFileName);
      blobs       = load_blob_features(img_dir, blobsFileName);
      adjacencies = load_blob_adjacencies(img_dir, adjFileName);
    
    catch
      % If we didn't find the file at all then we don't worry about
      % it. We'll initialize empty image index, patch features and patch
      % adjacencies. 
      imgIndex.imgSuffix     = imgSuffix;
      imgIndex.imgSubdir     = imgSubdir;
      imgIndex.segSubdir     = segSubdir;
      imgIndex.segimgSubdir  = segimgSubdir;
      imgIndex.blobimgSubdir = blobimgSubdir;
      imgIndex.images        = {};
      blobs                  = new_blob_features;
      adjacencies            = new_blob_adjacencies;
    end;
    clear imgSuffix imgSubdir segSubdir segimgSubdir blobimgSubdir
    
    % Build data directory structure
    % ------------------------------
    % Build the absolute directories and create the subdirectories if
    % they don't exist already. Create the following directories:
    %   - segments directory
    %   - segmented images directory
    %   - blob images directory
    mainDir    = img_dir;
    imgDir     = create_dir(mainDir, imgIndex.imgSubdir);
    segDir     = create_dir(mainDir, imgIndex.segSubdir);
    segimgDir  = create_dir(mainDir, imgIndex.segimgSubdir);
    blobimgDir = create_dir(mainDir, imgIndex.blobimgSubdir);
    clear img_dir

    % Get list of images
    % ------------------
    % Here we want to get this list of images to process. This may come
    % from the user, or by getting a directory listing.
    try
      % Check to see if the user has already inputed a list of images to
      % process. 
      if iscell(images),
	imgList = images;
      else
	% Since "images" is not a cell array, it is either empty or a
        % number, which is okay for the function "get_file_list".
	imgList = get_file_list(imgDir, imgIndex.imgSuffix, images);
      end;
            
      % Since we've successfully loaded the image index, let's remove
      % duplicates from "imgIndex". Also, we're going to override the
      % user's choice for the subdirectories with the values set in the
      % "image_index" file.
      imgList = rem_cell_elems(imgList, imgIndex.images);

    catch
      % If for some reason this didn't work, we assume that we can't
      % process any images.
      imgList = {};
    end;
    clear images

    % If the list of images is empty, this is because they've already
    % been previously processed or there are in fact no images in the
    % directory. 
    if ~length(imgList),
      error(['No images to process. This is either because you ' ...
	     'already processed all the images, as indicated in ' ...
	     '"image_index", or because the directory ' mainDir ...
             ' does not exist.']);
    end;
    
    % Load feature information
    % ------------------------
    % We are going to end up in this section with the following
    % variables: 
    %   - whichFeatures, the feature indicies to calculate
    %   - featureNames, the names of the features to calculate
    
    % Figure out the names of the features we will be calculating.
    % Load the feature table from disk.
    featureTable = load_feature_table('.', featureTableFileName);
    
    % If the parameter "whichFeatures" is empty, then just grab all the
    % features. If it is an array of integers, grab the features by
    % index. Otherwise, we have a cell array of feature names, and we
    % have to grab the features by name.
    if ~length(whichFeatures),
      
      % Grab all the features.
      featureNames  = featureTable.names;
      whichFeatures = [1:featureTable.num];
      
    elseif ~iscell(whichFeatures),
      
      % We have the indices of the features, but not the names. Grab the
      % names of the features from the feature table. 
      featureNames = featureTable.names(whichFeatures);
    else,
      
      % We have the feature names but not the indicies. Find the indices
      % corresponding to each feature. 
      featureNames  = whichFeatures;
      whichFeatures = [];
      
      % Repeat for each feature selected.
      for i = 1:length(whichFeatures),
        featName = featureNames{i};
        j = find(strcmp(featureTable.names, featName));
        if ~length(j),
	  % We didn't find a matching feature name so we report an error.
	  error(['Cannot find feature name corresponding to ' featName]);
        end;
        whichFeatures = [whichFeatures j];
      end;
      
      clear i j featName
    end;

    % Load blob information and save segments to disk
    % -----------------------------------------------
    % Capture the segmentation information for all the files in the image
    % directory.    
    [blobsNew.counts blobsNew.features blobsNew.adjacencies] = ... 
	segment_images(imgDir, featureTable, whichFeatures, patchType, ...
		       patchSize, ncuts, [mainDir '/' paramsFileName], ...
		       croppedPixels, keepSegments, segDir, segimgDir, ...
		       blobimgDir, imgIndex.imgSuffix, imgList);

    % Merge the new and old blob information.
    blobs.adjacencies = adjacencies.c;
    blobsNew.images   = imgList;
    blobs             = merge_blob_info(blobs, blobsNew, featureNames, ...
			    featureTable.counts(whichFeatures));
    clear blobsNew adjacencies
   
    % Write adjacencies to disk
    % -------------------------
    fprintf('- Writing blob adjacency information to disk. \n');
    write_blob_adjacencies(mainDir, adjFileName, blobs);
    
    % Write blobs to disk
    % -------------------
    fprintf('- Writing blob feature information to disk. \n');
    write_blob_features(mainDir, blobsFileName, blobs);
    
    % Write image index to disk
    % -------------------------
    % Update the image index information.
    imgIndex.images = blobs.images;
    
    % Write the new image index to disk.
    fprintf('- Writing image index to disk. \n');
    write_image_index(mainDir, imageIndexFileName, imgIndex);
    
  catch,
    disp(lasterr);
    err = 1;
  end;
  
  % Restore the old path.
  path(oldPath);
    
  