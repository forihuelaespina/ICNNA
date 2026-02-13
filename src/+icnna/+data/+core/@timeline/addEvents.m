function obj = addEvents(obj,varargin)
%Add new events to the timeline
%
% obj = addEvents(obj,...)
%
% -- Safe methods (provide condition's |id| as well as the condition's |name|)
% obj = addEvents(obj,cEvents)
% obj = addEvents(obj,cEventsTable)
%
% -- Unsafe methods (provide only condition's |id|)
% obj = addEvents(obj,theEvents)
% obj = addEvents(obj,theEvents,eventsInfo)
% obj = addEvents(obj,id,onsets,durations)
% obj = addEvents(obj,id,onsets,durations,amplitudes)
% obj = addEvents(obj,id,onsets,durations,eventsInfo)
% obj = addEvents(obj,id,onsets,durations,amplitudes,eventsInfo)
%
%
%
%% Remarks
%
% The conditions to which the events are added ought to exist in advance.
%That is, you cannot use this method to add conditions on-the-fly.
%
% Regardless of the input format, the onsets and durations will be assumed
% to be in the current timeline's |unit| and, if in seconds, also in the
% same |timeUnitMultiplier|.
%
%
% IMPORTANT: The IDs (whether in parameter cevents, theEvents or id)
% ought to correspond to conditions already existing within the timeline. 
% If the condition as not been defined, a warning is issued and
% nothing is done.
%
%
%
%
%% Input parameters
%
% cEvents - struct[1xk]. List of new condition events.
%         Each struct is an event with the following fields;
%          + id - uint32. The |id| of the condition to which the event belongs.
%          + name - char[]. The |name| of the condition to which the event belongs.
%          + onsets - double. The event onset
%          + durations - double. An event duration,
%          + amplitudes  - double. An event amplitude or magnitude,
%          + info - cell. An event information. Whatever the user
%                   wants to store associated to the condition event.
%           k is the number of new events to be added (across conditions)
%         to the timeline),
%
% cEventsTable - Table. A 6 column table including a list of new condition
%           events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + id (double/uint32)
%          + name (char[]/string)
%          + onsets (double)
%          + durations (double)
%          + amplitudes (double)
%          + info (cell)
%
% theEvents - double array. Either <nEvents x 3> or <nEvents x 4>
%       If <nEvents x 3> - First column are ids, second column are
%           onsets and third column are durations. Amplitudes will
%           be assumed to be 1.
%       If <nEvents x 4> - First column are ids, second column are
%           onsets, third column are durations, and fourth column
%           are amplitudes.
%       In both cases, the column of ids will be typecasted to uint32.
%
% id - uint32 array <nEvents x 1>. List of condition's id
%
% onsets - double array <nEvents x 1>. List of event onsets
%
% durations - double array <nEvents x 1>. List of event durations
%
% amplitudes - Optional. double array <nEvents x 1>. List of event
%       amplitudes. If not provided, amplitudes will be assumed to be 1.
%
% eventsInfo - Optional. Cell array <nEvents,1>
%       The events companion information.
%
%
% Copyright 2025
% @author Felipe Orihuela-Espina
% 
% See also icnna.data.core.timeline
%

%% Log
%
%
% File created: 10-Jul-2025
%
% -- ICNNA v1.3.1
%
% 10-Jul-2025: FOE. 
%   + File created
%
% 11-Jul-2025: FOE
%   + Adapted to the new internal structure for the storing
% of conditions |id| and |name| (from dictionary to table).
%
%
% -- ICNNA v1.4.0
%
% 10-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Class version - Updated to 1.2
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents|.
%	+ Improved some comments
%


%Figure out which call stand
% obj = addEvents(obj,cEvents)
% obj = addEvents(obj,cEventsTable)
% obj = addEvents(obj,theEvents)
% obj = addEvents(obj,theEvents,eventsInfo)
% obj = addEvents(obj,id,onsets,durations)
% obj = addEvents(obj,id,onsets,durations,amplitudes)
% obj = addEvents(obj,id,onsets,durations,eventsInfo)
% obj = addEvents(obj,id,onsets,durations,amplitudes,eventsInfo)



%First arg is obj, and length(varargin) == nargin-1
% tmpEvents = struct( ...
%            'id', [], ...
%            'name', {}, ...
%            'onsets', [], ...
%            'durations', [], ...
%            'amplitudes', [], ...
%            'info', {} );
flagConvertToStruct = false;
theEvents = nan(0,4); %[ids, onsets, durations, amplitudes]

