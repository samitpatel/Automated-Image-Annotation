% CAT_CELLS    Merge two cells.
%    CNEW = CAT_CELLS(DIM,C1,C2) merges the two cells C1 and C2 along
%    dimension DIM. If the dimensions of C1 and C2 are not equal along
%    the other dimensions, the missing entries are filled with
%    empty cell elements. Note that this only works for cells of
%    dimension at most 3.  
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function cnew = cat_cells (dim, c1, c2)
  
  s1 = size(c1);
  s2 = size(c2);
  if ~min(s1),
    cnew = c2;
  elseif ~min(s2),
    cnew = c1;
  else,

    % Create the empty cells.
    w  = length(s1) - length(s2);
    s1 = [s1 ones(1,max(-w,0))];
    s2 = [s2 ones(1,max(w,0))];
    s  = max([s1; s2]);
  
    s(dim) = s1(dim);
    z1     = cell(s);
    s(dim) = s2(dim);
    z2     = cell(s);
  
    % Concatenate the cells.
    z1(1:size(c1,1), 1:size(c1,2), 1:size(c1,3)) = c1;
    z2(1:size(c2,1), 1:size(c2,2), 1:size(c2,3)) = c2;
    cnew = cat(dim,z1,z2);
  end;
  