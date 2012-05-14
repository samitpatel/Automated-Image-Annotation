% CREATE_IMAGE_LABELS    Run the interface for adding labels to images
%                        and image segments.
%    CREATE_IMAGE_LABELS('INIT',DATA_DIR,IMG_CACHE_SIZE) runs the image
%    labeling interface using the Matlab GUI package. The first parameter
%    must be 'INIT'. DATA_DIR is the directory where the IMAGE_INDEX is
%    located. IMG_CACHE_SIZE is an optional parameter to specify the
%    number of images stored in memory. This speeds up the display. The
%    default is 16.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function varargout = create_image_labels (varargin)
  
  % Invoke callback function
  % ------------------------
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
% Initialization function for GUI.
function init (data_dir, varargin)
  
  % Function constants.
  imageIndexFileName   = 'image_index';
  blobsFileName        = 'blob_features';
  imageLabelsFileName  = 'labels';  
  segmentsWEdgesSuffix = '_edges';
  segmentsOrigSuffix   = '_orig';
  generalPath          = '../general';
  defaultImgCacheSize  = 16;
  defaultImgLabelSize  = 9;
  
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
  
  % Manage function parameters
  % --------------------------
  % Get the parameters from "varargin".
  defargs = { defaultImgCacheSize };
  [handles.imgCacheSize] = manage_vargs(varargin, defargs);  
  clear defargs varargin
  
  % Load image index and blob features
  % ----------------------------------
  try
    % Load the image index from the data directory.
    handles.imgIndex = load_image_index(data_dir, imageIndexFileName);
  
    % We've successfully loaded the image index, so let's load the blob
    % features information.
    handles.blobs = load_blob_features(data_dir, blobsFileName);
    
  catch
    disp(lasterr);
    close;
    return;
  end;
  
  % Load old image labels
  % ---------------------
  % Now that we've successfully loaded the segment information, let's
  % check to see if the some images have already previously been
  % labeled.
  try
    labels = load_image_labels(data_dir, imageLabelsFileName);
    handles.labels = update_image_labels(handles.blobs, labels);
    clear labels
  catch
    % If we've hit this point, that means that we were unsuccessful in
    % loading the image labels file. Let's create an empty data struct.
    handles.labels = update_image_labels(handles.blobs);
  end;
  
  % Initialize image cache
  % ----------------------
  handles.imgCache = new_cache(handles.imgCacheSize, ...
			       length(handles.imgIndex.images));
  
  % Initialize vocabulary
  % ---------------------
  handles.vocabulary = labelfunc('newVocab', handles.labels);
  
  % Set up interface
  % ----------------
  % Modify the vocabulary control.
  set(handles.vocab, 'FontName', 'helvetica');
  set(handles.vocab, 'Value', []);  
  handles.imgLabelFontSize = defaultImgLabelSize;
  
  % Set up some interface variables.
  handles.selWords   = [];
  handles.curImg     = 1;
  handles.mainDir    = data_dir;
  handles.segDir     = [data_dir '/' handles.imgIndex.segSubdir];
  handles.imgDir     = [data_dir '/' handles.imgIndex.imgSubdir];
  handles.segimgDir  = [data_dir '/' handles.imgIndex.segimgSubdir];
  handles.blobimgDir = [data_dir '/' handles.imgIndex.blobimgSubdir];
  handles.imageLabelsFileName  = imageLabelsFileName;
  handles.segmentsWEdgesSuffix = segmentsWEdgesSuffix;
  handles.segmentsOrigSuffix   = segmentsOrigSuffix;
  clear segmentsWEdgesSuffix segmentsOrigSuffix
  
  % The original positions for GUI controls.
  handles.origpos.fig          = get(fig, 'Position');
  handles.origpos.save         = get(handles.save_btn, 'Position');
  handles.origpos.merge        = get(handles.merge_btn, 'Position');
  handles.origpos.vocabremove  = get(handles.vocabremove, 'Position');
  handles.origpos.rename       = get(handles.modify_btn, 'Position');
  handles.origpos.vocab        = get(handles.vocab, 'Position');
  handles.origpos.vocablabel   = get(handles.vocab_label, 'Position');

  handles.origpos.segimg       = get(handles.segimg, 'Position');
  handles.origpos.segimglabel  = get(handles.segimg_label, 'Position');
  handles.origpos.origimg      = get(handles.origimg, 'Position');
  handles.origpos.origimglabel = get(handles.origimg_label, 'Position');
  handles.origpos.avgimg       = get(handles.avgimg, 'Position');
  handles.origpos.clustertxt   = get(handles.cluster_text, 'Position');

  handles.origpos.frame        = get(handles.theframe, 'Position');
  handles.origpos.docwords     = get(handles.doc_words, 'Position');
  handles.origpos.text8        = get(handles.text8, 'Position');
  handles.origpos.addwordedit  = get(handles.addwordedit, 'Position');
  handles.origpos.addwordbtn   = get(handles.addwordbutton, 'Position');
  handles.origpos.removebtn    = get(handles.remove_btn, 'Position');
  handles.origpos.backbtn      = get(handles.back, 'Position');
  handles.origpos.forwardbtn   = get(handles.forward, 'Position');
  handles.origpos.imgnumbox    = get(handles.imgnum_box, 'Position');
  handles.origpos.text9        = get(handles.text9, 'Position');
  handles.origpos.fontsizebox  = get(handles.fontsize_box, 'Position');
  
  % Update display
  % --------------
  handles = updateDisplay(handles);
  
  % Store the changes.
  guidata(fig, handles);

