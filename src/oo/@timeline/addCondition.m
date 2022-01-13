function obj=addCondition(obj,tag,events,varargin)
%TIMELINE/ADDCONDITION Add a experimental condition to the timeline
%
% obj=addCondition(obj,tag,events) Add a experimental condition
%    to the timeline. By default the condition is exclusory with
%    every other existent condition.
%
% obj=addCondition(...,eventsInfo) Add a experimental
%    condition to the timeline.
%   The events info is a cell array of information associated to the
%   events.
%
% obj=addCondition(...,exclusoryState) Add a experimental
%    condition to the timeline. If exclusoryState is equal to 1 then
%    the condition is exclusory with every other existent condition.
%    If exclusoryState is equal to 0 then the condition is
%    non exclusory with every other existent condition.
%
%
%
%% Remarks
%
%If the tag is not a string or the events is not a 2 column
%<onset,duration> -or an empty matrix, an
%error ICNA:timeline:addCondition:Invalid parameter is issued.
%
%If the condition already exists (tag has already been defined)
%an error ICNA:timeline:addCondition:RepeatedTag is issued.
%
%
% Copyright 2008-13
% @date: 18-Apr-2008
% @author Felipe Orihuela-Espina
% @modified: 1-Jan-2013
%
% See also getCondition, removeCondition, setConditionTag, 
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%

while ~isempty(varargin)
    element = varargin{1};
    varargin(1)=[];
    if iscell(element)
        %This should be the eventsInfo
        eventsInfo = element;
    elseif isscalar(element)
        %This should be the exclusoryState
        exclusoryState = element;
    else
        error('ICNA:timeline:addCondition:InvalidParameterValue',...
            'Unexpected parameter value.');
    end
end

if ~exist('eventsInfo','var')
    eventsInfo = cell(size(events,1),1);
end
eventsInfo=reshape(eventsInfo,numel(eventsInfo),1);
assert(iscell(eventsInfo),...
        ['ICNA:timeline:addCondition:InvalidParameterValue ',...
         'Events information must be nx1 cell array.']);
assert(size(events,1)==length(eventsInfo),...
        ['ICNA:timeline:addCondition:InvalidParameterValue ',...
         'Number of information records mismatches number of events.']);


if (ischar(tag))
    cond.tag = tag;
else
    error('ICNA:timeline:addCondition:InvalidParameter',...
        'Tag must be a string');
end



if isempty(events)
    cond.events=zeros(0,2);
    cond.eventsInfo=cell(0,1);
elseif ((ndims(events)==2) && (size(events,2)==2))
    [cond.events,index] = sortrows(events);
    cond.eventsInfo=eventsInfo(index);
else
    error('ICNA:timeline:addCondition:InvalidParameter',...
        'Events must be a 2 column <onset duration> matrix.');
end

if (~exist('exclusoryState','var'))
   exclusoryState=1; %By default, exclusory behaviour
end

idx=findCondition(obj,tag);
if (isempty(idx))
    obj.conditions(end+1)={cond};
else
    error('ICNA:timeline:addCondition:RepeatedTag',...
          ['Condition ' tag ' already defined.']);
end

obj.exclusory(end+1,:)=exclusoryState*ones(1,length(obj.conditions)-1);
obj.exclusory(:,end+1)=exclusoryState*ones(1,length(obj.conditions));
obj.exclusory(end,end)=0;

assertInvariants(obj);
