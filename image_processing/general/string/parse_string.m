% PARSE_STRING    Parse the string.
%    STRS = PARSE_STRING(STR) returns a cell array STRS of the tokenized
%    elements of STR.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function strs = parse_string (str),  
  
  strs = {};
  n    = 0;
  while length(str),
    [t str] = strtok(str);
    if length(t),
      n = n + 1;
      strs{n} = t;
    end;
  end;
  