% --------------------------------------------------------------------
% Callback routine for vocabulary list control.
function varargout = vocab_Callback(h, eventdata, handles, varargin)
  
  % Find out what words are selected.
  selWords = get(handles.vocab, 'Value');
    
  % Create the string of words for display in the "addwordedit" control. 
  dispStr = '';
  for s = 1:length(selWords),
    str = handles.vocabulary.words{selWords(s)};
    dispStr = [dispStr str ' '];
  end;
  set(handles.addwordedit, 'String', dispStr);
  
  % Update the clusters display.
  handles.selWords = selWords;
  updateDisplayClusters(handles);
  
  % Store the changes.
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for word textedit control.
function varargout = addwordedit_Callback(h, eventdata, handles, varargin)
  
% --------------------------------------------------------------------
% Callback routine for "add word" button.
function varargout = addwordbutton_Callback(h, eventdata, handles, varargin)
  
  % Parse the user's input.
  strs = parseUserInput(get(handles.addwordedit, 'String'));
  
  dispStr          = '';
  addedWordToLabel = 0;
  addedWordToVocab = 0;
  
  % Repeat for each word in the user's input.
  for s = 1:length(strs),
    str = strs{s};
    
    % Add the word to the label.
    [handles.labels handles.vocabulary ans aToLabel aToVocab] = ...
	labelfunc('addWordToLabel', handles.labels, handles.vocabulary, ...
		  handles.curImg, str);
    
    addedWordToLabel = addedWordToLabel | aToLabel;
    addedWordToVocab = addedWordToVocab | aToVocab;
    
    % Update the display string.
    dispStr = [dispStr str ' '];
  end;
  
  % Get the list of words to select.
  selWords = [];
  for s = 1:length(strs),
    str = strs{s};
    selWords = [selWords labelfunc('findWordInVocab', ...
				   handles.vocabulary, str)];
  end;
  
  % Update the edit text display.
  set(handles.addwordedit, 'String', dispStr);
  
  % Update the "doc_words" static text display.
  if addedWordToLabel,
    updateDisplayLabels(handles);
  end;
  
  % Update the vocabulary display.
  if addedWordToVocab,
    updateDisplayVocab(handles);
  end;
  
  % Select the words in the vocabulary display.
  set(handles.vocab, 'Value', selWords);
  
  % Show the segments only if there is exactly one word selected.
  handles.selWords = selWords;
  updateDisplayClusters(handles);
  
  % Store the changes.
  guidata(h, handles);
  
% --------------------------------------------------------------------
% Callback routine for the "remove word" button.
function varargout = remove_btn_Callback(h, eventdata, handles, varargin)

  strs = parseUserInput(get(handles.addwordedit, 'String'));
  
  removedWordFromLabel = 0;
  removedWordFromVocab = 0;
  
  for s = 1:length(strs),
    str = strs{s};  
    
    % Remove the word from the label.
    [handles.labels handles.vocabulary aFromLabel aFromVocab] = ...
	labelfunc('removeWordFromLabel', handles.labels, ...
		  handles.vocabulary, handles.curImg, str);
    
    removedWordFromLabel = removedWordFromLabel | aFromLabel;
    removedWordFromVocab = removedWordFromVocab | aFromVocab;
  end;
  
  % Update the edit text display.
  set(handles.addwordedit, 'String', '');
  
  % Update the "doc_words" static text display.
  if removedWordFromLabel,
    updateDisplayLabels(handles);
  end;
  
  % Update the vocabulary display.
  if removedWordFromVocab,
    updateDisplayVocab(handles);
  end;  
  
  % Update the clusters display.
  handles.selWords = [];
  updateDisplayClusters(handles);
  
  % Select the words in the vocabulary display.
  set(handles.vocab, 'Value', []);
  
  % Store the changes.
  guidata(h, handles);  

