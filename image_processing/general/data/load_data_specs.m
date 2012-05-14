% LOAD_DATA_SPECS    Load the data specification from a directory.
%    DATA = LOAD_DATA_SPECS(D) loads the data specifications from
%    directory D. DATA is a struct with the following entries:
%      - numDatasets    N, the number of data sets in the directory. 
%      - setlabels      N x 1 cell array containing the set labels.
%      - numImagesets   D, the number of image sets used.
%      - datadir        D x 1 cell array with the main image
%                       directory for each image set.
%      - segSubdir      D x 1 cell array with the segment info sub-
%                       directory for each image set.
%      - imgSubdir      D x 1 cell array with the image sub-
%                       directory for each image set.
%      - segimgSubdir   D x 1 cell array with the segmented image sub-
%                       directory for each image set.
%      - blobimgSubdir  D x 1 cell array with the "blob image" sub-
%                       directory for each image set.
%      - imgSuffix      D x 1 cell array containing the image suffix for
%                       each image set.
%      - featureNames   F x 1 cell array with the names of the features,
%                       where F is the number of features.
%      - featureCounts  F x 1 array describing the number of dimensions
%                       per feature.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function data = load_data_specs (d)
  
  % Open "specs" file.
  infile = openfile(d,'specs','r');

  % Read in the data sets
  % ---------------------
  data.numDatasets = 0;
  data.setlabels   = {};
  
  % Read in the filler line.
  s = fgetl(infile);
  
  % Repeat for each dataset label until we hit a blank line.
  while 1,
    s = fgetl(infile);
    if ischar(s) & length(s),
      data.numDatasets = data.numDatasets + 1;
      data.setlabels{data.numDatasets,1} = s;
    else,
      break;
    end;
  end;
  
  % Read in the feature information.
  % -------------------------------
  data.featureNames  = {};
  data.featureCounts = [];
  numFeatures = 0;
  
  % Get filler line.
  s = fgetl(infile);
  
  while 1,
    s = fgetl(infile);
    if ischar(s) & length(s),
      numFeatures = numFeatures + 1;
      [t ans data.featureNames{numFeatures,1}] = getlineinfo2(s);
      data.featureCounts(numFeatures,1) = str2num(t);
    else,
      break;
    end;
  end;
  clear t numFeatures
  
  % Read in the image set information.
  % ---------------------------------
  data.numImagesets  = 0;
  data.datadir       = {};
  data.segSubdir     = {};
  data.imgSubdir     = {};
  data.segimgSubdir  = {};
  data.blobimgSubdir = {};
  data.imgSuffix     = {};
  
  while 1,
    
    % Get filler line.
    s = fgetl(infile);
    if ischar(s) & length(s),
      
      % Get information for that image set.
      data.numImagesets = data.numImagesets + 1;
      data.datadir{data.numImagesets,1}       = getlineinfo(infile);
      data.segSubdir{data.numImagesets,1}     = getlineinfo(infile);
      data.imgSubdir{data.numImagesets,1}     = getlineinfo(infile);
      data.segimgSubdir{data.numImagesets,1}  = getlineinfo(infile);
      data.blobimgSubdir{data.numImagesets,1} = getlineinfo(infile);
      data.imgSuffix{data.numImagesets,1}     = getlineinfo(infile);
      
      % Get empty line.
      s = fgetl(infile);
    else,
      break;
    end;
  end;
  
  fclose(infile);  

% ---------------------------------------------------------------------
function s = getlineinfo (infile);
  
  s     = fgetl(infile);
  [s r] = strtok(s);
  [s r] = strtok(r);
  s     = [s r];

% ---------------------------------------------------------------------
function [a, b, c] = getlineinfo2 (s)

  [a s] = strtok(s);
  [b s] = strtok(s);
  [s t] = strtok(s);
  c     = [s t];

% ---------------------------------------------------------------------
function file = openfile (d, f, perm)

  filename = [d '/' f];
  file     = fopen(filename, perm);
  if file == -1,
    error(sprintf('Unable to open file %s for %s access', ...
		  filename, perm));
  end;
