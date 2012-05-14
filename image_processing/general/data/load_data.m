% LOAD_DATA    Load data sets from a directory.
%    DATA = LOAD_DATA(DATADIR) loads the data sets located in directory
%    DATADIR. The result, DATA, is a cell array of data sets, where each
%    element is a struct with the following entries:
%      - setlabels        The data set label.
%      - numImagesets     I, the number of image sets used.
%      - datadir          I x 1 cell array with the main image
%                          directory for each image set.
%      - segSubdir        I x 1 cell array with the segment info sub-
%                         directory for each image set.
%      - imgSubdir        I x 1 cell array with the image sub-
%                         directory for each image set.
%      - segimgSubdir     I x 1 cell array with the segmented image sub-
%                         directory for each image set.
%      - blobimgSubdir    I x 1 cell array with the "blob image" sub-
%                         directory for each image set.
%      - imgSuffix        I x 1 cell array containing the image suffix for
%                         each image set.
%      - featureNames     FN x 1 cell array with the names of the features,
%                         where FN is the number of feature names.
%      - featureCounts    FN x 1 array describing the number of dimensions
%                         per feature.
%      - numImages        N, the number of features.
%      - images           N x 1 cell array of image names.
%      - imgsets          N x 1 array of image set indices.
%      - numWords         WN, the number of words in the data set.
%      - words            WN x 1 cell array of words.
%      - imageWordCounts  N x 1 matrix of label sizes for each image.
%      - imageWords       N x W matrix of word indices, where W is the
%                         maximum size of an image label.
%      - imageBlobCounts  N x 1 matrix with the number of blobs for each
%                         image. 
%      - numFeatures      F, the number of features.
%      - imageBlobs       F x B x N matrix where F is the number of
%                         features and B is the maximum number of blobs
%                         in an image. 
%      - blobWordCounts   N x B matrix of correspondence counts for each
%                         blob.  
%      - blobWords        V x B x N matrix of correspondences, where V is
%                         the maximum size of a correspondence.
%      - adjacencies      A N x 1 cell array. Each entry is an BN x BN
%                         matrix, where BN is the number of blobs in
%                         document N. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function data = load_data (datadir)
  
  % Load the data specs
  % -------------------
  spec_data = load_data_specs(datadir);
  
  % Repeat for each data set.
  data = {};
  for d = 1:spec_data.numDatasets,
    
    sd = [datadir '/' spec_data.setlabels{d}];
    
    % Grab the spec information
    % -------------------------
    data{d} = spec_data;
    data{d}.setlabel = data{d}.setlabels{d};
    data{d} = rmfield(data{d}, {'numDatasets'; 'setlabels'});
    
    % Initialize data
    % ---------------
    data{d}.numImages       = 0;
    data{d}.imgsets         = [];
    data{d}.images          = {};
    data{d}.imageWordCounts = [];
    data{d}.imageBlobCounts = [];
    data{d}.blobWordCounts  = [];
    data{d}.adjacencies     = {};
    
    % Load the images information
    % ---------------------------
    infile = openfile(sd,'images','r');
    while 1,
      s = fgetl(infile);
      if ischar(s) & length(s),
	data{d}.numImages = data{d}.numImages + 1;
	[n data{d}.images{data{d}.numImages,1}] = getlineinfo2(s);
	data{d}.imgsets(data{d}.numImages,1) = str2num(n);
      else,
	break;
      end;
    end;
    fclose(infile);
    
    % Load the words
    % --------------
    data{d}.words = importdata([sd '/words']);
    data{d}.numWords = length(data{d}.words);
    
    % Load the "image_words" and calculate the imageWordCounts
    % --------------------------------------------------------
    data{d}.imageWords = importdata([sd '/image_words']);
    for i = 1:data{d}.numImages,
      data{d}.imageWordCounts(i,1) = sum(data{d}.imageWords(i,:) > 0);
    end;

    % Load the "image_blobs" info and calculate the imageBlobCounts
    % -------------------------------------------------------------
    imageBlobs = importdata([sd '/image_blobs']);
    for i = 1:data{d}.numImages,
      data{d}.imageBlobCounts(i,1) = sum(imageBlobs(i,:) > 0);
    end;
    clear imageBlobs
    
    % Load "blob_words" find blobWordCounts and blobWords matrices
    % ------------------------------------------------------------
    blobWords = importdata([sd '/blob_words']);
    data{d}.blobWords = zeros(size(blobWords,2), 0, 0);
    bn = 0;
    for i = 1:data{d}.numImages,
      for b = 1:data{d}.imageBlobCounts(i),
	bn = bn + 1;
	data{d}.blobWordCounts(i,b) = sum(blobWords(bn,:) > 0);
	data{d}.blobWords(:,b,i)    = blobWords(bn,:)';
      end;
    end;
    clear blobWords
    
    % Load the "blobs" information and create the imageBlobs matrix
    % -------------------------------------------------------------
    blobs = importdata([sd '/blobs']);
    data{d}.numFeatures = size(blobs,2);
    data{d}.imageBlobs = zeros(data{d}.numFeatures, 0, 0);
    bn = 0;
    for i = 1:data{d}.numImages,
      for b = 1:data{d}.imageBlobCounts(i),
	bn = bn + 1;
	data{d}.imageBlobs(:,b,i) = blobs(bn,:)';
      end;
    end;
    clear blobs
    
    % Load the "adjacency" information and create adjacencies
    % -------------------------------------------------------
    adjacencies = importdata([sd '/adjacencies']);
    b = 1;
    for i = 1:data{d}.numImages,
      bn = data{d}.imageBlobCounts(i);
      data{d}.adjacencies{i,1} = adjacencies(b:b+bn-1, 1:bn);
      b = b + bn;
    end;
  end;

% ---------------------------------------------------------------------
function [a, b] = getlineinfo2 (s)

  [a s] = strtok(s);
  [s t] = strtok(s);
  b     = [s t];
  
% ---------------------------------------------------------------------
function file = openfile (d, f, perm)

  filename = [d '/' f];
  file     = fopen(filename, perm);
  if file == -1,
    error(sprintf('Unable to open file %s for %s access', ...
		  filename, perm));
  end;