% --------------------------------------------------------------------
% Callback routine for the "remove word from vocabulary" button.
function varargout = vocabremove_Callback(h, eventdata, handles, varargin)
  
  % Find out what words are selected.
  selWords = get(handles.vocab, 'Value');
    
  % Repeat for each word selected in the vocabulary.
  for w = 1:length(selWords),
    wrd = handles.vocabulary.words{selWords(w)};
    
    % Remove the word from the vocabulary.
    [handles.labels handles.vocabulary ans] = ...
	labelfunc('removeWordFromVocab', handles.labels, ...
		  handles.vocabulary, wrd);
  end;

  % Update the edit text display.
  set(handles.addwordedit, 'String', '');
  
  % Update the "doc_words" static text display.
  updateDisplayLabels(handles);
  updateDisplayVocab(handles);
  
  % Update the vocabulary display.
  set(handles.vocab, 'Value', []);
  
  % Update the clusters display.
  handles.selWords = [];
  updateDisplayClusters(handles);
  
  % Store the changes.
  guidata(h, handles);  

% --------------------------------------------------------------------
% Callback routine for the "merge words" button.
function varargout = merge_btn_Callback(h, eventdata, handles, varargin)

  % Find out what words are selected. There must be at least two words
  % selected.
  selWords = get(handles.vocab, 'Value');
  if selWords < 2,
    set(handles.vocab, 'Value', []);
    return;
  end;
  
  % Get a list of the vocabulary words selected.
  wrds = {};
  for w = 1:length(selWords),
    wrds{length(wrds)+1,1} = handles.vocabulary.words{selWords(w)};
  end;
  
  [handles.labels handles.vocabulary] = ...
      labelfunc('mergeVocabWords', handles.labels, ...
		handles.vocabulary, wrds);
  
  % Update the edit text display.
  set(handles.addwordedit, 'String', wrds{1});
  
  % Update the "doc_words" static text display.
  updateDisplayLabels(handles);
  updateDisplayVocab(handles);
  
  % Update the vocabulary display.
  selWords = selWords(1);
  set(handles.vocab, 'Value', selWords);
  
  % Update the clusters display.
  handles.selWords = selWords;
  updateDisplayClusters(handles);
  
  % Store the changes.
  guidata(h, handles);    
  
% --------------------------------------------------------------------
% Callback routine for the "rename word" button.
function varargout = modify_btn_Callback(h, eventdata, handles, varargin)
  
  % Find out what words are selected. It only works if exactly one word
  % is selected.
  selWords = get(handles.vocab, 'Value');
  if length(selWords) ~= 1,
    return;
  end;
  
  % Next get the text in the edit box.
  strs = parseUserInput(get(handles.addwordedit, 'String'));
  if length(strs) == 0,
    fprintf(['You must enter a string to replace. If you want to remove' ...
	     ' the word, use delete.\n']);
    return;
  elseif length(strs) > 1,
    fprintf('You can only replace with one word.\n');
    return;
  end;
    
  % Check to see if it is the same word as before.
  newWrd = strs{1};
  w      = selWords(1);
  oldWrd = handles.vocabulary.words{w};
  if strcmp(newWrd, oldWrd),
    return;
  end;  
 
  % Next check to make sure that the new name for the word isn't already
  % being used. If so, do nothing.
  i = labelfunc('findWordInVocab', handles.vocabulary, newWrd);
  if i,
    fprintf('Word already exists in vocabulary. Use merge instead.\n');
    return;
  end;  
  clear i
 
  % Now we have exactly one word and we know it's not already in the
  % vocabulary. 
  [handles.labels handles.vocabulary w] = ...
      labelfunc('renameVocabWord', handles.labels, ...
		handles.vocabulary, oldWrd, newWrd);

  % Select the words in the vocabulary display.
  set(handles.vocab, 'Value', [w]);

  % Update the "doc_words" static text display and the vocabulary
  % display. 
  updateDisplayLabels(handles);
  updateDisplayVocab(handles);
  updateDisplayClusters(handles);
  
  % Store the changes.
  guidata(h, handles);    

