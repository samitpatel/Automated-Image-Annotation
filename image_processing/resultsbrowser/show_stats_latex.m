% SHOW_STATS_LATEX   Display the model evaluation statistics in Latex
%                    format .
%    SHOW_STATS(STATS,TRIAL) displays the statistics returned by
%    COMPILE_STATS on trial number TRIAL. To show the averaged results,
%    set TRIAL to 0.
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function show_stats_latex (stats, trial)

  % Function constants.
  generalPath = '../general';
  dataLabelSz = 5;
  
  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs  

  % Repeat for each data set.
  numDatasets = length(stats.sets);
  
  % Grab the precision for the trial.
  for d = 1:numDatasets,
    if trial,
      pr{d}  = stats.sets{d}.pr(:,trial);
      prt{d} = stats.sets{d}.prt(trial);
    else,
      pr{d}  = stats.sets{d}.prAll;
      prt{d} = stats.sets{d}.prtAll;
    end;
  end;
  
  % Get the list of all the words combined in the training and test
  % sets. 
  words = stats.sets{1}.words;
  for d = 2:numDatasets,
    words = merge_cells(words, stats.sets{d}.words);
  end;
  words = sort(words);

  % Get the data labels to be printed.
  for d = 1:numDatasets,
    dataLabels{d} = stats.sets{d}.label;
    dataLabels{d} = dataLabels{d}(1:min(dataLabelSz, ...
					length(dataLabels{d})));
    dataLabels{d} = leftJustify(upper(dataLabels{d}), dataLabelSz);
  end;
  
  % Show the word frequencies
  % -------------------------
  msg   = ['Frequencies of words'];
  fprintf([msg '\n']);
  printLine(length(msg));
  
  % Find the word with the longest length.
  maxWordLen = max([length('WORD') length('TOTALS') ...
		    maxStrLength(words)]);
  numWords = length(words);

  % Top part 1.
  x = dataLabelSz*numDatasets + 3*(numDatasets-1);
  fprintf([leftJustify('', maxWordLen) '  ' ...
	   leftJustify('LABEL%%',x+1) '  ' ...
	   leftJustify('ANNOT%%',x+1) '  PRECISION \n']);
  
  % Top part 2.
  fprintf([leftJustify('WORDS', maxWordLen) '  ']);
  for i = 1:3,
    for d = 1:numDatasets,
      fprintf(dataLabels{d});
      if d < numDatasets,
	fprintf(' | ');
      end;
    end;
    fprintf('  ');
  end;
  fprintf('  \n');
  
  % Repeat for each word.
  for w = 1:numWords,
    wrd = words{w};
    
    % Find the word in the respective data sets.
    wi = zeros(numDatasets, 1);
    for d = 1:numDatasets,
      x = find(strcmp(wrd,stats.sets{d}.words));
      if length(x),
	wi(d) = x;
      else,
	wi(d) = 0;
      end;
    end;
    clear x
    
    % Show the word name.
    fprintf([leftJustify(wrd, maxWordLen) ' & ']);
    
    % Repeat for each data set, show the label word frequency.
    for d = 1:numDatasets,
      if wi(d),
	fprintf('%0.3f', stats.sets{d}.labelWordFreq(wi(d)));
      else,
	fprintf(' n/a ');
      end;

      fprintf(' & ');
    end;
    
    % Repeat for each data set, show the label annotation frequency. 
    for d = 1:numDatasets,
      if wi(d),
	fprintf('%0.3f', stats.sets{d}.annotWordFreq(wi(d)));
      else,
	fprintf(' n/a ');
      end;
      
      fprintf(' & ');
    end;
    
    % Repeat for each data set, show the annotation precision. 
    for d = 1:numDatasets,
      if wi(d),
	fprintf('%0.3f', pr{d}(wi(d)));
      else,
	fprintf(' n/a ');
      end;
      
      if d < numDatasets,
	fprintf(' & ');
      end;
    end;

    fprintf(' \\\\ \n');
  end;

  % Show the totals
  % ---------------
  % Show the word name.
  fprintf([leftJustify('TOTALS', maxWordLen) ' & ']);
  
  % Repeat for each data set, show the frequency totals.
  for i = 1:2,
    for d = 1:numDatasets,
      fprintf('%0.3f & ', 1);
    end;
  end;
  
  % Repeat for each data set, show the annotation precision. 
  for d = 1:numDatasets,
    fprintf('%0.3f', prt{d});
    if d < numDatasets,
      fprintf(' & ');
    end;
  end;
  fprintf(' \\\\ \n\n');
  
  % Show tau
  % --------
  try
    tau = stats.tau;
    msg = ['Tau for ' stats.model];
    fprintf([msg '\n']);
    printLine(length(msg));
    
    maxFeatLen  = max(length('FEATURE'), ...
		      maxStrLength(stats.featureNames));
    numFeatures = length(tau);
    
    fprintf('%s  TAU \n', leftJustify('FEATURE', maxFeatLen));
    
    for f = 1:numFeatures,
      fName = stats.featureNames{f};
      fprintf('%s  %0.3f \n', leftJustify(fName, maxFeatLen), ...
	      tau(f));
    end;
    
  catch
  end
  
  % Restore the old path.
  path(oldPath);
  
% ----------------------------------------------------------
function s = leftJustify (s, n)
  s = [s repmat(' ', [1 n - length(s)])];

% ----------------------------------------------------------
function printLine (n)
  fprintf([repmat('-', [1 n]) '\n']);

% ----------------------------------------------------------
function n = maxStrLength (strs)

  S = length(strs);
  ls = zeros(S, 1);
  for i = 1:S,
    ls(i) = length(strs{i});
  end;
  n = max(ls);

% ----------------------------------------------------------
% Returns -1 if s1 is before s2. 
% Returns  0 if s1 equals s2. 
% Returns  1 if s1 is after s2.
function strcmp2 (s1, s2)
  
  % Make the strings the same size.
  l1 = length(s1);
  l2 = length(s2);
  if l1 < l2,
    s1 = [s1 repmat(0,[1 l2 - l1])];
  elseif l2 < l1,
    s2 = [s2 repmat(0,[1 l1 - l2])];
  end;
  
  