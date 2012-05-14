% LOAD_MODEL_TABLE    Load the model table from disk.
%    MODELS = LOAD_MODEL_TABLE(D,F) loads the model table from file F in
%    directory D. MODELS is a cell array, where each element is a struct
%    with the following fields:
%      - name        The name of the model.
%      - func.train  The name of the training function. The function
%                    call is [MODEL VAL] = FUNC.TRAIN(B,W,A,M,L,NUMWORDS,...).
%                    B is a (f x b x n) matrix where f is the number of
%                    features, b is the maximum number of blobs in an
%                    image and n is the number of images. W is a (n x w)
%                    matrix where w is the maximum size of an image
%                    label; i.e. the maximum number of words in an
%                    image. A is a (n x 1) cell array of adjacency
%                    matrices. Each entry is a (bn x bn) adjacency
%                    matrix, where bn is the number of blobs in image
%                    n. M is a (n x 1) matrix of blob counts and L  
%                    is a (n x 1) matrix of word counts. NUMWORDS is the 
%                    total number of separate word tokens in
%                    the data set. The function can also receive an
%                    additional set of model-specific parameters as
%                    specified in the model text file. The return value
%                    MODEL is a struct with model-specific
%                    information. The value of the model is returned in
%                    VAL, which is used to compare models in the case
%                    that there is more than one restart.
%      - func.write  The function to write the model to disk. The
%                    function call is FUNC.WRITE(D,MODEL) where MODEL is
%                    the return value from the training function and D is
%                    the directory.
%      - func.trans  The function to translate a set of blobs to words
%                    using the trained model. The function call is T =
%                    FUNC.TRANS(B,M,A,MODEL). B and M are the same as in
%                    training function, and MODEL is the return value
%                    from the training function. T is a (wn x b x n)
%                    matrix of translation probabilities where wn is the
%                    number of word tokens, b is the maximum number of
%                    blobs in a single image and n is the number of
%                    images. A is a (n x 1) cell array, and each entry
%                    contains a (bn x bn) adjacency matrix, where bn is
%                    the number of blobs in image n.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function models = load_model_table (d, f)
  
  % Open model table file
  % ---------------------
  filename = [d '/' f];
  infile = fopen(filename, 'r');
  if infile == -1,
    error(sprintf('Unable to read file %s', filename));
  end;
  
  % Initialize "models"
  % -------------------
  models    = {};
  numModels = 0;
  
  while 1,
    s = fgetl(infile);
    if ischar(s) & length(s),
      numModels = numModels + 1;
      
      % Grab the info for this model
      % ----------------------------
      models{numModels}.name = s;
      models{numModels}.func.train = remove_whitespace(fgetl(infile));
      models{numModels}.func.write = remove_whitespace(fgetl(infile));
      models{numModels}.func.trans = remove_whitespace(fgetl(infile));
      
      % Get the empty space.
      s = fgetl(infile);
      
    else,
      break;
    end;    
  end;
  
  % Close the file.
  fclose(infile);