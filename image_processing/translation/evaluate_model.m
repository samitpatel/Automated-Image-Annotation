% EVALUATE_MODEL    Train and test a model on a specified data set and
%                   save the results to disk.
%    EVALUATE_MODEL(DATA_DIR,MODEL_DIR,MODEL_NAME,NUM_TRIALS,
%    TRAINING_SET) trains the model MODEL_NAME found in directory
%    MODEL_DIR on the training set found in DATA_DIR, and then evaluates
%    the trained model on all the data sets. The results saved to disk
%    include the trained model parameters and the translation results for
%    each data set.
%
%    NUM_TRIALS is an optional parameter. It is a vector which specifies
%    which trial numbers to evaluate. For example, [5:7] will run trial
%    numbers 5 through 7. The default is 1. TRAINING_SET specifies
%    the index of the data set to use. The default is 1, which usually
%    means the set labeled "training". 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function evaluate_model (data_dir, model_dir, model_name, varargin)  

  % Function constants.
  numReqdArgs        = 3;
  generalPath        = '../general';
  resultsSubdir      = 'results';
  modelTableFileName = 'models.txt';
  modelSuffix        = '.txt';
  trialPrefix        = 'trial';
  progLogFileName    = 'log';
  
  % Default arguments.
  defaultTrainingSet = 1;  
  defaultNumTrials   = 1;
  
  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs  
  
  try 
    % Check to make sure there's enough arguments to run the function.
    if nargin < numReqdArgs,
      error('Not enough input arguments for function. See help for details');
    end;
   
    % Set up function parameters
    % --------------------------
    defargs = { defaultNumTrials;
	        defaultTrainingSet };
    [numTrials trainingSet] = manage_vargs(varargin, defargs);
    clear defargs varargin numReqdArgs defaultTrainingSet defaultNumTrials 
    
    % Set the random seed
    % -------------------
    rand('state', sum(100*clock));
    
    % Load data
    % ---------
    fprintf('- Loading data from %s.\n', data_dir);
    data = load_data(data_dir);
    
    % Load the model
    % --------------
    fprintf('- Loading model.\n');
    modelTable  = load_model_table('.', modelTableFileName);
    modelparams = load_model_params(model_dir, modelTable, ...
				  [model_name modelSuffix]);
    clear modelTable

    % Display model parameters.
    infile = fopen([model_dir '/' model_name modelSuffix], 'r');
    while 1,
      s = fgetl(infile);
      if length(s) & ischar(s),
        fprintf(['   ' s '\n']);
      else,
        break;
      end;
    end;
    fclose(infile);
    clear s infile
  
    % Create results subdirectories
    % -----------------------------
    % Create the "results" directory and the "results/model" subdirectory
    % if it hasn't already been created. 
    status     = mkdir(data_dir, resultsSubdir);
    result_dir = [data_dir '/' resultsSubdir];
    status     = mkdir(result_dir, model_name);
    result_dir = [result_dir '/' model_name];
    clear status
  
    % Save the model specs
    % --------------------
    % Copy the model parameters into the "result_dir" directory.
    f1 = [model_dir '/' model_name modelSuffix];
    f2 = [result_dir '/specs'];
    err = system(['cp -f ' f1 ' ' f2]);  
    clear f1 f2 err
  
    % Save the words we trained on
    % ----------------------------
    % Copy the list of words from the training set.
    spec_data = load_data_specs(data_dir);
    f1 = [data_dir '/' spec_data.setlabels{trainingSet} '/words' ];
    f2 = [result_dir '/words'];
    err = system(['cp -f ' f1 ' ' f2]);  
    clear f1 f2 err spec_data
  
    % Train model for each trial
    % --------------------------
    for trialNum = numTrials,
      fprintf('TRIAL No. %i\n', trialNum);
          
      % Train the model on the training set
      % -----------------------------------
      fprintf('- Training model.\n');
      trainData = data{trainingSet};
      [model progress_log] = train_model(trainData, modelparams);
      clear trainData
  
      % Test model and write translations to disk
      % -----------------------------------------
      % Run the model on all the data using the translation function of
      % the model. Write the generated translation probabilities to disk.
      fprintf(['- Calculating translation probabilities for ' ...
	       'data sets.\n']);
      for d = 1:length(data),
        fprintf('   %i. %s\n', d, data{d}.setlabel);
        t{d} = translate(data{d}, modelparams, model);
      end;
    
      % Create the "results/model/trialnum" subdirectory if it hasn't
      % already been created.
      s = sprintf('%s%i', trialPrefix, trialNum);
      status = mkdir(result_dir, s);
      trial_result_dir = [result_dir '/' s];
      clear status s

      % Write model information to disk.
      % -------------------------------
      % Save the log.
      fprintf('- Writing progress log to disk.\n');
      write_proglog(trial_result_dir, progLogFileName, progress_log);
  
      % Save the trained model to the "trial_result_dir".
      fprintf('- Saving trained model to disk.\n');  
      write_model(trial_result_dir, modelparams, model);

      % Write the translation matrices to disk.
      fprintf('- Saving translation matrices to disk.\n');
      for d = 1:length(data),
	write_translation(trial_result_dir, data{d}, t{d});
      end;
      
      fprintf('\n');
    
    end; % for each trial number.
  
  catch
    disp(lasterr);
    return;
  end; %try
  
  % Restore the old path.
  path(oldPath);
    
