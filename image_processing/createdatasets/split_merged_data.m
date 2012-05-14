% SPLIT_MERGED_DATA    Split data into several data sets.
%    SDATA = SPLIT_MERGED_DATA(MDATA,DATASELECTION) splits the images
%    (i.e. documents) of MDATA until several data sets N, where N is the
%    length of the cell array DATASELECTION. DATASELECTION specifies
%    which images go into which data sets; each entry in the cell array
%    is a vector of image indices corresponding to those in MDATA. The
%    result is a cell array of data structs SDATA. For more information
%    on the fields of SDATA and MDATA, see SPLIT_MERGED_DATA.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function sdata = split_merged_data (mdata, dataSelection)
  
  numDatasets = length(dataSelection);
  for d = 1:numDatasets,
    ds = dataSelection{d};
    
    % Grab information and put it into sdata{d}.
    sdata{d}.datadir       = mdata.datadir;
    sdata{d}.imgSuffix     = mdata.imgSuffix;
    sdata{d}.imgSubdir     = mdata.imgSubdir;
    sdata{d}.segSubdir     = mdata.segSubdir;
    sdata{d}.segimgSubdir  = mdata.segimgSubdir;
    sdata{d}.blobimgSubdir = mdata.blobimgSubdir;
    sdata{d}.featureNames  = mdata.featureNames;
    sdata{d}.featureCounts = mdata.featureCounts;
  
    sdata{d}.images        = mdata.images(ds);
    sdata{d}.imgsets       = mdata.imgsets(ds);
    
    sdata{d}.blobCounts    = mdata.blobCounts(ds);
    sdata{d}.blobFeatures  = mdata.blobFeatures(:,:,ds);
    
    sdata{d}.adjacencies   = mdata.adjacencies(ds);
    
    sdata{d}.wordCounts    = mdata.wordCounts(ds);
    sdata{d}.imageWords    = mdata.imageWords(ds,:);
    sdata{d}.correspCounts = mdata.correspCounts(ds,:);
    sdata{d}.blobWords     = mdata.blobWords(ds,:,:);
  end;
