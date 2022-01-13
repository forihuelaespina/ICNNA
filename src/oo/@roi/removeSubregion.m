function obj=removeSubregion(obj,n)
% ROI/REMOVESUBREGION Removes the current n-th subregion from the ROI
%
% obj=removeSubregion(obj,n) Removes the n-th subregion from the ROI
%   If the n-th subregion has not been defined, then nothing is done.
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also addSubregion, setSubregion, getNSubregions, getNVertexes
%

if (isscalar(n) && ~ischar(n) && floor(n)==n ...
    && (n>0) & (n<=getNSubregions(obj)))
    obj.subregions(n)=[];
end
