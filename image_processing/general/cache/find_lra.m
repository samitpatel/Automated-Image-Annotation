% FIND_LRA    Find the least recent accessed element index in the cache. 
%    I = FIND_LRA(CACHE) returns the index I of the least recently
%    accessed accessed element in the CACHE. In the case of the tie, will
%    return an arbitrary element index.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function i = find_lra (cache)
  
  % Create the vector of "last accesses". The higher the number the
  % further away it was accessed. The maximum time is one greater than
  % the maximum possible size of the access queue. This is referred to as
  % the "last possible access", or "limit".
  indices = cache.aq.limit * ones(cache.size,1);
    
  % Populate the cache indices with last accesses.
  for i = length(cache.aq.elems):-1:1,
    indices(cache.aq.elems(i)) = i;
  end;

  % Get the cache index with the largest access time.
  [ans i] = max(indices);
