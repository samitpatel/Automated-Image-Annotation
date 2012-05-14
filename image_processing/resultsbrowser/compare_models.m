% COMPARE_MODELS    Compare the performance of several models on a single
%                   data set.
%    ERR = COMPARE_MODELS(DATA_DIR,MODEL_NAMES,OPTIONS,TEST,...) compares
%    the performance of models on the data set located in
%    DATA_DIR. MODEL_NAMES is a cell array of model names;  
%    their translation results must be located in the "results" directory
%    of DATA_DIR. TEST is a string describing the test measure to
%    perform; see the function RUN_MODEL_TEST for a list of possible
%    tests to run.
%
%    The return value ERR is a D x 1 cell array, where D is the number of
%    datasets in DATA_DIR. Each entry of ERR is a T x M matrix, where M
%    is the number of models, or the length of the cell array
%    MODEL_NAMES, and T is the maximum number of trials for a single
%    model. 
%
%    OPTIONS is a cell array with the entries {TRAININGSET,USEBOX,
%    RANDLINE,EMPLINE}. The optional parameters, in order, are: 
%
%      - TRAININGSET  The index of the training set. This is only
%                     applicable if EMPLINE is set to 1, since it is used
%                     for finding the empirical distribution of the
%                     labels. Generally, the default of 1 is correct. 
%      
%      - USEBOX       If set to 1, use the Box and Whisker plot. The
%                     default is 1.
%
%      - RANDLINE     If 1 (the default), show the random upper bound in
%                     the graphs.
%
%      - EMPLINE      If 1 (the default), show the empirical distribution
%                     upper bound on the graphs.
%
%    After OPTIONS, you may need to include other arguments as specified
%    by the function parameter TEST.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function err = compare_models (data_dir, model_names, test, options, ...
			       varargin) 
  
  % Function constants.
  trialPrefix = 'trial';
  generalPath = '../general';
  numReqdArgs = 3;
  plotClrs    = 'bgr';
  naiveClr    = 'c';
  randClr     = 'm';
  horizThresh = 0.005;
  vertSep     = 0.03;
  maxSTitle   = 32;
  
  % Default arguments.
  defopts = { 1;    % Training set index.
	      1;    % Use the Box-and-Whisker plot.
	      1;    % Plot the random upper bound.
	      1  }; % Plot the empirical dist. upper bound.
  
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
    if nargin <= numReqdArgs,
      options = {};
    end;
    [ trainingSet, useBox, plotRandLine, plotEmpLine ] ...
	= manage_options(options, defopts);
    clear nargin options defopts

    testParams = varargin;
    clear varargin

    % Create the new figure.
    cf = figure;
    s = data_dir;
    if length(s) > maxSTitle,
      s = ['...' s(length(s)-maxSTitle+1:length(s))];
    end;
    set(cf, 'NumberTitle', 'off', 'Name', ...
	    sprintf('%s for data set "%s"', test, s));
    clear cf s
    
    % Load the data
    % -------------
    % Load the specifications and data for the data set.
    specs     = load_data_specs(data_dir);
    data      = load_data(data_dir);
    numModels = length(model_names);
    
    % Load the models
    % ---------------
    % Figure out how many trials there are for each model and load the
    % model labels as well.
    for m = 1:numModels,
      % Get number of trials.
      model_dir = [data_dir '/results/' model_names{m}];
      files = get_file_list(model_dir, '', -1, trialPrefix);
      numTrials(m) = length(files);
      
      % Get model label.
      model = load_model_params(model_dir, [], 'specs');
      modelLabels{m} = model.label;
    end;
    clear model_dir files model
    
    % Check to make sure the number of trials for each model is the
    % same. If not, do not use the box plot. Or, if the number of trials
    % is 1 for at least one of the trials, "set useBox" to 0.
    for m = 2:numModels,
      if (numTrials(m) ~= numTrials(1)) | (numTrials(m) < 2),
	useBox = 0;
	break;
      end;
    end;
    
    % First calculate the "naive" translation probability. We simply
    % look at the empirical distribution of the training set. We assume the
    % first one is the training set unless specified by the user. We'll
    % call this this "naive model".
    naiveModel = naive_train(data{trainingSet});

    % Figure out what the random model is.
    randModel.t = ones(data{trainingSet}.numWords,1) ...
	/ data{trainingSet}.numWords;
    
    % Repeat for each data set.
    for d = 1:specs.numDatasets,
    
      % Repeat for each model.
      for m = 1:numModels,
      
        % Load the words for the model.
        model_dir = [data_dir '/results/' model_names{m}];
        modelWords = importdata([model_dir '/words']);
      
        % Repeat for each model trial.
        for i = 1:numTrials(m),
	
	  fprintf('- Evaluating trial %i model %s for data set "%s"\n', ...
		  i, model_names{m}, data{d}.setlabel);
	  
	  % Load the translation table for model and data set
	  % -------------------------------------------------
	  trial_dir = [model_dir sprintf('/%s%i', trialPrefix, i)];
	  t = load_translation(trial_dir, data{d});
	  
	  % Test the model's translation
	  % ----------------------------
	  e = run_model_test(test, data{d}.words, data{d}.blobWords, ...
			     modelWords, t, testParams{:});
	  err{d}(i,m) = e;
        end;
      end;
    
      % Create the parameters string.
      s = '';
      for i = 1:length(testParams),
        s = [s ' ' sprintf('%i',testParams{i})];
      end;
    
      % Plot the results for data set
      % -----------------------------
      subplot(1, specs.numDatasets, d);
      set(cla, 'XTick', [], 'XTickLabel', []);
     
      if useBox,
	% Draw the box plot.
	boxplot(err{d}, 1);
      else,
	% Draw the point plot.
	hold on;
	
	% Repeat for each model.
	for m = 1:numModels,
	  e = sort(err{d}(1:numTrials(m),m));
	  g = group(e,horizThresh);
	  x = [];
	  
	  % Calculate the x's.
	  % Repeat for each group.
	  for i = 1:size(g,1),
	    c = sum(g(i,:) > 0);
	    x = [x (([1:c]-(1+c)/2)*vertSep)];
	  end;
	  
	  % Plot the points for that model.
	  plot(m+x,e',[plotClrs(mod(m-1,length(plotClrs))+1) '+']);
	end;
      end;
      
      axis([0.5 numModels + 0.5 0 1]);
      xlabel('Model', 'FontSize', 12);
      ylabel(sprintf('%s%s measure', test, s), 'FontSize', 12);
      title(sprintf('Error on data set "%s"', data{d}.setlabel), ...
	    'FontWeight', 'bold', 'FontSize', 12);
      
      % Add the model labels to the graph.
      for m = 1:numModels,
        text(m, min(err{d}(1:numTrials(m),m)) - 0.08, ...
	     modelLabels{m}, 'FontSize', 9, ...
	     'Rotation', 90, 'HorizontalAlignment', 'right');
      end;
      
      % Plot random bound
      % -----------------
      % Add the random upper bound to the graph, corresponding to random
      % prediction. 
      hold on;
      if plotRandLine,
	t = repmat(randModel.t, ...
		   [1 size(data{d}.imageBlobs,2) data{d}.numImages]);
	e = run_model_test(test, data{d}.words, data{d}.blobWords, ...
			   data{trainingSet}.words, t, testParams{:});
	plot([0 numModels+0.5], [e e], [':' randClr]);
      end;
      
      % Plot upper bound
      % ----------------
      % Add the "upper bound" to the graph, corresponding to the prediction
      % of the naive model.
      if plotEmpLine,
	t = naive_trans(naiveModel, data{d});
	e = run_model_test(test, data{d}.words, data{d}.blobWords, ...
			   data{trainingSet}.words, t, testParams{:});
	plot([0 numModels+0.5], [e e], [':' naiveClr]);
      end;
      hold off;
      
      % Set up the legend.
      if ~useBox,
	legend(modelLabels{:}, 'random', 'naive model', 4);
      end;
      
      % Show the plot right now.
      drawnow;
      
    end; % for each dataset
    
  catch,
    disp(lasterr);
    return;
  end; %try
  
  % Restore the old path.
  path(oldPath);
    
  