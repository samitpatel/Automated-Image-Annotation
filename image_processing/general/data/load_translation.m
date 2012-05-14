% LOAD_TRANSLATION    Loads the image translation probability matrix from
%                     disk. 
%    T = LOAD_TRANSLATION(DATA_DIR,DATA) loads the translation matrix
%    table from directory DATA_DIR and returns the result in T, a 
%    W x B x N matrix of translation probabilities where W is the
%    number of word tokens, B is the maximum number of blobs in an image
%    and N is the number of images. DATA is the result from function
%    /GENERAL/DATA/LOAD_DATA.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = load_translation (data_dir, data) 
  
  t = importdata([data_dir '/' data.setlabel]);
  t = unsmash_blobs(t, data.imageBlobCounts);

  