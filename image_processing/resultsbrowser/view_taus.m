% VIEW_TAUS    Display the dimensions of Tau in a graph.
%    VIEW_TAUS(DATA_DIR,MODEL_NAME,USEBOX,TRIAL) displays the parameter
%    Tau from model MODEL_NAME trained on the data set located in
%    DATA_DIR, averaged over all the trials. USEBOX is an optional
%    parameter. If it is 1, use the Box and Whisker plot. Otherwise, use
%    a point plot. TRIAL is also an optional parameter. If it is not
%    empty, plot the Taus only for that trial number.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function view_taus (data_dir, model_name, varargin)
  
  % Function constants.
  numReqdArgs = 2;
  generalPath = '../general';
  trialPrefix = 'trial';
  horizThresh = 0.005;
  vertSep     = 0.1;

  % Default arguments.
  defaultUseBox = 1;
  defaultHTrial = [];
  
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
    defargs    = { defaultUseBox;
		   defaultHTrial  };
    [ useBox, ...
      hTrial  ] = manage_vargs(varargin, defargs);
    clear defargs varargin numReqdArgs defaultUseBox defaultHTrial
  
    % Get number of trials.
    model_dir = [data_dir '/results/' model_name];
    files     = get_file_list(model_dir, '', -1, trialPrefix);
    numTrials = length(files);
    clear files
    
    % If the number of trials is 1 for at least one of the trials, "set
    % useBox" to 0. 
    if numTrials < 2,
      useBox = 0;
    end;

    % Load the taus for each trial.
    for i = 1:numTrials,
      trial_dir = sprintf('%s/%s%i', model_dir, trialPrefix, i);
      tau       = load_tau(trial_dir, 'tau');
      taus(i,1:length(tau)) = tau';
    end;
    
    % Plot the results.
    cf = figure;
    set(cf,'NumberTitle','off','Name',sprintf('Tau for %s',model_name));
    F = size(taus,2);
    if useBox,
      % Draw the box plot.
      boxplot(taus, 1);
    else,
      % Draw the point plot.
	hold on;
	
	% Repeat for each dimension of tau.
	for f = 1:F,
	  tau = sort(taus(:,f));
	  g = group(tau,horizThresh);
	  x = [];
	  
	  % Calculate the x's.
	  % Repeat for each group.
	  for i = 1:size(g,1),
	    c = sum(g(i,:) > 0);
	    x = [x (([1:c]-(1+c)/2)*vertSep)];
	  end;
	  
	  % Plot the points for that dimension.
	  plot(f+x,tau','+b');
	  if length(hTrial),
	    plot(f+x(hTrial),tau(hTrial)','+r');
	  end;
	end;
      end;
      
      axis([0.5 F + 0.5 -max(max(taus))/4 max(max(taus))+0.01]);
      xlabel('Dimension');
      ylabel('Tau value');
      title(sprintf('Tau for %s', model_name), ...
	    'FontWeight', 'bold');

      % Load the feature names.
      dataSpecs = load_data_specs(data_dir);
      
      % Load the model specs.
      modelParams = load_model_params(model_dir, [], 'specs');
      
      % Figure out what the feature numbers correspond to.
      i = 1;
      for f = 1:length(dataSpecs.featureCounts),
	n = dataSpecs.featureCounts(f);
	fIndex(i:i+n-1) = f;
	i = i + n;
      end;
      
      % Add the model labels to the graph.
      for f = 1:F,
        text(f, min(taus(:,f)) - 0.025, ...
	     dataSpecs.featureNames{fIndex(modelParams.featureSel(f))}, ...
	     'FontSize', 9, 'Rotation', 90, ...
	     'HorizontalAlignment', 'right');
      end;
    
  catch,
    disp(lasterr);
    return;
  end;
  