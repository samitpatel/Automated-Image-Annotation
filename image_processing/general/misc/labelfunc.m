% LABELFUNC    Runs a label, vocabulary or correspondence operation.
%    LABELFUNC(F,...) runs operation F. See below for a list of possible
%    operations. 
%
%    Here is a list of all the available label, vocabulary and
%    correspondence operations: 
%    
%    a. Create a new vocabulary.
%       VOCAB = LABELFUNC('newVocab',LABELS)
%    
%    b. Find a word in the vocabulary.
%       W = LABELFUNC('findWordInVocab',VOCAB,WRD) returns 0 if the word
%       WRD cannot be found.
%    
%    c. Add a word to the vocabulary.
%       [VOCAB,W,ADDEDTOVOCAB] = LABELFUNC('addWordToVocab',VOCAB,WRD)
%       returns the new word index in W and ADDEDTOVOCAB is 0 if the word   
%       is already in the vocabulary.
%    
%    d. Remove a word from the vocabulary.
%       [LABELS,VOCAB,REMFROMVOCAB] = LABELFUNC('removeWordFromVocab',
%       LABELS,VOCAB,WRD) where REMFROMVOCAB is 0 if the word was already 
%       removed from the vocabulary. In other words, it could not be
%       found. 
%
%    e. Rename a word in the vocabulary.
%       [LABELS,VOCAB,W] = LABELFUNC('renameVocabWord',LABELS,VOCAB,W)
%       renames the word indexed by W and returns the new word index in
%       W. If the operation is unsuccessful, it returns 0.
%
%    f. Merge several word tokens into one word.
%       [LABELS,VOCAB] = LABELFUNC('mergeVocabWords',LABELS,VOCAB,WRDS)
%       where WRDS is a cell array of words to merge. The words following
%       the first are renamed to the first word.
%
%    g. Find a word in a label.
%       W = LABELFUNC('findWordInLabel',LABELS,IMG,WRD) returns the index
%       of the word WRD in image IMG, or 0 if it cannot be found.
%
%    h. Find a word in the set of labels.
%       FOUND = LABELFUNC('findWordInLabels',LABELS,WRD) returns 1 if an
%       instance of the word WRD was found in the labels, otherwise 0.
%
%    i. [LABELS,VOCAB,REMFROMLABEL,REMFROMVOCAB] = 
%       LABELFUNC('removeWordFromLabel',LABELS,VOCAB,IMG,WRD) removes the
%       word WRD from image IMG. REMFROMLABEL is 1 if the function found
%       an instance of the word to remove. REMFROMVOCAB is 1 if the
%       instance found was the last instance in the set of labels, and
%       thus it was removed from the vocabulary.
%
%    j. Find a word in a correspondence. 
%       W = LABELFUNC('findWordInCorresp',LABELS,IMG,BLOB,WRD) returns
%       the index of the word WRD found in the correspondence of blob
%       BLOB in image IMG. If no instance is found, it returns 0.
%
%    k. Find a word in all the blob correspondences for an image. 
%       FOUND = LABELFUNC('findWordInCorresps',LABELS,IMG,WRD) returns 1
%       if the word WRD was found in one of the correspondences for image
%       IMG, otherwise it returns 0.
%
%    l. Add a word to a correspondence.
%       [LABELS,VOCAB,W,ADDEDTOCORRESP,ADDEDTOLABEL,ADDEDTOVOCAB] = 
%       LABELFUNC('addWordToCorresp',LABELS,VOCAB,IMG,BLOB,WRD) returns
%       the new correspondence index for WRD in W. ADDEDTOCORRESP is 0 if
%       the word has already been added. ADDEDTOLABEL is 0 if the word
%       already exists in the label for image IMG. ADDEDTOVOCAB is 0 if
%       the word already exists in the vocabulary. 
%
%    m. Remove a word to a correspondence.
%       [LABELS,VOCAB,REMFROMCORRESP,REMFROMLABEL,REMFROMVOCAB] = 
%       LABELFUNC('removeWordFromCorresp',LABELS,VOCAB,IMG,BLOB,WRD)
%       removes word WRD from blob BLOB in image IMG. REMFROMCORRESP is 0
%       if the word has already been removed the correspondence. 
%       REMFROMLABEL is 0 if the word has already been removed from the
%       label. REMFROMVOCAB is 0 if the word has already been removed
%       form the vocabulary.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function varargout = labelfunc (varargin)
  
  % Invoke callback function.
  if nargout,
    [varargout{1:nargout}] = feval(varargin{:}); 
  else,
    feval(varargin{:});
  end;

