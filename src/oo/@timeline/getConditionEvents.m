function [events,eventsInfo]=getConditionEvents(obj,tag)
%TIMELINE/GETCONDITIONEVENTS Get the events for the condition referred by tag
%
% [events,eventsInfo]=getConditionEvents(obj,tag) Gets the events for
%   the experimental
%   condition referred by tag or an empty matrix if the condition has
%   not been defined. Note that if condition exist there is still the
%   possibility that no events have been declared for that condition.
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, removeCondition, setConditionTag,
%   setConditionEvents, addConditionEvents, removeConditionEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 28-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%

idx=findCondition(obj,tag);
events=zeros(0,2);
eventsInfo=cell(0,1);
if (~isempty(idx))
    events=obj.conditions{idx}.events;
    eventsInfo=obj.conditions{idx}.eventsInfo;
end



end