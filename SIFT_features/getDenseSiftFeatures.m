function [] = getDenseSiftFeatures(datadir)
%Extracted dense sift features of all the images in a given dir
% frames is numOfImages * 2 * numOfSiftDescriptorsPerImage dimension array

% Initialize vl_feat library paths
run('~/research/packages/vlfeat-0.9.14/toolbox/vl_setup')

stepSize = 10;
binSize = 8;
magnif = 3;
desc_pos = {};
descriptor = {};

subdir = dir(datadir);
count=1;
for i=1:12%numel(subdir) 
    disp(subdir(i).name);
   if(~strcmp(subdir(i).name,'.') && ~strcmp(subdir(i).name,'..') && isdir([datadir subdir(i).name]))
      currSubDir = [datadir subdir(i).name '/images/'];      
      imgfiles = dir(currSubDir);
      for j=1:numel(imgfiles)
          file = [currSubDir imgfiles(j).name];          
%           disp(imgfiles(j).name);
        if(~isdir(file))
            [pathstr filename ext] = fileparts(file);
            %Extract sift features for an image[token, remain] = strtok('remain,'_')
            [pos, desc] = get_dsift(file, stepSize, binSize, magnif);
            if(~isempty(desc))
               desc_pos{str2num(filename)} = pos;
               descriptor{str2num(filename)} = desc;
               % and create map from imageid to feature map            
               count = count + 1;
            end
        end
      end
   end
end

save('../data/dsiftdesc.mat','desc_pos','descriptor');
end

function [desc_pos, desc] = get_dsift(imgpath, stepSize, binSize, magnif) 
    desc_pos = [];
    desc = [];
    img = imread(imgpath);    
    if(size(img,3)==3)
        img = rgb2gray(img);
    end
    if(size(img,1)==360 && size(img,2)==480)      
      img = single(img);
      %smoothen up the image (gaussian)
      img=vl_imsmooth(img, sqrt((binSize/magnif)^2 -.25));    
      %get d sift features
      [desc_pos, desc] =vl_dsift(img, 'step',stepSize);
      desc_pos = desc_pos';
      desc = desc';
    end
end
