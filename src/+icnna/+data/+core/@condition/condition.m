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
% Onsets and durations may be associated with real time stamps or
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
% This class is somewhat analogous to @icnna.data.snirf.stim but;
% 1) This is not attached to the evolution of the .snirf format
% 2) This provides some additional functionality over @icnna.data.snirf.stim
%   e.g. includes eventInfo
%
%
% Switching time units (i.e. from samples to seconds) and back may
% result in rounding errors.
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Immutable instance property)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%       
%   .flagSRInitialized - logical. Private, Transient. Default false.
%       Guards |set.nominalSamplingRate| against spuriously rescaling
%       event onset and duration values during MATLAB deserialization.
%       See @icnna.data.core.timeline.flagSRInitialized for the full
%       background and mechanism - both classes carry this flag for the
%       same reason.
%       This property has no public getter or setter and
%       is not visible to users of the class.
%      
%   -- Inherited properties
%   .id - uint32. default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is 'condition0001'.
%       A name for the condition. 
%
%   -- Public properties
%   .cevents - struct[kx1]. List of condition events.
%         Each struct is an event with the following fields;
%          + onsets - double An event onsets
%          + durations - double An event durations,
%          + amplitudes  - double An event amplitudes or magnitudes,
%          + info - cell. An event information. Whatever the user
%                   wants to store associated to the condition event.
%           NOTE 1: cevents is ALWAYS sort by onsets,
%           NOTE 2: k is the number of events in the condition,
%
%       Additional fields may be added, but the 4 fields above
%       ought to be present and be named 'onsets', 'durations', 'amplitudes'
%       and 'info' respectively. Although, the order does not matter in
%       principle, if any of these four fields are missing when setting
%       up the value, a default order will be assumed and the field will
%       be renamed accordingly.
%
%       Within a condition events can overlap. Control of overlapping
%       occurs in class @icnna.data.core.timeline. This is a sharp
%       distinction with timeline conditions until ICNNA version 1.2.1
%       where the conditions were not separate objects but structs
%       stored in a cell array within class @timeline and when event
%       overlap within timeline was not permitted. Now, this is controlled
%       by the exclusory behaviour of the class @icnna.data.core.timeline,
%       but it is in principle permitted.
%
%
%   .unit - Char array. 'samples' (Default) or 'seconds'.
%       The temporal unit of measure for the events.
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
%   .nEvents - Read only. Number of events. Number of elements in |cevents|
%   .onsets  - Read only. Double array with the list of events' onsets.
%   .durations - Read only. Double array with the list of events' durations.
%   .amplitudes - Read only. Double array with the list of events' amplitudes.
%   .ends  - Read only. Double array with the list of events' ends.
%       obj.onsets + obj.durations
%   .eventTimes - Read only. Double array of [onsets durations [ends]]
%   .dataLabels - Read only. Equivalent to accessing the fields
%       names of the cevents struct array but typecasted to a string array.
%   .tag - *DEPRECATED* since v1.3.1. Use |name| instead.
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
%   + Adapted to reflect the new handle status e.g. no object return on setters.
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
%
% -- ICNNA v1.4.0
%
% 5-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Class version - Updated to 1.2
%	+ Method copy() removed.
%   + Refactored code for property cevents from a table to a struct array
%   for improved performance.
%	+ Improved some comments with the help of chatGPT
%	+ Bug fixed; derived property eventTime should be eventTimes.
%   + Deprecated property |tag| is now hidden as per best practices.
%
%
% 6-Dec-2025: FOE
%	+ Further improved some comments for consistency.
%
%
% -- ICNNA v1.4.1
%
% 17-Mar-2026: FOE
%	+ Bug fixed; Method set.nominalSamplingRate was still using the tabular
%   syntax for cevents from object version 1.1.
%
% 22-May-2026: FOE
%   + Enhanced performance for set.timeUnitMultiplier
%   + Enhanced performance for set.nominalSamplingRate
%
% 25-May-2026: FOE
%   + Bug fixed: Enforced positive integers onsets and non-negative
%   durations of events when unit is 'samples' and non-negative onsets
%   non-negative durations of events when unit is 'seconds'.
%   + Enhanced performance for set.unit
%
%       
% 31-May-2026: FOE
%   + Bug fixed: Added private transient flag |flagSRInitialized| and
%     updated |set.nominalSamplingRate| to guard against spurious
%     rescaling of event onset/duration values during MATLAB
%     deserialization. See @icnna.data.core.timeline log entry of the
%     same date for the full background. The fix is symmetric across
%     both classes: @condition and @timeline each carry their own
%     |flagSRInitialized| flag for the same reason.
%      
%
% -- ICNNA v1.4.2
%
% 19-Jun-2026: FOE
%
% + Improvement: Silent typecasting now yields warning.
%
% 23-Jun-2026: FOE
%
% + Improvement: Property |timeUnitMultiplier| is now verified to be non NaN.
% + Improvement: Property |nominalSamplingRate| is now verified to be non NaN.
%       HOWEVER watch out!! The validator 'mustBeNonNan' is NOT
%       sufficient to do the job for integear types as the validator
%       will be called only after any implicit type cast, e.g. int16(NaN), i.e.
%       the real question the validator is asking is whether
% 
%           "Is the stored value NaN?"
%
%       Since in the particular case of uint32, this can never
%       be the case, then the validator fails to do its job as
%       by then it is too late because the input has already
%       been converted to 0. This is not a problem for properties
%       of type double though; In case of double, the typecasting
%       double(NaN) still yields NaN. Moreover, even if one tries to check
%       for isnan "manually" in the set_id method, than will still
%       occur AFTER the implicit typecasting, so again too late.
%       So in order to verify that the input is not NaN (and hence
%       no side effects e.g. setting the id to 0 inadvertently),
%       I need to check for NaN in the intercepted subasgn method.
%       Nevertheless, it is good to keep the validator (even if
%       useless) for the sake of clarity.
%
% 1-Jul-2026: FOE
%	+ Deprecated warning id changed from:
%
%       'icnna:data:core:condition:deprecatedProperty'
%       
%   to
%
%       'icnna:data:core:condition:tag:Deprecated'
%
%
% -- ICNNA v1.4.2.1
%
% 9-Jul-2026: FOE
%   + Data integrity fix: |classVersion| changed from Constant
%   (non-serializable) to immutable (serializable, but still
%   read-only). The .classVersion() accessor method and all call
%   site remain unchanged. Class version also remains 1.2.
%
%   NOTE: MATLAB does NOT serialize Constant properties, so on reload
%     an old file, a loaded (not freshly created) object would
%     not recovered the value of such property when the object was saved
%     but instead, will load the current class default, e.g. the
%     current class version. This silently defeats runtime versions
%     guards and can potentially lead to inconsistencies and ultimately
%     errors. Instead, immutable properties ARE serialized yet they
%     remain read-only, hence they will recover properly upon loading
%     and still remain safe against tampering and forging attempts.
%
% 10-Jul-2026: FOE
%   Bug fixed: Interception of subsasgn now works for calls from
%     nested structures e.g. myConds(k).unit.
%   
%




    properties (SetAccess = immutable, GetAccess = private)
        classVersion = '1.2'; %Read-only. Object's class version.
    end

    properties (Access=private, Transient)
        % This flag guards set.nominalSamplingRate against spuriously
        % rescaling condition events during MATLAB deserialization.
        % It is Transient so it is never written to or read from .mat
        % files - it resets to false on every construction and every
        % load from disk. See the Private properties section of the
        % class header and set.nominalSamplingRate for full rationale.
        flagSRInitialized(1,1) logical = false;
    end    

    properties
        % The cevents struct array holds the event data for the condition.
        % Each struct represents a single event, with scalar fields:
        %   - onsets: double. Event onset time (scalar)
        %   - durations: double. Event duration (scalar)
        %   - amplitudes: double. Event amplitude (scalar)
        %   - info: cell. Event metadata (cell array)
        cevents struct = struct( ...
            'onsets', [], ...
            'durations', [], ...
            'amplitudes', [], ...
            'info', {} );

        unit(1,:) char {mustBeMember(unit,{'samples','seconds'})} = 'samples'; % Unit of measure: 'samples' or 'seconds'
        timeUnitMultiplier(1,1) int16 {mustBeNonNan} = 0; % Multiplier for time precision (e.g., milliseconds = -3, or microseconds = -6)
        nominalSamplingRate(1,1) double {mustBeNonNan} = 1; %Nominal sampling rate in Hz (samples per second)
    end
    
    properties (Dependent)
        nEvents %Read only. Number of events
        onsets %Read only. Column vector of onsets
        durations %Read only. Column vector of durations
        amplitudes %Read only. Column vector of amplitudes
        ends %Read only. Column vector of event ends.
        eventTimes %Read only. Array of [onsets, durations, ends]
        dataLabels %Read only. Events fields
    end
    properties (Dependent, Hidden)
        tag %DEPRECATED. Use |name| instead.
    end
    
    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj = condition(varargin)
            %Constructor for class @icnna.data.core.condition
            %
            % obj=icnna.data.core.condition() creates a default object.
            % obj=icnna.data.core.condition(obj2) acts as a copy constructor
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
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
        %Retrieves the events of the condition
        function res = get.cevents(obj)
            % Getter for |cevents|:
            %   Returns the current value of the |cevents| property.
            %
            % Usage:
            %   res = obj.cevents;  % Retrieve event data
            %
            %% Output
            % res - struct[]
            %   The list of events (occurrences) of this condition.
            %   Each element of |cevents| contains data for a single event,
            %   with scalar fields:
            %   - onsets: double. Event onset time
            %   - durations: double. Event duration
            %   - amplitudes: double. Event amplitude
            %   - info: cell array. Event-specific info.
            %
            res = obj.cevents;
        end

        %Sets the events of the conditions
        function obj = set.cevents(obj,val)
            % Setter for |cevents|:
            %   Sets the |cevents| property to a new value. The input
            %   must be a struct array, where
            %
            %   Throws an error if the input is not a valid struct array
            %   or is missing any of the required fields.
            %   The input structs must have scalar values for the fields
            %   onsets, durations, and amplitudes.
            %
            % Usage:
            %   newEvents = [struct('onsets', 1, 'durations', 2, 'amplitudes', 1, 'info', {'Event1'}), ...
            %                struct('onsets', 4, 'durations', 3, 'amplitudes', 2, 'info', {2})];
            %   obj.cevents = newEvents;  % Assign new event data
            %
            % Error handling:
            %   - Input must be a struct array
            %   - Each struct must contain the required fields: onsets,
            %       durations, amplitudes, info
            %   - onsets, durations, and amplitudes must be scalars
            %
            %% Input parameters
            %
            % val - struct[]
            %   The list of condition events as a struct array.
            %   Each struct of the array contains the fields:
            %   - onsets: double. Scalar value for event onset
            %   - durations: double. Scalar value for event duration
            %   - amplitudes: double. Scalar value for event amplitude
            %   - info: Cell array for event info
            %
            %% Output
            %
            % obj - @icnna.data.core.condition
            %   The updated object
            %

            % ---- Validate input --------------------------------------
            % Ensure the input is a struct array with the correct fields.
            if ~isstruct(val)
                error('icnna:data:core:condition:set_cevents:InvalidValue',...
                      'Condition events is expected to be a struct array.');
            end
            % Ensure that each struct in the array has the necessary fields
            requiredFields = {'onsets','durations','amplitudes','info'};
            for i = 1:numel(val)
                if ~all(isfield(val(i), requiredFields))
                    error('icnna:data:core:condition:set_cevents:MissingFields', ...
                        'Each event struct must contain the fields: onsets, durations, amplitudes, info.');
                end
                
                % Check that the fields contain valid data
                if ~isscalar(val(i).onsets)
                    error('icnna:data:core:condition:set_cevents:InvalidOnsets', ...
                        'The "onsets" field must be a scalar value.');
                end
                if ~isscalar(val(i).durations)
                    error('icnna:data:core:condition:set_cevents:InvalidDurations', ...
                        'The "durations" field must be a scalar value.');
                end
                if ~isscalar(val(i).amplitudes)
                    error('icnna:data:core:condition:set_cevents:InvalidAmplitudes', ...
                        'The "amplitudes" field must be a scalar value.');
                end
            end

            % Assign the validated value to the cevents property
            [~, idx] = sort([val.onsets]);
            obj.cevents = val(idx);
        end

        %Retrieves the temporal |unit|, whether 'samples' or 'seconds'
        function res = get.unit(obj)
            % Getter for |unit|:
            %   Returns the current unit of measure for the events. It can
            % be either:
            %   - 'samples': Time is measured in samples
            %   - 'seconds': Time is measured in seconds.
            %
            % Usage:
            %   res = obj.unit;  % Get the current unit
            %
            %% Output
            % res - string
            %   The current unit of measure for the events
            %
            res = obj.unit;
        end
        %Sets the temporal |unit|, whether 'samples' or 'seconds'
        function obj = set.unit(obj,val)
            % Setter for |unit|:
            %   Sets the |unit| property. It can be either:
            %   - 'samples': Time is measured in samples
            %   - 'seconds': Time is measured in seconds.
            %
            % If the unit is changed, the event onsets and durations
            % are automatically converted based on the nominal sampling
            % rate.
            %   
            % Usage:
            %   obj.unit = 'seconds';  % Set unit to 'seconds'
            %
            %% Input parameters
            %
            % val - char[]
            %   The new unit for temporal samples ('samples'|'seconds').
            %
            %% Output
            %
            % obj - @icnna.data.core.condition
            %   The updated object
            %

            currentUnit = obj.unit; % Store the current unit
            obj.unit    = val;      % Assign the new unit value

            % If the unit is changing, perform the conversion.
            if ~strcmp(currentUnit,obj.unit) && ~isempty(obj.cevents)
                %Conversion needed between units (samples <-> seconds)
                tmpMultiplier = double(obj.timeUnitMultiplier); %typecasting is
                                                      %explicitly needed
                if strcmp(obj.unit,'samples')
                     %Convert from seconds to samples
                    tmpOnsets = round([obj.cevents.onsets] * ...
                        obj.nominalSamplingRate * 10^tmpMultiplier);
                    tmpOnsets = max(1, tmpOnsets); %Ensure all onsets are
                                                   %positive integers.
                                                   % Samples are 1-based; onset=0 is invalid.
                    tmpDurations = round([obj.cevents.durations] * ...
                        obj.nominalSamplingRate * 10^tmpMultiplier);
                    tmpDurations = max(0, tmpDurations); %Ensure all
                                                   %durations are
                                                   %non-negative integers.

                else %Convert from samples to seconds
                    tmpOnsets = [obj.cevents.onsets] ./ ...
                        (obj.nominalSamplingRate * 10^tmpMultiplier);
                    tmpOnsets = max(0, tmpOnsets); %Ensure all onsets are
                                                    %non-negative.
                    tmpDurations = [obj.cevents.durations] ./ ...
                        (obj.nominalSamplingRate * 10^tmpMultiplier);
                    tmpDurations = max(0, tmpDurations); %Ensure all
                                                   %durations are
                                                   %non-negative.

                end
                %23-May-2026: FOE
                % DEPRECATED CODE
                % for iEv = 1:numel(obj.cevents)
                %     obj.cevents(iEv).onsets    = tmpOnsets(iEv);
                %     obj.cevents(iEv).durations = tmpDurations(iEv);
                % end
                c = num2cell(tmpOnsets);
                [obj.cevents.onsets] = c{:};
                c = num2cell(tmpDurations);
                [obj.cevents.durations] = c{:};
            end
        end


        %Retrieves the temporal unit multiplier
        function res = get.timeUnitMultiplier(obj)
            % Getter for |timeUnitMultiplier|:
            %   Returns the current value of the time unit multiplier,
            %   which determines the temporal precision (e.g.
            %   milliseconds= -3, microseconds = -6).
            %
            % Usage:
            %   res = obj.timeUnitMultiplier;  % Get the current multiplier
            %
            %% Output
            % res - int16
            %   The time unit multiplier.
            %
            res = obj.timeUnitMultiplier;
        end
        %Sets the temporal unit multiplier
        function obj = set.timeUnitMultiplier(obj,val)
            % Setter for |timeUnitMultiplier|:
            %   Sets the |timeUnitMultiplier| property.
            % 
            % If the multiplier is changed, the event onsets and durations
            % are adjusted according to the difference in precision.
            %   
            % Usage:
            %   obj.timeUnitMultiplier = -3;  % Set the multiplier to -3 (e.g., milliseconds)
            %
            %% Input parameters
            %
            % val - int16
            %   The new time unit multiplier.
            %
            %% Output
            %
            % obj - @icnna.data.core.condition
            %   The updated object
            %

            currentMultiplier = obj.timeUnitMultiplier; % Store the current multiplier
            obj.timeUnitMultiplier = val; % Assign the new multiplier value
            %If the unit is 'seconds' and the multiplier changes, adjust
            % the onsets and durations
            if strcmp(obj.unit,'seconds') && obj.timeUnitMultiplier ~= currentMultiplier
                % for iEv = 1:numel(obj.cevents)
                %     % If the multiplier is changing, adjust onsets and
                %     % durations by the difference in powers of 10
                %     obj.cevents(iEv).onsets = obj.cevents(iEv).onsets * ...
                %         10^double(currentMultiplier - obj.timeUnitMultiplier);
                %     obj.cevents(iEv).durations = obj.cevents(iEv).durations * ...
                %         10^double(currentMultiplier - obj.timeUnitMultiplier);
                % end
                scale = 10^double(currentMultiplier - obj.timeUnitMultiplier);
                newOnsets    = num2cell([obj.cevents.onsets]    * scale);
                newDurations = num2cell([obj.cevents.durations] * scale);
                [obj.cevents.onsets]    = deal(newOnsets{:});
                [obj.cevents.durations] = deal(newDurations{:});               
            end
        end


        %Retrieves the |nominalSamplingRate| of the condition
        function res = get.nominalSamplingRate(obj)
            % Getter for |nominalSamplingRate|:
            %   Returns the current nominal sampling rate in Hz
            %   (samples per second).
            %
            % Usage:
            %   res = obj.nominalSamplingRate;  % Get the current sampling rate in Hz
            %
            %% Output
            % res - double
            %   The nominal sampling rate in Hz.
            %
            res = obj.nominalSamplingRate;
        end
        %Sets the |nominalSamplingRate| of the condition
        function obj = set.nominalSamplingRate(obj,val)
            % Setter for |nominalSamplingRate|:
            %   Sets the nominal sampling rate in Hz. If the |unit| is
            % 'samples', it updates the |cevents| onsets and durations
            % based on the ratio of the new to old sampling rates.
            %
            % Usage:
            %   obj.nominalSamplingRate = 2;  % Set the new sampling rate to 2 Hz
            %
            %% Remarks
            %
            % Rescaling of events is skipped on the first invocation
            % after object construction or after loading from disk,
            % controlled by the private transient flag
            % |flagSRInitialized| (see class header). This prevents
            % MATLAB's deserialization mechanism from applying the
            % rescaling spuriously when restoring a saved object from
            % a .mat file.
            %
            %% Input parameters
            %
            % val - double
            %   The new nominal sampling rate in Hz.
            %
            %% Output
            %
            % obj - @icnna.data.core.condition
            %   The updated object
            %

            if (val == 0)
                warning('icnna:data:core:condition:set_nominalSamplingRate:ParameterValue',...
                    ['A nominal sampling rate equal to 0 can lead to ' ...
                    'incorrect conversions between samples and seconds.'])
            end

            currentSR = obj.nominalSamplingRate; % Store the current nominal sampling rate
            obj.nominalSamplingRate = val; % Assign the new sampling rate value
            % If the unit is 'samples', adjust onsets and durations
            % based on the sampling rate ratio
            % Rescale events only if the rate was previously established.
            % On the first call (flagSRInitialized==false) no rescaling
            % is appropriate — see class header for full rationale.
            if strcmp(obj.unit,'samples') && val ~= currentSR ...
                                          && obj.flagSRInitialized
                % Adjust onsets and durations by the ratio of the new
                % sampling rate to the old one
                % for iEv = 1:numel(obj.cevents)
                %     obj.cevents(iEv).onsets = round([obj.cevents(iEv).onsets] * ...
                %                         (obj.nominalSamplingRate / currentSR));
                %     obj.cevents(iEv).durations = round([obj.cevents(iEv).durations] * ...
                %                         (obj.nominalSamplingRate / currentSR));
                % end
                scale        = obj.nominalSamplingRate / currentSR;
                newOnsets    = num2cell(round([obj.cevents.onsets]    * scale));
                newDurations = num2cell(round([obj.cevents.durations] * scale));
                [obj.cevents.onsets]    = deal(newOnsets{:});
                [obj.cevents.durations] = deal(newDurations{:});
                
            end
            obj.flagSRInitialized = true;
        end







        %Dependent properties gets/sets
        %Returns the number of events in cevents
        function res = get.nEvents(obj)
            %(DEPENDENT) Gets the object |nEvents|
            %
            % The number of events declared in the condition.
            %
            % Usage:
            %   res = obj.nEvents;  % Get the number of events in cevents
            %
            %% Output
            % res - double
            %   The number of events in the condition.
            %
            res = numel(obj.cevents);
        end

        function res = get.onsets(obj)
            %(DEPENDENT) Gets the list of events' |onsets|
            %
            % The list of events' |onsets|
            %
            % Usage:
            %   res = obj.onsets;  % Get a column vector of onsets
            %
            %% Output
            % res - double[] (Column vector)
            %   List of events' onsets
            %
            res = [obj.cevents.onsets]';
        end

        function res = get.durations(obj)
            %(DEPENDENT) Gets the list of events' |durations|
            %
            % The list of events' |durations|
            %
            % Usage:
            %   res = obj.durations;  % Get a column vector of event durations
            %
            %% Output
            % res - double[] (Column vector)
            %   List of events' durations
            %
            res = [obj.cevents.durations]';
        end

        function res = get.amplitudes(obj)
            %(DEPENDENT) Gets the list of events' |amplitudes|
            %
            % The list of events' |amplitudes|
            %
            % Usage:
            %   res = obj.amplitudes;  % Get a column vector of event amplitudes
            %
            %% Output
            % res - double[] (Column vector)
            %   List of events' amplitudes
            %
            res = [obj.cevents.amplitudes]';
        end

        function res = get.ends(obj)
            %(DEPENDENT) Gets the list of events' |ends|
            %
            % The list of events' |ends| (onsets + durations)
            %
            % Usage:
            %   res = obj.ends;  % Get a column vector of event end times
            %
            %% Output
            % res - double[] (Column vector)
            %   List of events' ends
            %
            res = [obj.cevents.onsets]' + [obj.cevents.durations]';
        end

        function res = get.eventTimes(obj)
            %(DEPENDENT) Retrieves the events times
            % Returns a matrix of event times where each row contains:
            %   [onset, duration, end]
            % The end time is calculated as the onset + duration.
            %
            % Usage:
            %   res = obj.eventTime;  % Get a matrix of event times (onset, duration, end)
            %
            %% Output
            % res - double[|nEvents|x3]
            %   List of events' time triplets [onset, duration, end].
            %
            res = [[obj.cevents.onsets]' [obj.cevents.durations]' obj.ends];
        end

        function res = get.dataLabels(obj)
            %(DEPENDENT) Retrieves the fields names of the |condEvents|
            %
            % Usage:
            %   res = obj.dataLabels;  % Get a string array of the |condEvents|
            %
            %% Output
            % res - string[]
            %   Fields names of the |condEvents|
            %
            res = string(fieldnames(obj.cevents))';
        end


        function res = get.tag(obj)
            %(*DEPRECATED*) Retrieves the |tag| (|name|) of the condition
            %
            %The use of |tag| is now deprecated. Please use |name| instead.
            %
            % Usage:
            %   res = obj.tag;  % Get the value of the deprecated `tag` (which is the name)
            %
            %% Output
            % res - char[]
            %   The object |name|
            %
            warning('icnna:data:core:condition:tag:Deprecated',...
                    'The use of |tag| is now deprecated. Please use |name| instead.')
            res = obj.name;
        end
        function obj = set.tag(obj,val)
            %(*DEPRECATED*) Sets the |tag| (|name|) of the condition
            %
            %The use of |tag| is now deprecated. Please use |name| instead.
            %
            % Usage:
            %   obj.tag = 'newName';  % Set the |name|
            %
            %% Input parameters
            %
            % val - char[]
            %   The object's new name.
            %
            %% Output
            %
            % obj - @icnna.data.core.condition
            %   The updated object
            %
            warning('icnna:data:core:condition:tag:Deprecated',...
                    'The use of |tag| is now deprecated. Please use |name| instead.')
            obj.name = val;
        end




        %Catch the silent typecastings by intercepting the assignment
        function obj = subsasgn(obj, s, val)
            % Intercept ONLY simple .property assignments to warn on implicit typecast
            %
            %
            %On a regular call, e.g. myCond.id, s is a struct with 2 fields
            %
            %   .type - (char) Valued '.'
            %   .subs - (char) Valued 'id'
            %
            % However, when the call is from some nested structure,
            % e.g. conds(1).unit, then s becomes a struct array
            % with those two fields;
            %
            %   s(1).type - (char) Valued '()'
            %   s(1).subs - (char) Valued '1'
            %   s(2).type - (char) Valued '.'
            %   s(2).subs - (char) Valued 'unit'
            %
            % That is the search for the field below, that looks for a property
            % name will only work if the type is '.' otherwise
            % the search will fail (not produce an empty output, but
            % actually fail!) - hence when the number of elements in s>1
            % then we should just pass it along.
            if numel(s) == 1 && strcmp(s.type, '.')
                switch s.subs
                    case 'flagSRInitialized'
                        if ~islogical(val)
                            warning('icnna:data:core:condition:set_flagSRInitialized:ImplicitTypecast', ...
                                ['Value assigned to |' s.subs '| is not logical. ' ...
                                'MATLAB will attempt implicit typecasting.']);
                        end

                    case 'cevents'
                        if ~isstruct(val)
                            warning('icnna:data:core:condition:set_cevents:ImplicitTypecast', ...
                                ['Value assigned to |' s.subs '| is not struct. ' ...
                                'MATLAB will attempt implicit typecasting.']);
                        end

                    case 'unit'
                        if ~ischar(val)
                            warning('icnna:data:core:condition:set_unit:ImplicitTypecast', ...
                                ['Value assigned to |' s.subs '| is not char. ' ...
                                'MATLAB will attempt implicit typecasting.']);
                        end

                    case 'timeUnitMultiplier'
                        if isnumeric(val) && isscalar(val)
                            % Safe to call numeric functions here
                            if isnan(val)
                                error('icnna:data:core:condition:set_timeUnitMultiplier:mustBeNonNan', ...
                                    ['NaN is not a valid value for |' s.subs '|.']);
                            elseif val ~= floor(val)
                                warning('icnna:data:core:condition:set_timeUnitMultiplier:ImplicitTypecast', ... 
                                    ['Value assigned to |' s.subs '| is not integer. ' ...
                                    'MATLAB will attempt implicit typecasting.']);
                            end
                        else
                            % Not numeric or not scalar
                            warning('icnna:data:core:condition:set_timeUnitMultiplier:ImplicitTypecast', ... 
                                ['Value assigned to |' s.subs '| is not numeric or not scalar. ' ...
                                'MATLAB will attempt implicit typecasting.']);
                        end

                    case 'nominalSamplingRate'
                        if ~(isnumeric(val) && isscalar(val))
                            warning('icnna:data:core:condition:set_nominalSamplingRate:ImplicitTypecast', ... 
                                ['Value assigned to |' s.subs '| is not numeric or not scalar. ' ...
                                'MATLAB will attempt implicit typecasting.']);
                        end


                end

                %Call the appropriate subsagn
                tmp = metaclass(obj);
                idx = find(ismember({tmp.PropertyList.Name}, s.subs), 1); %Only find first match
                if ~isempty(idx)
                    classStr = tmp.PropertyList(idx).DefiningClass.Name;
                    if strcmp(classStr,class(obj))
                        % Property defined here. Just pass it along
                        obj = builtin('subsasgn', obj, s, val);
                    else
                        % Property inherited. Call the superclass method for property assignment
                        obj = eval(['subsasgn@' classStr '(obj, s, val)']);
                    end
                else
                    obj = builtin('subsasgn', obj, s, val);
                end
            else %Nested call (s struct has more than 1 element)
                    obj = builtin('subsasgn', obj, s, val);
            end
        end

    end



end
