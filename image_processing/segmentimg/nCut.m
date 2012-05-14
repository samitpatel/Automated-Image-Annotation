function [ output_args ] = Test( input_args )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

datadir  = '/Users/samitpatel/Downloads/ML/imagetrans/segmentimg/images';
ncuts    = '/Users/samitpatel/Downloads/ML/imagetrans/NcutImage/specific_NcutImage_files/NcutImage';
%ncuts = '/bin/ncuts';
features = [ ]; %[1 3:6];
options  = {'ncuts', [ ], [ ], ncuts, ...
            [ ], features};
create_segment_data(datadir, options);

end

