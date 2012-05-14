% REM_CELL_ELEMS   Remove elements from a cell array.
%    CNEW = REM_CELL_ELEMS(C,ELEMS) removes the cell array of elements
%    ELEMS from cell array C. The result is contained in CNEW.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function cnew = rem_cell_elems (c, elems)

  if ~length(elems),
    cnew = c;
    return;
  end;
  
  % Repeat for each element we want to remove.
  for i = 1:length(elems),
    
    cnew = {};
    k = 0;
    % Repeat for each element in the original cell.
    for j = 1:length(c),
      if ~strcmp(char(c{j}),char(elems{i})),
	k = k + 1;
	cnew{k,1} = char(c{j});
      end;
    end;
  
    c = cnew;
  end;
