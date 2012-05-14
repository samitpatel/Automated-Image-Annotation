% NAIVE_TRAIN    Train the naive model.
%    T = NAIVE_TRAIN(DATA) builds the W x 1 translation probability table
%    for the naive model by training on the data set DATA. W is the
%    number of word tokens in the data set. The naive model computes the
%    translation probabilities solely by looking at the word
%    frequencies. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function t = naive_train (data)
  
  % Count number of times each word appears in the dataset
  % ------------------------------------------------------
  t = zeros(data.numWords, 1);
  for s = 1:data.numImages,
    for w = 1:data.imageWordCounts(s),
      wi = data.imageWords(s,w);
      t(wi) = t(wi) + 1;
    end;
  end;
  
  % Normalize word frequencies
  % --------------------------
  t = t / sum(t);
  