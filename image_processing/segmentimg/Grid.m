function [ output_args ] = Test2( input_args )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

datadir  = '/Users/samitpatel/Downloads/ML/imagetrans/segmentimg/images';
ncuts    = '/bin/ncuts';
features = [1 3:6];
patchsz  = 24;
crop =6;
options = {'grid', patchsz, crop, [ ], ...
            [ ], features};
create_segment_data(datadir, options);

end

