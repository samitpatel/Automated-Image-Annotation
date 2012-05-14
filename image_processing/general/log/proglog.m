% PROGLOG    Print string to disk and to progress log.
%    PROGLOG(S,...) displays the string S and optional parameters used by
%    the SPRINTF function. Before using this function, initialize the
%    global variable PROGLOG to an empty string.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function proglog (s, varargin)
  
  global progress_log
  
  if length(varargin),
    s = sprintf([s '\n'], varargin{:});
  else,
    s = sprintf([s '\n']);
  end;
  
  progress_log = [progress_log s];
  fprintf(['   ' s]);
  
  