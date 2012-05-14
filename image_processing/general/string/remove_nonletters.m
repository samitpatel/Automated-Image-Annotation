% REMOVE_NONLETTERS    Remove the non-letter characters from the string.
%    RESULT = REMOVE_NONLETTERS(S) returns the string S with only the
%    letter characters remaining.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function result = remove_nonletters (s)
  
    result = '';
    for i = 1:length(s),
      c = s(i);
      if isletter(c),
        result = [result c];
      end;
    end;

  