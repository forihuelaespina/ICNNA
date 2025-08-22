function addEvents(obj,varargin)
%Add new events to the condition
%
% cond.addEvents(...)
% addEvents(cond,...)
%
% cond.addEvents(cEvents)
% cond.addEvents(theEvents)
% cond.addEvents(theEvents,eventsInfo)
% cond.addEvents(onsets,durations)
% cond.addEvents(onsets,durations,amplitudes)
% cond.addEvents(onsets,durations,eventsInfo)
% cond.addEvents(onsets,durations,amplitudes,eventsInfo)
%
%
%% Remarks
%
% icnna.data.core.condition is a handle object. Therefore,
% calling this method does modify this object.
%
% Regardless of the input format, the onsets and durations will be assumed
%to be in the current condition's |unit|.
%
%% Input parameters
%
% cEvents - Table. A 4 column table including a list of condition events.
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


%Figure out which call stand
% cond.addEvents(cEvents)
% cond.addEvents(theEvents)
% cond.addEvents(theEvents,eventsInfo)
% cond.addEvents(onsets,durations)
% cond.addEvents(onsets,durations,amplitudes)
% cond.addEvents(onsets,durations,eventsInfo)
% cond.addEvents(onsets,durations,amplitudes,eventsInfo)

%First arg is obj, and length(varargin) == nargin-1
% tmpEvents = table('Size',[0 4],...
%                   'VariableTypes',{'double','double','double','cell'},...
%                   'VariableNames',{'onset','duration','amplitude','info'}) ;
switch (nargin)
    case 2
        if iscell(varargin{1}) % [cond] = cond.addEvents(cEvents)
            tmpEvents = varargin{1};
    
        elseif ismatrix(varargin{1}) % [cond] = cond.addEvents(theEvents)
            theEvents = varargin{1};
            if size(theEvents,2) < 3 %amplitudes missing
                theEvents(:,3) = 1;
            end
            tmpInfo = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
                        tmpInfo, ...
                        'VariableNames',{'onsets','durations','amplitudes','info'});
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
            tmpInfo = varargin{2};
            tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
                        tmpInfo, ...
                        'VariableNames',{'onsets','durations','amplitudes','info'});
    
        elseif ismatrix(varargin{2}) % [cond] = cond.addEvents(onsets,durations)
            theEvents = [varargin{1} varargin{2}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
                        tmpInfo, ...
                        'VariableNames',{'onsets','durations','amplitudes','info'});
        else
            error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end

    case 4
        if iscell(varargin{3}) % [cond] = cond.addEvents(onsets,durations,eventsInfo)
            theEvents = [varargin{1} varargin{2}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo = varargin{3};
            tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
                        tmpInfo, ...
                        'VariableNames',{'onsets','durations','amplitudes','info'});
    
        elseif ismatrix(varargin{2}) % [cond] = cond.addEvents(onsets,durations,amplitudes)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            tmpInfo = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
                        tmpInfo, ...
                        'VariableNames',{'onsets','durations','amplitudes','info'});
        else
            error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end




    case 5 % [cond] = cond.addEvents(onsets,durations,amplitudes,eventsInfo)
        theEvents = [varargin{1} varargin{2} varargin{3}];
        tmpInfo = varargin{4}; %Events info missing
        tmpEvents = table(theEvents(:,1),theEvents(:,2),theEvents(:,3),...
            tmpInfo, ...
            'VariableNames',{'onsets','durations','amplitudes','info'});
        
    otherwise %nargin > 4
        error('icnna:data:core:condition:addEvents:InvalidInputParameter',...
              'Unexpected number of parameters.');

end


obj.cevents = [obj.cevents; tmpEvents];


end