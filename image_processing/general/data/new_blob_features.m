% NEW_BLOB_FEATURES   Create a new blob features structure.
%    BLOBS = NEW_BLOB_FEATURES returns a new blob structure with the
%    following fields: images, counts and features.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function blobs = new_blob_features
  
  blobs.images    = {};
  blobs.counts    = [];
  blobs.features  = [];
