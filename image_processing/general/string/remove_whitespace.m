% REMOVE_WHITESPACE    Remove the whitespace from the string.
%    RESULT = REMOVE_WHITESPACE(S) returns a new string with the
%    whitespace removed from S.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function result = remove_whitespace (s)
  
    result = '';
    for i = 1:length(s),
      c = s(i);
      if ~isspace(c),
        result = [result c];
      end;
    end;

  
