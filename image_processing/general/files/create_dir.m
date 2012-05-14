% CREATE_DIR    Make a new directory if it doesn't exist already.
%    RD = CREATE_DIR(D,SD) creates a new sub-directory SD in the
%    directory D, if it doesn't already exist. The complete relative
%    pathname for SD is returned in RD.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function rd = create_dir (d, sd)
  
  % Make directory if it doesn't exist already.
  status = mkdir(d, sd);
  rd = [d '/' sd];
