function obj=removeCondition(obj,tag)
%TIMELINE/REMOVECONDITION Removes the indicated condition if exists
%
% obj=removeCondition(obj,tag) Removes the condition from the
%   timeline. If the condition has not been defined, nothing is done.
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, setConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): N/A. This method
%   had not been modified since creation.
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date.
%


idx=findCondition(obj,tag);
if (~isempty(idx))
    obj.conditions(idx)=[];
    obj.exclusory(idx,:)=[];
    obj.exclusory(:,idx)=[];
end
assertInvariants(obj);

end