classdef condition
% icnna.data.core.condition - Experimental conditions for marking a timeline
%
% Equivalent to a stimulus measurement defined in the snirf file format.
%
% Each one of the conditions marked in a @icnna.data.core.timeline.
%
%% Conditions
%
% Experimental conditions is a convenient way to mark timelines.
% Each condition can represent an experimental stimulus (e.g. some kind
% of factor), but also other types of information important to add
% semantics to the data e.g. distractions or unexpected confounding
% factors that may have occurred during a data collection session.
%
% A condition may ocurr never, once or more than once. Any time the
% condition holds is referred to as an event (see next section). In
% addition to the mere "temporal" marking, events can hold additional
% information such as the amplitude or strength, some event associated
% information e.g. video being presented in a case of visual stimulus, etc
%
%% Events
%
% Onset and durations may be associated with real time stamps or
%with samples indexes (see property |unit|), however, the condition
%has no notion of the sampling rate, i.e. it does NOT know how to
%convert samples to seconds or viceversa.
%
%Conditions might happen never, once, or more than one
%time. Every time a condition occurs during the experiment
%(i.e. the condition holds) an event is inserted in the timeline
%with a mark representing the event onset. The event
%will last for a certain amount of time (duration) and then finish.
%For instance an event which start at time
%sample 30 and finishes at time sample 45 (BOTH INCLUDED)
%will have its onset set to 30 and its duration set
%to 16. 
%
% Sample  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45
%       ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
%Duration  1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16
%
%
%Timeline can hold experiments design under the block paradigm, the
%event related paradigm or the self-pace paradigm. In particular for
%the instantaneous events, duration of events is simply set to 0, e.g.
%
%
%  Sample  30
%        ---+--
% Duration  0
%
%
%% Remark
%
% This class is somewhat analogous to icnna.data.snirf.stim but;
% 1) This is not attached to the evolution of the .snirf format
% 2) This provides some additional functionality over icnna.data.snirf.stim
%   e.g. includes eventInfo
%
%% Properties
%
%   .id - A numerical identifier.
%   .tag - Char array. A name for the condition. By default is
%       'condition0001'.
%   .cevents - Table. List of condition events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + onset - The rows of the table is ALWAYS sort by onsets,
%          + duration,
%          + amplitude i.e. magnitude or strength.
%          + info - Event information. Whatever the user wants to
%                   store associated to the condition event.
%
%       Additional columns may be added, but the 4 columns above
%       ought to be present and be named 'onset', 'duration', 'amplitude'
%       and 'info' respectively. Although, the order does not matter in
%       principle, if any of these four columns are missing when setting
%       up the value, a default order will be assumed and the column will
%       be renamed accordingly.
%
%       Within a condition events can overlap. Control of overlapping
%       occurs in class timeline. This is a sharp distinction with
%       timeline conditions until ICNNA version 1.2.1 where the conditions
%       where not separate objects but structs stored in a cell array
%       within class @timeline and when event overlap within timeline
%       was not permitted. Now, this is control by the exclusory behaviour
%       of the class @timeline, but it is in principle permitted.
%
%       You can use obj.cevents.onset to get/set the list of onsets and
%       analogously for the duration, amplitude and info. See also derived
%       property ends and eventTime.
%
%
%   .unit - Char array. 'samples' (Default) or 'seconds'.
%   .timeUnitMultiplier - Scalar (int16). The time unit multiplier exponent
%       in base 10. It only affects the onset and duration.
%       Default 0, i.e. attribute events would be in scale 10^0.
%           + If .unit is 'samples', this will ALWAYS be 0. 
%           + If .unit is 'seconds', this represents fractional units,
%               e.g. -3 is equals to [ms]. 
%   .amplitudeUnitMultiplier - Scalar (int16). The amplitude unit
%       multiplier exponent in base 10. It only affects the event amplitude.
%       Default 0, i.e. attribute events would be in scale 10^0.
%
%
%% Dependent properties
%
%   .nEvents - Read only. Number of events. Number of rows of property |cevents|
%   .ends  - Read only. Double array with the list of event ends. obj.onsets + obj.durations
%   .eventTime - Read only. Double array of [onsets durations [ends]]
%   .dataLabels - Equivalent to accessing the variables names of the
%       cevents table but typecasted to a string array.
%       These are automatically updated when setting property |cevents|
%
%
%% Methods
%
% Type methods('icnna.data.core.condition') for a list of methods
% 
% Copyright 2024
% @author: Felipe Orihuela-Espina
%
% See also timeline, icnna.data.snirf.stim
%



