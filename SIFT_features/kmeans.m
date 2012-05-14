function [centres] = kmeans(featureMap)

%TODO Download it
addpath('../../packages/netlab3.3');

%2 Class classifier: 1 vs All

subset_size=100000; %Wang et al. select a subset of 100,000 features to cluster
k = 1000; %number of clusters

class = 1;

[num_features,numdims] = size(featureMap);

%take a random subset of subset_size features
if subset_size > num_features
    subset_size = num_features;
end
p = randperm(num_features);
trainingSet = double(featureMap(p(1:subset_size),:));
%clear all_features;

%netlab uses the options vector (see foptions)
options = zeros(1,18);
%options(1) = 1;% This provides display of error values.
options(14) = 20;% Number of training cycles.

fprintf('running KMeans\n');
%since  features_subset is in random order
%we initialize centres with the first k points (i.e. random features)
[centres,options,post,errlog] = kmeansNetlab(trainingSet(1:k,:),trainingSet,options);
fprintf('KMeans Finished\n');

save('../data/kmeans.mat', 'centres', 'featureMap');
end
