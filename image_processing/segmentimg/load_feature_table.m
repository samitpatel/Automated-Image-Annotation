% LOAD_FEATURE_TABLE    Load the feature information from disk.
%    FEATURES = LOAD_FEATURE_TABLE(D,F) loads the feature table with file
%    name F from directory D. The result FEATURES is a struct with the
%    following fields:
%       - num        N, the number of features
%       - names      a cell of length N containing the feature names
%       - counts     an array of length N with the number of dimensions
%                    for each feature.
%       - functions  a cell of length N with a function handle
%                    corresponding to each feature name.
%       - file       the name of the file loaded
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function features = load_feature_table (d, f)
  
  % Open feature table file
  % -----------------------
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to read file %s', filename));
  end;
  
  % Initialize feature table
  % ------------------------
  features.num       = 0;
  features.names     = {};
  features.counts    = [];
  features.functions = {};
  features.file      = f;
  
  % Read in information from file
  % -----------------------------
  while 1,
    s = fgetl(infile);
    if ischar(s),
      
      % Get feature name
      % ----------------
      % Find the location of the two quotes. The string in between the
      % quotes is the feature name.
      i = strfind(s,'"');
      if ~length(i), break; end;
      features.num                   = features.num + 1;
      features.names{features.num,1} = s(i(1)+1:i(2)-1);
      s = s(i(2)+1:length(s));
      
      % Get feature count and function name
      % -----------------------------------
      % Parse the rest of the string and get the feature count and the
      % function name.
      ss = parse_string(s);
      if length(ss) < 2, break; end;
      features.counts(features.num,1)    = str2num(ss{1});
      features.functions{features.num,1} = ss{2};
      
    else, break; end;
  end;
  
  % Close the file.
  fclose(infile);  
  