% GROUP    Group elements together if they are close enough to each
%          other, as defined by a threshold.
%    The function call is GROUP(X,T), where X is a vector of elements and
%    T is the threshold. It returns a G x N matrix, where G is the number
%    of groups and N is the maximum number of elements in a single group,
%    and each entry is an index to the elements vector X.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function g = group (x,t)
  
  % If there are no elements just quit.
  if ~length(x),
    g = [];
    return;  
  end;
  
  % Sort the elements of x.
  y = sort(x);

  % Put them into groups.  
  j    = 1;
  c    = 1;
  b    = y(1);
  g(1) = b;
  for i = 2:length(y),
    if (y(i) - b) <= t,
      c = c + 1;
      g(j,c) = y(i);
    else,
      j = j + 1;
      c = 1;
      b = y(i);
      g(j,1) = b;
    end;
  end;
  
  