% SHOW_PSI    Display a discretized version of PSI.
%    SHOW_PSI(STATS) returns the discretized version of STATS.PSI, where
%    STATS is the return value of COMPILE_STATS. It also outputs a Latex
%    table. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function x = show_psi (stats)
  
  clc;
  
  psi      = stats.psi;
  words    = stats.sets{1}.words;
  numWords = length(words);
  x = (psi <= 0.01)*255 + ...
      (0.01 < psi & psi <= 0.02)*170 + ...
      (0.02 < psi & psi <= 0.03)*85 + ...
      (0.03 < psi)*0; 
  imshow(uint8(imresize(x,2)));

  % Print the table.
  fprintf('\\begin{tabular}{@{}>{\\tablesizeb}r@{}');
  for w = 1:numWords,
    fprintf('@{}>{\\tablesizeb}c@{}');
  end;
  fprintf('} \n & ');
 
  for w = 1:numWords,
    fprintf('\\begin{rotate}{90}%s\\end{rotate}', words{w});
    if w < numWords, fprintf(' & \n'); end;
  end;
  fprintf(' \\\\ \n');
  
  for w1 = 1:numWords,
    fprintf(words{w1});
    for w2 = 1:numWords,
      if x(w1,w2) == 170,
	clr = 'tcola';
      elseif x(w1,w2) == 85,
	clr = 'tcolb';
      elseif x (w1,w2) == 0,
	clr = 'tcolc';
      else clr = '';
      end;
      if length(clr),
	% fprintf('\\colorbox{%s}{}', clr);
      end;
      if w2 < numWords, fprintf(' & '); end;
    end;
    fprintf(' \\\\ \n');
  end;
  
  fprintf('\\end{tabular} \n');