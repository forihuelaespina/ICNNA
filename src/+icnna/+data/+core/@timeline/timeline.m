classdef timeline < icnna.data.core.identifiableObject
% icnna.data.core.timeline - A timeline for recording of events.
% 
% This class supersedes class @timeline
%
% A timeline holds a list of @icnna.data.core.condition to keep track
% of the occurrence of events at a certain times of the experiment. An
% example of a typical event might be the starting or finishing of a
% block when some experimental condition is being administered.
%
%
%% Samples vs Timestamps
%
% @icnna.data.core.timeline supports operation either in samples or
%seconds (or any scaling of these e.g. milliseconds). However, all
%conditions within the timeline have the same units, i.e. a timeline
%cannot have some conditions in 'samples' and some in 'seconds' at
%the same time. Notwithstanding, the user can switch between these
%two temporal representations (see |unit|). 
%
% Similarly, when operating in 'seconds', a timeline supports operation
%at different scales (see |timeUnitMultiplier|), but again, all
%conditions within the timeline will have the same |timeUnitMultiplier|.
% 
% ICNNA versions earlier than v1.2.2 only operate in samples.
%
% When timestamps are not be available this class uses the nominal
% sampling rate to automatically generate timestamps.
%
%% Conditions as experimental stimulus or factors
%
%For each experimental stimulus type you define an @icnna.data.core.condition.
%Every @icnna.data.core.condition represent a different stimulus type.
% A @icnna.data.core.timeline support any number of different
% @icnna.data.core.condition (other than memory limits), each identified
% by its |id| and |name|. Within a timeline, all |id| and |name| ought to
% be unique.
% 
% @li All condition |id| and |name| ought to be unique,
% @li It is not permitted that a |name| is an empty string,
% @li Condition names are case sensitive i.e. 'A' is not the same as 'a'
%
%
%% Exclusory behaviour
%
%Conditions may be exclusory (default behaviour) or not.
%Exclusory conditions are not allow to have overlapping events.
%Non-exclusory conditions can have overlapping events.
%Exclusory state is store in a pairwise fashion, which allow
%for flexibility on determining which pairs of conditions are
%exclusory independent of their exclusory relations with the
%rest of conditions. Marks of different events
%represented by different conditions might occur at the same time,
%but two events corresponding to the same condition can not overlap
%in time.
%
%% Properties
%
%   -- Private properties
%   .classVersion - Char array. (Read only. Constant)
%       The class version of the object
%       This is separate from the superclass' own |classVersion|.
%
%   -- Inherited properties
%   .id - uint32. Default is 1.
%       A numerical identifier.
%   .name - (Since v1.3.1) Char array. By default is 'timeline0001'.
%       A name for the timeline. 
%
%   -- Public properties
%   .startTime - datetime. A reference absolute start time.
%         The default start time is the object creation time.
%           Up to ICNNA version 1.3.0, the type was datenum.
%   .timestamps - A vector of .lengthx1 timestamps in seconds
%         relative to the |startTime|. Note that the initial timestamp
%         does not have to be 0. When not available, timestamps will
%         automatically generated at 1Hz. If not provided, the nominal
%         sampling rate to automatically generate timestamps.
%
%       +==============================================+
%       | Timestamps is ALWAYS in 'seconds' units (or  |
%       | the fractional time in |timeUnitMultiplier|) |
%       | even if the timeline |unit| is samples.      |
%       +==============================================+
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
%   .unit - (Since v1.3.1) Char array. 'samples' (Default) or 'seconds'.
%       In switching between 'samples' and 'seconds' or the other
%       way around, the |nominalSamplingRate| is used to convert
%       the |cevents| onsets and durations.
%       Also, when unit is 'samples', the timeUnitMultiplier is
%       transiently ignored. But when unit is 'seconds', the
%       timeUnitMultiplier is also considered.
%
%   .timeUnitMultiplier - (Since v1.3.1) Scalar (int16).Scalar (int16). Default 0.
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
%       +==============================================+
%       | Watch out! Updating the |timeUnitMultiplier| |
%       | automatically updates the timestamps as well |
%       | as the events.                               |
%       +==============================================+
%
%
%
%  -- Set access private properties
%
%   .conditions - (Since v1.3.1) icnna.data.core.condition[kx1]
%       List of conditions in the timeline.
%       Both id and names ought to be unique.
%
%   .exclusory - Array of logical. A matrix of pairwise exclusory states.
%	  exclusory(condA,condB)= icnna.data.core.timeline.CONDITIONS_NON_EXCLUSORY => Non exclusory behaviour
%	  exclusory(condA,condB)= icnna.data.core.timeline.CONDITIONS_EXCLUSORY => Exclusory behaviour
%
%       exclusory(condA,condA) indicates whether a condition is allowed
%       to have self-overlapping events (non-exclusory) or not (exclusory).
%
%       From ICNNA version 1.2.2, a condition can have overlapping
%       events with itself. This is controlled with the main diagonal
%       of .exclusory.
%
%% Dependent properties
%
%   .length - Int. Read-only. The experiment duration (in samples). Length of the
%       timestamps property.
%   .nConditions - Int. Read-only. Number of conditions.
%       Number of entries in the private property |conds| property.
%   .averageSamplingRate - Double. Read-only. Average sampling rate. This is calculated
%       on the fly from the timestamps and use in many operations
%       e.g. getAvgTaskTime. This is different from the nominal
%       sampling rate property.
%   .conditions - Array of icnna.data.core.conditions. Read-only. 
%       All conditions within a timeline ought to have distinct |id| and
%       distinct |name|
%       Conditions are sorted by |id|
%       Since v1.3.1 this became a derived property.
%   .nTotalEvents - Int. Read-only. Number of total events in the timeline across
%       conditions.
%       Available since v1.3.1 
%   .condEvents - struct[]. Read-only. A list of all the events across
%       the conditions in the timeline.
%       Somewhat akin to property |cevents| for each condition, but this
%       is enriched with the condition's id and name.
%       Available since v1.3.1 
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('icnna.data.core.timeline') for a list of methods
% 
%
% Copyright 2025
% @author: Felipe Orihuela-Espina
%
% See also assertInvariant
%




