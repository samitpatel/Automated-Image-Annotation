% SEGMENTOP    Run generic operation on a segment.
%    Y = SEGMENTOP(SEGMENT,OP,IMG,...) runs operation OP on the pixels of
%    IMG that are only included in the SEGMENT, a 0/1 matrix where 1
%    indicates that a pixel is part of the segment. Additional arguments
%    can be included after IMG if they are required for the operation.
%
%    Copyright (c) 2002 University of British Columbia. All Rights
%    Reserved. Created by Peter Carbonetto, Department of Computer
%    Science.  

function y = segmentop (segment, varargin)
  
  s       = size(segment,1) * size(segment,2);
  segment = find(reshape(segment,1,s));
  img     = reshape(varargin{2},1,s,3);
  
  for c = 1:3,
    varargin{2} = img(:,segment,c);
    y(:,c) = feval(varargin{:});
  end;

