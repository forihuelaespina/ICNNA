function s=getSubregion(obj,n)
%ROI/GETSUBREGION Get the n-th subregion
%
% s=getSubregion(obj,n) gets the vertex of the bounding polygon
%   of the n-th subregion or an empty
%   matrix if the subregion has not been defined.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also getNSubregions, getNVertexes
%

s=zeros(0,2);
if (isscalar(n) && ~ischar(n) && floor(n)==n ...
    && (n>0) && (n<=getNSubregions(obj)))
    s=obj.subregions{n};
end
