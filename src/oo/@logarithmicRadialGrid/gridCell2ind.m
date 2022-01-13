function ind=gridCell2ind(obj,varargin)
%LOGARITHMICRADIALGRID/GRIDCELL2IND Transform position to cell index
%
% ind=gridCell2ind(obj,posAngular,posRadial) Transform polar position to
%   cell index
%
% Copyright 2008
% date: 15-Aug-2008
% Author: Felipe Orihuela-Espina
%
% See also logarithmicRadialGrid, getNCells, getCellCenter, inWhichCells,
% ind2gridCell, getPolygon
%

%Using varargin so it is compatible with superclass abstract definition
posAngular=varargin{1};
posRadial=varargin{2};

assert(length(posAngular)==length(posRadial),...
        'ICNA:logarithmicRadialGrid:gridCell2ind:MismatchLength',...
        'Mismatch number of indexes.');


r=obj.r;
th=obj.th;
nRadials=size(r,1)-1;
nAngulars=size(th,2)-1;

ind=NaN*zeros(1,length(posAngular));
tmpZeros=find(posAngular==0 | posRadial==0);
tmpIdxAng=find(posAngular>=1 & posAngular<=nAngulars);
tmpIdxRad=find(posRadial>=1 & posRadial<=nRadials);
tmpIdx=intersect(tmpIdxAng,tmpIdxRad);

ind(tmpIdx)=sub2ind([nAngulars,nRadials],...
                    posAngular(tmpIdx),posRadial(tmpIdx));
ind=ind+1;
ind(tmpZeros)=1;

