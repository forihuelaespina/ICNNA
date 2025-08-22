function addEvents(obj,varargin)
%Add new events to the timeline
%
% obj.addEvents(...)
% addEvents(obj,...)
%
% obj.addEvents(cEvents)
% obj.addEvents(theEvents)
% obj.addEvents(theEvents,eventsInfo)
% obj.addEvents(id,onsets,durations)
% obj.addEvents(id,onsets,durations,amplitudes)
% obj.addEvents(id,onsets,durations,eventsInfo)
% obj.addEvents(id,onsets,durations,amplitudes,eventsInfo)
%
%
%
% Regardless of the input format, the onsets and durations will be assumed
%to be in the current timeline's |unit| and, if in seconds, also in the
%same|timeUnitMultiplier|.
%
%
% IMPORTANT: The IDs (whether in parameter cevents, theEvents or id)
% ought to correspond to conditions already existing within the timeline. 
% If the condition as not been defined, a warning is issued and
% nothing is done.
%
%
%
%% Remarks
%
% icnna.data.core.timeline is a handle object. Therefore,
% calling this method does modify this object.
%
%
%
%
%% Input parameters
%
% cEvents - Table. A 5 column table including a list of condition events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + id (uint32) - 
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


%Figure out which call stand
% obj.addEvents(cEvents)
% obj.addEvents(theEvents)
% obj.addEvents(theEvents,eventsInfo)
% obj.addEvents(id,onsets,durations)
% obj.addEvents(id,onsets,durations,amplitudes)
% obj.addEvents(id,onsets,durations,eventsInfo)
% obj.addEvents(id,onsets,durations,amplitudes,eventsInfo)



%First arg is obj, and length(varargin) == nargin-1
% tmpEvents = table('Size',[0 5],...
%                   'VariableTypes',{'uint32','double','double','double','cell'},...
%                   'VariableNames',{'id','onset','duration','amplitude','info'}) ;
switch (nargin)
    case 2
        if iscell(varargin{1}) % obj.addEvents(cEvents)
            tmpEvents = varargin{1};
    
        elseif ismatrix(varargin{1}) % obj.addEvents(theEvents)
            theEvents = varargin{1};
            if size(theEvents,2) < 4 %amplitudes missing
                theEvents(:,4) = 1;
            end
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});
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
            tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});
    

    case 4
            % obj.addEvents(id,onsets,durations)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            theEvents(:,4) = 1; %amplitudes missing
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});

    case 5 
        if iscell(varargin{4}) % obj.addEvents(id,onsets,durations,eventsInfo)
            theEvents = [varargin{1} varargin{2} varargin{3}];
            theEvents(:,3) = 1; %amplitudes missing
            tmpInfo   = varargin{4};
            tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});
    
        elseif ismatrix(varargin{4}) % obj.addEvents(id,onsets,durations,amplitudes)
            theEvents = [varargin{1} varargin{2} varargin{3} varargin{4}];
            tmpInfo   = cell(size(theEvents,1),1); %Events info missing
            tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});
        else
            error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
                  ['Invalid input parameter of class ' class(varargin{1})]);
        end
        
    case 6 % obj.addEvents(id,onsets,durations,amplitudes,eventsInfo)
        theEvents = [varargin{1} varargin{2} varargin{3} varargin{4}];
        tmpInfo   = varargin{5}; %Events info missing
        tmpEvents = table(theEvents(:,1),theEvents(:,2), ...
                        theEvents(:,3),theEvents(:,4), ...
                        tmpInfo, ...
                        'VariableNames',{'id','onsets','durations',...
                                        'amplitudes','info'});
    otherwise %nargin > 6
        error('icnna:data:core:timeline:addEvents:InvalidInputParameter',...
              'Unexpected number of parameters.');

end

%Ensure the ids are uint32
if ~isa(tmpEvents.id,'uint32')
    tmpEvents.id = uint32(tmpEvents.id);
end

%Check that the id of the conditions for the new events do exist.

idx = obj.findConditions(unique(tmpEvents.id));
if (isempty(idx))
    warning('icnna:data:core:timeline:addEvents:UndefinedCondition',...
        ['Some conditions |id| have not ' ...
         ' been defined. Ignoring event addition attempt.']);
else

    obj.cevents = [obj.cevents; tmpEvents];
    assert(obj.assertExclusory(), ...
        ['icnna:data:core:timeline:addCondition:ViolatedInvariant: ' ...
        'Inconsistent exclusory behaviour.']);
end


end