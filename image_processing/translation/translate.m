% TRANSLATE    Translates a data set using a trained model.
%    T = TRANSLATE(DATA,MODELPARAMS,MODEL) returns a W x B x N matrix of
%    translation probabilities where W is the number of word tokens, B is
%    the maximum number of blobs in an image and N is the number of
%    images (or documents). MODELPARAMS is obtained from
%    /GENERAL/DATA/LOAD_MODEL_PARAMS. DATA is obtained from
%    /GENERAL/DATA/LOAD_DATA. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = translate (data, modelparams, model)
  
  % Do some general preprocessing on the data.
  if modelparams.threshOnTest,
    blobThresh = modelparams.blobAreaThresh;
  else,
    blobThresh = 'none';
  end;
  data = process_data(data, model.blobs.mean, model.blobs.std, ...
		      blobThresh, 'all', modelparams.featureSel);
  
  % Run the model on the data.
  t = feval(modelparams.func.trans, data.imageBlobs, ...
	    data.imageBlobCounts, data.adjacencies, model);
