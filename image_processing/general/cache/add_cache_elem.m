% ADD_CACHE_ELEM    Store new element in cache.
%    CACHE = ADD_CACHE_ELEM(CACHE,ELEM,LABEL) stores ELEM with
%    corresponding LABEL in CACHE and returns the changes.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function cache = add_cache_elem (cache, elem, label)
  
  % First check to see if the element is already in the cache. If so, do
  % nothing. 
  tElem = get_cache_elem(cache, label);
  if length(tElem),
    return;
  end;
  
  % Find an appropriate cache index.
  if cache.size < cache.maxSize,
    
    % We don't have to remove the old ones.
    cache.size = cache.size + 1;
    i = cache.size;
  else,
    
    % We're going to have to remove one of the elements in the cache.
    i = find_lra(cache);
  end;
    
  % Put the information into the cache.
  cache.index.index(i)        = label;
  cache.index.contents(label) = i;
  cache.elems{i}              = elem;
  
  % Add the access to the queue.
  cache = add_access(cache, i);
