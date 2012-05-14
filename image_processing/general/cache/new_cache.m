% NEW_CACHE    Creates a new cache.
%    CACHE = NEW_CACHE(S,T) returns an empty cache. S is the maximum
%    number of elements contained in the cache and T is the maximum size
%    of the access queue.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function cache = new_cache (s, t)
  
  % Setup the access queue.
  aq.elems   = [];
  aq.maxSize = t;
  aq.limit   = t*2+1;
  
  % Setup the cache.
  cache.maxSize = s;
  cache.size    = 0;
  cache.elems   = cell(s,1);
  cache.aq      = aq;
  cache.index   = new_index;
 