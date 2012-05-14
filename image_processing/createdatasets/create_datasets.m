% CREATE_DATASETS    Create data sets from several sources of
%                    segmentation and label information. 
%    CREATE_DATASETS(DATA_DIRS,RESULT_DIR,SET_LABELS,SET_PORTIONS, 
%    SEQUENTIAL, SEED) creates data sets and saves the information to
%    disk in the directory RESULT_DIR. DATA_DIRS is a cell array of the
%    locations of the source information (the image label information
%    should be created using the CREATELABELS function). SET_LABELS is an
%    N x 1 cell array of names for the data sets, where N is the number
%    of data sets. Usually, the first one is "training". SET_PORTIONS is
%    an N x 1 vector of proportions of the number of images per data
%    set. The proportions do not have to add up to 1 since they will be 
%    normalized. 
%
%    SEQUENTIAL is an optional parameter. If it is 1, the data is
%    distributed sequentially. Otherwise, it is distributed randomly. The
%    default is 0. SEED = J sets the random seed to the Jth state, and is
%    only applicable if SEQUENTIAL is set to 0. This is useful if you
%    want a random (but predetermined) order to the images. If you don't
%    want to set the random seed, set it to the empty matrix [].
%
%    For more information on what files are created by this function, see
%    help for /GENERAL/DATA/WRITE_DATA.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function create_datasets (data_dirs, result_dir, set_labels, set_portions, ...
			  varargin)
  
  % Function constants.
  numReqdArgs          = 4;
  imageIndexFileName   = 'image_index';
  blobsFileName        = 'blob_features';
  adjFileName          = 'adjacencies';
  imageLabelsFileName  = 'labels';  
  generalPath          = '../general';
  defaultSequential    = 0;
  defaultSeed          = [];
  
  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs
  
  % Check to make sure there's enough arguments to run the function.
  if nargin < numReqdArgs,
    error('Not enough input arguments for function. See help for details');
  end;
  
  % Set up the optional arguments
  % -----------------------------
  defargs = { defaultSequential; defaultSeed };
  [sequential seed] = manage_vargs(varargin, defargs);
  clear defargs varargin defaultSequential defaultSeed numReqdArgs
  
  % Load data from disk and make sure it is okay
  % --------------------------------------------
  % Notes:
  %   odata -> original data
  %   mdata -> merged data
  %   sdata -> split data
  fprintf('- Loading data from disk.\n');
  try
    for i = 1:length(data_dirs),
      data_dir = data_dirs{i};
      fprintf('  %i. %s\n', i, data_dir);
      odata{i}.imgIndex = load_image_index(data_dir, imageIndexFileName);
      odata{i}.blobs    = load_blob_features(data_dir, blobsFileName);
      odata{i}.adj      = load_blob_adjacencies(data_dir, adjFileName);
      odata{i}.labels   = load_image_labels(data_dir, imageLabelsFileName);
    end;
    clear data_dir i
    
    % Check compatibility of blob features.
    fprintf('- Checking compatibility of blob features.\n');
    blobs = odata{1}.blobs;
    for i = 2:length(data_dirs),
      blobsi = odata{i}.blobs;
      errMsg = sprintf(['The blob features for data sets 1 and ' ...
                        '%i are incompatible'], i);
      
      % First check the number of features.
      if length(blobsi.featureNames) ~= length(blobs.featureNames),
        error(errMsg);
      end;
      
      % Next check the names and counts for each feature.
      for f = 1:length(blobs.featureNames),
	if ~strcmp(blobsi.featureNames{f}, blobs.featureNames{f}) | ...
	  blobsi.featureCounts(f) ~= blobs.featureCounts(f),
	  error(errMsg);
	end;
      end;
      
    end;
    
    % At this point we've passed all the consistency checks, so the data
    % is probably okay. 
    clear i f blobs blobsi errMsg
    
  catch
    disp(lasterr);
    return;
  end;
  
  % Merge data from various sources
  % -------------------------------
  % Since the data is consistent, merge all the data into one single
  % struct "mdata".
  fprintf('- Merging data.\n');  
  mdata = merge_original_data(odata, data_dirs);
  clear odata
  
  % Set the random seed
  % -------------------
  if length(seed),
    rand('state', seed);
  else,
    rand('state', sum(100*clock));
  end;
  
  % Split data 
  % ----------
  % Divide the examples among the different data sets. Do this either
  % sequentially or randomly. First pick the order of the data, then
  % separate ("split") the data into separate data sets.
  numImages   = length(mdata.images);
  numDatasets = length(set_labels);
  
  if sequential,
    dataOrder = [1:numImages];
  else,
    dataOrder = randperm(numImages);
  end;
  
  % Normalize the data set proportions and multiply it by the number of
  % examples (images).
  set_portions = (set_portions / sum(set_portions)) * numImages;
  start = 0;
  for d = 1:numDatasets,
    finish = round(start + set_portions(d));
    dataSelection{d} = dataOrder(start+1:finish);
    start = finish;
  end;
  clear start finish dataOrder sequential set_portions d data_dirs
  
  % Split the merged data set.
  fprintf('- Splitting data into separate data sets.\n');    
  for d = 1:numDatasets,
    l = length(dataSelection{d});
    fprintf('  "%s" has %i examples\n', set_labels{d}, l);
    if ~l,
      fprintf(['* Warning: this data set will not be created since it has' ...
	       ' no examples.\n']);
    end;
  end;
  clear l
  
  sdata = split_merged_data(mdata, dataSelection);
  clear mdata
  
  % Write data to disk
  % ------------------
  fprintf('- Writing data sets to disk.\n');      
  write_data(result_dir, set_labels, sdata);
  
  % Restore the old path.
  path(oldPath);
    
 