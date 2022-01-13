function obj=addSubregion(obj,coord)
% ROI/ADDSUBREGION Append a new subregion to the ROI
%
% obj=addSubregion(obj,coord) Append a new subregion to the ROI with
%   coordinates coord=[X Y]. Each row is a vertex of the polygon.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also removeSubregion, setSubregion
%

if ((ndims(coord)~=2) | (size(coord,2)~=2) | (any(coord)<0))
    error('ICNA:ROI:addSubregion:InvalidInput',...
          'Invalid vertex coordinates.');
end
if (size(coord,1)<=2)
    error('ICNA:ROI:addSubregion:InvalidInput',...
          'A subregion is bounded by 3 or more points.');
end
obj.subregions(end+1)={coord};
