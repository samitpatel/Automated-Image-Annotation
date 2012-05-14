% IMAGE_BROWSER    Run interface for browsing image translation results.
%    The first function call should be IMAGE_BROWSER('init',DATA_DIR,
%    MODEL_NAME,TRIAL_NUM,DATASET_LABEL,PR,HIDE_THRESH,MOVIEFRAME_TIME,
%    IMG_CACHE_SIZE) where DATA_DIR is the location of the data set and
%    MODEL is the name of the model we want to view. MODEL can be [],
%    which means no model results will be shown. The rest of the
%    parameters are optional.
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

function varargout = image_browser (varargin)
  
  % Invoke callback function.
  try
    if nargout,
      [varargout{1:nargout}] = feval(varargin{:}); 
    else,
      feval(varargin{:});
    end;
  
  catch
    disp(lasterr);
  end;
  
% --------------------------------------------------------------------
% CALLBACK FUNCTIONS
% --------------------------------------------------------------------  
function init (data_dir, model_name, varargin)
  
  % Function constants.
  generalPath     = '../general';
  resultsSubdir   = 'results';
  trialPrefix     = 'trial';
  
  % Default parameters.
  defaultTrialNum       = 1;
  defaultDatasetLabel   = {};
  defaultPR             = 1;
  defaultHideThresh     = 0;
  defaultMovieFrameTime = 0.8;
  defaultImgCacheSize   = 16;
  defaultImgLabelSize   = 9;
  
  % Add the proper paths in order to access the "general" functions. 
  oldPath = path;
  dirs    = genpath(generalPath);
  path(dirs, oldPath);
  clear generalPath dirs oldPath

  % Launch GUI
  % ----------
  fig = openfig(mfilename, 'new');
  
  % Generate a structure of handles to pass to callbacks, and store it. 
  handles = guihandles(fig);
  
  % Set up function parameters
  % --------------------------
  % Get the parameters from "varargin".
  defargs = { defaultTrialNum;
	      defaultDatasetLabel;
	      defaultPR;
	      defaultHideThresh;
	      defaultMovieFrameTime;
	      defaultImgCacheSize    };
  [ trialNum ...
    datasetLabel ...
    handles.PR ...
    handles.hideThresh ...
    handles.movieFrameTime ...
    handles.imgCacheSize ] = manage_vargs(varargin, defargs);  
  clear defargs varargin defaultDatasetLabel defaultPR 
  clear defaultHideThresh defaultMovieFrameTime defaultImgCacheSize

  try
    % Load the data set
    % -----------------
    handles.data = load_data(data_dir);
    if ~length(handles.data),
      error('Unable to load data sets.');
    end;
    
    % Load the model
    % --------------
    if length(model_name),
      modelDir = [data_dir '/' resultsSubdir '/' model_name];
      trialDir = [modelDir sprintf('/trial%i', trialNum)];
      model = load_model_params(modelDir, {}, 'specs');
      handles.model.name  = model.name;
      handles.model.label = model.label;
      clear model model_name
      
      % Load the words
      % --------------
      handles.model.words = importdata([modelDir '/words']);
    
      % Load the translation tables for each data set
      % ---------------------------------------------
      for i = 1:length(handles.data),
        handles.t{i} = load_translation(trialDir, handles.data{i});
      end;
      clear modelDir trialDir

    else,
      handles.model = [];
    end;

  catch
    disp(lasterr);
    close;
    return;
  end;
  
  % Set current data set
  % --------------------
  found = 0;
  if length(datasetLabel),
    for i = 1:length(handles.data),
      if strcmp(handles.data{i}.setlabel, datasetLabel),
	found = 1;
	curDataset = i;
      end;
    end;
  end;
  clear i
   
  if ~found | ~length(datasetLabel),
    curDataset = 1;
  end;
  clear datasetLabel found
    
  % Set up image caches
  % -------------------
  for i = 1:length(handles.data),
    handles.imgCache{i} = new_cache(handles.imgCacheSize, ...
	                  handles.data{i}.numImages);
  end;
  
  % Set up user interface
  % ---------------------
  % Set up some interface variables.
  handles.curImg           = 1;
  handles.curBlob          = 0;
  handles.dataDir          = data_dir;
  handles.showBlobNums     = 0;
  handles.showAdj          = 0;
  handles.imgLabelFontSize = defaultImgLabelSize;
  
  % The original positions for GUI controls.
  handles.origpos.fig          = get(fig, 'Position');
  handles.origpos.manualimg    = get(handles.manualimg, 'Position');
  handles.origpos.origimg      = get(handles.origimg, 'Position');
  handles.origpos.blobimg      = get(handles.blobimg, 'Position');
  handles.origpos.manualimglbl = get(handles.manualimg_label, 'Position');
  handles.origpos.origimglbl   = get(handles.origimg_label, 'Position');
  handles.origpos.modelname    = get(handles.model_name_text, 'Position');

  handles.origpos.blobnum      = get(handles.blob_num_text, 'Position');
  handles.origpos.blobmodel    = get(handles.bloblabel_model_text, ...
				     'Position'); 
  handles.origpos.blobmodellbl = get(handles.bloblabel_model_label, ...
				     'Position'); 
  handles.origpos.blobman      = get(handles.bloblabel_manual_text, ...
				     'Position'); 
  handles.origpos.blobmanlbl   = get(handles.bloblabel_manual_label, ...
				     'Position'); 
  
  handles.origpos.controlframe = get(handles.controlframe, 'Position');
  handles.origpos.back         = get(handles.back, 'Position');
  handles.origpos.forward      = get(handles.forward, 'Position');
  handles.origpos.imgnum       = get(handles.imgnum_box, 'Position');
  handles.origpos.pr           = get(handles.pr_textedit, 'Position');
  handles.origpos.prlbl        = get(handles.pr_label, 'Position');
  handles.origpos.hidethresh   = get(handles.hidethreshold_textedit, ...
				     'Position');
  handles.origpos.hidethrlbl   = get(handles.hidethreshold_label, ...
				     'Position');
  handles.origpos.showblobs    = get(handles.show_blobs_btn, 'Position');
  handles.origpos.showadj      = get(handles.show_adj_btn, 'Position');
  handles.origpos.changeset    = get(handles.changeset_btn, 'Position');
  handles.origpos.fontsize     = get(handles.fontsize_box, 'Position');
  handles.origpos.fontsizelbl  = get(handles.fontsize_label, 'Position');
  
  handles.origpos.movieframe   = get(handles.movieframe, 'Position');
  handles.origpos.movielbl     = get(handles.movie_label, 'Position');
  handles.origpos.startmovie   = get(handles.startmovie_btn, 'Position');
  handles.origpos.frametime    = get(handles.frametime_textedit, 'Position');
  handles.origpos.frametimelbl = get(handles.frametimelbl, 'Position');  
  
  % Set up the dataset.
  handles = switchDatasets(handles, curDataset);
  
  % Update the display
  % ------------------
  handles = updateDisplay(handles);
  
  % Store the changes.
  guidata(fig, handles);
  
