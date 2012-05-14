datadir = '../data/';

disp('computing dense sift features...');
%getDenseSiftFeatures(datadir);
load ../data/dsiftdesc.mat;

disp('computing Segment Masks...');
%createImageSegmentMap(datadir);
load ../data/segmentedImage.mat;

count=0;
featureDim = 128;
for i=1:numel(descriptor)
    if(~isempty(descriptor{i}))
      count = count + size(descriptor{i},1);
    end
end

allFeatures = zeros(count,128);

disp('combining features');

count = 1;
for imgid=1:numel(descriptor)
    if(~isempty(descriptor{imgid}))
       for j=1:size(descriptor{imgid},1)
          x = floor(desc_pos{imgid}(j,1));
          y = floor(desc_pos{imgid}(j,2));
          
          %if segment is labelled
          if(~isempty(segmentedImg{imgid}) && segmentedImg{imgid}(y,x) ~=0)               
	    allFeatures(count,:) = descriptor{imgid}(j,:);            
            count = count + 1;
          end
       end
    end
end

trainingPercent = 1;
max_training_size = 100000;

p = randperm(floor(trainingPercent*size(allFeatures,1)));

if numel(p) < max_training_size 
    max_training_size = numel(p);
end

trainingSet = allFeatures(p(1:max_training_size),:);

%TODO create test set
%testSet = allFeatures(q,:);

%disp('Running KMeans...');

kmeans(trainingSet);
load ../data/kmeans.mat;

disp('Generating feature and label set');
createFeatureMap;
