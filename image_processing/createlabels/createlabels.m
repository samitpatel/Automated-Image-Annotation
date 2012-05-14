% CREATELABELS    Run the interface for adding labels to images
%                 and image segments.
%    CREATE_IMAGE_LABELS(DATA_DIR,IMG_CACHE_SIZE) runs the image
%    labeling interface using the Matlab GUI package. DATA_DIR is the
%    directory where the IMAGE_INDEX is located. IMG_CACHE_SIZE is an
%    optional parameter to specify the number of images stored in
%    memory. This speeds up the display. The default is 16.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function createlabels (data_dir, varargin)
  
  % Run the interface.
  create_image_labels('init', data_dir, varargin{:});