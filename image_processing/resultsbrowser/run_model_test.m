% RUN_MODEL_TEST    Run a test on a translation matrix.
%    ERR = RUN_MODEL_TEST(TEST_NAME,MANUAL_WORDS,MANUAL_BLOBWORDS,
%    MODEL_WORDS,MODEL_BLOBWORDS,...) runs the test TEST_NAME and returns
%    the value between 0 and 1 which is the percentage of image segments
%    that were inaccurately translated into words. The error is averaged
%    over each image, and then over all the images. MANUAL_WORDS is the
%    list of word tokens for the data set. MANUAL_BLOBWORDS is the
%    matrix of correspondences; the 'blobWords' field derived from the
%    data struct when using the function /GENERAL/DATA/DATA_SET. 
%    MODEL_WORDS is the list of word tokens used by the model and
%    MODEL_BLOBWORDS is the translation probability matrix obtained from
%    running the function /GENERAL/DATA/LOAD_TRANSLATION.
%
%    TEST_NAME can be one of the following:
%      - prs   The error when the words are randomly sampled.
%      - prn   The error when the correct word(s) must be found among
%              the N most probable words, as deemed by the model. A
%              parameter N > 0 must be specified.
%      - pon   Similar to 'prn', only we normalize over the words first. 
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function err = ...
    run_model_test (test_name, manual_words, manual_blobwords, ...
		    model_words, model_blobwords, varargin)
  
  % Run the appropriate test.
  functionName = ['run_test_' test_name];
  err = feval(functionName, manual_words, manual_blobwords, ...
	      model_words, model_blobwords, varargin{:});
  
  