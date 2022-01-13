function res=isClean(obj,idx)
%INTEGRITYSTATUS/ISCLEAN Check whether certain elements are clean.
%
% res=isClean(obj) Check whether all elements are clean.
%
% res=isClean(obj,idx) Check whether the idx-th elements are clean.
%
%The function return a row vector of 0s (not clean) and 1s (clean).
%An element is considered clean is it is either UNCHECK or FINE.
%
%
%
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also isCheck, getStatus, setStatus
%

if (~exist('idx','var'))
    idx=1:length(obj.elements);
end
res=((obj.elements(idx)==obj.UNCHECK) | ...
       (obj.elements(idx)==obj.FINE));