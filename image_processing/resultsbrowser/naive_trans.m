% NAIVE_TRANS    Translate using a trained naive model.
%    T = NAIVE_TRANS(MODEL,DATA) returns a W x B x N matrix of
%    translation probabilities where W is the number of word tokens, B is 
%    the maximum number of blobs in an image and N is the number of
%    images (or documents). DATA is obtained from
%    /GENERAL/DATA/LOAD_DATA. MODEL is obtained from the function
%    NAIVE_TRAIN. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = naive_trans (model, data)
  
  t = repmat(model, [1 size(data.imageBlobs,2) data.numImages]);