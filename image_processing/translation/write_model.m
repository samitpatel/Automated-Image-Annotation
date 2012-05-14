% WRITE_MODEL    Writes the trained model parameters to disk.
%    WRITE_MODEL(DATADIR,MODELPARAMS,MODEL) writes the trained model
%    MODEL (obtained from function TRAIN_MODEL) to the directory
%    DATADIR. MODELPARAMS is the result of function
%    /GENERAL/DATA/LOAD_MODEL_PARAMS.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function write_model (datadir, modelparams, model)
  
  % First write out the general information.
  % ---------------------------------------
  % Write out the blob information.
  write_matrix(datadir, 'blobs', [model.blobs.mean'; model.blobs.std']);
  
  % Write out model-specific information.
  % ------------------------------------
  feval(modelparams.func.write, datadir, model);