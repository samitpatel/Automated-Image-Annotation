% GET_CACHE_ELEM    Retrieve a stored element from the cache.
%    [ELEM,CACHE] = GET_CACHE_ELEM(CACHE,LABEL) returns the element ELEM
%    stored in CACHE with the specified label. If it cannot find the
%    corresponding cache element, it returns an empty matrix. It also
%    returns the changed to the cache in the second returned output.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function [elem,cache] = get_cache_elem (cache, label)
  
  if length(cache.index.contents) < label | ~cache.index.contents(label),
    elem = [];
  else,
    i = cache.index.contents(label);
    elem = cache.elems{i};
    cache = add_access(cache, i);
  end;
  
