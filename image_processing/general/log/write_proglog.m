% WRITE_PROGLOG    Write the progress log to disk.
%    WRITE_PROGLOG(D,F,PROGRESS_LOG) writes the string PROGRESS_LOG to
%    the file F in directory D.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_proglog (d, f, progress_log)
  
  % Open the log file.
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to write file %s', filename));
  end;
  
  fprintf(outfile, progress_log);
  
  % Close the file.
  fclose(outfile);

    