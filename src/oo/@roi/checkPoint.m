function [b,subrIdx]=checkPoint(obj,pCoords)
% ROI/CHECKPOINT Check whether a point is contained in the ROI.
%
% [b,subrIdx]=checkPoint(obj,pCoords) Check whether a point (or list of points)
%   are contained within any of the subregions of the ROI. pCoords
%   contains the list of points to be check, with one point per row.
%   b is a column vector of boolean values with one row per point in pCoords.
%   b contains a 0 for points not belonging to the ROI or 1 for points
%   contained within any of the ROI subregions.
%   For each point, the index to the subregion it belongs to is returned
%   in subrIdx, or a 0 if the point does not belong to any region
%
%Parameter pCoords is a Nx2 matrix of N points with coordinates <X,Y>.
%
%
% Copyright 2008
% @date: 23-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also roi, addSubregion, getSubregion, getNSubregions, getNVertexes
%

%Some preliminaries
nPoints=size(pCoords,1);

%Allocate memory, and by default consign all points to the background.
subrIdx=zeros(nPoints,1);

%Check the subregions
for ss=1:getNSubregions(obj)
    subregion_polygon=getSubregion(obj,ss);
    subregion_polygon=[subregion_polygon; subregion_polygon(1,:)];
        %Temporally close the polygon region
    tmp=inpolygon(pCoords(:,1),pCoords(:,2),...
                    subregion_polygon(:,1),subregion_polygon(:,2));
    idx=find(tmp);
    subrIdx(idx)=ss;
end

b=(subrIdx~=0);