datadir = '/cs/beta/People/Nando/corel/imagetrans/data/sets/new/robomedia';
models  = {'dML1', 'gML1', 'gMAP1', 'gMAP1MRF'};
test    = 'pos';
pr      = 1;
boxplot = 0;
options = {[] boxplot}; 

cd resultsbrowser
compare_models(datadir, models, test, options);
