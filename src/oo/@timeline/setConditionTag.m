function obj=setConditionTag(obj,tag,newTag)
%TIMELINE/SETCONDITIONTAG Set a new tag for a condition
%
% obj=setConditionTag(obj,tag,newTag) Updates the tag for a condition.
%   If the condition referred by tag has not been defined, a warning
%   is issued and nothing is done.
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, removeCondition, getConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%

%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 31-Oct-2013
%
% 31-Oct-2013 (FOE): Ammended bug in function documentation. Previously,
%   the function call in the documentation read
%               obj=getCondition(obj,tag,newTag)
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%

idx=findCondition(obj,tag);
if (isempty(idx))
    warning('ICNA:timeline:setConditionTag',...
        ['Condition ' tag ' not defined. Ignoring update attempt']);
else
    obj.conditions{idx}.tag=newTag;
end
assertInvariants(obj);
end