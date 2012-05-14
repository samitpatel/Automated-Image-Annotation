datadir = '../data/saiaprtc12ok.part1/benchmark/saiapr_tc-12/';
subdir = dir(datadir);

for i=1:numel(subdir)
   if(~strcmp(subdir(i).name,'.') && ~strcmp(subdir(i).name,'..') && isdir([datadir subdir(i).name]))
      currSubDir = [datadir subdir(i).name '/segmentation_masks/'];      
      dirToSave =  [datadir subdir(i).name '/segmentation_masks_txt/'];
      if(~exist(dirToSave))
         mkdir (dirToSave);
      end
      matfiles = dir(currSubDir);
      for j=1:numel(matfiles)
          file = [currSubDir matfiles(j).name];
        if(~isdir(file))
            load (file);
            [path filename ext] = fileparts(file);
            fid = fopen([dirToSave filename '.txt'],'w');
            fprintf(fid, repmat([repmat('%d ',[1 size(segimg_t,2)]) '\n' ],[1 size(segimg_t,1)]),segimg_t);            
        end
      end
   end
end