% --------------------------------------------------------------------
% VOCABULARY FUNCTIONS
% --------------------------------------------------------------------
function vocab = newVocab (labels)
  
  vocab.words    = {};
  vocab.numWords = 0;
  
  % Repeat for each image.
  for i = 1:length(labels.images),
    % Repeat for each word in the image.
    for w = 1:labels.wordCounts(i),
      wrd = labels.imageWords{i,w};
      vocab = addWordToVocab(vocab, wrd);
    end;
  end;  

% --------------------------------------------------------------------
function w = findWordInVocab (vocab, wrd)
  
  for w = 1:vocab.numWords,
    if strcmp(vocab.words{w}, wrd),
      return;
    end;
  end;
  
  w = 0;
  
% --------------------------------------------------------------------
function [vocab, w, addedToVocab] = addWordToVocab (vocab, wrd)
  
  addedToVocab = 0;
  
  % First check to see if it's already there or not.
  w = findWordInVocab(vocab, wrd);
  if ~w,
    
    % We didn't find it, so add the word to the vocabulary.
    addedToVocab     = 1;
    w                = vocab.numWords + 1;
    vocab.numWords   = w;
    vocab.words{w,1} = wrd;
    vocab.words      = sort(vocab.words);
    w                = findWordInVocab(vocab, wrd);
  end;

% --------------------------------------------------------------------
function [labels, vocab, remFromVocab] = ...
      removeWordFromVocab (labels, vocab, wrd)
  
  remFromVocab = 0;
  
  % Check to see if there is a word to remove to the vocabulary.
  w = findWordInVocab(vocab, wrd);
  if w,
    
    % There is a word to remove.
    remFromVocab = 1;
    
    % Remove the word from the correspondences for the particular blob. 
    vocab = simpleRemWordFromVocab(vocab, w);
    
    % Remove the word from the labels and correspondences for each
    % image. Repeat for all images. 
    for img = 1:length(labels.images),
      w = findWordInLabel(labels, img, wrd);
      if w,
        labels = simpleRemWordAndCorrespFromLabel(labels, img, w, wrd);
      end;
    end;
  end;

% --------------------------------------------------------------------
function [labels, vocab, w] = renameVocabWord (labels, vocab, ...
					       oldWrd, newWrd)
  
  % Rename the word in the vocabulary.
  w = findWordInVocab(vocab, oldWrd);
  if w,
    vocab.words{w} = newWrd;
    vocab.words    = sort(vocab.words);
  else,
    return;
  end;
    
  % Rename the word in the labels and correspondences.
  for i = 1:length(labels.images),
    for w = 1:labels.wordCounts(i),
      if strcmp(labels.imageWords{i,w}, oldWrd),
	labels.imageWords{i,w} = newWrd;
      end;
    end;  
    
    for b = 1:length(labels.correspCounts(i,:)),
      for w = 1:labels.correspCounts(i,b),
        if strcmp(labels.blobWords{i,b,w}, oldWrd),
	  labels.blobWords{i,b,w} = newWrd;
        end;
      end;      
    end;
  end;
  
  w = findWordInVocab(vocab, newWrd);

