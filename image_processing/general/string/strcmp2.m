% STRCMP    Compares to strings.
%    The function call is STRCMP2(S1,S2) and returns -1 if s1 is before 
%    s2, 0 if s1 equals s2, or 1 if s1 is after s2.

function y = strcmp2 (s1, s2)
  
  % Make the strings the same size.
  l1 = length(s1);
  l2 = length(s2);
  if l1 < l2,
    s1 = [s1 repmat(0,[1 l2 - l1])];
  elseif l2 < l1,
    s2 = [s2 repmat(0,[1 l1 - l2])];
  end;

  % Compare the two strings.
  x = -(s1 < s2) + (s1 > s2);
  
  before = min(find(x == 1));
  after  = min(find(x == -1));
  
  if length(before),
    if length(after),
      if before < after,
	y = 1;
      else,
	y = -1;
      end;
    else,
      y = 1;
    end;
  else,
    if length(after),
      y = -1;
    else,
      y = 0;
    end;
  end;
  
