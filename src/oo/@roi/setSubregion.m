function obj=setSubregion(obj,n,coord)
% ROI/SETSUBREGION Replace the n-th subregion polygon vertex coordinates
%
% obj=setSubregion(obj,n,newCoordinates) Replace the n-th subregion
%   polygon vertex coordinates.
%   If the n-th subregion has not been defined, then nothing is done.
%
% Copyright 2008-9
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also addSubregion, removeSubregion
%

if ((size(coord,2)~=2) || (any(any(coord)<0)) || ndims(coord)>2)
    error('ICAF:ROI:setSubregion:InvalidInput',...
          'Invalid vertex coordinates.');
end
if (size(coord,1)<=2)
    error('ICAF:ROI:setSubregion:InvalidInput',...
          'A subregion is bounded by 3 or more points.');
end


if (isscalar(n) && ~ischar(n) && floor(n)==n ...
    && (n>0) && (n<=getNSubregions(obj)))
    obj.subregions(n)={coord};
end
