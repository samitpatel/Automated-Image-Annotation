% LOAD_TAU    Load the model parameter Tau from disk.
%    LOAD_TAU(D,F) returns Tau located on disk in file F in directory D. 
%
%    Copyright (c) 2003 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.

function tau = load_tau (d, f)

  tau = importdata([d '/' f]);