function idxs=inWhichCells(obj,points)
%LOGARITHMICRADIALGRID/INWHICHCELLS Get which cells does each point belong to
%
% idxs=inWhichCells(obj,points) Get which cells does each point
%   belong to, or 0 if the point is outside the grid
%
%% Output
%
% idxs - List of cell index to which the list of points belong
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, getNCells, getCellCenter, gridCell2ind,
% ind2gridCell, getPolygon
%


nPoints=size(points,1);
nCells= getNCells(obj);
idxs=zeros(nPoints,1);
for ii=1:nCells
    [posAngular,posRadial]=ind2gridCell(obj,ii);
    
    cartesianPol=getPolygon(obj,posAngular,posRadial);
    IN = inpolygon(points(:,1),points(:,2), ...
                   cartesianPol(:,1),cartesianPol(:,2));
    idxs(find(IN))=ii;
end



