function b=getExclusory(obj,tagA,tagB)
%TIMELINE/GETEXCLUSORY Checks the exclusory behaviour among conditions
%
% b=getExclusory(obj) Gets the complete matrix of exclusory behaviour.
%
% b=getExclusory(obj,tagA,tagB) Checks the exclusory behaviour
%    among the two conditions.
%
% @li If one or both tags correspond to a non defined
%condition an empty matrix is returned.
%
%
%
% Copyright 2008-23
% @date: 29-May-2008
% @author Felipe Orihuela-Espina
%
% See also switchExclusory, setExclusory, setAllExclusory
%


%% Log
%
% File created: 29-May-2008
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old label @date.
%


if (nargin==1)
    b=obj.exclusory;
    return
end

b=[];

idxA=findCondition(obj,tagA);
if (isempty(idxA))
    return;
end
idxB=findCondition(obj,tagB);
if (isempty(idxB))
    return;
end
b=obj.exclusory(idxA,idxB);


end