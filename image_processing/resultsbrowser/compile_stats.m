% COMPILE_STATS   Load statistics from evaluation of a model.
%    COMPILE_STATS(DATA_DIR, MODEL_NAME) loads the statistics from the
%    evaluation of MODEL_NAME on the data set located in DATA_DIR and
%    returns a structure with the following fields:
%      - psi           The parameter learned for the MRF model, averaged
%                      over the trials. 
%      - tau           The shrinkage parameter learned by the MAP model,
%                      averaged over the trials. 
%      - featureNames  1 x F cell array of feature names, where F is the
%                      dimension of the blob data.
%      - model         The name of the model.
%      - stats.sets    A cell array of size 1 x F, where D is the number
%                      of data sets in DATA_DIR. Each entry is a
%                      struct. The most important fields are:
%                      "labelWordFreq" and "annotWordFreq", the frequency
%                      of word tokens occuring in labels and manual
%                      annotations, respectively; "pr", the precision
%                      corresponding to the "pon" error measure for each
%                      word and analog "prAll" averaged over all the
%                      trials; "prt", the total precision and the analog
%                      "prtAll" averaged over the trials.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function stats = compile_stats (data_dir, model_name)

  % Function constants.
  numReqdArgs = 2;
  generalPath = '../general';
  trialPrefix = 'trial'; 
  winNTrials  = 12;

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
  
    % Set up function parameters.
    % (Right now we don't need to worry about this because we
    % don't have any optional parameters.)  

    % Load the data
    % -------------
    specs       = load_data_specs(data_dir);
    data        = load_data(data_dir);
    numDatasets = length(data);
    
    % Get the word tokens.
    for d = 1:numDatasets,
      % Note that the words are already in alphabetical order.
      stats.sets{d}.words = data{d}.words;
    end;
    
    % Get data set labels.
    for d = 1:numDatasets,
      stats.sets{d}.label = data{d}.setlabel;
    end;
    
    % Load the model trials
    % ---------------------
    % Get number of trials.
    numTrials = get_num_trials(data_dir, model_name);

    % Get model label.
    model_dir   = [data_dir '/results/' model_name];
    model       = load_model_params(model_dir, [], 'specs');
    stats.model = model.label;
    
    % Get the names of the features as selected by the model.
    stats.featureNames = {};
    i = 0;
    for f = 1:length(data{1}.featureNames),
      fName = data{1}.featureNames{f};
      for fi = 1:data{1}.featureCounts(f),
        i = i + 1;
        stats.featureNames{i} = fName;
      end;
    end;
    
    stats.featureNames = stats.featureNames(model.featureSel);
    clear model
    
    % Initialize the statistics
    % -------------------------
    tau = [];
    psi = [];
    for d = 1:numDatasets,
      numWords = data{d}.numWords;
      labelWordFreq{d} = zeros(numWords, 1);
      annotWordFreq{d} = zeros(numWords, 1);
      pr{d}            = zeros(numWords, numTrials);
      prt{d}           = zeros(1, numTrials);
    end;
    
    % Load the word frequencies (in labels)
    % -------------------------------------
    % Repeat for each data set.
    
    for d = 1:numDatasets,
      fprintf(['Getting word-label freqencies for data set "' ...
               stats.sets{d}.label '". \n']);
                 
      % Repeat for each image (i.e. document).
      numImages = length(data{d}.images);
      for s = 1:numImages,
        ls   = data{d}.imageWordCounts(s);
        wrds = data{d}.imageWords(s,1:ls);
        labelWordFreq{d}(wrds) = labelWordFreq{d}(wrds) + 1;
      end;  
    end;
    
    % Load the word frequencies (in annotations)
    % ------------------------------------------
    % Repeat for each data set
    for d = 1:numDatasets,
      fprintf(['Getting word-annotation freqencies for data set "' ...
               stats.sets{d}.label '". \n']);
      numImages = length(data{d}.images);
      numWords  = data{d}.numWords;
      
      % Repeat for each image (i.e. document), and then for
      % each patch (i.e. blob).
      for s = 1:numImages,
        
        % Get the annotation counts for that image.
        x = zeros(numWords, 1);
        numBlobs = data{d}.imageBlobCounts(s);
        for b = 1:numBlobs,
          ls = data{d}.blobWordCounts(s,b);
          if ls,
            wrds = data{d}.blobWords(1:ls,b,s)';
            x(wrds) = x(wrds) + 1/ls;
          end;
        end;
        
        annotWordFreq{d} = annotWordFreq{d} + x / numBlobs;
      end;
    end; %for each dataset
    
    % Load the items that are model-dependent
    % ---------------------------------------
    % Repeat for each model trial.
    for i = 1:numTrials,    
      fprintf('Getting statistics for trial %i.\n', i);
      trial_dir = [model_dir sprintf('/%s%i', trialPrefix, i)];

      % Load tau
      % --------
      % Load the model parameter "tau" if it exists. If it doesn't 
      % exist, then set "tau" to empty.
      try
        taui = importdata([trial_dir '/tau']);
        if length(tau),
          tau = tau + taui;
        else,
          tau = taui;
        end;
      catch
        tau = [];
      end;
      clear taui
      
      % Load psi
      % --------
      try
        psii = importdata([trial_dir '/psi1']);
        if length(psi),
          psi = psi + psii;
        else,
          psi = psii;
        end;
      catch
        psi = [];
      end;
      clear psii
      
      % Load the precision/recall for each word
      % ---------------------------------------
      % The idea is that we will keep track of two statistics at the
      % same time for each trial:
      %   1. The number of times we consider word i for each blob.
      %   2. The numbber of times the word i is correct over the blobs.
      % If there is more than one manual annotation for a blob, we only
      % consider the word that won. If none won, then we split the blame
      % uniformly. 
            
      % Load the model words.
      modelWords = importdata([model_dir '/words']);
      
      % Repeat for each data set.
      for d = 1:numDatasets,
      
        % Load the model translation table.
        t        = load_translation(trial_dir, data{d});
        [ans t]  = sort(-t,1);
        t        = t(1,:,:);

        numWordTokens     = data{d}.numWords;
        manualWords       = data{d}.words;
        wordPr            = zeros(numWordTokens,1);
        numImgsConsidered = zeros(numWordTokens,1);
        numImgsConsAll    = 0;
	wordPrAll         = 0;
	
        % Repeat for each image, and then for each blob in the image.
        numImages = length(data{d}.images);
        for s = 1:numImages,
          
          numBlobs           = data{d}.imageBlobCounts(s);
          blobCountsForWords = zeros(numWordTokens,1);
          prCountsForWords   = zeros(numWordTokens,1);
          numBlobsConsidered = 0;
          
          % Repeat for each blob in the image.
          for b = 1:numBlobs,
            
            % Check to see if we should consider this blob. We only 
            % consider it if there is at least 1 manually-annotated
            % word.
            numWords = data{d}.blobWordCounts(s,b);
            if numWords,
              numBlobsConsidered = numBlobsConsidered + 1;
              correctAnnotation  = 0;
              
              for w = 1:numWords,
                wi    = data{d}.blobWords(w,b,s);
                wrd   = manualWords(wi);
                wrds  = find(strcmp(modelWords, wrd));
                if length(wrds), 
                  found = find(t(:,b,s) == wrds);
                else,
                  found = [];
                end;
                
                if length(found),
                  correctAnnotation      = 1;
                  blobCountsForWords(wi) = blobCountsForWords(wi) + 1;
                  prCountsForWords(wi)   = prCountsForWords(wi) + 1;
                  break;
                end;
              end; % for each word in the manual annotation
              
              % If we didn't find the a correct annotation, then we
              % have to distribute the blame equally among all the 
              % words in the blob.
              if ~correctAnnotation,
                x = 1 / numWords;
                for w = 1:numWords,
                  wi = data{d}.blobWords(w,b,s);
                  blobCountsForWords(wi) = blobCountsForWords(wi) + x;
                end;
              end;
              
            end; % if the blob contains at least one word.
          end; % for each blob in the image.
          
          % If there was at least one blob in the image, increment
          % the precision.
          if numBlobs,
            w = find(blobCountsForWords);
            numImgsConsidered(w) = numImgsConsidered(w) + 1;
	    numImgsConsAll = numImgsConsAll + 1;
            wordPr(w) = wordPr(w) + prCountsForWords(w) ...
                                  ./ blobCountsForWords(w);
	    wordPrAll = wordPrAll + mean(prCountsForWords(w) ./ ...
					 blobCountsForWords(w));
          end; % if there was at least one blob in the image.
        end; % for each image in the data set.
        
        % Now that we have the wordPr summed over all the images,
        % divide by the number of images considered for each word.
        w  = find(numImgsConsidered);
        wn = find(~numImgsConsidered);
        pr{d}(w,i)  = wordPr(w) ./ numImgsConsidered(w);
        pr{d}(wn,i) = nan;
	prt{d}(i)   = wordPrAll / numImgsConsAll;
      end; % for each data set.
      
    end; %for each model trial.

    % Average the Tau and Psi model parameters and return tau and psi (if
    % they exist). 
    if length(tau),
      stats.tau = tau / numTrials;
    end;
    if length(psi),
      stats.psi = psi / numTrials;
    end;
    clear tau psi
    
    % Normalize the word frequencies and return it in "stats".
    for d = 1:numDatasets,
      stats.sets{d}.labelWordFreq = labelWordFreq{d} ...
        / sum(labelWordFreq{d});
    end;
    
    % Normalize the annotaiton frequencies and return it in "stats".
    for d = 1:numDatasets,
      stats.sets{d}.annotWordFreq = annotWordFreq{d} ...
        / sum(annotWordFreq{d});
    end;  
    
    % Normalize the precision/recall and return it in "stats".
    for d = 1:numDatasets,
      stats.sets{d}.pr     = pr{d};
      stats.sets{d}.prt    = prt{d};
      stats.sets{d}.prAll  = mean(pr{d},2);
      stats.sets{d}.prtAll = mean(prt{d});
    end;
    
  catch,
    disp(lasterr);
    return;
  end; %try
  
  % Restore the old path.
  path(oldPath);
 
 
