function err = run_test_prs (manual_words, manual_blobwords, ...
		             model_words, model_blobwords)
  
  maxNumBlobs = size(manual_blobwords, 2);
  numImages   = size(manual_blobwords, 3);
  
  % Repeat for each image (i.e. document).
  err = 0;
  numImgsWithWrds = 0;
  for s = 1:numImages,
    
    % Repeat for each blob in the document.
    eImg = 0;
    numBlobs = 0;
    for b = 1:maxNumBlobs,
      
      numWords = sum(manual_blobwords(:,b,s) > 0);
      if numWords,
	
	numBlobs = numBlobs + 1;
	eBlob = 1;
	for w = 1:numWords,
	  
	  % Find the index of the word in the list of words from the
          % model. 
	  wrd = manual_words(manual_blobwords(w,b,s));
	  wi = find(strcmp(model_words, wrd));
	  
	  % If we don't find the word in the list, then it will never be
          % predicted and the error will be 1. On the other hand, if we
          % do find an index, subtract from the error the probability it
          % will be chosen.
	  if wi,
	    eBlob = eBlob - model_blobwords(wi,b,s);
	  end;
	end; % for each word entered manually for the blob.
	
	eImg = eImg + eBlob;
      end; % if the blob contains at least one word.
      
    end; % for each blob in the image.
    
    % If there was at least one blob, increment the error.
    if numBlobs,
      numImgsWithWrds = numImgsWithWrds + 1;
      err = err + eImg / numBlobs;
    end;
    
  end; % for each image.
  
  % Return the final result.
  err = err / numImgsWithWrds;