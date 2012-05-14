% IMAGEBROWSER    Run interface for browsing image translation results.
%    The function call is IMAGEBROWSER(DATA_DIR,MODEL_NAME,TRIAL_NUM,
%    DATASET_LABEL,PR,HIDE_THRESH,MOVIEFRAME_TIME,IMG_CACHE_SIZE) where
%    DATA_DIR is the location of the data set and MODEL is the name of
%    the model we want to view. MODEL can be [], which means no model
%    results will be shown. The rest of the parameters are optional.
%
%    DATASET_LABEL is a string that specifies the initial data set to
%    view. The default is {}, which means use the training set (i.e. the
%    first one). TRIAL_NUM specifies the trial number to view if you have
%    run multiple trials for the model. The default is 1. PR specifies
%    the initial recall number for the translations. The default is
%    1. HIDE_THRESH sets the initial area ratio in which to hide blobs,
%    where the default is 0 (i.e. no hiding). MOVIEFRAME_TIME sets the
%    initial movie frametime in seconds. By default it is 0.8
%    seconds. The IMG_CACHE_SIZE sets the size of the image cache. The
%    default is 16.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function imagebrowser (data_dir, model_name, varargin)
  
  image_browser('init', data_dir, model_name, varargin{:})