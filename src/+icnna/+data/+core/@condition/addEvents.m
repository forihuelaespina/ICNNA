function obj = addEvents(obj,varargin)
%Add new events to the condition
%
% cond = addEvents(cond,...)
%
% cond = addEvents(cond,cEvents)
% cond = addEvents(cond,cEventsTable)
% cond = addEvents(cond,theEvents)
% cond = addEvents(cond,theEvents,eventsInfo)
% cond = addEvents(cond,onsets,durations)
% cond = addEvents(cond,onsets,durations,amplitudes)
% cond = addEvents(cond,onsets,durations,eventsInfo)
% cond = addEvents(cond,onsets,durations,amplitudes,eventsInfo)
%
%
%% Remarks
%
% Regardless of the input format, the onsets and durations will be assumed
%to be in the current condition's |unit|.
%
%% Input parameters
%
% cEvents - struct[1xk]. List of condition events.
%         Each struct is an event with the following fields;
%          + onsets - double. An event onsets
%          + durations - double. An event durations,
%          + amplitudes  - double. An event amplitudes or magnitudes,
%          + info - cell. An event information. Whatever the user
%                   wants to store associated to the condition event.
%           k is the number of events in the condition,
%
% cEventsTable - Table. A 4 column table including a list of condition events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + onsets (double)
%          + durations (double)
%          + amplitudes (double)
%          + info (cell)
%
% theEvents - double array. Either <nEvents x 2> or <nEvents x 2>
%       If <nEvents x 2> - First column are onsets and second column are
%           durations. Amplitudes will be assumed to be 1.
%       If <nEvents x 3> - First column are onsets, second column are
%           durations, and third column are amplitudes.
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
% See also icnna.data.core.condition, clearEvents
%

%% Log
%
%
% File created: 25-Jun-2025
%
% -- ICNNA v1.3.1
%
% 25-Apr-2025: FOE. 
%   + File created
%
% 9-Jul-2025: FOE. 
%   + Adapted to reflect the new handle status e.g. no object return.
%
% 5-Dec-2025: FOE. 
%   + Revert back to value class status, i.e. object return
%


%Figure out which call stand
% cond.addEvents(cEvents)
% cond.addEvents(cEventsTable)
% cond.addEvents(theEvents)
% cond.addEvents(theEvents,eventsInfo)
% cond.addEvents(onsets,durations)
% cond.addEvents(onsets,durations,amplitudes)
% cond.addEvents(onsets,durations,eventsInfo)
% cond.addEvents(onsets,durations,amplitudes,eventsInfo)

%First arg is obj, and length(varargin) == nargin-1
% obj.cevents = struct( ...
%            'onsets', [], ...
%            'durations', [], ...
%            'amplitudes', [], ...
%            'info', {} );
flagConvertToStruct = false;
theEvents = nan(0,3);
tmpInfo   = cell(0,1);
switch (nargin)
    case 2
        if isstruct(varargin{1}) % [cond] = cond.addEvents(cEvents)
            tmpEvents = varargin{1};
            flagConvertToStruct = false;
        elseif iscell(varargin{1}) % [cond] = cond.addEvents(cEventsTable)
            tmpEvents = table2struct(varargin{1});
            flagConvertToStruct = false;
    
        elseif ismatrix(varargin{1}) % [cond] = cond.addEvents(theEvents)
            theEvents = varargin{1};
            if size(theEvents,2) < 3 %amplitudes missing
                theEvents(:,3) = 1;
            end
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            flagConvertToStruct = true;
        else
            error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end
        


    case 3
        if iscell(varargin{2}) % [cond] = cond.addEvents(theEvents,eventsInfo)
            theEvents = varargin{1};
            if size(theEvents,2) < 3 %amplitudes missing
                theEvents(:,3) = 1;
            end
            tmpInfo   = varargin{2};
    
        elseif ismatrix(varargin{2}) % [cond] = cond.addEvents(onsets,durations)
            theEvents = [varargin{1} varargin{2}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
        else
            error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end
        flagConvertToStruct = true;

    case 4
        if iscell(varargin{3}) % [cond] = cond.addEvents(onsets,durations,eventsInfo)
            theEvents = [varargin{1} varargin{2}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo   = varargin{3};
    
        elseif ismatrix(varargin{2}) % [cond] = cond.addEvents(onsets,durations,amplitudes)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
        else
            error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end
        flagConvertToStruct = true;




    case 5 % [cond] = cond.addEvents(onsets,durations,amplitudes,eventsInfo)
        theEvents = [varargin{1} varargin{2} varargin{3}];
        tmpInfo   = varargin{4}; %Events info missing
        flagConvertToStruct = true;
        
    otherwise %nargin > 4
        error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
              'Unexpected number of parameters.');

end


%Reformat and verify the input
if (flagConvertToStruct)
    tmpEvents = struct( ...
        'onsets',     num2cell(theEvents(:,1).'), ...
        'durations',  num2cell(theEvents(:,2).'), ...
        'amplitudes', num2cell(theEvents(:,3).'), ...
        'info',       tmpInfo');
else
    % Ensure that each struct in the array has the necessary fields
    requiredFields = {'onsets','durations','amplitudes','info'};
    for i = 1:numel(tmpEvents)
        if ~all(isfield(tmpEvents(i), requiredFields))
            error('icnna:data:core:condition:addEvents:MissingFields', ...
                'Each event struct must contain the fields: onsets, durations, amplitudes, info.');
        end

        % Check that the fields contain valid data
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

% Add the events
obj.cevents = [obj.cevents tmpEvents];


end