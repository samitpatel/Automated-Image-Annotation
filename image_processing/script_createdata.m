% Sample script for creating a data set from a single set of images.
datadir     = '/cs/beta/People/Nando/corel/imagetrans/data/images/new/robomedia';
resultdir   = '/cs/beta/People/Nando/corel/imagetrans/data/sets/new/robomedia';
datalabels  = {'training' 'test'};
proportions = [5 2];
seed        = 2067;

cd createdatasets
create_datasets({datadir}, resultdir, datalabels, proportions, 0, seed);