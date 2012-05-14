function err = run_test_pon (manual_words, manual_blobwords, ...
		             model_words, model_blobwords, n)
  
  maxNumBlobs = size(manual_blobwords, 2);
  numImages   = size(manual_blobwords, 3);
  W           = length(manual_words);
  
  % Create the prediction matrix using the translation probabilities in
  % model_blobwords. 
  [ans t] = sort(-model_blobwords,1);
  t = t(1:min(n,size(t,1)),:,:);
  
  % Repeat for each image (i.e. document).
  err = 0;
  numImgsWithWrds = 0;
  for s = 1:numImages,
    
    % We want to count two things at the same time:
    %   1. The number of times we consider word i for a particular blob.
    %   2. The number of times the word i is correct given the
    %      model_blobwords. 
    % If there is more than one manual annotation for a blob, we only
    % consider the word that won. If none won, then we split the blame
    % uniformly. 
    blobCountsForWords = zeros(1,W);
    errCountsForWords  = zeros(1,W);
    numBlobs           = 0;
    
    % Repeat for each blob in the document.
    for b = 1:maxNumBlobs,
      
      numWords = sum(manual_blobwords(:,b,s) > 0);
      if numWords,
	
	numBlobs          = numBlobs + 1;
	correctAnnotation = 0;
	for w = 1:numWords,
	  
	  % Find the index of the word in the list of words from the
          % model. 
	  wi    = manual_blobwords(w,b,s);
	  wrd   = manual_words(wi);
	  found = find(t(:,b,s) == find(strcmp(model_words, wrd)));
	  if length(found),
	    correctAnnotation      = 1;
	    blobCountsForWords(wi) = blobCountsForWords(wi) + 1;
	    break;
	  end;
	end; % for each word entered manually for the blob.
	
	% If we didn't find a correct annotation, then we have to
        % distribute the blame equally among all the words in the image. 
	if ~correctAnnotation,
	  k = 1 / numWords;
	  for w = 1:numWords,
	    wi = manual_blobwords(w,b,s);
	    blobCountsForWords(wi) = blobCountsForWords(wi) + k;
	    errCountsForWords(wi)  = errCountsForWords(wi) + k;
	  end;
	end;
	  
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