function obj=addCondition(obj,tag,events,varargin)
%TIMELINE/ADDCONDITION Add a experimental condition to the timeline
%
% obj=addCondition(obj,tag,events) Add a experimental condition
%    to the timeline. By default the condition is exclusory with
%    every other existent condition.
%
% obj=addCondition(...,dataLabels) Add a experimental
%    condition to the timeline.
%   The dataLabels is a strings array of data labels alike .snirf
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
% Copyright 2008-24
% @author Felipe Orihuela-Espina
%
% See also getCondition, removeCondition, setConditionTag, 
% getConditionEvents, setConditionEvents, addConditionEvents,
% removeConditionEvents
%


%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 1-Jan-2013
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%
% 8-May-2024: FOE
%   + Updated the error messages from "ICNA" to "ICNNA"
%   + Added support for dataLabels and event amplitudes
%




while ~isempty(varargin)
    element = varargin{1};
    varargin(1)=[];
    if iscell(element)
        %This should be the eventsInfo
        eventsInfo = element;
    elseif isstring(element)
        %This should be the dataLabels. This is an optional field.
        dataLabels = element;
    elseif isscalar(element)
        %This should be the exclusoryState
        exclusoryState = element;
    else
        error('ICNNA:timeline:addCondition:InvalidParameterValue',...
            'Unexpected parameter value.');
    end
end

if ~exist('eventsInfo','var')
    eventsInfo = cell(size(events,1),1);
end
eventsInfo=reshape(eventsInfo,numel(eventsInfo),1);
assert(iscell(eventsInfo),...
        ['ICNNA:timeline:addCondition:InvalidParameterValue ',...
         'Events information must be nx1 cell array.']);
assert(size(events,1)==length(eventsInfo),...
        ['ICNNA:timeline:addCondition:InvalidParameterValue ',...
         'Number of information records mismatches number of events.']);


if (ischar(tag))
    cond.tag = tag;
else
    error('ICNNA:timeline:addCondition:InvalidParameter',...
        'Tag must be a string');
end



if isempty(events)
    cond.events=zeros(0,2);
    cond.eventsInfo=cell(0,1);
elseif ((ndims(events)==2) && (size(events,2)==2 || size(events,2)==3))
    [cond.events,index] = sortrows(events);
    cond.eventsInfo=eventsInfo(index);
else
    error('ICNNA:timeline:addCondition:InvalidParameter',...
        ['Events must be a 2 column <onset duration> matrix ' ...
         'or a 3 column <onset duration amplitude> matrix.']);
end


if exist('dataLabels','var')
    cond.dataLabels = dataLabels;
end


if (~exist('exclusoryState','var'))
   exclusoryState=1; %By default, exclusory behaviour
end

idx=findCondition(obj,tag);
if (isempty(idx))
    obj.conditions(end+1)={cond};
else
    error('ICNNA:timeline:addCondition:RepeatedTag',...
          ['Condition ' tag ' already defined.']);
end

obj.exclusory(end+1,:)=exclusoryState*ones(1,length(obj.conditions)-1);
obj.exclusory(:,end+1)=exclusoryState*ones(1,length(obj.conditions));
obj.exclusory(end,end)=0;

assertInvariants(obj);


end
