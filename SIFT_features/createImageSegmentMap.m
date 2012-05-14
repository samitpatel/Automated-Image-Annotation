function [] = createImageSegmentMap( datadir )
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

subdir = dir(datadir);
segmentedImg = {};%cell(1,10000);
for i=1:12%numel(subdir)
    disp(subdir(i).name);
%      segmentedImg = {};
   if(~strcmp(subdir(i).name,'.') && ~strcmp(subdir(i).name,'..') && isdir([datadir subdir(i).name]))
      currSubDir = [datadir subdir(i).name '/segmentation_masks/'];      
      segmaskfiles = dir(currSubDir);
      for j=1:numel(segmaskfiles)
          file = [currSubDir segmaskfiles(j).name];          
%           disp(segmaskfiles(j).name);
        if(~isdir(file))
            [pathstr filename ext] = fileparts(file);
            [imgid, remain] = strtok(filename,'_');
            imgid=str2double(imgid);
            regionid = str2double(strtok(remain,'_'));

            load (file);            
            
            if(numel(segmentedImg) < imgid)
                segmentedImg{imgid} = zeros(size(segimg_t,1), size(segimg_t,2));                
            end
	    if(size(segimg_t,1)==360 && size(segimg_t,2)==480)
	      [row col] = find(segimg_t == 0);
              for k=1:numel(row)
	          segmentedImg{imgid}(row(k),col(k)) = regionid; 
              end
	    end
            clear segimg_t;
        end            
      end
%        save([datadir subdir(i).name '/segmentedImage.mat'],'segmentedImg');
%        clear segmentedImg;
    end
end
save('../data/segmentedImage.mat', 'segmentedImg','-v7.3');
end

