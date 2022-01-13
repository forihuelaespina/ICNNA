function res=isCheck(obj,idx)
%INTEGRITYSTATUS/ISCHECK Indicates whether elements have been checked.
%
% res=isClean(obj) Indicates whether the integrity of each element
%   have been checked.
%
% res=isClean(obj,idx) Indicates whether the integrity of the
%   selected idx-th elements have been checked.
%
%The function return a row vector of 0s (not clean) and 1s (clean).
%An element is considered check is its code is not UNCHECK.
%
%
%
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also isClean, getStatus, setStatus
%

if (~exist('idx','var'))
    idx=1:length(obj.elements);
end
res=(obj.elements(idx)~=obj.UNCHECK);