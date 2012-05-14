srcdir     = '/cs/beta/People/Nando/corel/data-corel/images/corel_images_4';
destdir    = '/cs/beta/People/Nando/corel/imagetrans/data/images/corelB/clrimages';
srcsuffix  = '.jpeg';
destsuffix = '.jpg';
imglist    = importdata('corelBlist.dat');

collect_images(imglist, srcdir, destdir, srcsuffix, destsuffix);