% --------------------------------------------------------------------
% Callback function for the frame time textedit box.
function varargout = frametime_textedit_Callback(h, eventdata, handles, ...
						 varargin)
  
  n = str2num(get(handles.frametime_textedit, 'String'));
  handles.movieFrameTime = n;

  % Store the changes.
  guidata(fig, handles);

% --------------------------------------------------------------------
% Callback function for the "start movie" button.
function varargout = startmovie_btn_Callback(h, eventdata, handles, varargin)

  % Get the frame time
  % ------------------
  frameTime = str2num(get(handles.frametime_textedit, 'String'));
  set(handles.startmovie_btn, 'String', 'Running');
  
  % Check to see if its a valid time.
  if ~length(frameTime) | (frameTime < 0),
    fprintf('Not a valid frame time.\n');
    return;
  end;
  
  handles.curBlob = 0;
  updateDisplayBloblabel(handles);
  
  % Cycle through the images
  % ------------------------
  tic;
  for i = handles.curImg+1:handles.data{handles.curDataset}.numImages,
    
    % Wait for "toc" to be greater than frameTime.
    while toc < frameTime,
    end;
    tic;
    
    % Move to the next image.
    handles.curImg = i;
    
    % Display the image.
    updateDisplayImage(handles);
    
    drawnow;
  end;
  
  set(handles.startmovie_btn, 'String', 'Show');

  % Store the changes.
  guidata(h, handles);    

% --------------------------------------------------------------------
% Callback function for the "show blobs" button.
function varargout = show_blobs_btn_Callback(h, eventdata, handles, varargin)
  
  if handles.showBlobNums,
    handles.showBlobNums = 0;
    set(handles.show_blobs_btn, 'String', 'Show blob nums');
  else,
    handles.showBlobNums = 1;
    set(handles.show_blobs_btn, 'String', 'Hide blob nums');
  end;
  
  % Display the image.
  updateDisplayImage(handles);  
  
  % Store the changes.
  guidata(h, handles);    
  
% --------------------------------------------------------------------
% Callback function for the "show blobs" button.
function varargout = show_adj_btn_Callback(h, eventdata, handles, varargin)
  
  if handles.showAdj,
    handles.showAdj = 0;
    set(handles.show_adj_btn, 'String', 'Show adjacencies');
    set(handles.bloblabel_model_label, 'String', 'Model');
  else,
    handles.showAdj = 1;
    set(handles.show_adj_btn, 'String', 'Hide adjacencies');
    set(handles.bloblabel_model_label, 'String', 'Adjacencies');
  end;
  
  % Display the image.
  updateDisplayImage(handles);  
  
  % Store the changes.
  guidata(h, handles);    
 
