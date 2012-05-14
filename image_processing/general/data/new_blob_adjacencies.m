% NEW_BLOB_ADJACENCIES   Create a new blob adjacencies structure.
%    ADJACENCIES = NEW_BLOB_ADJACENCIES returns a new blob structure with
%    the following fields: images, counts and c.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function adjacencies = new_blob_adjacencies
  
  adjacencies.images = {};
  adjacencies.counts = [];
  adjacencies.c      = {};
