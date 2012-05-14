% WRITE_DATA    Write a data set to disk.
%    WRITE_DATA(DATADIR,LABELS,DATA) writes a data set to disk in the
%    directory DATADIR. This function creates the following files for
%    each data set:
%      - images
%      - words
%      - image_words
%      - image_blobs
%      - blob_words
%      - blobs
%      - adjacencies
%    The files for each data set is stored in a separate subdirectory
%    with the same name as the data set label. In addition, WRITE_DATA
%    creates a file called "specs" in the main directory. For more
%    information on this file, see WRITE_DATA_SPECS.
%
%    The parameter DATA is a struct with the following fields:
%      - imgSuffix      For information on these fields, see 
%      - imgSubdir      /GENERAL/DATA/LOAD_IMAGE_INDEX.
%      - segSubdir
%      - segimgSubdir
%      - blobimgSubdir
%
%      - images         N x 1 array of image names.
%      - imgsets        N x 1 array of data set indices
%
%      - blobCounts     For information on these fields, see
%      - blobFeatures   /GENERAL/DATA/LOAD_BLOB_FEATURES.
%      - featureNames
%      - featureCounts
%
%      - adjacencies    For information on this field, see
%                       /GENERAL/DATA/LOAD_BLOB_ADJACENCIES. 
%
%      - wordCounts     For information on these fields, see
%      - imageWords     /GENERAL/DATA/LOAD_IMAGE_LABELS.
%      - correspCounts
%      - blobWords
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_data (datadir, labels, data)

  % Write out specs file
  % --------------------
  write_data_specs(datadir, labels, data{1});
  
  % Write out information for each data set
  % ---------------------------------------
  numDatasets = length(labels);
  for d = 1:numDatasets,

    % Create the subdirectory "label" if it doesn't exist already.
    label = labels{d};
    sd    = create_dir(datadir, label);
    
    dt          = data{d};
    numImages   = length(dt.images);
    numFeatures = size(dt.blobFeatures,1);
    
    % Create data matrices in preparation for disk writing
    % ----------------------------------------------------
    % Initialize new matrices.
    documentWords = zeros(numImages, max(dt.wordCounts));
    documentBlobs = zeros(numImages, max(dt.blobCounts));
    blobWords     = zeros(sum(dt.blobCounts),max(max(dt.correspCounts)));
    adjacencies   = [];
    
    % Create the vocabulary, the documentWords, documentBlobs and
    % blobWords. 
    vocab = labelfunc('newVocab', dt);
    bNum  = 0;
    for i = 1:numImages,
      for w = 1:dt.wordCounts(i),
        documentWords(i,w) = labelfunc('findWordInVocab', vocab, ...
				       dt.imageWords{i,w});
      end;
    
      for b = 1:dt.blobCounts(i),
        % Add blob to documentBlobs.
        bNum = bNum + 1;
        documentBlobs(i,b) = bNum;
      
        % Add words to blobWords.
	if b <= size(dt.correspCounts,2),
	  for w = 1:dt.correspCounts(i,b),
	    blobWords(bNum,w) = labelfunc('findWordInVocab', vocab, ...
					  dt.blobWords{i,b,w});
	  end;      
	end;
      end;
      
      % Add the adjacencies to the "mother" matrix.
      adjacencies = cat_matrix(1, adjacencies, dt.adjacencies{i});
    end;
  
    numMaxWords     = size(documentWords,2);
    numMaxBlobs     = size(documentBlobs,2);
    numMaxBlobWords = size(blobWords,2);
    
    % Write "images" file
    % -------------------
    % Write the images and their associated datasets to disk.
    outfile = openfile(sd,'images','w');
    for i = 1:numImages,
      fprintf(outfile, '%i %s\n', dt.imgsets(i), dt.images{i});
    end;
    fclose(outfile);
    
    % Write "words" file
    % ------------------
    % Write the words by composing a vocabulary from the dataset.
    outfile = openfile(sd,'words','w');
    for w = 1:vocab.numWords,
      fprintf(outfile, '%s\n', vocab.words{w});
    end;
    fclose(outfile);
  
    % Write "image_words" file
    % ------------------------
    outfile = openfile(sd,'image_words','w');
    for i = 1:numImages,
      for w = 1:numMaxWords,
        fprintf(outfile, '%i ', documentWords(i,w));
      end;
      fprintf(outfile, '\n');
    end;
    fclose(outfile);
  
    % Write "image_blobs" file
    % ------------------------
    outfile = openfile(sd,'image_blobs','w');
    for i = 1:numImages,
      for b = 1:numMaxBlobs,
        fprintf(outfile, '%i ', documentBlobs(i,b));
      end;
      fprintf(outfile, '\n');
    end;
    fclose(outfile);
  
    % Write "blob_words" file
    % -----------------------
    outfile  = openfile(sd,'blob_words','w');
    numBlobs = size(blobWords,1);
    for b = 1:numBlobs,
      for w = 1:numMaxBlobWords,
        fprintf(outfile, '%i ', blobWords(b,w));
      end;
      fprintf(outfile, '\n');
    end;
    fclose(outfile);
  
    % Write out "blobs" file
    % ----------------------
    outfile = openfile(sd,'blobs','w');
    for i = 1:numImages,
      for b = 1:dt.blobCounts(i),
        for f = 1:numFeatures,
	  fprintf(outfile, '%0.6g ', dt.blobFeatures(f,b,i));
        end;
        fprintf(outfile, '\n');
      end;
    end;
    fclose(outfile);

    % Write out "adjacency" file
    % --------------------------
    outfile = openfile(sd,'adjacencies','w');
    for i = 1:size(adjacencies,1),
      for j = 1:size(adjacencies,2),
	fprintf(outfile, '%i ', adjacencies(i,j));
      end;
      fprintf(outfile, '\n');
    end;
    fclose(outfile);
  
  end;
  
% ---------------------------------------------------------------------
function file = openfile (d, f, perm)

  filename = [d '/' f];
  file     = fopen(filename, perm);
  if file == -1,
    error(sprintf('Unable to open file %s for %s access', ...
		  filename, perm));
  end;
