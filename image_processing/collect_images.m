function collect_images (imglist, srcdir, destdir, srcsuffix, destsuffix)
  
  numImages = length(imglist);
  for i = 1:numImages,
    img = imglist(i);
    f1  = sprintf('%s/%i/%i%s', srcdir, 100*floor(img / 100), ...
		  img, srcsuffix); 
    f2  = sprintf('%s/%i%s', destdir, img, destsuffix);
    [status result] = system(sprintf('cp -f %s %s', f1, f2));
  end;