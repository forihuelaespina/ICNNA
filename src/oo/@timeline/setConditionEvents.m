function obj=setConditionEvents(obj,tag,events,eventsInfo)
%TIMELINE/SETCONDITIONEVENTS Set the events for the condition referred by tag
%
% obj=setConditionEvents(obj,tag,events) Sets the events for
%   the experimental condition referred by tag. If the condition
%   has not been defined, a warning is issued and nothing is done.
%   Note that this will remove previously defined events.
%
% obj=setConditionEvents(obj,tag,events,eventsInfo) Sets the events for
%   the experimental condition referred by tag. If the condition
%   has not been defined, a warning is issued and nothing is done.
%   Note that this will remove previously defined events.
%   The events info is a cell array of information associated to the
%   events.
%
%
%
%
% Copyright 2008-23
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, removeCondition, setConditionTag,
% getConditionEvents, addConditionEvents, removeConditionEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 31-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%


if ~exist('eventsInfo','var')
    eventsInfo = cell(size(events,1),1);
end
eventsInfo=reshape(eventsInfo,numel(eventsInfo),1);
assert(iscell(eventsInfo),...
        ['ICNA:timeline:setConditionEvents:InvalidParameterValue ',...
         'Events information must be nx1 cell array.']);
assert(size(events,1)==length(eventsInfo),...
        ['ICNA:timeline:setConditionEvents:InvalidParameterValue ',...
         'Number of information records mismatches number of events.']);
     


idx=findCondition(obj,tag);
if (isempty(idx))
    warning('ICNA:timeline:setConditionEvents:InvalidCondition',...
            ['Condition ' tag ' not defined. Ignoring update attempt']);
else
    if isempty(events)
        obj.conditions{idx}.events=zeros(0,2);
        obj.conditions{idx}.eventsInfo=cell(0,1);
    elseif ((ndims(events)==2) && (size(events,2)==2))
        [obj.conditions{idx}.events,index]=sortrows(events);
        obj.conditions{idx}.eventsInfo=eventsInfo(index);
    else
        error('ICNA:timeline:setConditionEvents:InvalidEvents',...
            'Events must a 2 column (onset duration) matrix.');
    end
end
assertInvariants(obj);

end