% GET_NUM_TRIALS   Figure out how many trials were computed for a model. 
%    GET_NUM_TRIALS(DATA_DIR,MODEL_NAME) returns the number of trials for
%    MODEL_NAME on the data set found in directory DATA_DIR.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function n = get_num_trials (data_dir, model_name)

  % Function constants.
  trialPrefix = 'trial';

  % Get number of trials.
  model_dir = [data_dir '/results/' model_name];
  files = get_file_list(model_dir, '', -1, trialPrefix);
  n = length(files);
 