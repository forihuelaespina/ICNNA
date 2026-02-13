function obj=addCondition(obj,id,name,cevents,varargin)
%Add a experimental condition to the @icnna.data.core.timeline
%
% obj = addCondition(obj,id,name,events) Add a experimental condition
%    to the @icnna.data.core.timeline. By default the condition
%    is exclusory with every other existent condition.
%
% obj = addCondition(...,dataLabels) Add a experimental condition
%    to the @icnna.data.core.timeline.
%   The dataLabels is a strings array of data labels alike .snirf
%
% obj = addCondition(...,eventsInfo) Add a experimental condition 
%    to the @icnna.data.core.timeline.
%   The events info is a cell array of information associated to the
%   events.
%
% obj = addCondition(...,exclusoryState) Add a experimental condition
%    to the @icnna.data.core.timeline. If exclusoryState is equal to 1 then
%    the condition is exclusory with every other existent condition.
%    If exclusoryState is equal to 0 then the condition is
%    non exclusory with every other existent condition.
%
%
%% Error handling
%
% If the name is not a char[], a string, or empty, an
% error ICNA:timeline:addCondition:Invalid parameter is issued.
% 
% 
% If the events is not a 2 column <onset,duration>, a 3 column
% <onset,duration,amplitude> -or an empty matrix, an
% error ICNA:timeline:addCondition:Invalid parameter is issued.
%
% If eventsInfo is passed as argument, the number of elements in
% eventsInfo ought to match the number of rows of parameter events.
%
%If the condition already exists (either |id| or |name| has alreadyç
% been defined in the @icnna.data.core.timeline)
% an error ICNA:timeline:addCondition:RepeatedTag is issued.
%
% The exclusory behaviour should hold after adding the condition.
%
%% Remarks
%
% This method is a short-cut to add an @icnna.data.core.condition to the
% @icnna.data.core.timeline without having to explicitly create the
% @icnna.data.core.condition. If the condition is already an
% @icnna.data.core.condition, then use method addConditions instead.
% Further, this method can only be used to add one condition at a time.
%
% In contrast with timeline.addCondition, here the |id| has to be
% passed as an argument (even if empty -see input parameters below).
%
% The condition |unit|, |timeUnitMultiplier| and |nominalSamplingRate|
% are set to be the same of the timeline.
%
%
%% Input parameters
%
% id - int.
%   The numerical identifier of the new condition. If empty,
%   then, the first non-used id among the conditions in the timeline
%   will be used.
%
% name - char[] or string.
%   The name of the new condition. If empty,
%   then, it will be set to 'condXXXX' where XXXX is the left-zero-padded
%   identifier.
%   If string, then it will be typecasted to char[].
%
% events - double[kx2 | kx3] <onsets, durations, [amplitudes]>
%   The list of events (without the info) as a matrix. Each row
%   is an event.
%   Note that the condition |unit|, |timeUnitMultiplier| and
%   |nominalSamplingRate| are set to be the same of the timeline.
%
% dataLabels - (Optional) cell[] of char[]
%   The dataLabels for the columns of the events.
%
% eventsInfo - (Optional) cell[kx1]
%   The information associated to each event. Note that the number of
%   elements in eventsInfo ought to match the number of rows of parameter
%   events.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
%
% See also addConditions
%


%% Log
%
%
% -- ICNNA v1.4.0 (Class version 1.2)
%
% 15-Dec-2025: FOE
%   + Method created (from timeline.addCondition)
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
        error('icnna:data:core:timeline:addCondition:InvalidParameterValue',...
            'Unexpected parameter value.');
    end
end



%% Prepare the parameters

%-- Deal with the id
if isempty(id)
    %Use the first non-used id.
    if obj.nConditions == 0
        id = 1;
    else
        idList = [obj.conditions.id];
        idx = find(~ismember(min(idList):max(idList),idList),1,'first');
        if isempty(idx)
            id = max(idList)+1;
        else
            id = idx;
        end
    end
else
    if ~isinteger(id)
        error('icnna:data:core:timeline:addCondition:InvalidParameter',...
                'Parameter id must be an int.');
    end
end
id = uint32(id);


%-- Deal with the name
if isempty(name)
    name = ['cond' num2str(id,'%04d')]; %Use 'condXXXX'
else
    if isstring(name)
        name = char(name);
    end
    if ~ischar(name)
        error('icnna:data:core:timeline:addCondition:InvalidParameter',...
                'Parameter name must be a char[].');
    end
end



%-- Deal with the cevents
if isempty(cevents)
    cevents=zeros(0,3);
elseif ((ismatrix(cevents)) && (size(cevents,2)==2 || size(cevents,2)==3))
    [cevents,index] = sortrows(cevents);
        %Note that eventsInfo may need sorting accordingly.
else
    error('icnna:data:core:timeline:addCondition:InvalidParameter',...
        ['Events must be a 2 column <onset duration> matrix ' ...
         'or a 3 column <onset duration amplitude> matrix.']);
end


%-- Deal with the eventsInfo
if ~exist('eventsInfo','var')
    eventsInfo = cell(size(cevents,1),1);
else
    assert(size(events,1)==numel(eventsInfo),...
        ['icnna:data:core:timeline:addCondition:InvalidParameterValue ',...
         'Number of information records mismatches number of events.']);
    if iscell(eventsInfo)
        eventsInfo = reshape(eventsInfo,numel(eventsInfo),1);
        eventsInfo = eventsInfo(index); %sort in the same order as the cevents
    else
        error('icnna:data:core:timeline:addCondition:InvalidParameterValue',...
              'Events information must be nx1 cell array.');
    end
end


%-- Deal with the dataLabels
if exist('dataLabels','var')
    if iscell(eventsInfo)
        %Do nothing
    else
        error('icnna:data:core:timeline:addCondition:InvalidParameterValue',...
              ['dataLabels information must be kx1 cell array with k ' ...
               'the number of columns in cevents.']);
    end
else
    dataLabels = [];
end

%-- Deal with the exclusory behaviour
if (~exist('exclusoryState','var'))
   exclusoryState=1; %By default, exclusory behaviour
end





%% Build the condition
cond = icnna.data.core.condition();
cond.id   = id;
cond.name = name;
% The condition |unit|, |timeUnitMultiplier| and |nominalSamplingRate|
% are set to be the same of the timeline.
cond.unit                = obj.unit;
cond.timeUnitMultiplier  = obj.timeUnitMultiplier;
cond.nominalSamplingRate = obj.nominalSamplingRate;
if ~isempty(cevents)
    cond = addEvents(cond,cevents,eventsInfo);
end
if ~isempty(dataLabels)
    cond.dataLabels = dataLabels;
end

%% Attempt to add the condition to the timeline
obj = addConditions(obj,cond,exclusoryState);


end