% --------------------------------------------------------------------
function [labels, vocab] = mergeVocabWords (labels, vocab, wrds)
  
  % Do nothing if there's only one word.
  if length(wrds) < 2,
    return;
  end;
  
  % Rename the rest of the words to the first one.
  wrd = wrds{1};
  for wi = 2:length(wrds),
    [labels vocab] = renameVocabWord(labels, vocab, wrds{wi}, wrd);
  end;
  
  % Merge the words in the vocabulary. Note that we keep the first word
  % and remove all the others.
  found = 0;
  for w = 1:vocab.numWords,
    if strcmp(vocab.words{w}, wrd),
      if found,
	vocab = simpleRemWordFromVocab(vocab,w);
      else,
	found = 1;
      end;
    end;
  end;
  
  % Now that we've renamed all the words, we just have to look in the
  % labels and correspondences and delete any multiple entries of the
  % same word.
  for img = 1:length(labels.images),
    
    % Repeat for each word in the label.
    found = 0;
    for w = 1:labels.wordCounts(img),
      if strcmp(labels.imageWords{img,w}, wrd),
	% If we've already found the word previously in this label,
        % remove the extras.
	if found,
	  labels = simpleRemWordFromLabel(labels, img, w);
	else,
	  found = 1;
	end;
      end;
    end;
    
    % Repeat for each blob and then for each correspondence in the blob.
    for b = 1:length(labels.correspCounts(img,:)),
      found = 0;
      for w = 1:labels.correspCounts(img,b),
	if strcmp(labels.blobWords{img,b,w}, wrd),
	  if found,
	    labels = simpleRemWordFromCorresp(labels, img, b, w);
	  else,
	    found = 1;
	  end;
	end;
      end;
    end;    
  end;
  
% --------------------------------------------------------------------
function vocab = simpleRemWordFromVocab (vocab, w)  
  
  W = vocab.numWords - 1;
  vocab.numWords = W;
  for i = w:W,
    vocab.words{i} = vocab.words{i+1};
  end;
  
  % Sort the words.
  vocab.words{W+1} = '~';
  vocab.words = sort(vocab.words);
  
% --------------------------------------------------------------------
% LABEL FUNCTIONS
% --------------------------------------------------------------------
function w = findWordInLabel (labels, img, wrd)
  
  % Repeat for each word in the image's label.
  for w = 1:labels.wordCounts(img),
    if strcmp(labels.imageWords{img,w}, wrd), 
      return;
    end;
  end;
  
  w = 0;

% --------------------------------------------------------------------
function found = findWordInLabels (labels, wrd)
  
  for i = 1:length(labels.images),
    for w = 1:labels.wordCounts(i),
      if strcmp(labels.imageWords{i,w}, wrd),
        found = 1;
        return;
      end;
    end;  
  end;
  
  found = 0;

% --------------------------------------------------------------------
function [labels, vocab, w, addedToLabel, addedToVocab] = ...
      addWordToLabel (labels, vocab, img, wrd)
  
  addedToLabel = 0;
  addedToVocab = 0;
    
  % Check to make sure that we're not adding the word twice. If w
  % is 0, then we have to add the word.
  w = findWordInLabel(labels, img, wrd);
  if ~w,
    
    % We didn't find the word in the image's label, so add it.
    addedToLabel             = 1;
    w                        = labels.wordCounts(img) + 1;
    labels.wordCounts(img)   = w;
    labels.imageWords{img,w} = wrd;  
    
    % We may have to add the word to the vocabulary.
    [vocab ans addedToVocab] = addWordToVocab(vocab, wrd);
  end;
  
% --------------------------------------------------------------------
function [labels, vocab, remFromLabel, remFromVocab] = ...
      removeWordFromLabel (labels, vocab, img, wrd)
  
  remFromLabel   = 0;
  remFromVocab   = 0;
  
  % Check to see if there is a word to remove to the label.
  w = findWordInLabel(labels, img, wrd);
  if w,
    
    % There is a word to remove.
    remFromLabel = 1;
    
    % Remove the word from the label and correspondences for the
    % particular blob.  
    labels = simpleRemWordAndCorrespFromLabel(labels, img, w, wrd);
    
    % Check to see if this word still exists in the other
    % labels. If not, remove this word from the vocabulary.
    found = findWordInLabels(labels, wrd);
    if ~found,
	
      % Remove word from the vocabulary.
      remFromVocab = 1;
      w = findWordInVocab(vocab, wrd);
      vocab = simpleRemWordFromVocab(vocab, w);
    end;
  end;

