% ADD_ACCESS    Adds access instance to the access queue.
%    CACHE = ADD_ACCESS(CACHE,I) adds access of element index I to the
%    access queue located in CACHE, and then returns the changes to the
%    cache struct.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function cache = add_access (cache, i)
  
  % Check to see if the access queue has gotten very big. If so, return
  % it back to the unofficial maximum size.
  if length(cache.aq.elems) >= 2*cache.aq.maxSize,
    cache.aq.elems = cache.aq.elems(1:cache.aq.maxSize);
  end;  

  % Add the element to the access queue.
  cache.aq.elems = [i cache.aq.elems];
  
