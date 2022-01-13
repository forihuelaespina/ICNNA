function n=getNSubregions(obj)
%ROI/GETNSUBREGIONS Gets the number of subregions defined in the ROI
%
% n=getNSubregions(obj) Gets the number of subregions defined in the ROI
%
%
% Copyright 2008
% @date: 22-Dec-2008
% @author Felipe Orihuela-Espina
%
% See also roi, getSubregion
%

n=length(obj.subregions);