% --------------------------------------------------------------------
% Callback function for the button that changes the current data set.
function varargout = changeset_btn_Callback(h, eventdata, handles, varargin)
  
  curDataset = handles.curDataset + 1;
  if curDataset > length(handles.data),
    curDataset = 1;
  end;
  
  % Set up the new data set.
  handles.curDataset = curDataset;
  handles.curImg = 1;
  handles.curBlob = 0;
  
  handles = updateDisplayDataset(handles);
  
  % Store the changes.
  guidata(h, handles);
  
% --------------------------------------------------------------------
% Callback function for the "hide threshold" textedit box.
function varargout = hidethreshold_textedit_Callback(h, eventdata, ...
						  handles, varargin)

  n = str2num(get(handles.hidethreshold_textedit, 'String'));
  
  if length(n),
    
    if n < 0,
      n = 0;
    elseif n > 1,
      n = 1;
    end;
    
    if n ~= handles.hideThresh,
      handles.hideThresh = n;
      handles = updateDisplayImage(handles);
    end;
  end;
  
  % Store the changes.
  set(handles.hidethreshold_textedit, 'String', ...
      num2str(handles.hideThresh));
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback function for the PR textedit box.
function varargout = pr_textedit_Callback(h, eventdata, handles, varargin)

  n = str2num(get(handles.pr_textedit, 'String'));
  
  if length(n),
    
    if n < 1,
      n = 1;
    end;
    
    if n ~= handles.PR,
      handles.PR = n;
      handles = updateDisplayImage(handles);
      updateDisplayBloblabel(handles);
    end;
  end;
  
  % Store the changes.
  set(handles.pr_textedit, 'String', num2str(handles.PR));
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the back button.
function varargout = back_Callback(h, eventdata, handles, varargin)

  if handles.curImg > 1,
    handles.curImg = handles.curImg - 1;
    handles.curBlob = 0;
    handles = updateDisplayImage(handles);
    updateDisplayBloblabel(handles);
  end;
  
  % Store the changes.
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the forward button.
function varargout = forward_Callback(h, eventdata, handles, varargin)
  
  numImages = handles.data{handles.curDataset}.numImages;
  if handles.curImg < numImages,
    handles.curImg = handles.curImg + 1;
    handles.curBlob = 0;
    handles = updateDisplayImage(handles);
    updateDisplayBloblabel(handles);
  end;

  % Store the changes.
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the image number textedit box.
function varargout = imgnum_box_Callback(h, eventdata, handles, varargin)

  n = str2num(get(handles.imgnum_box, 'String'));
  
  changed = 0;
  numImages = handles.data{handles.curDataset}.numImages;
  if length(n) > 0,
    
    if n < 1,
      n = 1;
    elseif n > numImages,
      n = numImages;
    end;
    
    if n ~= handles.curImg,
      changed = 1;
      handles.curBlob = 0;
      handles.curImg = n;
      handles = updateDisplayImage(handles);
      updateDisplayBloblabel(handles);
    end;
  end;
  
  % Store the changes.
  set(handles.imgnum_box, 'String', num2str(n));
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the "quit" menu item.
function varargout = QuitMenuItem_Callback(h, eventdata, handles, varargin)
  close;
  
% --------------------------------------------------------------------
% Callback routine for the figure.
function varargout = figure1_ButtonDownFcn(h, eventdata, handles, varargin)
  
% --------------------------------------------------------------------
% Callback routine for the file menu.
function varargout = FileMenu_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
% Callback routine for when the user clicks on one of the images.
function varargout = image_callback(h, eventdata, handles, varargin)
  
  % Function constants.
  imageCallback = ...
      'image_browser(''image_callback'',gcbo,[],guidata(gcbo))';

  % Get location of mouse click
  % ---------------------------
  pt = get(gca,'CurrentPoint');
  x = round(pt(1,1));
  y = round(pt(1,2));
  
  % Check which cluster (x,y) is in
  % -------------------------------
  [imageData handles.imgCache{handles.curDataset}] = ...
      loadImageFromCache(handles, handles.curImg);
  [h w s] = size(imageData.segments);
  b = find(imageData.segments(min(y,h), min(x,w),:));

  % If the user did not select a point in a cluster, do nothing.
  if ~length(b),
    return;
  end;

  if handles.curBlob == b,
    handles.curBlob = 0;
  else,
    handles.curBlob = b;
  end;
  
  if handles.showAdj,
    updateDisplayImage(handles);
  end;
  
  % Update blob label display
  % -------------------------
  updateDisplayBloblabel(handles);
  
  % Store the changes.
  guidata(handles.image_browser_figure, handles);
  
% --------------------------------------------------------------------
% Callback routine for the image label font size text edit box.
function varargout = fontsize_box_Callback(h, eventdata, handles, varargin)

  n = str2num(get(handles.fontsize_box, 'String'));
  handles.imgLabelFontSize = n;
  
  % Update the display.
  handles = showImages(handles);
  
  % Store the changes.
  guidata(h, handles);
  
