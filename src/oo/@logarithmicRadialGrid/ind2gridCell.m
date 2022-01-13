function [varargout]=ind2gridCell(obj,ind)
%LOGARITHMICRADIALGRID/IND2GRIDCELL Transform cell index to position
%
% [posAngular,posRadial]=ind2gridCell(obj,ind) Transform cell
%   index to polar position
%
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, getNCells, getCellCenter, inWhichCells,
% ind2gridCell, getPolygon
%

ind(find(ind<=0))=NaN;
if (ind==1)
    posAngular=0;
    posRadial=0;    
else
    nRadials=size(obj.r,1)-1;
    nAngulars=size(obj.th,2)-1;
    [posAngular,posRadial]=ind2sub([nAngulars,nRadials],ind-1);
    posAngular(find(ind==1))=0;
    posRadial(find(ind==1))=0;
end

%Using varargout so it is compatible with superclass abstract definition
varargout(1)={posAngular};
varargout(2)={posRadial};