switch (nargin)
    case 2
        if isstruct(varargin{1}) % [cond] = cond.addEvents(cEvents)
            tmpEvents = varargin{1};
            flagConvertToStruct = false;
    
        elseif iscell(varargin{1}) % obj.addEvents(cEventsTable)
            tmpEvents = table2struct(varargin{1});
            flagConvertToStruct = false;
    
        elseif ismatrix(varargin{1}) % obj.addEvents(theEvents)
            theEvents = varargin{1};
            if size(theEvents,2) < 4 %amplitudes missing
                theEvents(:,4) = 1;
            end
            nNewEvents = size(theEvents,1);
            tmpInfo    = cell(nNewEvents,1); %Events info missing
            flagConvertToStruct = true;

        else
            error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end


    case 3
            % obj.addEvents(theEvents,eventsInfo)
            theEvents = varargin{1};
            if size(theEvents,2) < 4 %amplitudes missing
                theEvents(:,4) = 1;
            end
            tmpInfo   = varargin{2};
            flagConvertToStruct = true;
   

    case 4
            % obj.addEvents(id,onsets,durations)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            theEvents(:,4) = 1; %amplitudes missing
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            flagConvertToStruct = true;

    case 5 
        if iscell(varargin{4}) % obj.addEvents(id,onsets,durations,eventsInfo)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo   = varargin{4};
            flagConvertToStruct = true;
    
        elseif ismatrix(varargin{4}) % obj.addEvents(id,onsets,durations,amplitudes)
            theEvents = [varargin{1} varargin{2} varargin{3} varargin{4}];
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            flagConvertToStruct = true;
        else
            error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end
        
    case 6 % obj.addEvents(id,onsets,durations,amplitudes,eventsInfo)
        theEvents = [varargin{1} varargin{2} varargin{3} varargin{4}];
        tmpInfo   = varargin{5}; %Events info missing
        flagConvertToStruct = true;
    otherwise %nargin > 6
        error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
              'Unexpected number of parameters.');

end



%Reformat and verify the input
if (flagConvertToStruct)
    %Find the conditions names
    tmpNames = findConditionNames(obj,theEvents(:,1));

    tmpEvents = struct( ...
        'id', num2cell(uint32(theEvents(:,1)).'), ...
        'name', tmpNames', ...
        'onsets', num2cell(theEvents(:,2).'), ...
        'durations', num2cell(theEvents(:,3).'), ...
        'amplitudes', num2cell(theEvents(:,4).'), ...
        'info', tmpInfo');

else
    % Ensure that each struct in the array has the necessary fields
    requiredFields = {'id','name','onsets','durations','amplitudes','info'};
    for i = 1:numel(tmpEvents)
        if ~all(isfield(tmpEvents(i), requiredFields))
            error('icnna:data:core:condition:addEvents:MissingFields', ...
                'Each event struct must contain the fields: onsets, durations, amplitudes, info.');
        end

        % Check that the fields contain valid data
        if ~isscalar(tmpEvents(i).id)
            error('icnna:data:core:condition:addEvents:InvalidOnsets', ...
                'The "id" field must be a scalar value.');
        end
        if ~iscell(tmpEvents(i).name)
            error('icnna:data:core:condition:addEvents:InvalidInfo', ...
                'The "name" field must be a cell array of char[].');
        end
        if ~isscalar(tmpEvents(i).onsets)
            error('icnna:data:core:condition:addEvents:InvalidOnsets', ...
                'The "onsets" field must be a scalar value.');
        end
        if ~isscalar(tmpEvents(i).durations)
            error('icnna:data:core:condition:addEvents:InvalidDurations', ...
                'The "durations" field must be a scalar value.');
        end
        if ~isscalar(tmpEvents(i).amplitudes)
            error('icnna:data:core:condition:addEvents:InvalidAmplitudes', ...
                'The "amplitudes" field must be a scalar value.');
        end
    end
end

%Ensure the ids are uint32
if ~isa([tmpEvents.id],'uint32')
    [tmpEvents.id] = deal(uint32(tmpEvents.id));
end

%Check that the id of the conditions for the new events do exist.
uniqueIds = unique([tmpEvents.id]);
idx = obj.findConditions(uniqueIds);
if (any(isnan(idx)))
    warning('icnna:data:core:timeline:addEvents:UndefinedCondition',...
        ['Some conditions |id| have not been defined. ' ...
         'Ignoring attempt to add events.']);
else

     for iCond = 1:numel(uniqueIds)
        tmpIdx = idx(iCond);
        %Filter the events for this condition
        tmpEvents2 = tmpEvents([tmpEvents.id] == uniqueIds(iCond));
        %Ignore the columns for id and name
        keepFields = {'onsets','durations','amplitudes','info'};
        tmpEvents2 = rmfield(tmpEvents2, ...
                             setdiff(fieldnames(tmpEvents2), keepFields));
        %Add the events
        obj.conditions(tmpIdx) = addEvents(obj.conditions(tmpIdx),...
                                           tmpEvents2);
    end

    assert(obj.assertExclusory(), ...
        ['icnna:data:core:timeline:addCondition:ViolatedInvariant: ' ...
        'Inconsistent exclusory behaviour.']);
end


end




%% AUXILIARY FUNCTIONS
function [tmpNames] = findConditionNames(obj,ids)
%Retrieve the condition names for a list of condition |ids|
%
% [tmpNames] = findConditionNames(obj,ids)
%
%
%% Error handling
%
% - All conditions for which the |id| is being queried ought to exist
%
%% Input parameter
%
% obj - @icnna.data.core.timeline
%   The timeline in which the conditions are searched.
% ids - uint32[kx1].
%   The list of condition |id|. These can be repeated retrieving
%   the same name more than once.
%
%% Output
%
% tmpNames - Cell[kx1]
%   The list of condition |names| for each of the ids.
%   The names are given in the same order as the queried ids.
%

idx = obj.findConditions(ids);
if any(isnan(idx))
    error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
          'Some condition ids not found.');
end
tmpNames = {obj.conditions(idx).name}';

end
