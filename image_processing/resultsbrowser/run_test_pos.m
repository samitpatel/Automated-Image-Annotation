function err = run_test_pos (manual_words, manual_blobwords, ...
		             model_words, model_blobwords)
  
  maxNumBlobs = size(manual_blobwords, 2);
  numImages   = size(manual_blobwords, 3);
  W           = length(manual_words);
  
  % Repeat for each image (i.e. document).
  err = 0;
  numImgsWithWrds = 0;
  for s = 1:numImages,
    
    % We want to count two things at the same time:
    %   1. The number of times we consider word i for a particular blob.
    %   2. The number of times the word i is correct given the
    %      model_blobwords. 
    % If there is more than one manual annotation for a blob, we split
    % the blame/reward uniformly. 
    blobCountsForWords = zeros(1,W);
    errCountsForWords  = zeros(1,W);
    numBlobs           = 0;
    
    % Repeat for each blob in the document.
    for b = 1:maxNumBlobs,
      numWords = sum(manual_blobwords(:,b,s) > 0);
      wrds     = manual_blobwords(1:numWords,b,s);
      
      if numWords,
	
	% Add blame to each of the words in the blob.
	blobCountsForWords(wrds) = blobCountsForWords(wrds) ...
	                           + 1 / numWords;
	errCountsForWords(wrds)  = errCountsForWords(wrds) ...
	                           + 1 / numWords;
	numBlobs                 = numBlobs + 1;
	
	for w = 1:numWords,
	  
	  % Find the index of the word in the list of words from the
          % model.
	  wi  = wrds(w);
	  wrd = manual_words(wi);
	  wi2 = find(strcmp(model_words, wrd));

	  if length(wi2),
	    errCountsForWords(wi) = errCountsForWords(wi) ...
		                    - model_blobwords(wi2,b,s);
	  end;
	end; % for each word entered manually for the blob.
      end; % if the blob contains at least one word.
    end; % for each blob in the image.
    
    % If there was at least one blob, then increment the error. 
    if numBlobs,
      numImgsWithWrds = numImgsWithWrds + 1;
      w = find(blobCountsForWords);
      err = err + mean(errCountsForWords(w) ./ blobCountsForWords(w));
    end;
    
  end; % for each image.
  
  % Return the final result.
  err = err / numImgsWithWrds;