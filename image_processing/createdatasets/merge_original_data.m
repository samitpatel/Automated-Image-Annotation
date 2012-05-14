% MERGE_ORIGINAL_DATA    Merges data sets into one single data set.
%    MDATA = MERGE_ORIGINAL_DATA(ODATA,DATA_DIRS) merges a cell array of
%    data set structs ODATA into a single struct MDATA. DATA_DIRS is a
%    cell array of the original locations of the data sets. Note that
%    ODATA must contain at least one element. The structs in ODATA and
%    MDATA have the following fields: 
%      - imgSuffix      For information on these fields, see 
%      - imgSubdir      /GENERAL/DATA/LOAD_IMAGE_INDEX.
%      - segSubdir
%      - segimgSubdir
%      - blobimgSubdir
%
%      - images         N x 1 array of image names.
%      - imgsets        N x 1 array of data set indices
%
%      - blobCounts     For information on these fields, see
%      - blobFeatures   /GENERAL/DATA/LOAD_BLOB_FEATURES.
%      - featureNames
%      - featureCounts
%
%      - c              For information on this field, see
%                       /GENERAL/DATA/LOAD_BLOB_ADJACENCIES. 
%
%      - wordCounts     For information on these fields, see
%      - imageWords     /GENERAL/DATA/LOAD_IMAGE_LABELS.
%      - correspCounts
%      - blobWords
%
%    In addition, MDATA also contains a field "datadir", which is a cell
%    array containing the data directory for each data set.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function mdata = merge_original_data (odata, data_dirs)
  
  % Initialize the merged data
  % --------------------------
  % "mdata" stands for merged data.
  % "odata" stands for original data.
  mdata.images        = {};
  mdata.imgsets       = [];
  mdata.blobCounts    = [];  
  mdata.blobFeatures  = [];
  mdata.wordCounts    = [];
  mdata.imageWords    = {};
  mdata.correspCounts = [];
  mdata.blobWords     = {};
  
  mdata.imgSuffix     = {};
  mdata.imgSubdir     = {};
  mdata.segSubdir     = {};
  mdata.segimgSubdir  = {};
  mdata.blobimgSubdir = {};

  mdata.datadir       = data_dirs;
  mdata.featureNames  = odata{1}.blobs.featureNames;
  mdata.featureCounts = odata{1}.blobs.featureCounts;

  mdata.adjacencies   = {};
  
  % Repeat for each data set.
  for i = 1:length(odata),
    
    % Merge directory information
    % ---------------------------
    mdata.imgSuffix     = [mdata.imgSuffix; {odata{i}.imgIndex.imgSuffix}];
    mdata.imgSubdir     = [mdata.imgSubdir; {odata{i}.imgIndex.imgSubdir}];
    mdata.segSubdir     = [mdata.segSubdir; {odata{i}.imgIndex.segSubdir}];
    mdata.segimgSubdir  = ...
	[mdata.segimgSubdir; {odata{i}.imgIndex.segimgSubdir}];
    mdata.blobimgSubdir = ...
	[mdata.blobimgSubdir; {odata{i}.imgIndex.blobimgSubdir}];
    
    % Merge images
    % ------------
    mdata.images      = [mdata.images; odata{i}.labels.images];
    mdata.imgsets = ...
	[mdata.imgsets; i*ones(length(odata{i}.labels.images),1)];

    % Merge adjacencies
    % -----------------
    mdata.adjacencies = [mdata.adjacencies; odata{i}.adj.c];
    
    % Merge blob feature information
    % ------------------------------
    mdata.blobCounts = [mdata.blobCounts; odata{i}.blobs.counts];
    mdata.blobFeatures = ...
	cat_matrix(3, mdata.blobFeatures, odata{i}.blobs.features);
    
    % Merge label information
    % -----------------------
    mdata.wordCounts = ...
	[mdata.wordCounts; odata{i}.labels.wordCounts];
    mdata.imageWords = ...
	cat_cells(1, mdata.imageWords, odata{i}.labels.imageWords);
    mdata.correspCounts = ...
	cat_matrix(1, mdata.correspCounts, odata{i}.labels.correspCounts);
    mdata.blobWords = ...
	cat_cells(1, mdata.blobWords, odata{i}.labels.blobWords);
  end;
  