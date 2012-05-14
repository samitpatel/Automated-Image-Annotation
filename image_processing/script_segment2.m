% Sample script for segmenting images using a grid segmentation.
features  = [1 3:6 10:12];
datadir   = '/cs/beta/People/Nando/corel/imagetrans/data/images/new/robomedia-p24';
patchsize = 24;
crop      = 6;
options   = {'grid', patchsize, crop, [], [], features};

cd segmentimg
create_segment_data(datadir, options);

cd ../createlabels
createlabels(datadir);
