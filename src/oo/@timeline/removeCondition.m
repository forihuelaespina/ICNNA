function obj=removeCondition(obj,tag)
%TIMELINE/REMOVECONDITION Removes the indicated condition if exists
%
% obj=removeCondition(obj,tag) Removes the condition from the
%   timeline. If the condition has not been defined, nothing is done.
%
% Copyright 2008
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, setConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%

idx=findCondition(obj,tag);
if (~isempty(idx))
    obj.conditions(idx)=[];
    obj.exclusory(idx,:)=[];
    obj.exclusory(:,idx)=[];
end
assertInvariants(obj)