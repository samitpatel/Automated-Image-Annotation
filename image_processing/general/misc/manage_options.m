% MANAGE_OPTIONS    Setup argument list with either default or
%                   user-specified arguments. 
%    VARARGOUT = MANAGE_OPTIONS(OPTS,DEFOPTS) returns a list of
%    arguments, where the number of arguments is specified by the length 
%    of DEFOPTS. OPTS is a cell array of user-specified argument values
%    and DEFOPTS are the default argument values. If the user does not
%    provide a value for an argument, the default value is used. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function varargout = manage_options (opts, defopts)
  
  % Essentially, what we will do is run "manage_vargs" first, which takes
  % care of the problem when we have differing sizes for cell arrays
  % between "opts" and "defopts". Once we do that, we replace the
  % outputted options by default ones if they are empty.
  % Get the number of default and user-specified arguments.
  n = length(defopts);
  m = length(opts);

  % Get the parameters from varargin or defargs.
  for i = 1:n,
    if m >= i & length(opts{i}),
      varargout{i} = opts{i};
    else,
      varargout{i} = defopts{i};
    end;
  end;
