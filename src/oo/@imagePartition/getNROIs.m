function n=getNROIs(obj)
%IMAGEPARTITION/GETNROIS Gets the number of ROIs defined in the imagePartition
%
% n=getNROIs(obj) Gets the number of ROIs defined in the imagePartition
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also findROI
%

n=length(obj.rois);
