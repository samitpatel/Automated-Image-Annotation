% GET_FILE_LIST    Create a listing of the files in a directory.
%    FILES = GET_FILE_LIST(D,SUFFIX) returns a listing of the files in
%    directory D with the specified SUFFIX. To get a listing of all files
%    and directories, enter a blank string for the SUFFIX  parameter. The
%    directory and suffix are pruned from the final files listing.
%
%    FILES = GET_FILE_LIST(D,SUFFIX,N) returns a list of files of length
%    at most N. By default N is -1, which corresponds to no limit to the
%    number of files.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function files = get_file_list (d, suffix, varargin)

  % Manage the optional arguments.
  [maxNumFiles prefix] = manage_vargs(varargin, {-1; ''});
  
  % Initialize the list of files.
  files = {};
  
  % Get a directory listing
  % -----------------------
  [err r] = system(sprintf('ls -d -A1 %s/%s*%s', d, prefix, suffix));
  if err, % Error checking.
    error('Cannot get the list of files using the system call "ls".');
  end;

  % Tokenize directory listing
  % --------------------------
  % Tokenize the directory listing to find all the files.
  numFiles = 0;
  while length(r),
    [t r] = strtok(r);
    if length(t),
      numFiles = numFiles + 1;
      files{numFiles,1} = t;
      
      % Stop if we've reached the limit on the number of files. This
      % condition will never be met if numFiles is -1.
      if numFiles == maxNumFiles,
	break;
      end;
    end;
  end;
  
  % Remove the path and suffix from each of the names. To do that, we
  % simply find the last occurence of the slash and remove the suffix.
  for i = 1:numFiles,
    fn = files{i};
    fn = fn(1:(length(fn) - length(suffix)));
    n  = strfind(fn, '/');
    if length(n),
      fn = fn(n(length(n))+1:length(fn));
    end;
    files{i} = fn;
  end;
