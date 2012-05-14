% WRITE_DATA_SPECS    Write the specifications for the data sets to disk.   
%    WRITE_DATA_SPECS(D,LABELS,DATA) writes to disk the data sets
%    specifications in directory D. LABELS is an N x 1 cell array of data
%    set labels, where N is the number of data sets. DATA is a N x 1 cell
%    array of data sets. For more information on the fields for each
%    element of DATA, see WRITE_DATA.
%
%    This function creates a file called "specs" in the directory D. It
%    contains all the information with regards to the data set labels,
%    the feature names and counts, and the specifications of the image
%    sets. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_data_specs (d, labels, data)
  
  % Write out the "specs" file.
  outfile = openfile(d,'specs','w');
  
  % Write out a list of the data sets
  % ---------------------------------
  fprintf(outfile, 'DATA SETS\n');
  numDatasets = length(labels);
  for d = 1:numDatasets,
    fprintf(outfile, '%s\n', labels{d});
  end;
  fprintf(outfile, '\n');
  
  % Write out the feature information
  % ---------------------------------
  fprintf(outfile, 'FEATURES\n');
  n = 0;
  for f = 1:length(data.featureNames),
    fprintf(outfile, '%i %i:%i %s\n', data.featureCounts(f), ...
	    n+1, n+data.featureCounts(f), data.featureNames{f});
    n = n + data.featureCounts(f);
  end;
  fprintf(outfile, '\n');
  clear n
  
  % Write out the image sets
  % ------------------------
  numImagesets = length(data.imgSuffix);
  for d = 1:numImagesets,
    fprintf(outfile, 'IMAGE SET %i\n', d);
    fprintf(outfile, 'dir: %s\n', data.datadir{d});
    fprintf(outfile, 'segments_subdir: %s\n', data.segSubdir{d});
    fprintf(outfile, 'images_subdir: %s\n', data.imgSubdir{d});
    fprintf(outfile, 'segimages_subdir: %s\n', data.segimgSubdir{d});
    fprintf(outfile, 'blobimages_subdir: %s\n', data.blobimgSubdir{d});
    fprintf(outfile, 'image_suffix: %s\n', data.imgSuffix{d});
    fprintf(outfile, '\n');
  end;
  
  fclose(outfile);
  
% ---------------------------------------------------------------------
function file = openfile (d, f, perm)

  filename = [d '/' f];
  file     = fopen(filename, perm);
  if file == -1,
    error(sprintf('Unable to open file %s for %s access', ...
		  filename, perm));
  end;
