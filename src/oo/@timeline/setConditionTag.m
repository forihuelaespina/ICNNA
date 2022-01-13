function obj=setConditionTag(obj,tag,newTag)
%TIMELINE/SETCONDITIONTAG Set a new tag for a condition
%
% obj=setConditionTag(obj,tag,newTag) Updates the tag for a condition.
%   If the condition referred by tag has not been defined, a warning
%   is issued and nothing is done.
%
%
% Copyright 2008-13
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 31-Oct-2013
%
% See also getCondition, addCondition, removeCondition, getConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%

%% Log
%
% 31-Oct-2013 (FOE): Ammended bug in function documentation. Previously,
%   the function call in the documentation read
%               obj=getCondition(obj,tag,newTag)
%

idx=findCondition(obj,tag);
if (isempty(idx))
    warning('ICNA:timeline:setConditionTag',...
        ['Condition ' tag ' not defined. Ignoring update attempt']);
else
    obj.conditions{idx}.tag=newTag;
end
assertInvariants(obj)