% --------------------------------------------------------------------
% Callback routine for the back button.
function varargout = back_Callback(h, eventdata, handles, varargin)

  if handles.curImg > 1,
    handles.curImg = handles.curImg - 1;
    handles = updateDisplayImage(handles);
  end;
  
  % Store the changes.
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the forward button.
function varargout = forward_Callback(h, eventdata, handles, varargin)

  if handles.curImg < length(handles.imgIndex.images),
    handles.curImg = handles.curImg + 1;
    handles = updateDisplayImage(handles);
  end;

  % Store the changes.
  guidata(h, handles);

% --------------------------------------------------------------------
% Callback routine for the image number textedit box.
function varargout = imgnum_box_Callback(h, eventdata, handles, varargin)

  n = str2num(get(handles.imgnum_box, 'String'));
  
  numImages = length(handles.imgIndex.images);
  if length(n) > 0,
    
    if n < 1,
      n = 1;
    elseif n > numImages,
      n = numImages;
    end;
    
    if n ~= handles.curImg,
      handles.curImg = n;
      handles = updateDisplayImage(handles);
    end;
  end;
  
  % Store the changes.
  set(handles.imgnum_box, 'String', num2str(handles.curImg));
  guidata(h, handles);

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
% Callback routine for the "quit" menu item.
function varargout = QuitMenuItem_Callback(h, eventdata, handles, varargin)
  close;
  
% --------------------------------------------------------------------
% Callback routine for the "save" menu item.
function varargout = SaveMenuItem_Callback(h, eventdata, handles, varargin)
  save_btn_Callback(h, eventdata, handles, varargin);
  
% --------------------------------------------------------------------
% Callback routine for the figure.
function varargout = figure1_ButtonDownFcn(h, eventdata, handles, varargin)
  
% --------------------------------------------------------------------
% Callback routine for the "save" button.
function varargout = save_btn_Callback(h, eventdata, handles, varargin)
  
  % Write the image labels to disk.
  write_image_labels(handles.mainDir, handles.imageLabelsFileName, ...
		     handles.labels);
		     
% --------------------------------------------------------------------
% Callback routine for the file menu.
function varargout = FileMenu_Callback(h, eventdata, handles, varargin)

% --------------------------------------------------------------------
% Callback routine when the user clicks on one of the images.
function varargout = image_callback(h, eventdata, handles, varargin)
  
  % Get location of mouse click
  % ---------------------------
  pt = get(gca,'CurrentPoint');
  x = round(pt(1,1));
  y = round(pt(1,2));
  
  % Load the image data from the cache and check which cluster (x,y) is
  % in. 
  [imageData handles.imgCache] = ...
      loadImageFromCache(handles, handles.curImg);
  [h w] = size(imageData.seg);
  b = imageData.seg(min(y,h), min(x,w));

  % If the user did not select a point in a cluster, do nothing.
  if ~b,
    return;
  end;
  
  % Display text for a single blob
  % ------------------------------
  % First figure out if the user is displaying blobs. This is only the
  % case if there is exactly one word selected in the vocabulary and
  % exactly one word in the edit text box. Otherwise, do nothing (other
  % than update the cluster text display).
  if length(handles.selWords) ~= 1,
    % Update the clusters text display.
    updateDisplayClusterText(handles, b);    
    return;
  end;
  
  % Update the blob we clicked on
  % -----------------------------
  % Now that we've found the blob, figure out whether the word is
  % currently in it. We want to toggle it's existence in the blob.
  addedToLabel = 0;
  wrd = handles.vocabulary.words{handles.selWords};
  w   = labelfunc('findWordInCorresp', handles.labels, ...
			  handles.curImg, b, wrd);
  if w,
    % We found the word, so remove it.
    [handles.labels handles.vocabulary ans ans ans] = ...
	labelfunc('removeWordFromCorresp', handles.labels, ...
		  handles.vocabulary, handles.curImg, b, wrd);
  else,
    % We didn't find the word, so add it.
    [handles.labels handles.vocabulary ans ans ans ans] = ...
	labelfunc('addWordToCorresp', handles.labels, ...
		  handles.vocabulary, handles.curImg, b, wrd);
    
    % If necessary, add the word to the label.
    [handles.labels ans ans addedToLabel ans] = ...
	labelfunc('addWordToLabel', handles.labels, handles.vocabulary, ...
		  handles.curImg, wrd);
  end;
  
  % Update display
  % --------------
  % Update the image label.
  updateDisplayLabels(handles);
  
  % Update the clusters display.
  updateDisplayClusters(handles);
  
  % Update the clusters text display.
  updateDisplayClusterText(handles, b);

  % Store the changes.
  guidata(handles.create_image_labels_figure, handles);

