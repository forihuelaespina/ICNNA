function n=getNCells(obj)
%LOGARITHMICRADIALGRID/GETNCELLS Gets the number of cells in the grid
%
% n=getNCells(obj) Gets the number of cells in the grid
%
%
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, grid, getCellCenter, inPolygon,
%ind2gridCell, gridCell2ind, inWhichCells
%
%
nRadials=size(obj.r,1)-1;
nAngulars=size(obj.th,2)-1;
n=(nRadials*nAngulars)+1;
