function s=getROI(obj,id)
%IMAGEPARTITION/GETROI Get the ROI identified by id
%
% s=getROI(obj,id) gets the ROI identified by id or an empty
%   matrix if the ROI has not been defined.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also findROI, getROIList
%

i=findROI(obj,id);
if (~isempty(i))
    s=obj.rois{i};
else
    s=[];
end
