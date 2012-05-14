function n = compute_frequency_histogram(features, vocabulary)

[numcases,numdims] = size(features);
[numwords,wordlength] = size(vocabulary);

assert(numdims==wordlength);

%for each case in features
%find closest word in vocabulary (Euclidean distance)

%first - compute distance matrix
d = distmat1(features,vocabulary);

[y,ind]=min(d,[],2);

n = hist(ind,1:numwords);

n = n/norm(n);