% --------------------------------------------------------------------
function labels = simpleRemWordFromLabel (labels, img, w)
  
  % Remove word from imageWords.
  W = labels.wordCounts(img) - 1;
  labels.wordCounts(img) = W;
  for i = w:W,
    labels.imageWords{img,i} = labels.imageWords{img,i+1};
  end;
  labels.imageWords{img,W+1} = [];

% --------------------------------------------------------------------
function labels = simpleRemWordAndCorrespFromLabel (labels, img, w, wrd)
  
  % Remove the word from the label.
  labels = simpleRemWordFromLabel(labels, img, w);
 
  % Remove the words from the correspondences. Repeat for each blob in
  % the image.
  for b = 1:length(labels.correspCounts(img,:)),
    w = findWordInCorresp(labels, img, b, wrd);
    if w,
      labels = simpleRemWordFromCorresp(labels, img, b, w);
    end;
  end;
  
% --------------------------------------------------------------------
% CORRESPONDENCE FUNCTIONS
% --------------------------------------------------------------------
function w = findWordInCorresp (labels, img, blob, wrd)
  
  % Repeat for each word in the image's blob correspondences.
  for w = 1:labels.correspCounts(img,blob),
    if strcmp(labels.blobWords{img,blob,w}, wrd),
      return;
    end;
  end;
  
  w = 0;  

% --------------------------------------------------------------------
function found = findWordInCorresps (labels, img, wrd)
  
  % Repeat for each blob in the img.
  for b = 1:length(labels.correspCounts(img,:)),
    for w = 1:labels.correspCounts(img,b),
      if strcmp(labels.blobWords{img,b,w}, wrd),
	found = 1;
	return;
      end;
    end;
  end;
  
  found = 0;
  
% --------------------------------------------------------------------
function [labels, vocab, w, addedToCorresp, addedToLabel, addedToVocab] = ...
      addWordToCorresp (labels, vocab, img, blob, wrd)
  
  addedToCorresp = 0;
  addedToLabel   = 0;
  addedToVocab   = 0;
  
  % Check to make sure that we're not adding the word twice to the
  % blob. If w is 0, then we have to add the word.
  w = findWordInCorresp(labels, img, blob, wrd);
  if ~w,
    
    % We didn't find it in the correspondence for that blob so we need to
    % add it.
    addedToCorresp  = 1;
    w               = labels.correspCounts(img,blob) + 1;
    labels.correspCounts(img,blob) = w;
    labels.blobWords{img,blob,w}   = wrd;  
    
    % We may have to add the word to the label (and hence the
    % vocabulary). 
    [labels vocab ans addedToLabel addedToVocab] = ...
	addWordToLabel(labels, vocab, img, wrd);
  end;
  
% --------------------------------------------------------------------
function [labels, vocab, remFromCorresp, remFromLabel, remFromVocab] = ...
      removeWordFromCorresp (labels, vocab, img, blob, wrd)
  
  remFromCorresp = 0;
  remFromLabel   = 0;
  remFromVocab   = 0;
  
  % Check to see if there is a word to remove.
  w = findWordInCorresp(labels, img, blob, wrd);
  if w,
    
    % There is a word to remove.
    remFromCorresp = 1;
    
    % Remove the word from the correspondences for the particular blob. 
    labels = simpleRemWordFromCorresp(labels, img, blob, w);
    
    % Check to see if this word still exists in the other
    % correspondences. If not, remove this word from the label.
    % found = findWordInCorresps(labels, img, wrd);
    % if ~found,
      
      % Remove the word from the label.
    %  [labels vocab remFromLabel remFromVocab] = ...
%	  removeWordFromLabel(labels, vocab, img, wrd);
%    end;
  end;

% --------------------------------------------------------------------
function labels = simpleRemWordFromCorresp (labels, img, blob, w)

  % Remove the word from the correspondences for the particular blob. 
  W = labels.correspCounts(img, blob) - 1;
  labels.correspCounts(img, blob) = W;
  for i = w:W,
    labels.blobWords{img,blob,i} = labels.blobWords{img,blob,i+1};
  end;
  labels.blobWords{img,blob,W+1} = [];
