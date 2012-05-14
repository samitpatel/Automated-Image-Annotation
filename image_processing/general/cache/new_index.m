% NEW_INDEX    Create a new index.
%    INDEX = NEW_INDEX returns an empty index struct.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function index = new_index
  
  index.index    = zeros(0,1);
  index.contents = zeros(0,1);