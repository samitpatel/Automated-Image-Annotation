% TRAIN_MODEL    Train model on data set.
%    [MODEL,PROGRESS_LOG] = TRAIN_MODEL(DATA,MODELPARAMS) trains a model
%    using the MODELPARAMS obtained from function
%    /GENERAL/DATA/LOAD_MODEL_PARAMS and data obtained from function
%    /GENERAL/DATA/LOAD_DATA. The result MODEL is a model-specific struct
%    describing the parameters trained on the data. In addition, MODEL
%    possesses the fields "blobs.mean" and "blobs.std" used to normalize
%    test data sets. PROGRESS_LOG is a string containing a record of the
%    model training progress. 
%
%    This function calls the training function written for the model. For
%    more information on this function, see help for
%    /GENERAL/DATA/LOAD_MODEL_TABLE.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function [model, progress_log] = train_model (data, modelparams)

  % Function constants.
  worstVal = -1e99;
  
  % Setup the progress log.
  global progress_log
  progress_log = '';  
  
  % Find mean and variance
  % ----------------------
  % First reshape the blobs data in a (F x N) matrix, where N is the
  % total number of blobs.
  blobs = smash_blobs(data.imageBlobs, data.imageBlobCounts);

  % Now that we have the blobs in a nice format, we can find the mean and
  % variance. 
  blobinfo.mean = mean(blobs')';
  blobinfo.std  = std(blobs')';
  clear blobs
  
  % Process the data
  % ----------------
  % Do some general preprocessing on the data.
  data = process_data(data, blobinfo.mean, blobinfo.std, ...
		      modelparams.blobAreaThresh, ...
                      modelparams.maxNumBlobs, modelparams.featureSel);
  
  % Train model
  % -----------
  % Train the model using the specified training model function. We're
  % going to run the model restarts and we're also going to retry on
  % faulty starts. Also, time the training process.
  bestR     = 0;
  bestVal   = worstVal;
  bestModel = [];
  for r = 1:modelparams.numRestarts,
    proglog('%s training, restart %i.', modelparams.name, r);
    
    % Occasionally we get some extreme results which we'll have to throw
    % away. That's no problem, we just try again! This only happens
    % because we sometimes get strange samples from the prior
    % distributions for our initial values for mu, sigma and tau. The
    % "faulty" parameter designates the maximum number of times to try
    % until we give up.
    success        = 0;
    faultyStartNum = 0;
    while ~success & faultyStartNum < modelparams.numFaultyStarts,
      faultyStartNum = faultyStartNum + 1;
      try
	
	% Train the model. If the exception was not caught, we have
        % success! 
	tic;
	[model val] = ...
	    feval(modelparams.func.train, data.imageBlobs, ...
		  data.imageWords, data.adjacencies, ...
		  data.imageBlobCounts, data.imageWordCounts, ...
		  length(data.words), modelparams.params{:});
	te = toc;
	success = 1;
	proglog('The training completed in %.1f seconds.', te);
	
      catch,
	if faultyStartNum < modelparams.numFaultyStarts,
	  proglog('Attempt %i at training failed, trying again.', ...
		  faultyStartNum);
	else,
	  prolog('Attempt %i at training failed.', faultyStartNum);
	end;
      end;
      
    end; % Repeat until we have a successful training.
    
    if success,

      % Check whether this model is better than the previous ones, based on
      % our computation of the model "value".
      if val > bestVal,
	bestR     = r;
	bestVal   = val;
	bestModel = model;
      end;
      
    else,
      % Report an error.
      error(sprintf('Training failed for restart %i', r));
    end;
    
  end; % Repeat for each restart.
  
  proglog('Out of %i restarts, the best model is from restart %i', ...
	  modelparams.numRestarts, bestR);
  proglog('with a value of %f.', bestVal);
  
  % Return the result.
  model       = bestModel;
  model.blobs = blobinfo;
  