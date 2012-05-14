datadir   = '/cs/beta/People/Nando/corel/imagetrans/data/sets/new/robomedia';
modeldir  = '/cs/beta/People/Nando/corel/imagetrans/data/models/new';
model     = 'gMAP1MRF';
numtrials = 1:2;

cd translation
evaluate_model(datadir, modeldir, model, numtrials);
cd ..