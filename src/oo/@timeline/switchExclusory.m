function obj=switchExclusory(obj,tagA,tagB)
%TIMELINE/SWITCHEXCLUSORY Switch exclusory behaviour among conditions
%
% obj=switchExclusory(obj,tagA,tagB) Switch the exclusory behaviour
%    among two conditions.
%
% @li Both conditions must exist. If one or both tags correspond
%to a non defined condition nothing is done.
% @li Conditions must be different
%
%
%
% Copyright 2008
% @date: 29-May-2008
% @author Felipe Orihuela-Espina
%
% See also setExclusory, setAllExclusory
%

if (strcmp(tagA,tagB))
    return;
end

idxA=findCondition(obj,tagA);
if (isempty(idxA))
    return;
end
idxB=findCondition(obj,tagB);
if (isempty(idxB))
    return;
end
if (idxA==idxB)
    error('Duplicated Tag?');
end

obj.exclusory(idxA,idxB)=1-obj.exclusory(idxA,idxB);
obj.exclusory(idxB,idxA)=1-obj.exclusory(idxB,idxA);
assertInvariants(obj);