%PENDING: Making the unit read-only (only writable upon creating a
%condition) and then having a method the returns a new condition
%with the other units that takes a sampling rate as parameter.
%This gives more certainty that the entries in the cevents are intended
%to be on that units, than if the attribute unit can be updated without
%updating the cevents.




%% Log
%
%   + Class available since ICNNA v1.2.3
%
% 11-Apr-2024: FOE
%   + File and class created.
%
% 8-May-2024: FOE
%   + Added support for more columns in the cevents table.
%   + Added support for dataLabels
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        tag(1,:) char = ''; %Tag of the condition
        cevents table = table('Size',[0 4],...
                        'VariableTypes',{'double','double','double','cell'},...
                        'VariableNames',{'onset','duration','amplitude','info'}) ;
        unit(1,:) char {mustBeMember(unit,{'samples','seconds'})}= 'samples';
        timeUnitMultiplier(1,1) int16 = 0;
        amplitudeUnitMultiplier(1,1) int16 = 0;
    end
    
    properties (Dependent)
        nEvents %Read only
        ends %Read only
        eventTime %Read only
        dataLabels
    end
    
    
    methods
        function obj=stim(varargin)
            %ICNNA.DATA.CORE.CONDITION A icnna.data.core.condition class constructor
            %
            % obj=icnna.data.core.condition() creates a default object.
            %
            % obj=icnna.data.core.condition(obj2) acts as a copy constructor
            %
            % obj=icnna.data.core.condition(inStruct) attempts to typecasts the struct
            %
            % 
            % Copyright 2024
            % @author: Felipe Orihuela-Espina
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.condition')
                obj=varargin{1};
                return;
            elseif isstruct(varargin{1}) %Attempt to typecast
                tmp=varargin{1};
                tmpFields = fieldnames(tmp);
                for iField = 1:length(tmpFields)
                    tmpProp = tmpFields{iField};
                    switch (tmpProp)
                        case 'events'
                            obj.cevents.onset     = tmp.events(:,1);
                            obj.cevents.duration  = tmp.events(:,2);
                            obj.cevents.amplitude = 1;
                        case 'eventsInfo'
                            obj.cevents.info = tmp.eventsInfo;
                        otherwise %inc. tag
                            if ismember(tmpProp,properties(obj))
                                obj.(tmpProp) = tmp.(tmpProp);
                            end
                    end
                end

                return;
            else
                error(['icnna.data.core.condition:condition:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets
        function res = get.id(obj)
        %Gets the object |id|
            res = obj.id;
        end
        function obj = set.id(obj,val)
        %Sets the object |id|
            obj.id =  val;
        end


        function val = get.tag(obj)
        %Retrieves the |tag| of the condition
            val = obj.tag;
        end
        function obj = set.tag(obj,val)
        %Sets the |tag| of the condition
            obj.tag = val;
        end



        function val = get.cevents(obj)
        %Retrieves the events of the condition
            val = obj.cevents;
        end
        function obj = set.cevents(obj,val)
        %Sets the events of the conditions

            %Check if the number of columns is AT LEAST 4
            if size(val,2) < 4
                error('icnna:data:core:condition:set_cevents:InvalidValue',...
                       ['Condition events ought to have at least 4 columns; ' ...
                        'onset, duration, amplitude and info.']);
            end

            %Check the column names to ensure the mandatory ones (onset,
            %duration, amplitude and info) are present.
            tmpColNames = val.Properties.VariableNames;
            if ~ismember('onset',tmpColNames)
                %Find the first non-mandatory column not yet used and rename
                idx = find(~ismember(tmpColNames,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to onset.'])
                tmpColNames{idx} = 'onset';
            end
            if ~ismember('duration',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to duration.'])
                tmpColNames{idx} = 'duration';
            end
            if ~ismember('amplitude',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to amplitude.'])
                tmpColNames{idx} = 'amplitude';
            end
            if ~ismember('info',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to info.'])
                tmpColNames{idx} = 'info';
            end
            assert(ismember('onset',tmpColNames) ...
                && ismember('duration',tmpColNames) ...
                && ismember('amplitude',tmpColNames) ...
                && ismember('info',tmpColNames), ...
                ['icnna:data:core:condition:set_cevents:MissingEventInformation', ...
                'Unable to find one or more mandatory columns (onset, '...
                'duration, amplitude, info).']);
            val.Properties.VariableNames = tmpColNames;

            obj.cevents = val;
            obj.cevents = sortrows(obj.cevents,'onset');
        end

        function val = get.unit(obj)
        %Retrieves the temporal unit, whether 'samples' or 'seconds'
            val = obj.unit;
        end
        function obj = set.unit(obj,val)
        %Sets the temporal unit, whether 'samples' or 'seconds'
        %
        %When switching from seconds to samples, the |timeUnitMultiplier|
        %will be reset to 0.
            obj.unit = val;
            if strcmp(val,'samples')
                obj.timeUnitMultiplier = 0;
            end
        end

        function val = get.timeUnitMultiplier(obj)
        %Retrieves the temporal unit multiplier
            val = obj.timeUnitMultiplier;
        end
        function obj = set.timeUnitMultiplier(obj,val)
        %Sets the temporal unit multiplier
            if strcmp(obj.unit,'samples') && val~=0
                error('icnna:data:core:condition:set_timeUnitMultiplier:InvalidValue',...
                      'timeUnitMultiplier ought to be 0 when condition unit is "samples".');
            end
            obj.timeUnitMultiplier = val;
        end


        function val = get.amplitudeUnitMultiplier(obj)
        %Retrieves the amplitude unit multiplier
            val = obj.amplitudeUnitMultiplier;
        end
        function obj = set.amplitudeUnitMultiplier(obj,val)
        %Sets the amplitude unit multiplier
            obj.amplitudeUnitMultiplier = val;
        end





        %Dependent properties gets/sets
        function val = get.nEvents(obj)
            %(DEPENDENT) Gets the object |nEvents|
            %
            % The number of events declared in the condition.
            val = size(obj.cevents,1);
        end

        function res = get.ends(obj)
            %(DEPENDENT) Gets the list of event's |ends|
            %
            % The list of event's |ends| (onset + duration)
            res = obj.cevents.onset + obj.cevents.duration;
        end

        function val = get.eventTime(obj)
        %Retrieves the events ends (onset + duration)
            val = [obj.cevents.onset obj.cevents.duration obj.ends];
        end

        function val = get.dataLabels(obj)
        %(DEPENDENT) Retrieves the variable names of the cevents table as a string array
        %
        %If you need the data labels as a cell array use:
        %       obj.cevents.Properties.VariableNames
            val = string(obj.cevents.Properties.VariableNames);
        end
        function obj = set.dataLabels(obj,val)
        %(DEPENDENT) Sets the variable names of the cevents table
            %Check that it is typed as string array
            if ~isstring(val)
                error('icnna:data:core:condition:set_dataLabels:InvalidType',...
                       'Property dataLabels ought to be a string array.');
            end
            val = cellstr(val); %Typecast to cell array

            %Check if the number of elements matches the number of columns
            %in cevents
            val=reshape(val,numel(val),1);
            if length(val) ~= length(obj.cevents.Properties.VariableNames)
                error('icnna:data:core:condition:set_dataLabels:InvalidValue',...
                       ['Number of dataLabels ought to match the number ' ...
                       'of columns in property .cevents.']);
            end
            %Check the column names to ensure the mandatory ones (onset,
            %duration, amplitude and info) are present.
            if ~ismember('onset',val)
                %Find the first non-mandatory column not yet used and rename
                idx = find(~ismember(val,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_dataLabels:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to onset.'])
                val{idx} = 'onset';
            end
            if ~ismember('duration',val)
                idx = find(~ismember(val,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_dataLabels:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to duration.'])
                val{idx} = 'duration';
            end
            if ~ismember('amplitude',val)
                idx = find(~ismember(val,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_dataLabels:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to amplitude.'])
                val{idx} = 'amplitude';
            end
            if ~ismember('info',val)
                idx = find(~ismember(val,{'onset','duration','amplitude','info'}),1,'first');
                warning('icnna:data:core:condition:set_dataLabels:MissingEventInformation',...
                        ['Renaming column ' num2str(idx) ' to info.'])
                val{idx} = 'info';
            end
            assert(ismember('onset',val) && ismember('duration',val) ...
                && ismember('amplitude',val) && ismember('info',val), ...
                ['icnna:data:core:condition:set_dataLabels:MissingEventInformation', ...
                'Unable to find one or more mandatory columns (onset, '...
                'duration, amplitude, info).']);
            
            obj.cevents.Properties.VariableNames = val;
        end



    end


end
