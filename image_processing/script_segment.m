% Sample script for segmenting images using NCuts.
features  = [1 3:6 10:12];
datadir   = '/cs/beta/People/Nando/corel/imagetrans/data/images/new/robomedia';
ncuts     = '/cs/beta/People/Nando/corel/ncuts/ncuts';
options   = {'ncuts', [], [], ncuts, 1, features};

cd segmentimg
create_segment_data(datadir, options);

cd ../createlabels
createlabels(datadir);