% --------------------------------------------------------------------
% Callback when the window is resized.
function varargout = ResizeFcn(H, eventdata, handles, varargin)
  
  if ~length(handles),
    return;
  end;
  
  % Get the new location of the figure.
  fig    = gcbo;
  figpos = get(fig, 'Position');
  
  % Make sure the new dimensions of the figure are allowed. We cannot
  % make the window smaller than the original dimensions.
  if sum(figpos(3:4) < handles.origpos.fig(3:4)),
    figpos(3) = max(figpos(3), handles.origpos.fig(3));
    if figpos(4) < handles.origpos.fig(4),
      figpos(4) < handles.origpos.fig(4),
      figpos(2) = figpos(2) - (handles.origpos.fig(4) - figpos(4));
      figpos(4) = handles.origpos.fig(4);
    end;
    set(fig, 'Position', figpos);
  end;
  
  % Set the position of the manually-labeled image.
  rw = figpos(3) / handles.origpos.fig(3);
  rh = figpos(4) / handles.origpos.fig(4);
  w  = handles.origpos.manualimg(3) * rw;
  h  = handles.origpos.manualimg(4) * rh;
  x  = handles.origpos.manualimg(1) * rw;
  y  = handles.origpos.manualimg(2) * rh;
  set(handles.manualimg, 'Position', [x y w h]);
  
  % Set the position of the manual image label.
  w2 = handles.origpos.manualimglbl(3) * rw;
  h2 = handles.origpos.manualimglbl(4);
  x  = handles.origpos.manualimglbl(1) * rw;
  y  = handles.origpos.manualimglbl(2) * rh;  
  set(handles.manualimg_label, 'Position', [x y w2 h2]);  
  
  % Set the position of the original image.
  x = handles.origpos.origimg(1) * rw;
  y = handles.origpos.origimg(2) * rh;
  set(handles.origimg, 'Position', [x y w h]);
  
  % Set the position of the original image label.
  w2 = handles.origpos.origimglbl(3) * rw;
  h2 = handles.origpos.origimglbl(4);
  x  = handles.origpos.origimglbl(1) * rw;
  y  = handles.origpos.origimglbl(2) * rh;  
  set(handles.origimg_label, 'Position', [x y w2 h2]);
  
  % Set the position of the model-labeled image.
  x = handles.origpos.blobimg(1) * rw;
  y = handles.origpos.blobimg(2) * rh;
  set(handles.blobimg, 'Position', [x y w h]);
  
  % Set the position of the model image label.
  w2 = handles.origpos.modelname(3) * rw;
  h2 = handles.origpos.modelname(4);
  x  = handles.origpos.modelname(1) * rw;
  y  = handles.origpos.modelname(2) * rh;  
  set(handles.model_name_text, 'Position', [x y w2 h2]);  

  % Set the position for the model label information.
  x   = figpos(3) - handles.origpos.fig(3) + handles.origpos.blobnum(1);
  pos = get(handles.model_name_text, 'Position');
  y   = pos(2);
  set(handles.blob_num_text, 'Position', [x y handles.origpos.blobnum(3:4)]);
  
  x2 = figpos(3) - handles.origpos.fig(3) + handles.origpos.blobmodel(1);
  y2 = handles.origpos.blobmodel(2) - handles.origpos.blobnum(2) + y;
  set(handles.bloblabel_model_text, 'Position', ...
		    [x2 y2 handles.origpos.blobmodel(3:4)]);
  
  x2 = figpos(3) - handles.origpos.fig(3) + handles.origpos.blobmodellbl(1);
  y2 = handles.origpos.blobmodellbl(2) - handles.origpos.blobnum(2) + y;
  set(handles.bloblabel_model_label, 'Position', ...
		    [x2 y2 handles.origpos.blobmodellbl(3:4)]);

  x2 = figpos(3) - handles.origpos.fig(3) + handles.origpos.blobman(1);
  y2 = handles.origpos.blobman(2) - handles.origpos.blobnum(2) + y; 
  set(handles.bloblabel_manual_text, 'Position', ...
		    [x2 y2 handles.origpos.blobman(3:4)]);
  
  x2 = figpos(3) - handles.origpos.fig(3) + handles.origpos.blobmanlbl(1);
  y2 = handles.origpos.blobmanlbl(2) - handles.origpos.blobnum(2) + y;
  set(handles.bloblabel_manual_label, 'Position', ...
		    [x2 y2 handles.origpos.blobmanlbl(3:4)]);
  
  % Set the position of the control frame and its contents.
  x = handles.origpos.blobimg(1) * rw + ...
      (w2 - handles.origpos.controlframe(3)) / 2;
  y = handles.origpos.blobimg(2) * rh - ...
      handles.origpos.controlframe(4) - 1.2;
  set(handles.controlframe, 'Position', ...
      [x y handles.origpos.controlframe(3:4)]);
  
  x2 = handles.origpos.back(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.back(2) - handles.origpos.controlframe(2) + y;
  set(handles.back, 'Position', [x2 y2 handles.origpos.back(3:4)]);

  x2 = handles.origpos.forward(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.forward(2) - handles.origpos.controlframe(2) + y;
  set(handles.forward, 'Position', [x2 y2 handles.origpos.forward(3:4)]);  
  
  x2 = handles.origpos.imgnum(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.imgnum(2) - handles.origpos.controlframe(2) + y;
  set(handles.imgnum_box, 'Position', [x2 y2 handles.origpos.imgnum(3:4)]);  

  x2 = handles.origpos.pr(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.pr(2) - handles.origpos.controlframe(2) + y;
  set(handles.pr_textedit, 'Position', [x2 y2 handles.origpos.pr(3:4)]);
  
  x2 = handles.origpos.prlbl(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.prlbl(2) - handles.origpos.controlframe(2) + y;
  set(handles.pr_label, 'Position', [x2 y2 handles.origpos.prlbl(3:4)]);

  x2 = handles.origpos.hidethresh(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.hidethresh(2) - handles.origpos.controlframe(2) + y;
  set(handles.hidethreshold_textedit, 'Position', ...
      [x2 y2 handles.origpos.hidethresh(3:4)]);

  x2 = handles.origpos.hidethrlbl(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.hidethrlbl(2) - handles.origpos.controlframe(2) + y;
  set(handles.hidethreshold_label, 'Position', ...
      [x2 y2 handles.origpos.hidethrlbl(3:4)]);
  
  x2 = handles.origpos.showadj(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.showadj(2) - handles.origpos.controlframe(2) + y;
  set(handles.show_adj_btn, 'Position', ...
      [x2 y2 handles.origpos.showadj(3:4)]);

  x2 = handles.origpos.showblobs(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.showblobs(2) - handles.origpos.controlframe(2) + y;
  set(handles.show_blobs_btn, 'Position', ...
      [x2 y2 handles.origpos.showblobs(3:4)]);

  x2 = handles.origpos.changeset(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.changeset(2) - handles.origpos.controlframe(2) + y;
  set(handles.changeset_btn, 'Position', ...
      [x2 y2 handles.origpos.changeset(3:4)]);

  x2 = handles.origpos.fontsize(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.fontsize(2) - handles.origpos.controlframe(2) + y;
  set(handles.fontsize_box, 'Position', [x2 y2 handles.origpos.fontsize(3:4)]);

  x2 = handles.origpos.fontsizelbl(1) - handles.origpos.controlframe(1) + x;
  y2 = handles.origpos.fontsizelbl(2) - handles.origpos.controlframe(2) + y;
  set(handles.fontsize_label, 'Position', ...
      [x2 y2 handles.origpos.fontsizelbl(3:4)]);  
  
  % Set the position for the movie frame.
  pos = get(handles.bloblabel_model_text, 'Position');
  x   = pos(1);
  pos = get(handles.controlframe, 'Position');
  y   = handles.origpos.movieframe(2) - handles.origpos.controlframe(2) + ...
	pos(2);
  set(handles.movieframe, 'Position', ...
      [x y handles.origpos.movieframe(3:4)]);

  x2 = handles.origpos.startmovie(1) - handles.origpos.movieframe(1) + x;
  y2 = handles.origpos.startmovie(2) - handles.origpos.movieframe(2) + y;
  set(handles.startmovie_btn, 'Position', ...
		    [x2 y2 handles.origpos.startmovie(3:4)]);
  
  x2 = handles.origpos.frametime(1) - handles.origpos.movieframe(1) + x;
  y2 = handles.origpos.frametime(2) - handles.origpos.movieframe(2) + y;
  set(handles.frametime_textedit, 'Position', ...
		    [x2 y2 handles.origpos.frametime(3:4)]);

  x2 = handles.origpos.frametimelbl(1) - handles.origpos.movieframe(1) + x;
  y2 = handles.origpos.frametimelbl(2) - handles.origpos.movieframe(2) + y;
  set(handles.frametimelbl, 'Position', ...
		    [x2 y2 handles.origpos.frametimelbl(3:4)]);
  
  x2 = handles.origpos.movielbl(1) - handles.origpos.movieframe(1) + x;
  y2 = handles.origpos.movielbl(2) - handles.origpos.movieframe(2) + y;
  set(handles.movie_label, 'Position', ...
		    [x2 y2 handles.origpos.movielbl(3:4)]);

  % Reinitialize the cache.
  for i = 1:length(handles.data),
    handles.imgCache{i} = new_cache(handles.imgCacheSize, ...
				    handles.data{i}.numImages);
  end;
  
  % Update the display.
  handles = showImages(handles);
  
  % Store the changes.
  guidata(H, handles);

% --------------------------------------------------------------------
% DISPLAY FUNCTIONS
% --------------------------------------------------------------------
% Updates the entire display.
function handles = updateDisplay (handles)
 
  figure(handles.image_browser_figure);
  
  % Update display for data set
  % ---------------------------
  handles = updateDisplayDataset(handles);
  
  % Show model name
  % ---------------
  if length(handles.model),
    s = [handles.model.label '  /  ' handles.model.name];
  else,
    s = '';
  end;
  set(handles.model_name_text, 'String', s);
  
  % Show the movie frame time
  % -------------------------
  set(handles.frametime_textedit, 'String', ...
      num2str(handles.movieFrameTime));
  
% --------------------------------------------------------------------
% Update the display for the current data set.
function handles = updateDisplayDataset (handles)
  
  % Show data set name
  % ------------------
  set(handles.changeset_btn, 'String', ...
      handles.data{handles.curDataset}.setlabel);

  % Show current image
  % ------------------
  handles = updateDisplayImage(handles);

% --------------------------------------------------------------------
% Update the display for the current image.
function handles = updateDisplayImage (handles)

  % Show the images
  % ---------------
  handles = showImages(handles);
    
  % Show document number
  % --------------------
  set(handles.imgnum_box, 'String', num2str(handles.curImg));

  % Show file name
  % --------------
  d       = handles.curDataset;
  imgName = [handles.data{d}.images{handles.curImg} ...
      handles.data{d}.imgSuffix{handles.data{d}.imgsets(handles.curImg)}];
  set(handles.origimg_label, 'String', ...
	sprintf('ORIGINAL IMAGE (%s)', imgName));

  updateDisplayBloblabel(handles);
  
% --------------------------------------------------------------------
% Show the images in the display.
function handles = showImages (handles)

  % Function constants.
  imageCallback = ...
      'image_browser(''image_callback'',gcbo,[],guidata(gcbo))';
  baseMarkerSize = 24;
  
  % Load image from cache
  % ---------------------
  [imageData handles.imgCache{handles.curDataset}] = ...
	loadImageFromCache(handles, handles.curImg);
  axes(handles.origimg);
  cla;
  imshow(imageData.img);
  
  d        = handles.curDataset;
  numBlobs = size(imageData.segments,3);
  
  % Show manual clusters
  % --------------------
  axes(handles.manualimg);
  cla;
  t = handles.data{d}.blobWords(:,1:numBlobs,handles.curImg)';
  updateDisplayClusters(handles, t, handles.data{d}.words, ...
			imageData.blobimg, imageData);
  set(handles.manualimg, 'YTick', [], 'XTick', [], 'XTickLabel', [], ...
		    'YTickLabel', [], 'Box', 'off');

  axes(handles.blobimg);
  cla;
  if handles.showAdj,

    % Show the adjacencies
    % --------------------
    imshow(imageData.blobimg);
    imgHandle = image(imageData.blobimg);
    set(imgHandle, 'ButtonDownFcn', imageCallback);

    % Show the adjacencies for each blob.
    % Repeat for each blob.
    % Do a check to make sure the adjacencies are symmetric. If not,
    % blow the whistle!
    adj = handles.data{handles.curDataset}.adjacencies{handles.curImg};
    if sum(sum((adj > 0) ~= (adj > 0)')) > 0,
      fprintf(['Warning: the adjacency matrix for image %i is not' ...
	       ' symmetric.\n'], handles.curImg);
    end;
    
    if handles.showBlobNums,
      markerSize = 18 + handles.imgLabelFontSize*3;
    else,
      markerSize = baseMarkerSize;
    end;    
    
    for b1 = 1:size(imageData.segments,3),
      % Show the blob only if it is greater than the "hide threshold".
      if imageData.segarea(b1) >= handles.hideThresh,
	% Repeat for each of the neighbours of blob b.
	for b2 = find(adj(b1,:)),
	  if imageData.segarea(b2) >= handles.hideThresh,
	    % Show a line between the two blobs.
	    line([imageData.segpos(b1,2) imageData.segpos(b2,2)], ...
		 [imageData.segpos(b1,1) imageData.segpos(b2,1)], ...
		 'ButtonDownFcn', imageCallback, 'LineWidth', 1, ...
		 'Marker', '.', 'MarkerSize', markerSize, ...
		 'Color', [0 0 0.75]);
	  end;
	end;
      end;
    end;
    
    % Show the selected blob.
    if handles.curBlob,
      b = handles.curBlob;
      % Repeat for each of the neighbours of blob b.
      for b2 = find(adj(b,:)),
	if imageData.segarea(b2) >= handles.hideThresh,
	  % Show a line between the two blobs.
	  line([imageData.segpos(b,2) imageData.segpos(b2,2)], ...
	       [imageData.segpos(b,1) imageData.segpos(b2,1)], ...
	       'ButtonDownFcn', imageCallback, 'LineWidth', 1, ...
	       'Marker', '.', 'MarkerSize', markerSize, ...
	       'Color', [0.6 0 0]);
	end;
      end;
    end;      
    
    % Show the blob numbers.
    if handles.showBlobNums, 
      for b = 1:size(imageData.segments,3),
	% Show the blob only if it is greater than the "hide threshold".
	if imageData.segarea(b) >= handles.hideThresh,
	  text(imageData.segpos(b,2), imageData.segpos(b,1), ...
	       sprintf('%i', b), 'Color', [1 1 1], 'FontSize', ...
	       handles.imgLabelFontSize, ...
	       'HorizontalAlignment', 'center', 'ButtonDownFcn', ...
	       imageCallback);
	end;
      end;    
    end;
  else, 
    
    % Show model clusters
    % -------------------
    if length(handles.model),
      numWords = min(handles.PR, length(handles.model.words));
      t = zeros(numBlobs, numWords);
      for b = 1:numBlobs,
	ws     = getBestWords(handles.t{d}, b, handles.curImg);
	t(b,:) = ws(1:numWords)';
      end;
      updateDisplayClusters(handles, t, handles.model.words, ...
			    imageData.blobimg, imageData);  
    else,
      imshow(imageData.blobimg);
      imgHandle = image(imageData.blobimg);
      set(imgHandle, 'ButtonDownFcn', imageCallback);
    end;
  end;
  set(handles.blobimg, 'YTick', [], 'XTick', [], 'XTickLabel', [], ...
		       'YTickLabel', [], 'Box', 'off');  
  
% --------------------------------------------------------------------
% Show the words in the segments.
function updateDisplayClusters (handles, t, words, img, imageData)
  
  imageCallback = ...
      'image_browser(''image_callback'',gcbo,[],guidata(gcbo))';
  
  % Display image
  % -------------
  imshow(img);
  imgHandle = image(img);
  set(imgHandle, 'ButtonDownFcn', imageCallback);

  % Show the words for each blob
  % ----------------------------
  for b = 1:size(t,1),
    
    % Show the blob only if it is greater than the "hide threshold".
    if imageData.segarea(b) >= handles.hideThresh,
      if handles.showBlobNums,
        s = sprintf(' (%i)', b); 
      else,
	s = '';
      end;
      
      for w = 1:sum(t(b,:) > 0),
        s = [s sprintf('\n%s', words{t(b,w)})];
      end;
    
      % If there are words to display, show it!
      if length(s),
        s = s(2:length(s));
        text(imageData.segpos(b,2), imageData.segpos(b,1), s, ...
	     'Color', imageData.segwhite(b)*[1 1 1], ...
	     'FontSize', handles.imgLabelFontSize, ...
	     'HorizontalAlignment', 'center', ...
	     'FontWeight', 'bold', 'ButtonDownFcn', imageCallback);
      end;
    end;
  end;

% --------------------------------------------------------------------
% Show the words for the selected blob.
function updateDisplayBloblabel (handles)
  
  % Function constants.
  numWordsToShow = 10;
  wordProbThresh = 0.009;
  relStrings = { 'is next to';
		 'is below';
		 'is above' };
  
  % Show the blob number
  % --------------------
  if handles.curBlob,
    s = sprintf('blob %i', handles.curBlob);
  else,
    s = '';
  end;
  set(handles.blob_num_text, 'String', s);  
  
  if ~handles.curBlob,
    set(handles.bloblabel_model_text, 'String', '');
    set(handles.bloblabel_manual_text, 'String', '');
    return;
  end;
  
  d = handles.curDataset;
  b = handles.curBlob;
  i = handles.curImg;
  W = handles.data{d}.blobWordCounts(i,b);
  
  % Show model labeling or the adjacencies
  % --------------------------------------
  if handles.showAdj,
    adj = handles.data{d}.adjacencies{handles.curImg}(handles.curBlob,:);
    s = '';
    for j = 1:length(adj),
      if adj(j),
	s = [s sprintf('- %i %s %i\n', handles.curBlob, ...
		       relStrings{adj(j)}, j)];
      end;
    end;
    set(handles.bloblabel_model_text, 'String', s);
    
  elseif length(handles.model),
    % First get a list of the best words.
    [words probs] = getBestWords(handles.t{d}, b, i);
    s = '';
    for w = 1:min([numWordsToShow length(handles.model.words) ...
		   sum(probs > wordProbThresh)]),
      s = [s sprintf('%.3f %s\n', probs(w), ...
		     handles.model.words{words(w)})];
    end;
    set(handles.bloblabel_model_text, 'String', s);
  else,
    set(handles.bloblabel_model_text, 'String', '');
  end;
  
  % Update manual labeling
  % ----------------------
  s = '';
  for w = 1:W,
    wi = handles.data{d}.blobWords(w,b,i);
    if wi,
      s = [s sprintf('%s\n', handles.data{d}.words{wi})];
    end;
  end;
  set(handles.bloblabel_manual_text, 'String', s);
  
% --------------------------------------------------------------------
% IMAGE CACHE FUNCTIONS
% --------------------------------------------------------------------
% Load the image from the cache. If it is not in the cache, load it from
% disk. 
function [imageData, imgCache] = loadImageFromCache (handles, imgNum)
  
  imgCache = handles.imgCache{handles.curDataset};
  
  % Get image from cache if it's there
  % ----------------------------------
  % First check to see if the image is already in the cache. If so, let's
  % just return the images from the cache.
  imageData = get_cache_elem(imgCache, imgNum);
  if length(imageData),
    return;
  end;
  
  % Load image from disk
  % --------------------
  % If we've come this far, it's because we haven't found this image
  % index in the cache so we need to load it. First, load the information
  % from disk.
  data    = handles.data{handles.curDataset};
  imgName = data.images{imgNum};
  imgSet  = data.imgsets(imgNum);
  
  imgSuffix  = data.imgSuffix{imgSet};
  imgDir     = [data.datadir{imgSet} '/' data.imgSubdir{imgSet}];
  segDir     = [data.datadir{imgSet} '/' data.segSubdir{imgSet}];
  blobimgDir = [data.datadir{imgSet} '/' data.blobimgSubdir{imgSet}];
  
  pathNameImg     = [imgDir '/' imgName imgSuffix];
  pathNameMat     = [segDir '/' imgName '.mat'];
  pathNameBlobimg = [blobimgDir '/' imgName imgSuffix];
  
  [img seg] = load_segment_info(pathNameImg, pathNameMat);
  segments  = find_segments(seg);
  blobimg   = double(loadImageFromDisk(pathNameBlobimg, size(img)));
  
  % Resize images to fit the axes
  % -----------------------------
  % Modify the image controls.
  set(handles.origimg, 'Units', 'points');
  pos = get(handles.origimg, 'Position');
  set(handles.origimg, 'Units', 'characters'); 

  w      = round(pos(3));
  h      = round(pos(4));
  imageData.img     = uint8(resizeImgForAxes(img, w, h, 'bilinear'));
  imageData.blobimg = uint8(resizeImgForAxes(blobimg, w, h, 'bilinear'));
  
  % Resize the display segments
  % ---------------------------
  S = size(segments,3);
  imageData.noseg = zeros(h, w);
  imageData.segments = zeros(h,w,S);
  for s = 1:S,
    imageData.segments(:,:,s) = ...
	resizeImgForAxes(segments(:,:,s), w, h, 'nearest', 0);
    noseg = imageData.noseg + (imageData.segments(:,:,s) == 0);
  end;
  
  % This is the "remains" of the image -- the regions of the displayed
  % image that do not correspond to any segment.
  imageData.noseg = (noseg >= S);
  clear segments noseg
  
  % Get other image info
  % --------------------
  % Get the average (x,y), normalized area and RGB colour for each
  % segment. 
  imageData.segpos   = zeros(S,2);
  imageData.segwhite = zeros(S,1);
  iamgeData.segarea  = zeros(S,1);
  [h w C]            = size(imageData.img);
  img                = reshape(imageData.img,1,h*w,C);
  
  for s = 1:S,
    % Compute (x,y).
    [y x] = find(imageData.segments(:,:,s));
    imageData.segpos(s,:) = [mean(y) mean(x)];
    
    % Compute RGB colour.
    grey=mean(mean(img(:,find(reshape(imageData.segments(:,:,s),1,h*w)),:)));
    imageData.segwhite(s) = grey < 150;
    
    % Compute area.
    imageData.segarea(s) = sum(sum(imageData.segments(:,:,s))) / (h*w);
  end;
  clear img grey  
  
  % Put the information into the cache
  % ----------------------------------
  imgCache = add_cache_elem(imgCache, imageData, imgNum);

% --------------------------------------------------------------------
% Load the image from disk and crop it.
function img = loadImageFromDisk (filename, imgSize)
  
  try
    img = imread(filename);
    img = crop_image(img, imgSize);
    
  catch
    img = [];
    fprintf('Unable to load image %s. \n', filename);
  end;
    
% --------------------------------------------------------------------
% Resize an image.
function reImg = resizeImgForAxes(img, w, h, method, bgclr);
  
  if nargin < 5,
    bgclr = 255;
  end;
  
  w = round(w);
  h = round(h);
  [ho wo C] = size(img);
  if h*wo < w*ho,
    % Resize according to height.
    s  = h / ho;
    wn = floor(s*wo);
    img = imresize(img, [h wn], 'bilinear');
    
    % Fill in the width so that it matches the dimensions of (w,h). 
    for c = 1:C,
      t = (w - wn) / 2;
      reImg(:,:,c) = ...
	  [bgclr*ones(h, floor(t)) img(:,:,c) bgclr*ones(h, ceil(t))];
    end;
  else,
    
    % Resize according to width.
    s  = w / wo;
    hn = floor(s*ho);
    img = imresize(img, [hn w], method);
    
    % Fill in the width so that it matches the dimensions of (w,h). 
    for c = 1:C,
      t = (h - hn) / 2;
      reImg(:,:,c) = [bgclr*ones(floor(t), w); 
	              img(:,:,c); 
	              bgclr*ones(ceil(t), w)];
    end;
  end;

% --------------------------------------------------------------------
% MISCELLANEOUS FUNCTIONS
% --------------------------------------------------------------------
% Change the current data set.
function handles = switchDatasets (handles, curDataset)
  
  handles.curDataset = curDataset;
  handles.curImg = 1;

% --------------------------------------------------------------------
function [words, probs] = getBestWords (t, blob, img)
  
  t = t(:,blob,img);
  [probs words] = sort(-t);
  probs = -probs;
