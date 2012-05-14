% WRITE_TRANSLATION    Write the translation matrix to disk.
%    WRITE_TRANSLATION(RESULT_DIR,DATA,T) writes the translation matrix T
%    to directory RESULT_DIR using the label from the data set described
%    in DATA. DATA is obtained from function /GENERAL/DATA/LOAD_DATA. T
%    is a W x B x N matrix of translation probabilities where W is the
%    number of word tokens, B is the maximum number of blobs in an image
%    and N is the number of images.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_translation (result_dir, data, t) 
  
  write_matrix(result_dir, data.setlabel, ...
		 smash_blobs(t,data.imageBlobCounts));
  