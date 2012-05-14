% LOAD_MODEL_PARAMS    Load the model training parameters from disk.
%    MODEL = LOAD_MODEL_PARAMS(MODEL_DIR,MODEL_TABLE,MODEL_NAME) loads
%    the model from file MODEL_NAME in directory MODEL_DIR. MODEL_TABLE
%    is obtained from running the function
%    /GENERAL/DATA/LOAD_MODEL_TABLE. Note that MODEL_TABLE can also be an
%    empty matrix, in which case the pertinent data from the MODEL_TABLE
%    is not used. This is useful when you want to load the model
%    parameters without using it for training (say, to display the name
%    of the model in a figure). MODEL is a struct containing the
%    information specified in the model parameters text file: 
%      - label           The name of the model.
%      - name            The generic model used.
%      - featureSel      A vector containing the blob features on which
%                        to train. If you want to use all the features,
%                        set it to 'all'.
%      - blobAreaThresh  A number between 0 and 1. If the area ratio of a
%                        blob is less than this number, we remove it from
%                        the set of blobs for that document. To keep all
%                        the blobs, set it to 0 or select 'none'. If a
%                        "C" is added to the end of this value and the
%                        whole thing is surrounded with double quotes,
%                        the blobs will also be thresholded by area
%                        during the test phase.
%      - threshOnTest    If a "C" is added to the end of "Blob area
%                        threshold" value and the it is surrounded with
%                        double quotes, the blobs will also be
%                        thresholded by area during the test phase as
%                        well. 
%      - maxNumBlobs     The maximum number of blobs in a document
%                        Remove any exceeding this number. If you want to
%                        keep all the blobs, specify 'all'.
%      - numRestarts     Number of times to train the model, keeping only
%                        the best one.
%      - numFaultyStarts Some algorithms may fail under rare initial
%                        conditions. This is especially the case when we
%                        are sampling from unstable distributions. If so,
%                        you might want to set this to a large value so
%                        that the program retries the training after a
%                        failure. Otherwise, set this value to 1.
%      - paramLabels     A cell array containing the names of the
%                        additional model-specific parameters. 
%      - params          A cell array containing the values of the
%                        additional model-specific parameters.
%
%    Note that in the text file for the model specifications, all strings
%    should be enclosed in double quotes and the label for each value
%    should end with a colon (":"). 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function model = load_model_params (model_dir, model_table, model_name)

  % Open model file.
  filename = [model_dir '/' model_name];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to read file %s', filename));
  end;
  
  % Load the general parameters.
  % ---------------------------
  model.label           = getlineinfo(fgetl(infile));
  model.name            = getlineinfo(fgetl(infile));
  model.featureSel      = getlineinfo(fgetl(infile));
  model.blobAreaThresh  = getlineinfo(fgetl(infile));
  model.maxNumBlobs     = getlineinfo(fgetl(infile));
  model.numRestarts     = getlineinfo(fgetl(infile));
  model.numFaultyStarts = getlineinfo(fgetl(infile));
  
  % Modify "blobAreaThresh".
  model.threshOnTest = 0;
  if ~isnumeric(model.blobAreaThresh) & ...
	model.blobAreaThresh(length(model.blobAreaThresh)) == 'C',
    model.blobAreaThresh = ...
	str2num(model.blobAreaThresh(1:length(model.blobAreaThresh)-1));
    model.threshOnTest = 1;
  end;
  
  % Grab the information from the model table if it was given to us.
  if length(model_table),
    found = 0;
    for i = 1:length(model_table),
      if strcmp(model_table{i}.name, model.name),
        found = 1;
        model.func = model_table{i}.func;
      end;
    end;
  
    if ~found,
      error(sprintf(['No model can be found in the model table with' ...
		     ' the name %s.'], model.name));
    end;
  end;
  
  % Load the model-specific parameters
  % ----------------------------------
  numParams         = 0;
  model.params      = {};
  model.paramLabels = {};
  while 1,
    s = fgetl(infile);
    if ischar(s) & length(s),
      numParams = numParams + 1;
      [model.params{numParams,1} model.paramLabels{numParams,1}] ...
	  = getlineinfo(s);
    else,
      break;
    end;
  end;
  
  % Close the file.
  fclose(infile);  
  
% ----------------------------------------------------------------
function x = goodline (s)
  x = ischar(s) & length(s);

% ----------------------------------------------------------------
function [x, l] = getlineinfo (s)
  
  % First make sure this line is okay.
  if ~goodline(s),
    error('Error in loading model from disk.');
  end;
  
  f = find(s == ':');
  if ~length(f),
    x = '';
  else,
    [l r] = strtok(s(1:f(1)-1));
    l     = [l r];
    [s r] = strtok(s(f(1)+1:length(s)));
    s     = [s r];
    
    % Now we've isolated the part of the line that JUST has the
    % information. But we still have to process it. Check to see if the
    % parameter is a string (if it is surrounded by double
    % quotes). Otherwise, it is a number or an array of numbers.
    if s(1) == '"',
      
      % s is a string.
      f = find(s == '"');
      if length(f) < 2,
	x = '';
      else,
	x = s(f(1)+1:f(2)-1);
      end;
    else,
      
      % s is an array of numbers.
      x = str2num(s);
    end;
  end;
