function res=getStatus(obj,idx)
%INTEGRITYSTATUS/GETSTATUS Gets the integrity status
%
% res=getStatus(obj) Gets the integrity status of all elements
%
% res=getStatus(obj,idx) Gets the integrity status of the selected
%   idx-th elements.
%
%The function return a row vector with the numerical integrity codes.
%
%
%
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also isClean, isCheck, setStatus
%

if (~exist('idx','var'))
    idx=1:length(obj.elements);
end
res=obj.elements(idx);