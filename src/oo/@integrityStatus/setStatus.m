function obj=setStatus(obj,idx,vals)
%INTEGRITYSTATUS/SETSTATUS Set the integrity status of the idx-th elements
%
% obj=setStatus(obj,idx,vals) Sets the integrity status of the selected
%   idx-th elements.
%
%The function updates the numerical integrity codes of the elements
%at the idx-th positions. Both, idx and vals are row vectors.
%The number of provided values must match
%the number of referenced elements, i.e. length(idx)==length(vals).
%The values are assigned to elements in the same order that they
%are provided.
%
% Copyright 2008
% date: 14-May-2008
% Author: Felipe Orihuela-Espina
%
% See also isClean, isCheck, setStatus
%

if (isreal(vals) && all(floor(vals)==vals))
    obj.elements(idx)=vals;
else
    error('Invalid integrity codes.');
end