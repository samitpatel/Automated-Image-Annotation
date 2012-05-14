% WRITE_MATRIX    Write a matrix to disk.
%    WRITE_MATRIX(D,F,M,PRECISION) writes matrix M to file F in directory
%    D using floating-point precision PRECISION. PRECISION is an optional
%    parameter. The default is 6. This only works for one or two
%    dimensional matrices. You can now load this matrix using the 
%    function IMPORTDATA. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_matrix (d, f, m, precision)
  
  if nargin < 4,
    precision = 6;
  end;
  
  % Open the log file.
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to read file %s', filename));
  end;
  
  s = ['%0.' num2str(precision) 'g '];
  
  % Write out the matrix.
  for i = 1:size(m,1),
    for j = 1:size(m,2),
      fprintf(outfile, s, m(i,j));
    end;
    fprintf(outfile, '\n');
  end;
  
  % Close the file.
  fclose(outfile);

      