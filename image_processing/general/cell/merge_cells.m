% MERGE_CELLS    Merge two cell arrays, removing duplicate elements.
%    CNEW = MERGE_CELLS(C1,C2) creates a new cell array CNEW, merging the
%    elements of C1 and C2. It assume that the cell arrays C1 and C2 do
%    not already contain duplicates.

function cnew = merge_cells (c1, c2)
  
  % Merge the two cells c1 and c2 and remove any duplicates. Assume each
  % of the cells on it's own have no duplicates.
  cnew = c1;
  n = length(cnew);
  
  % Repeat for each element of c2.
  for i = 1:length(c2),
    
    found = 0;
    
    % See if the element is already in cnew.
    for j = 1:n,
      if strcmp(char(c2{i}),char(cnew{j})),
	found = 1;
	break;
      end;
    end;
    
    if ~found,
      n = n + 1;
      cnew{n} = char(c2{i});
    end;
    
  end;
  