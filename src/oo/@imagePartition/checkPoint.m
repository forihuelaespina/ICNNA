function roiId=checkPoint(obj,pCoords)
% IMAGEPARTITION/CHECKPOINT Check to which ROI belong the point(s)
%
% roiId=checkPoint(obj,pCoords) Check to which ROI belong the point(s)
%       and return the ID of the ROI to which the points belong to.
%
%Parameter pCoords is a Nx2 matrix of N points with coordinates <X,Y>.
%
% Points within the image or screen boundaries (size) but which do not
%belong to any of the existing ROIs will be consigned to the BACKGROUND
%region. Points outside or beyond the image or screen boundaries
%will be consigned to OUTOFBOUNDS region.
%
% Copyright 2008
% @date: 23-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also imagePartition, roi, addROI, getROIList
%

%Some preliminaries
width=get(obj,'Width');
height=get(obj,'Height');
nPoints=size(pCoords,1);

%Allocate memory, and by default consign all points to the background.
roiId=obj.BACKGROUND*ones(nPoints,1);

%Check points out of bounds
idx=find(pCoords(:,1)<0 | pCoords(:,1)>width);
roiId(idx)=obj.OUTOFBOUNDS;
idx=find(pCoords(:,2)<0 | pCoords(:,2)>height);
roiId(idx)=obj.OUTOFBOUNDS;

%And now check the ROIs
roiList=getROIList(obj);
for rrId=roiList
    rr=getROI(obj,rrId);
    [b,subrIdx]=checkPoint(rr,pCoords);
    roiId(find(b))=rrId;
end