% --------------------------------------------------------------------
% Callback when the window is resized.
function varargout = ResizeFcn(H, eventdata, handles, varargin)
  
  if ~length(handles),
    return;
  end;
  
  % Get the new location of the figure.
  fig    = gcbo;
  figpos = get(fig,'Position');
  
  % Make sure the new dimensions of the figure are allowed. We cannot
  % make the window smaller than the original dimensions.
  figpos(3:4) = max(figpos(3:4), handles.origpos.fig(3:4));
  
  % Set the position for the Save button.
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.save(1);
  y = handles.origpos.save(2);
  set(handles.save_btn, 'Position', [x y handles.origpos.save(3:4)]);
  
  % Set the position of the Merge button.
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.merge(1);
  y = handles.origpos.merge(2);  
  set(handles.merge_btn, 'Position', [x y handles.origpos.merge(3:4)]);
  
  % Set the position of the Remove button.
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.vocabremove(1);
  y = handles.origpos.vocabremove(2);  
  set(handles.vocabremove, 'Position', [x y handles.origpos.vocabremove(3:4)]);

  % Set the position of the Rename button.
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.rename(1);
  y = handles.origpos.rename(2);  
  set(handles.modify_btn, 'Position', [x y handles.origpos.rename(3:4)]);

  % Set the position of the Vocabulary control
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.vocab(1);
  y = handles.origpos.vocab(2);  
  set(handles.vocab, 'Position', [x y handles.origpos.vocab(3:4)]);
  
  % Set the position of the Vocabulary Label control
  x = figpos(3) - handles.origpos.fig(3) + handles.origpos.vocablabel(1);
  y = handles.origpos.vocablabel(2);  
  set(handles.vocab_label, 'Position', [x y handles.origpos.vocablabel(3:4)]); 
  
  % Set the position of the segmented image.
  rw = figpos(3) / handles.origpos.fig(3);
  rh = figpos(4) / handles.origpos.fig(4);
  w  = handles.origpos.segimg(3) * rw;
  h  = handles.origpos.segimg(4) * rh;
  x  = handles.origpos.segimg(1) * rw;
  y  = handles.origpos.segimg(2) * rh;
  set(handles.segimg, 'Position', [x y w h]);
  
  % Set the position of the segmented image label.
  w2 = handles.origpos.segimglabel(3) * rw;
  h2 = handles.origpos.segimglabel(4);
  x  = handles.origpos.segimglabel(1) * rw;
  y  = handles.origpos.segimglabel(2) * rh;  
  set(handles.segimg_label, 'Position', [x y w2 h2]);  
  
  % Set the position of the original image.
  x = handles.origpos.origimg(1) * rw;
  y = handles.origpos.origimg(2) * rh;
  set(handles.origimg, 'Position', [x y w h]);
  
  % Set the position of the original image label.
  w2 = handles.origpos.origimglabel(3) * rw;
  h2 = handles.origpos.origimglabel(4);
  x  = handles.origpos.origimglabel(1) * rw;
  y  = handles.origpos.origimglabel(2) * rh;  
  set(handles.origimg_label, 'Position', [x y w2 h2]);
  
  % Set the position of the averaged image.
  x = handles.origpos.avgimg(1) * rw;
  y = handles.origpos.avgimg(2) * rh;
  set(handles.avgimg, 'Position', [x y w h]);
  
  % Set the position of the averaged image label.
  w2 = handles.origpos.clustertxt(3) * rw;
  h2 = handles.origpos.clustertxt(4);
  x  = handles.origpos.clustertxt(1) * rw;
  y  = handles.origpos.clustertxt(2) * rh;  
  set(handles.cluster_text, 'Position', [x y w2 h2]);  

  % Set the position of the frame and its contents.
  x = handles.origpos.avgimg(1) * rw + (w2 - handles.origpos.frame(3)) / 2;
  y = handles.origpos.avgimg(2) * rh - handles.origpos.frame(4) - 1.2;
  set(handles.theframe, 'Position', [x y handles.origpos.frame(3:4)]);
  
  x2 = handles.origpos.docwords(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.docwords(2) - handles.origpos.frame(2) + y;
  set(handles.doc_words, 'Position', [x2 y2 handles.origpos.docwords(3:4)]);
  
  x2 = handles.origpos.text8(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.text8(2) - handles.origpos.frame(2) + y;
  set(handles.text8, 'Position', [x2 y2 handles.origpos.text8(3:4)]);
  
  x2 = handles.origpos.addwordedit(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.addwordedit(2) - handles.origpos.frame(2) + y;
  set(handles.addwordedit, 'Position', ...
		    [x2 y2 handles.origpos.addwordedit(3:4)]);
  
  x2 = handles.origpos.addwordbtn(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.addwordbtn(2) - handles.origpos.frame(2) + y;
  set(handles.addwordbutton, 'Position', ...
		    [x2 y2 handles.origpos.addwordbtn(3:4)]);

  x2 = handles.origpos.removebtn(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.removebtn(2) - handles.origpos.frame(2) + y;
  set(handles.remove_btn, 'Position', [x2 y2 handles.origpos.removebtn(3:4)]);

  x2 = handles.origpos.backbtn(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.backbtn(2) - handles.origpos.frame(2) + y;
  set(handles.back, 'Position', [x2 y2 handles.origpos.backbtn(3:4)]);

  x2 = handles.origpos.forwardbtn(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.forwardbtn(2) - handles.origpos.frame(2) + y;
  set(handles.forward, 'Position', [x2 y2 handles.origpos.forwardbtn(3:4)]);

  x2 = handles.origpos.imgnumbox(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.imgnumbox(2) - handles.origpos.frame(2) + y;
  set(handles.imgnum_box, 'Position', [x2 y2 handles.origpos.imgnumbox(3:4)]);
  
  x2 = handles.origpos.text9(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.text9(2) - handles.origpos.frame(2) + y;
  set(handles.text9, 'Position', [x2 y2 handles.origpos.text9(3:4)]);
  
  x2 = handles.origpos.fontsizebox(1) - handles.origpos.frame(1) + x;
  y2 = handles.origpos.fontsizebox(2) - handles.origpos.frame(2) + y;
  set(handles.fontsize_box, 'Position', ...
		    [x2 y2 handles.origpos.fontsizebox(3:4)]);

  % Reinitialize the cache.
  handles.imgCache = new_cache(handles.imgCacheSize, ...
			       length(handles.imgIndex.images));
  
  % Update the display.
  handles = showImages(handles);
  
  % Store the changes.
  guidata(H, handles);

% --------------------------------------------------------------------
% DISPLAY FUNCTIONS
% --------------------------------------------------------------------
% Update the display of the entire interface.
function handles = updateDisplay (handles)
 
  figure(handles.create_image_labels_figure);
  
  % Update the display of the current image.
  handles = updateDisplayImage(handles);
  
  % Update the vocabulary display.
  updateDisplayVocab(handles);
  
% --------------------------------------------------------------------
% Update the display of the current image.
function handles = updateDisplayImage (handles)
  
  % Display the images
  % ------------------
  handles = showImages(handles);
    
  % Show document number
  % --------------------
  set(handles.imgnum_box, 'String', num2str(handles.curImg));

  % Show the file name
  % ------------------
  imgName = [handles.imgIndex.images{handles.curImg} ...
	     handles.imgIndex.imgSuffix];
  set(handles.origimg_label, 'String', ...
	sprintf('ORIGINAL IMAGE (%s)', imgName));
  set(handles.segimg_label, 'String', ...
	sprintf('SEGMENTED IMAGE (%s)', imgName));
  clear imgName    
  
  % Show the image labels
  % ---------------------
  updateDisplayLabels(handles);

% --------------------------------------------------------------------
% Show the label for the current image.
function updateDisplayLabels (handles)
  
  dispStr = '';
  for w = 1:handles.labels.wordCounts(handles.curImg),
    dispStr = [dispStr handles.labels.imageWords{handles.curImg,w} ' '];
  end;
  set(handles.doc_words, 'String', dispStr);
  
% --------------------------------------------------------------------
% Show the information contained in the segments, such as
% correspondences. 
function updateDisplayClusters (handles, imageData)
  
  % Function constants.
  selColour = [153 0 0];
  imageCallback = ...
      'create_image_labels(''image_callback'',gcbo,[],guidata(gcbo))';
  
  % Check to see if the image data was passed as one of the parameters.
  if nargin < 2,
    [imageData handles.imgCache] = ...
	loadImageFromCache(handles, handles.curImg);
  end;
  
  % Set up image to display according to the word that is selected
  % --------------------------------------------------------------
  numSWords   = length(handles.selWords);
  showCluster = zeros(1,handles.blobs.counts(handles.curImg));
  if numSWords ~= 1,
    
    % If the number of selected words is not 1 then show only the blob
    % image. 
    clusterImg = imageData.blobimg;
  else,
    
    % There is exactly one word selected, so show the clusters.
    w   = handles.selWords;
    wrd = handles.vocabulary.words{w};
    clustersToShow = [];
    maxNumBlobs = size(handles.labels.correspCounts, 2);
    for b = 1:maxNumBlobs,
      found = labelfunc('findWordInCorresp' ,handles.labels, ...
			handles.curImg, b, wrd);
      if found,
	clustersToShow = [clustersToShow b];
      end;
    end;
    
    clustersToShow = [clustersToShow 0];
    
    % Create the cluster image
    % ------------------------
    [h w C] = size(imageData.blobimg);
    clusterImg = zeros(h,w,C);
  
    for k = 1:handles.blobs.counts(handles.curImg),
      if clustersToShow(1) == k,
        % This blob IS labeled by the selected word.
	showCluster(k) = 1;
        for c = 1:C,
	  clusterImg(:,:,c) = clusterImg(:,:,c) + ...
	      selColour(c) * imageData.segwedges(:,:,k);
        end;      
        clustersToShow = clustersToShow(2:length(clustersToShow));
      else,
        % This blob is not labeled by the selected word.
        for c = 1:C,
          clusterImg(:,:,c) = clusterImg(:,:,c) + ...
	      imageData.segwedges(:,:,k) .* imageData.blobimg(:,:,c);
        end;
      end;
    end;
  
    % Display the white area around the rest of the blobs.
    for c = 1:C,
      clusterImg(:,:,c) = clusterImg(:,:,c) + 255*imageData.noseg;
    end;
  end;
  
  % Display the newly created image
  % -------------------------------
  handles.clusterImg = uint8(clusterImg);
  axes(handles.avgimg);
  imshow(handles.clusterImg);
  handles.clusterImgHandle = image(handles.clusterImg);
  set(handles.clusterImgHandle, 'ButtonDownFcn', imageCallback);
  set(handles.avgimg, 'YTick', [], 'XTick', [], 'XTickLabel', [], ...
		    'YTickLabel', [], 'Box', 'off');

  % Show the words for each cluster
  % -------------------------------
  for b = 1:handles.blobs.counts(handles.curImg),
    
    dispText = '';
    
    % Repeat for each word in the blob.
    for w = 1:handles.labels.correspCounts(handles.curImg,b),
      dispText = [dispText ...
		  sprintf('\n%s', ...
			  handles.labels.blobWords{handles.curImg,b,w})];
    end;
    
    % If there are words to display, show them!
    if length(dispText),
      dispText = dispText(2:length(dispText));
      text(imageData.segpos(b,2), imageData.segpos(b,1), dispText, ...
	   'Color', (showCluster(b) | imageData.segwhite(b))*[1 1 1], ...
	   'FontSize', handles.imgLabelFontSize, 'HorizontalAlignment', ...
	   'center', 'FontWeight', 'bold', 'ButtonDownFcn', imageCallback);
    end;
  end;
  
% --------------------------------------------------------------------
% Update the display for the vocabulary.
function updateDisplayVocab (handles)
  
  % Create the array of words.
  dispStr = {};
  for w = 1:handles.vocabulary.numWords,
    dispStr{w} = handles.vocabulary.words{w};
  end;
  
  set(handles.vocab, 'String', dispStr);

% --------------------------------------------------------------------
% Show the words contained within a segment.
function updateDisplayClusterText (handles, blob)
  
  dispText = '';
  for w = 1:handles.labels.correspCounts(handles.curImg,blob),
    dispText = [dispText ' ' ...
		handles.labels.blobWords{handles.curImg,blob,w}];
  end;
  set(handles.cluster_text, 'String', dispText);  
   
% --------------------------------------------------------------------
function handles = showImages (handles)
  
  % Load image data
  % ---------------
  % Load the image from the cache and display it.
  [imageData handles.imgCache] = ...
	loadImageFromCache(handles, handles.curImg);
  axes(handles.origimg);
  imshow(imageData.img);
  axes(handles.segimg);
  imshow(imageData.segimg);
  
  % Show the blobs corresponding to highlighted word
  % ------------------------------------------------
  updateDisplayClusters(handles, imageData);

% --------------------------------------------------------------------
% INPUT FUNCTIONS
% --------------------------------------------------------------------
function strs = parseUserInput (str)
  
  % Parse the input string into separate words.
  strs = parse_string(str);

  % Remove all the non-letters from the strings and change to lower
  % case. 
  for s = 1:length(strs),
    strs{s} = lower(remove_nonletters(strs{s}));
  end;
  
% --------------------------------------------------------------------
% IMAGE FUNCTIONS
% --------------------------------------------------------------------
% Load the image from the cache. If it's not in the cache, load it from
% disk. 
function [imageData, imgCache] = loadImageFromCache (handles, imgNum)
  
  imgCache = handles.imgCache;
  
  % Load image from cache
  % ---------------------
  % First check to see if the image is already in the cache. If so, let's
  % just return the images from the cache.
  imageData = get_cache_elem(handles.imgCache, imgNum);
  if length(imageData),
    return;
  end;
  
  % Load image from disk
  % --------------------
  % If we've come this far, it's because we haven't found this image
  % index in the cache so we need to load it. First, load the information
  % from disk.
  imgName  = handles.imgIndex.images{imgNum};
  pathNameImg = [handles.imgDir '/' imgName handles.imgIndex.imgSuffix];
  pathNameMat = [handles.segDir '/' imgName '.mat'];
  pathNameMatEdges = [handles.segDir '/' imgName ...
		      handles.segmentsWEdgesSuffix '.mat'];
  [img seg] = load_segment_info(pathNameImg, pathNameMat);
  segments  = find_segments(seg);
  segimg    = loadImageFromDisk(handles, imgNum, handles.segimgDir, ...
				size(img));
  blobimg   = double(loadImageFromDisk(handles, imgNum, ...
				       handles.blobimgDir, size(img)));
  segmentsWEdges = find_segments(get_image_segments(pathNameMatEdges));
  
  % Resize the images to fit the axes
  % ---------------------------------
  % Modify the image controls.
  set(handles.origimg, 'Units', 'points');
  pos = get(handles.origimg, 'Position');
  set(handles.origimg, 'Units', 'characters'); 
  
  w = round(pos(3));
  h = round(pos(4));
  imageData.img     = uint8(resizeImgForAxes(img, w, h, 'bilinear'));
  imageData.segimg  = uint8(resizeImgForAxes(segimg, w, h, 'bilinear'));
  imageData.blobimg = resizeImgForAxes(blobimg, w, h, 'bilinear');
  
  % Resize the non-display segments. Now each pixel in the segmented
  % image corresponds to a corresponding blob index, and 0 for no blob.
  imageData.seg = resizeImgForAxes(seg, w, h, 'nearest', 0);
  
  % Resize the display segments.
  imageData.noseg = zeros(h, w);
  [ans ans S] = size(segmentsWEdges);
  for s = 1:S,
    imageData.segwedges(:,:,s) = ...
	resizeImgForAxes(segmentsWEdges(:,:,s), w, h, 'nearest', 0);
    imageData.noseg = imageData.noseg + (imageData.segwedges(:,:,s) == 0);
  end;
  
  % This is the "remains" of the image -- the regions of the displayed
  % image that do not correspond to any segment.
  imageData.noseg = (imageData.noseg >= S);
  
  % Get other information about the image
  % -------------------------------------
  % Get the average (x,y) and RGB colour for each segment, and whether it
  % is closer to white or black.
  imageData.segpos   = zeros(S,2);
  imageData.segwhite = zeros(S,1);
  [h w C]            = size(imageData.img);
  img                = reshape(imageData.img,1,h*w,C);
  
  for s = 1:S,
    
    % If there are no pixels in this segment, just put in some default
    % parameters for it, although it won't really matter.
    if ~sum(sum(imageData.segwedges(:,:,s))),
      imageData.segpos(s,:) = [0 0];
      imageData.segwhite(s) = 0;
    else,
      [y x] = find(imageData.segwedges(:,:,s));
      imageData.segpos(s,:) = [mean(y) mean(x)];
    
      grey=mean(mean(img(:,find(reshape(imageData.segwedges(:,:,s),1,h*w)),:)));
      imageData.segwhite(s) = grey < 150;
    end;
  end;
  clear img grey
  
  % Put the information into the cache.
  imgCache = add_cache_elem(imgCache, imageData, imgNum);

% --------------------------------------------------------------------
% Load image from disk and resize it with IMGSIZE = [H W] dimensions.
function img = loadImageFromDisk (handles, imgNum, imgDir, imgSize)
  
  filename = [imgDir '/' handles.imgIndex.images{imgNum} ...
	      handles.imgIndex.imgSuffix];

  try
    img = imread(filename);
    img = crop_image(img, imgSize);
    
  catch
    img = [];
    fprintf('Unable to load image %s. \n', filename);
  end;
    
% --------------------------------------------------------------------
% Resize the image IMG using the dimensions W and H. METHOD is the method
% used by the function IMRESIZE. BGCLR is the colour used to fill in the
% spaces where there is no image data.
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
    img = imresize(img, [h wn], method);
    
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

  