%% Log
%
%   + Class available since ICNNA v1.2.3
%
% 11-Apr-2024: FOE
%   + File and class created. Reused some code from predecessor class
%   @timeline. Class is still unfinished (and not documented)
%
% 12-Apr-2025: FOE
%   + Continued working on the class.
%   + Timeline are now also identifiable objects.
%   + Updated the property condition from a cell array of struct to
%       an array of icnna.data.core.condition.
%   + Nominal sampling rate is now valued 0 Hz by default to be consitent
%       with the derived real sampling rate which will be 0 when a timeline
%       is initialized.
%   + Length of the timeline is now a dependent property; simply the
%   length of the timestamps.
%   + exclusory attribute is now bool.
%   + Added two constants to provide support for maintaining the exclusory
%   behaviour; CONDITIONS_EXCLUSORY and CONDITIONS_NON_EXCLUSORY
%   + Modified the class constructors;
%       * Removed the constructor permitting declaring a condition
%       * Substituted the constructor that used only the length
%       for another that uses the length and the nominalSamplingRate.
%   + Added methods findCondition and cropOrRemoveEvents
%
%   PENDING: set.conditions not yet working properly as this does not
%       update the exclusory table accordingly.
%
%
% -- ICNNA v1.3.1
%
% 25-Jun-2025: FOE 
%   + Some improved comments.
%   + Class version - Updated to 1.1
%   + Property id has changed type from double to uint32
%   + Property |startTime| has changed type from datenum to datetime
%   + Added properties |unit| and |timeUnitMultiplier|
%
% 26-Jun-2025: FOE 
%   + Conditions are now sorted by |id|.
%   + Bug fixed. Syntax of assert when setting |conditions| was incorrect.
%   + Added get/set methods for |exclusory|
%
% 28-Jun-2025: FOE 
%   + Replace internal representation of conditions from a collection
%   of condition objects, to 1 dictionary to hold the condition id and
%   names and 1 table to contain the events. If the user wants to
%   retrieve the |conditions| he still get an array of conditions, but
%   these are now build on demand. That is, this is now a dependent
%   property, with the "real" properties now being hidden (under private
%   access). But internally, I can manipulate
%   events at timeline level much faster, plus maintaining consistency
%   of units and timeUnitMultiplier is easier.
%   + Removed constants CONDITIONS_EXCLUSORY and CONDITIONS_NON_EXCLUSORY
%
% 28-Jun-2025: FOE 
%   + Added derived read-only properties nTotalEvents and condEvents
%   + Improved some comments.
%
% 8-Jul-2025: FOE
%   + Warning for crop or removed events "moved" to cropOrRemoveEvents from
%   set_timestamps.
%   + Change of unit now work over .cevents property instead over
%   the list of conditions.
%
%
% 9-Jul-2025: FOE 
%   + Declared it as a child of identifiableObject. Properties
%   id and name are now inherited. Set methods no longer return
%   the object as output.
%   + Some improved comments.
%   + In method get.conditions, added support for new property
%   |nominalSamplingRate| for the @icnna.data.core.condition objects.
%
%
% 11-Jul-2025: FOE 
%   + Replace internal representation of conds from a dictionary to
%   a table holding the condition id and names.
%
% 4-Dec-2025: FOE 
%   + Bug fixed: Typecasting constructor from @timeline was not
%   correctly handling the case where the timeline had no conditions.
%
% -- ICNNA v1.4.0
%
% 5/6-Dec-2025: FOE
%   + Revert back to regular value (non-handle) class.
%	+ Class version - Updated to 1.2
%	+ Change .conds to .conditions, and updated from a table to a
%   struct array of conditions.
%	+ Revert .cevents to a derived property (extracted on the fly from
%       .conditions) |condEvents| and further it is now return as a
%       struct array instead of a table.
%	+ Improved some comments
%
% 15-Dec-2025: FOE
%   + Property |conditions| is now column array instead of row array.
%   + Method findConditions is now public.
%

    properties (Constant, Access=private)
        classVersion = '1.2'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        startTime(1,1) datetime = datetime('now'); % Absolute start time
        timestamps(:,1) double = zeros(0,1); %List of timestamps in [|timeUnitMultiplier|*secs] relative to .startTime
        nominalSamplingRate(1,1) double {mustBeNonnegative} = 1; %Nominal sampling rate in Hz
        unit(1,:) char {mustBeMember(unit,{'samples','seconds'})} = 'samples';
        timeUnitMultiplier(1,1) int16 = 0;
    end

    properties (SetAccess=private)
        exclusory(:,:) logical = false(0,0); %Pairwise exclusory states
        conditions(:,1) icnna.data.core.condition = ...
                    icnna.data.core.condition.empty; % List of conditions 
    end


    properties (Dependent)
        length %Read-only
        nConditions %Read-only
        averageSamplingRate %Read-only
        %conditions %Read-only
        nTotalEvents %Read-only
        condEvents %Read-only
            %note that events is a function in matlab. So avoid that name.
    end
    
    
    

    % =====================================================================
    % Constructor
    % =====================================================================
    methods
        function obj=timeline(varargin)
            %Constructor for class @icnna.data.core.timeline
            %
            % obj=icnna.data.core.timeline() creates a default empty timeline.
            % obj=icnna.data.core.timeline(obj2) acts as a copy constructor
            %
            % obj=icnna.data.core.timeline(obj2) Typecasts a @timeline into
            %   an @icnna.data.core.timeline
            %
            % obj=icnna.data.core.timeline(length,nominalSamplingRate)
            %   creates a new @icnna.data.core.timeline of a given
            %   |length| and |nominalSamplingRate| with no conditions
            %   defined.
            % 
            % Copyright 2024-25
            % @author: Felipe Orihuela-Espina
            %

            obj@icnna.data.core.identifiableObject();
            tmp = split(class(obj),'.');
            obj.name = [tmp{end} num2str(obj.id,'%04d')];
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'icnna.data.core.timeline')
                obj = varargin{1};
                return;
            elseif isa(varargin{1},'timeline')
                t = varargin{1}; %typecasts the timeline
                obj.unit = 'samples';
                obj.timeUnitMultiplier  = 0;
                obj.startTime  = datetime(t.startTime, 'ConvertFrom', 'datenum');
                warning('off')
                obj.timestamps = t.timestamps;
                warning('on')
                obj.nominalSamplingRate = t.nominalSamplingRate;
                if (t.nConditions > 0)
                    tmpConditions(t.nConditions) = icnna.data.core.condition();
                    for iCond = 1:numel(t.conditions)
                        tmpCond        = tmpConditions(iCond);
                            %icnna.data.core.conditions are handles.
                            %and ergo passed by reference, ergo all the
                            %lines below, automatically reflect the
                            %changes in tmpConditions
                        tmpCond.id     = iCond;
                        tmpCond.name   = t.conditions{iCond}.tag;
                        tmpCond.unit   = 'samples';
                        tmpCond.timeUnitMultiplier  = 0;
                        tmpCond.nominalSamplingRate = t.nominalSamplingRate;
                        tmpCond.addEvents(t.conditions{iCond}.events,...
                                          t.conditions{iCond}.eventsInfo);
                        
                    end
                    obj.conditions = tmpConditions;
                    obj.exclusory  = logical(t.exclusory);
                end
                return;
            elseif (nargin==2)
                %val=varargin{1};
                tmpLength = varargin{1};
                obj.nominalSamplingRate = varargin{2};
                t = 0:(tmpLength-1);
                obj.timestamps = (1/obj.nominalSamplingRate)*t;
                    %This automatically sets the length (dependent)
                    %Note that at this moment, there is no need to
                    %account for the |timeUnitMultiplier| as it this point
                    %it will be set to 0 i.e. 10^0 = 1.
            else
                error(['icnna.data.core.timeline:timeline:InvalidNumberOfParameters' ...
                            'Unexpected number of parameters.']);
            end
            %assertInvariants(obj);
        end
    end



    % =====================================================================
    % Getters & setters
    % =====================================================================
    methods
         %Gets the object |nominalSamplingRate|
      function res = get.nominalSamplingRate(obj)
            % Getter for |nominalSamplingRate|:
            %   Returns the value of the |nominalSamplingRate| property.
            %
            % Declared sampling rate. It may differ from the average
            %sampling rate (see 'averageSamplingRate'). This is used for
            %automatically generating timesamples when these latter are
            %unknown.
            %
            % Usage:
            %   res = obj.nominalSamplingRate;  % Retrieve nominal sampling rate
            %
            %% Output
            % res - double
            %   The nominal sampling rate in [Hz]
            %
         res = obj.nominalSamplingRate;
      end
         %Sets the object |nominalSamplingRate|
      function obj = set.nominalSamplingRate(obj,val)
            % Setter for |nominalSamplingRate|:
            %   Sets the |nominalSamplingRate| property in Hz.
            %
            % Declared sampling rate in Hz. It may differ from 
            % the average sampling rate (see obj.averageSamplingRate).
            % This is used for automatically generating timesamples
            % when these latter are unknown.
            %
            % If the |unit| is 'samples' altering the nominal sampling
            % rate also alters the |condEvents| accordingly, but won't
            % affect the timestamps.
            %
            % Usage:
            %   obj.nominalSamplingRate = 3;  % Set the nominal sampling rate to 3 Hz
            %
            %% Input parameters
            %
            % val - double
            %   The new nominal sampling rate in Hz.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            %
            if (val == 0)
                warning('icnna:data:core:timeline:set_nominalSamplingRate:ParameterValue',...
                    ['A nominal sampling rate equal to 0 can lead to ' ...
                    'incorrect conversions between samples and seconds.'])
            end
            currentSR = obj.nominalSamplingRate;
            obj.nominalSamplingRate = val;
            if strcmp(obj.unit,'samples')
                for iCond = 1:obj.nConditions
                    obj.conditions(iCond).onsets = round(...
                        obj.conditions(iCond).onsets * ...
                        (obj.nominalSamplingRate / currentSR));
                    obj.conditions(iCond).durations = round(...
                        obj.conditions(iCond).durations * ...
                        (obj.nominalSamplingRate / currentSR));
                end
            end
      end





         %Retrieves the object |startTime|
      function res = get.startTime(obj)
            % Getter for |startTime|:
            %   Returns the value of the |startTime| property.
            %
            % Timestamps are relative to this |startTime|.
            %
            % Usage:
            %   res = obj.startTime;  % Retrieve absolute start time.
            %
            %% Output
            % res - datetime
            %   An absolute start time.
            %
         res = obj.startTime;
      end
         %Sets the object |startTime|
      function obj = set.startTime(obj,val)
            % Setter for |startTime|:
            %   Sets the absolute start time.
            %
            % Timestamps are relative to this |startTime|.
            %
            % Usage:
            %   obj.startTime = datetime('10am','InputFormat','hha');  % Set the start time at today's 10am.
            %
            %% Input parameters
            %
            % val - datetime
            %   The new absolute start time.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            %
         obj.startTime = datetime(val);
      end




         %Retrieves the object |timestamps|
      function res = get.timestamps(obj)
            % Getter for |timestamps|:
            %   Returns the list of |timestamps|.
            %
            % Timestamps are relative to |startTime|. From these, the
            % average sampling rate (different from the nominal sampling
            % rate) is calculated.
            %
            %       +==============================================+
            %       | Timestamps is ALWAYS in 'seconds' units (or  |
            %       | the fractional time in |timeUnitMultiplier|) |
            %       | even if the timeline |unit| is samples.      |
            %       +==============================================+
            %
            % Usage:
            %   res = obj.timestamps;  % Retrieve the list of |timestamps|.
            %
            %% Output
            % res - double[length]
            %   List of timestamps in [|timeUnitMultiplier|*sec] relative
            %   to |startTime|.
            %
         res = obj.timestamps;
      end
         %Sets the object |timestamps|
      function obj = set.timestamps(obj,val)
            % Setter for |timestamps|:
            %   Sets the list of |timestamps| for the samples.
            %
            % Timestamps are relative to this |startTime|. From these, the
            % average sampling rate (different from the nominal sampling
            % rate) is calculated.
            %
            %       +==============================================+
            %       | Timestamps is ALWAYS in 'seconds' units (or  |
            %       | the fractional time in |timeUnitMultiplier|) |
            %       | even if the timeline |unit| is samples.      |
            %       +==============================================+
            %
            %  The timeline |length| is a derived property which
            % reflects the number of timestamps. Ergo, changing the
            % timestamps will also affect the |length|. Hence, some
            % events on conditions may need to be cropped or removed.
            %
            %  The timeline |averageSamplingRate| is a derived property
            % which reflects the average time between the timestamps.
            % Ergo, changing the |timestamps| will also affect the
            % |averageSamplingRate|.
            %
            % Changing the |timestamps| does not alter the
            % |nominalSamplingRate|.
            %
            % Usage:
            %   obj.timestamps = datetime('10am','InputFormat','hha');  % Set the start time at today's 10am.
            %
            %% Input parameters
            %
            % val - double[]
            %   The new list of |timestamps|.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            %
         if (isvector(val) && ~ischar(val) ...
                 && all(val(1:end-1)<val(2:end)) )
             %ensure it is a column vector
             val = reshape(val,numel(val),1);
             obj.timestamps = val;
             obj = cropOrRemoveEvents(obj);
         else
             error('icnna:data:core:timeline:set_timestamps:InvalidParameterValue',...
                 'Value must be a vector of length obj.length.');
         end
      end





         %Retrieves the object |conditions|
      function res = get.conditions(obj)
            % Getter for |conditions|:
            %   Returns the list of |conditions|.
            %
            % Usage:
            %   res = obj.conditions;  % Retrieve the list of experimental condtions.
            %
            %% Output
            % res - icnna.data.core.condition[]
            %   The list of |conditions|.
            %
         res = obj.conditions;
      end
        %NOTE that condition set permission is private.
        %See method setConditions


         %Retrieves the object |exclusory|
      function res = get.exclusory(obj)
            % Getter for |exclusory|:
            %   Returns the exclusory behaviour between the |conditions|.
            %
            % Usage:
            %   res = obj.exclusory;  % Retrieve the exclusory behaviour between the |conditions|.
            %
            %% Output
            % res - logical[|nConditions|x|nConditions|]
            %   The exclusory behaviour between the |conditions|.
            %
         res = obj.exclusory;
      end
         %Sets the object |exclusory|
      function obj = set.exclusory(obj,val)
            % Setter for |exclusory|:
            %   Sets the |exclusory| property.
            % 
            % If the multiplier is changed, the event onsets and durations
            % are adjusted according to the difference in precision.
            %   
            % Usage:
            %   obj.exclusory = eye(ob.nConditions); 
            %           % Allow overlap for all conditions (but 
            %           %not within conditions).
            %
            % Error handling:
            %   - val is a logical array
            %   - val is a square matrix sized |nConditions|x|nConditions|.
            %   - val is symmetric.
            %   - The exclusory behaviour must be consistent with the
            %   current overlapping request among the condition events
            %   (see assertExclusory). If this is not the case, the
            %   potential conflicts ought to be resolved in advance.
            %
            %% Input parameters
            %
            % val - logical[|nConditions|x|nConditions|]
            %   The new exclusory behaviour between the |conditions|.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %

         [nRows,nCols] = size(val);
         assert( islogical(val), ...
             ['icnna:data:core:timeline:set.exclusory: Exclusory matrix ' ...
              'ought to be logical.']);
         assert( ndims(val) <= 2 && ...
                nRows == obj.nConditions && nCols == obj.nConditions, ...
             'icnna:data:core:timeline:set.exclusory: Unexpected matrix size.');
         assert( issymmetric(val), ...
             ['icnna:data:core:timeline:set.exclusory: Exclusory matrix ' ...
              'ought to be symmetric.']);
         obj.exclusory = val;

         assert(obj.assertExclusory(), ...
            ['icnna:data:core:timeline:set.exclusory:ViolatedInvariant: ' ...
             'Inconsistent exclusory behaviour.']);

      end



        %Retrieves the temporal unit, whether 'samples' or 'seconds'
        function val = get.unit(obj)
            % Getter for |unit|:
            %   Returns the temporal |unit|, whether 'samples' or 'seconds'.
            %
            % Usage:
            %   res = obj.unit;  % Retrieve the temporal |unit|
            %
            %% Output
            % res - char[]
            %   The temporal |unit|, whether 'samples' or 'seconds'.
            %
            val = obj.unit;
        end
        %Sets the temporal unit, whether 'samples' or 'seconds'
        function obj = set.unit(obj,val)
            % Setter for |unit|:
            %   Sets the |unit| property.
            % 
            % Updating the |unit| also updates the events of the
            %   conditions accordingly.
            %
            % Timestamps are not affected as these are always in
            %   [|timeUnitMultiplier|*sec].
            %
            % Usage:
            %   obj.unit = 'samples';  % Use samples as the temporal unit.
            %
            %% Input parameters
            %
            % val - char[] (enum)
            %   The new temporal unit, whether 'samples' or 'seconds'.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            currentUnit = obj.unit;
            obj.unit = val;
            if ~strcmpi(currentUnit,obj.unit)
                %Conversion needed.
                for iCond = 1:obj.nConditions
                    obj.conditions(iCond).unit = obj.unit;
                end
            end
        end


        %Retrieves the temporal unit multiplier
        function val = get.timeUnitMultiplier(obj)
            % Getter for |timeUnitMultiplier|:
            %   Returns the temporal unit multiplier |timeUnitMultiplier|.
            %
            % Usage:
            %   res = obj.timeUnitMultiplier;  % Retrieve the temporal unit multiplier
            %
            %% Output
            % res - int16
            %   The temporal temporal unit multiplier.
            %
            val = obj.timeUnitMultiplier;
        end
        %Sets the temporal unit multiplier
        function obj = set.timeUnitMultiplier(obj,val)
            % Setter for |timeUnitMultiplier|:
            %   Sets the |timeUnitMultiplier| property.
            % 
            % Updating the |timeUnitMultiplier| also updates the events
            %   of the conditions accordingly.
            %
            % Timestamps are also updated to reflect the new units
            %   [|timeUnitMultiplier|*sec].
            %
            % Usage:
            %   obj.timeUnitMultiplier = -3;  % Set temporal unit to milliseconds
            %
            %% Input parameters
            %
            % val - int16
            %   The new temporal unit multiplier.
            %
            %% Output
            %
            % obj - @icnna.data.core.timeline
            %   The updated object
            %
            currentMultiplier = obj.timeUnitMultiplier;
            obj.timeUnitMultiplier = val;
            %...and update the timestamps accordingly
            if ~isempty(obj.timestamps)
                obj.timestamps = obj.timestamps * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
                %Typecase has to be explicit
            end
            %Ensure all conditions have this unit.
            if strcmp(obj.unit,'seconds')
                for iCond = 1:obj.nConditions
                    obj.conditions(iCond).timeUnitMultiplier = obj.timeUnitMultiplier;
                end
            end
            
        end







        %-- Dependent properties



         %(DEPENDENT) Retrieves the timeline |length|
      function res = get.length(obj)
            % Getter for |length|:
            %   (DEPENDENT) Gets the timeline |length| (number of samples).
            %
            % Usage:
            %   res = obj.length;  % Retrieve the length
            %
            %% Output
            % res - double
            %   The timeline |length| in samples.
            %
         res = size(obj.timestamps,1);
      end


         %(DEPENDENT) Retrieves the timeline |nConditions|
      function res = get.nConditions(obj)
            % Getter for |length|:
            %   (DEPENDENT) Gets the number of conditions (|nConditions|).
            %
            % Usage:
            %   res = obj.nConditions;  % Retrieve the timeline number of conditions
            %
            %% Output
            % res - double
            %   The number of conditions declared in the timeline.
            %
         res = numel(obj.conditions);
      end


         %(DEPENDENT) Retrieves the timeline |averageSamplingRate|
      function res = get.averageSamplingRate(obj)
            % Getter for |averageSamplingRate|:
            %   (DEPENDENT) Gets the |averageSamplingRate|.
            %
            % This is the average sampling rate in Hz. This is calculated 
            % on the fly from the timestamps and use in many operations
            % e.g. getAvgTaskTime. This is different from the nominal
            % sampling rate |nominalSamplingRate|.
            %
            % Usage:
            %   res = obj.averageSamplingRate;  % Retrieve the average sampling rate.
            %
            %% Output
            % res - double
            %   The average sampling rate in Hz.
            %
         %
         res = 0;
         if obj.length == 0
             %Do nothing 
             %res = 0;
         elseif obj.length == 1
              res = 1/obj.timestamps(1);
         else
              res = 1/mean(obj.timestamps(2:end)-obj.timestamps(1:end-1),...
                            "omitnan");
         end
      end


         %(DEPENDENT) Retrieves the object |nTotalEvents|
      function res = get.nTotalEvents(obj)
            % Getter for |nTotalEvents|:
            %   (DEPENDENT) Gets the total number of events across conditions (|nTotalEvents|).
            %
            % Usage:
            %   res = obj.nTotalEvents;  % Retrieve the total number of events across conditions
            %
            %% Output
            % res - double
            %   The total number of events across conditions declared
            %   in the timeline.
            %
         res = sum([obj.conditions(:).nEvents]);
      end

         %(DEPENDENT) Retrieves the object |condEvents|
      function res = get.condEvents(obj)
            % Getter for |condEvents|:
            %   (DEPENDENT) Gets the list of all the events across the conditions in the timeline (|condEvents|).
            %
            %   Events are sorted by onset.
            %   Events are enriched with the condition id and name to which
            %   they belong.
            %
            % Usage:
            %   res = obj.condEvents;  % Retrieve the list of all the events
            %                          %across the conditions in the timeline
            %
            %% Output
            % res - struct[]
            %   The list of all the events across the conditions in the
            %   timeline sorted by onset. Each struct in the array
            %   correspond to a single event and has the following
            %   fields;
            %     + id - double The condition |id|
            %     + name - char[] The condition |name|
            %     + onsets - double An event onsets
            %     + durations - double An event durations,
            %     + amplitudes  - double An event amplitudes or magnitudes,
            %     + info - cell. An event information. Whatever the user
            %       
            %
         %res = [tmp(:).cevents]; %This works fine but does not include
                                  %the condition id and name.
         res = struct( ...
            'id', [], ...
            'name', [], ...
            'onsets', [], ...
            'durations', [], ...
            'amplitudes', [], ...
            'info', {} );
         for iCond = 1:obj.nConditions
            for iEv = 1:obj.conditions(iCond).nEvents
                tmp.id         = obj.conditions(iCond).id;
                tmp.name       = obj.conditions(iCond).name;
                tmp.onsets     = obj.conditions(iCond).cevents(iEv).onsets;
                tmp.durations  = obj.conditions(iCond).cevents(iEv).durations;
                tmp.amplitudes = obj.conditions(iCond).cevents(iEv).amplitudes;
                tmp.info       = obj.conditions(iCond).cevents(iEv).info;
                res = [res tmp];
             end
         end
         [~, idx] = sort([res.onsets]);
         res = res(idx);
      end



    end

    methods (Access=private)
        % idx = findConditions(obj,tags); %Retrieves the indexes of the
        %                     %conditions with the given |id|(s) or |name|(s)
        obj = cropOrRemoveEvents(obj); %Crops or remove events exceeding
                                 %the timeline length.
        flag = assertExclusory(obj);  %Asserts that the exclusory
                                      %behaviour is respected.
    end



end
