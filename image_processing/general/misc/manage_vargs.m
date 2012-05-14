% MANAGE_VARGS    Setup variable argument list with either default
%                 or user-specified arguments.
%    VARARGOUT = MANAGE_VARGS(VARARGIN,DEFARGS) returns a list of
%    arguments, where the number of arguments is specified by the length
%    of DEFARGS. VARARGIN is a cell array of user-specified argument
%    values and DEFARGS are the default argument values. If the user does
%    not provide a value for an argument, the default value is used.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function varargout = manage_vargs (x, defargs)
  
  varargin = x;
  
  % Get the number of default and user-specified arguments.
  n = length(defargs);
  m = length(varargin);

  % Get the parameters from varargin or defargs.
  for i = 1:n,
    if m >= i,
      varargout{i} = varargin{i};
    else,
      varargout{i} = defargs{i};
    end;
  end;
  
  