classdef condition < icnna.data.core.identifiableObject
% icnna.data.core.condition - Experimental conditions for marking a timeline
%
% Each one of the conditions marked in a @icnna.data.core.timeline.
%
% Somewhat equivalent to a stimulus measurement defined in the snirf
% file format but with some additional niceties such as the event info.
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
%with samples indexes (see property |unit|). However, the condition
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
%to 15. 
%
% Sample  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45
%       ---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
%Duration  0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15
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
%% Remarks
%
% @icnna.data.core.condition are @icnna.data.core.identifiableObject,
% and therefore they are handles. Beware of collateral effects.
%
%
% This class is somewhat analogous to icnna.data.snirf.stim but;
% 1) This is not attached to the evolution of the .snirf format
% 2) This provides some additional functionality over icnna.data.snirf.stim
%   e.g. includes eventInfo
%
%
% Switching time units (i.e. from samples to seconds) and back may
% result in rounding errors.
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is 'condition0001'.
%       A name for the condition. 
%
%   -- Public properties
%   .cevents - Table. List of condition events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + onsets - The rows of the table is ALWAYS sort by onsets,
%          + durations,
%          + amplitudes i.e. magnitude or strength.
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
%       In switching between 'samples' and 'seconds' or the other
%       way around, the |nominalSamplingRate| is used to convert
%       the |cevents| onsets and durations.
%       Also, when unit is 'samples', the timeUnitMultiplier is
%       transiently ignored. But when unit is 'seconds', the
%       timeUnitMultiplier is also considered.
%
%   .timeUnitMultiplier - Scalar (int16). Default 0.
%       The time unit multiplier exponent in base 10. This represents
%       fractional units, e.g. -3 is equals to [ms]. The default 0
%       means that the |cevents| would be in scale 10^0 with respect
%       to seconds.
%       This property affects the |cevents| onsets and duration.
%         If the condition |unit| is in 'samples', changing the
%       |timeUnitMultiplier| does NOT affect the |cevents| onsets
%       and durations.
%         If the condition |unit| is in 'seconds', changing the
%       |timeUnitMultiplier| does affect the |cevents| onsets
%       and durations. For instance, if an onset occurs at second 1,
%       changing the |timeUnitMultiplier| to -3 i.e. expressing it
%       in [ms] means that now the value of the onset is 1000.
%
%   .nominalSamplingRate - Scalar (double). Default is 1 [Hz].
%       The nominal sampling rate in [Hz]. Permits converting sampling
%       into seconds and viceversa.
%         If the condition |unit| is in samples, changing the
%       |nominalSamplingRate| affects the |cevents| onsets and durations.
%       For instance, an onset at sample 5 sampled at 5 Hz, i.e. equal
%       to that sample being taken at second 1, if sampled at 10 Hz, to
%       represent the same time, then the onset would have been in
%       sample 10.
%         If the condition |unit| is in seconds, changing the
%       |nominalSamplingRate| does NOT affect the |cevents| onsets
%       and durations.
%
%
%% Dependent properties
%
%   .nEvents - Read only. Number of events. Number of rows of property |cevents|
%   .onsets  - Read only. Double array with the list of events' onsets.
%   .durations - Read only. Double array with the list of events' durations.
%   .amplitudes - Read only. Double array with the list of events' amplitudes.
%   .ends  - Read only. Double array with the list of events' ends.
%       obj.onsets + obj.durations
%   .eventTime - Read only. Double array of [onsets durations [ends]]
%   .dataLabels - Read only. Equivalent to accessing the variables
%       names of the cevents table but typecasted to a string array.
%       These are automatically updated when setting property |cevents|
%   .tag - DEPRECATED since v1.3.1. See |name|
%       |tag| is now only a "shell" for |name|. If you update the |name|
%       you will also be updating the name and viceversa.
%
%
%% Methods
%
% Type methods('icnna.data.core.condition') for a list of methods
% 
% Copyright 2024-25
% @author: Felipe Orihuela-Espina
%
% See also icnna.data.core.timeline, icnna.data.snirf.stim
%


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
%
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + Some improved comments.
%   + Class version - Updated to 1.1
%   + Property id has changed type from double to uint32
%   + Events can no longer be added in the constructor. They ought
%     to be added afterwards using the methods to manipulate events.
%   + Property |amplitudeUnitMultiplier| is no longer supported.
%   + Modiyfing the |unit| no longer modifies the |timeUnitMultiplier|
%   + Property |name| replaces |tag|. |tag| will still be accepted
%     for backward compatibility but it is now deprecated.
%
% 26-Jun-2025: FOE 
%   + Added dependent properties to access onsets, durations and amplitudes.
%       This addresses the assymmetry that otherwise will occurr when
%       accessing the ends, i.e.
%           * if these dependent properties were not added, then;
%               To access onsets: cond.cevents.onsets
%               To access end:    cond.ends
%           * With these dependent properties added, now;
%               To access onsets: cond.onsets
%               To access end:    cond.ends
%
% 9-Jul-2025: FOE 
%   + Declared it as a child of identifiableObject. Properties
%   id and name are now inherited. Set methods no longer return
%   the object as output.
%   + Added property nominalSamplingRate
%   + Changing the unit can now also update the events.
%   + Some improved comments.
%

    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
    end

    properties
        cevents table = table('Size',[0 4],...
                        'VariableTypes',{'double','double','double','cell'},...
                        'VariableNames',{'onsets','durations','amplitudes','info'}) ;
        unit(1,:) char {mustBeMember(unit,{'samples','seconds'})} = 'samples';
        timeUnitMultiplier(1,1) int16 = 0;
        nominalSamplingRate(1,1) double = 1; %In Hz
    end
    
    properties (Dependent)
        nEvents %Read only
        onsets %Read only
        durations %Read only
        amplitudes %Read only
        ends %Read only
        eventTime %Read only
        dataLabels %Read only
        tag %DEPRECATED. Use |name| instead.
    end
    
    
    methods
        function obj=condition(varargin)
            %A icnna.data.core.condition class constructor
            %
            % obj=icnna.data.core.condition() creates a default object.
            %
            % obj=icnna.data.core.condition(obj2) acts as a copy constructor
            %
            % 
            % Copyright 2024-25
            % @author: Felipe Orihuela-Espina
            %
            
            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.condition')
                obj=varargin{1};
                return;
            else
                error(['icnna.data.core.condition:condition:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);

            end
        end





        %Gets/Sets
        function val = get.cevents(obj)
        %Retrieves the events of the condition
            val = obj.cevents;
        end
        function set.cevents(obj,val)
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
            if ~ismember('onsets',tmpColNames)
                %Find the first non-mandatory column not yet used and rename
                idx = find(~ismember(tmpColNames,{'onsets','durations','amplitudes','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Column onsets not found. ' ...
                         'Renaming column ' num2str(idx) ' to onsets.'])
                tmpColNames{idx} = 'onsets';
            end
            if ~ismember('durations',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onsets','durations','amplitudes','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Column durations not found. ' ...
                         'Renaming column ' num2str(idx) ' to durations.'])
                tmpColNames{idx} = 'durations';
            end
            if ~ismember('amplitudes',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onsets','durations','amplitudes','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Column amplitudes not found. ' ...
                         'Renaming column ' num2str(idx) ' to amplitudes.'])
                tmpColNames{idx} = 'amplitudes';
            end
            if ~ismember('info',tmpColNames)
                idx = find(~ismember(tmpColNames,{'onsets','durations','amplitudes','info'}),1,'first');
                warning('icnna:data:core:condition:set_cevents:MissingEventInformation',...
                        ['Column info not found. ' ...
                         'Renaming column ' num2str(idx) ' to info.'])
                tmpColNames{idx} = 'info';
            end
            assert(ismember('onsets',tmpColNames) ...
                && ismember('durations',tmpColNames) ...
                && ismember('amplitudes',tmpColNames) ...
                && ismember('info',tmpColNames), ...
                ['icnna:data:core:condition:set_cevents:MissingEventInformation', ...
                'Unable to find one or more mandatory columns (onsets, '...
                'durations, amplitudes, info).']);
            val.Properties.VariableNames = tmpColNames;

            obj.cevents = val;
            obj.cevents = sortrows(obj.cevents,'onsets');
        end

        function val = get.unit(obj)
        %Retrieves the temporal unit, whether 'samples' or 'seconds'
            val = obj.unit;
        end
        function set.unit(obj,val)
        %Sets the temporal unit, whether 'samples' or 'seconds'
            currentUnit = obj.unit; 
            obj.unit = val;
            if ~strcmp(currentUnit,obj.unit)
                %Conversion needed.
                tmpMultiplier = double(obj.timeUnitMultiplier); %typecasting is
                                                      %explicitly needed
                if strcmp(obj.unit,'samples')
                     %Convert from seconds to samples
                    obj.cevents.onsets = round(obj.cevents.onsets * ...
                        obj.nominalSamplingRate * 10^tmpMultiplier);
                    obj.cevents.durations = round(obj.cevents.durations * ...
                        obj.nominalSamplingRate * 10^tmpMultiplier);
                     
                else %Convert from samples to seconds
                    obj.cevents.onsets = obj.cevents.onsets ./ ...
                        (obj.nominalSamplingRate * 10^tmpMultiplier);
                    obj.cevents.durations = obj.cevents.durations ./ ...
                        (obj.nominalSamplingRate * 10^tmpMultiplier);
                     
                end

            end
        end

        function val = get.timeUnitMultiplier(obj)
        %Retrieves the temporal unit multiplier
            val = obj.timeUnitMultiplier;
        end
        function set.timeUnitMultiplier(obj,val)
        %Sets the temporal unit multiplier
            currentMultiplier = obj.timeUnitMultiplier;
            obj.timeUnitMultiplier = val;
            if strcmp(obj.unit,'seconds')
                obj.cevents.onsets = obj.cevents.onsets * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
                obj.cevents.durations = obj.cevents.durations * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
            end
        end


        function val = get.nominalSamplingRate(obj)
        %Retrieves the |nominalSamplingRate| of the condition
            val = obj.nominalSamplingRate;
        end
        function set.nominalSamplingRate(obj,val)
        %Sets the |nominalSamplingRate| of the condition
            if (val == 0)
                warning('icnna:data:core:condition:set_nominalSamplingRate:ParameterValue',...
                    ['A nominal sampling rate equal to 0 can lead to ' ...
                    'incorrect conversions between samples and seconds.'])
            end
            currentSR = obj.nominalSamplingRate;
            obj.nominalSamplingRate = val;
            if strcmp(obj.unit,'samples')
                obj.cevents.onsets = round(obj.cevents.onsets * ...
                    (obj.nominalSamplingRate / currentSR));
                obj.cevents.durations = round(obj.cevents.durations * ...
                    (obj.nominalSamplingRate / currentSR));
            end
        end







        %Dependent properties gets/sets
        function val = get.nEvents(obj)
            %(DEPENDENT) Gets the object |nEvents|
            %
            % The number of events declared in the condition.
            val = size(obj.cevents,1);
        end

        function res = get.onsets(obj)
            %(DEPENDENT) Gets the list of events' |onsets|
            %
            % The list of events' |onsets|
            res = obj.cevents.onsets;
        end

        function res = get.durations(obj)
            %(DEPENDENT) Gets the list of events' |durations|
            %
            % The list of events' |durations|
            res = obj.cevents.durations;
        end

        function res = get.amplitudes(obj)
            %(DEPENDENT) Gets the list of events' |amplitudes|
            %
            % The list of events' |amplitudes|
            res = obj.cevents.amplitudes;
        end

        function res = get.ends(obj)
            %(DEPENDENT) Gets the list of events' |ends|
            %
            % The list of event's |ends| (onset + duration)
            res = obj.cevents.onsets + obj.cevents.durations;
        end

        function res = get.eventTime(obj)
        %(DEPENDENT) Retrieves the events ends (onset + duration)
            res = [obj.cevents.onsets obj.cevents.durations obj.ends];
        end

        function res = get.dataLabels(obj)
        %(DEPENDENT) Retrieves the variable names of the cevents table as a string array
        %
        %If you need the data labels as a cell array use:
        %       obj.cevents.Properties.VariableNames
            res = string(obj.cevents.Properties.VariableNames);
        end


        function val = get.tag(obj)
        %Retrieves the |tag| (|name|) of the condition
        %
        %The use of |tag| is now deprecated.
            val = obj.name;
        end
        function set.tag(obj,val)
        %Sets the |tag| (|name|) of the condition
        %
        %The use of |tag| is now deprecated.
            warning('icnna:data:core:condition:deprecatedProperty',...
                    'The use of |tag| is now deprecated. See |name|.')
            obj.name = val;
        end




    end


end
