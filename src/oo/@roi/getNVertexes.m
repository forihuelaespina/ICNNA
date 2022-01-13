function n=getNVertexes(obj,i)
%ROI/GETNVERTEXES Gets the number of vertexes defined in the i-th subregion
%
% n=getNVertexes(obj,i) Gets the number of vertexes defined in the 
%   i-th subregion of the ROI, or 0 if there is no i-th subregion
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also roi, getNSubregions, getVertexList
%

n=0;
if (i>0 && i<length(obj.subregions) && ...
    floor(i)==i && isscalar(i) && ~ischar(i))
    n=size(obj.subregions{i},1);
end