% WRITE_IMAGE_LABELS    Write the image labels to disk.
%    WRITE_IMAGE_LABELS(D,F,IMAGE_LABELS) writes the image labels
%    information to file F in directory D. For more information on the
%    struct IMAGE_LABELS, see /GENERAL/DATA/LOAD_IMAGE_LABELS.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_image_labels (d, f, image_labels)
  
  % Create image index file
  % -----------------------
  filename = [d '/' f];
  outfile = fopen(filename, 'w');
  if outfile == -1,
    error(sprintf('Unable to open file %s for writing', filename));
  end;

  numImages = length(image_labels.images);
  [ans maxNumWords] = size(image_labels.imageWords);
  [ans maxNumBlobs maxNumCorresp] = size(image_labels.blobWords);

  % Write out the maximum number of blobs.
  fprintf(outfile, '%i\n', maxNumBlobs);  
  
  % Repeat for each image.
  for i = 1:numImages,
    
    % Write out the image name.
    fprintf(outfile, '%s\n', image_labels.images{i});
    
    % Write out the words.
    for w = 1:maxNumWords,
      wrd = image_labels.imageWords{i,w};
      if ~length(wrd), break; end;
      fprintf(outfile, '%s ', wrd);
    end;
    fprintf(outfile, '\n');
    
    % Write out the correspondences.
    for b = 1:maxNumBlobs,
      
      % If there is at least one correspondence for that blob, write out
      % the correspondences for that blob.
      if length(image_labels.blobWords{i,b,1}),
	
	% Write out the blob number.
	fprintf(outfile, '%i ', b);

	% Write out the correspondences.
	for w = 1:maxNumCorresp,
	  wrd = image_labels.blobWords{i,b,w};
	  if ~length(wrd), 
	    break; 
	  end;
	  fprintf(outfile, '%s ', image_labels.blobWords{i,b,w});
	end;
	fprintf(outfile, '\n');
      end; %if numCorresp
      
    end; %for..number of blobs
    
    % Write a blank line to signify the end of the image.
    fprintf(outfile, '\n');
    
  end; %for..each image.
  
  % Close the file.
  fclose(outfile);  