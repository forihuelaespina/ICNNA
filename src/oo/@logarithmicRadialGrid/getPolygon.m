function cartesianPol=getPolygon(obj,varargin)
%LOGARITHMICRADIALGRID/GETPOLYGON Get the cartesian polygon of a cell
%
%
% cartesianPol=getPolygon(obj,posAngular,posRadial) Gets the
%   cartesian polygon of a cell of the grid (ready to be used
%   in the inpolygon function)
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, getNCells, getCellCenter, inWhichCells,
% ind2gridCell, gridCell2ind
%

%Using varargin so it is compatible with superclass abstract definition
posAngular=varargin{1};
posRadial=varargin{2};

r=obj.r;
th=obj.th;

if ((posAngular==0) || (posRadial==0)) %central cell
    nVertex=size(th,2);
    polarPol=zeros(nVertex,2);
    for vv=1:nVertex
        polarPol(vv,:)=[r(1,1) th(1,vv)];
    end    
else
   polarPol=[r(posRadial,1) th(1,posAngular); ...
     r(posRadial+1,1) th(1,posAngular); ...
     r(posRadial+1,1) th(1,posAngular+1); ...
     r(posRadial,1) th(1,posAngular+1); ...
     r(posRadial,1) th(1,posAngular)];
end
[cartesianPol(:,1),cartesianPol(:,2)] = pol2cart(polarPol(:,2),polarPol(:,1));
