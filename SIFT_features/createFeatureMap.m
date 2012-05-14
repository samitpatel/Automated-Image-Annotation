%Create feature map from histogram of clusters for sift features of a
%region
featureSet = [];
labelSet = [];
reverseMap = [];
regionLabels = textread('../data/imageRegionLabel.txt','','delimiter',' ');

for imgid=1:numel(descriptor)    
   if(~isempty(segmentedImg{imgid}))
       fprintf('.');
       uniq_seg_nos = unique(segmentedImg{imgid});        
%        if(uniq_seg_nos(1)==0)
%             numOfSegments = max(uniq_seg_nos)-1;
%        else
            numOfSegments = max(uniq_seg_nos);
%        end
       
       regionDescSet = cell(1,numOfSegments);

       for j=1:size(descriptor{imgid},1)
          x = floor(desc_pos{imgid}(j,1));
          y = floor(desc_pos{imgid}(j,2));
                    %if segment is labelled
          if(~isempty(segmentedImg{imgid}) && segmentedImg{imgid}(y,x) ~=0)
              regionDescSet{segmentedImg{imgid}(y,x)} = ...
                  [regionDescSet{segmentedImg{imgid}(y,x)}; descriptor{imgid}(j,:)];
          end
  
       end

       for j=1:numOfSegments
           if(~isempty(regionDescSet{j}))
              row = find(regionLabels(:,1)==imgid);
              label_map = regionLabels(row,2:3);
              row = find(label_map(:,1)==j);
              if(~isempty(row))
                 labelSet = [labelSet; label_map(row(1),2)];
                 reverseMap = [reverseMap; imgid j];
                 histFeature = compute_frequency_histogram(double(regionDescSet{j}),centres);
                 featureSet = [featureSet; histFeature];          
              end
           end
       end       
   end
end

save('../data/featureSet_LabelSet.mat', 'featureSet','labelSet','reverseMap');
