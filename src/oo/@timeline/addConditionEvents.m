function obj=addConditionEvents(obj,tag,events,eventsInfo)
%TIMELINE/ADDCONDITIONEVENTS Adds the events for the condition referred by tag
%
% obj=addConditionEvents(obj,tag,events) Adds the events for
%   the experimental condition referred by tag to the existing
%   events if any. If the condition
%   has not been defined, a warning is issued and nothing is done.
%
% obj=addConditionEvents(obj,tag,events,eventsInfo) Adds the events for
%   the experimental condition referred by tag to the existing
%   events if any. If the condition
%   has not been defined, a warning is issued and nothing is done.
%   The events info is a cell array of information associated to the
%   events.
%
% Copyright 2008-12
% @author Felipe Orihuela-Espina
%
% See also getCondition, addCondition, setConditionTag, removeCondition,
% getConditionEvents, setConditionEvents, removeConditionEvents
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
        ['ICNA:timeline:addConditionEvents:InvalidParameterValue ',...
         'Events information must be nx1 cell array.']);
assert(size(events,1)==length(eventsInfo),...
        ['ICNA:timeline:addConditionEvents:InvalidParameterValue ',...
         'Number of information records mismatches number of events.']);
     


idx=findCondition(obj,tag);
if (isempty(idx))
    warning('ICNA:timeline:addConditionEvents:UndefinedCondition',...
        ['Condition ' tag ...
         ' not defined. Ignoring event addition attempt']);
else
    if isempty(events)
        events=zeros(0,2);
        eventsInfo=cell(0,1);
    end

    [obj.conditions{idx}.events,index]=...
        sortrows([obj.conditions{idx}.events; events]);
    obj.conditions{idx}.eventsInfo = ...
        [obj.conditions{idx}.eventsInfo; eventsInfo];
    %...and sort
    obj.conditions{idx}.eventsInfo = obj.conditions{idx}.eventsInfo(index);
end
assertInvariants(obj);