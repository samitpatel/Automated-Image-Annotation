% MERGE_BLOB_INFO   Merge the blob features and adjacencies.
%    BLOBS = MERGE_BLOB_INFO(BLOBS1,BLOBS2,FEATURENAMES,
%    FEATURECOUNTS) merges BLOBS1 and BLOBS2, using FEATURENAMES and
%    FEATURECOUNTS, returning the merged information in BLOBS. For more
%    information, see the function LOAD_BLOB_FEATURES and
%    LOAD_BLOB_ADJACENCIES. Note that the only field we need from the
%    ADJACENCY struct is "c", which is identified by the field
%    "adjacencies" in the structs BLOBS1 and BLOBS2.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function blobs = merge_blob_info (blobs1, blobs2, featureNames, ...
				  featureCounts)

  blobs.featureNames  = featureNames;
  blobs.featureCounts = featureCounts;
  blobs.images        = merge_cells(blobs1.images, blobs2.images);
  blobs.counts        = [blobs1.counts; blobs2.counts];
  
  % Merge the adjacencies.
  blobs.adjacencies = [blobs1.adjacencies; blobs2.adjacencies];

  % Merge the features.
  [f m1 i1]           = size(blobs1.features);
  [f m2 i2]           = size(blobs2.features);
  if ~i1 | ~m1,
    blobs.features = blobs2.features;
  elseif ~i2 | ~m2,
    blobs.features = blobs1.features;
  else,
    blobs.features = ...
        cat(3, cat(2, blobs1.features, zeros(f, max(m2-m1,0), i1)), ...
	       cat(2, blobs2.features, zeros(f, max(m1-m2,0), i2)));
  end;
  
   