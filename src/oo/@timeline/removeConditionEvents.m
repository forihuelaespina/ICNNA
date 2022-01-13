function obj=removeConditionEvents(obj,tag)
%TIMELINE/REMOVECONDITIONEVENTS Removes all events defined for the condition
%
% obj=removeConditionEvents(obj,tag) Removes ALL the events defined for
%   the experimental condition referred by tag. If the condition
%   has not been defined, a warning is issued and nothing is done.
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @date: 28-Dec-2012
%
% See also getCondition, addCondition, removeCondition, setConditionTag,
% getConditionEvents, setConditionEvents, addConditionEvents
%

idx=findCondition(obj,tag);
if (isempty(idx))
    warning('ICNA:timeline:removeConditionEvents',...
      ['Condition ' tag ' not defined. Ignoring event addition attempt']);
else
    obj.conditions{idx}.events=zeros(0,2);
    obj.conditions{idx}.eventsInfo=cell(0,1);
end
assertInvariants(obj);