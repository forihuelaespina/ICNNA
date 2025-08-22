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
%% Remarks
%
% @icnna.data.core.timeline are @icnna.data.core.identifiableObject,
% and therefore they are handles. Beware of collateral effects.
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
%   .name - (Since v1.3.1) Char array. By default is empty 'timeline0001'.
%       A name for the timeline. 
%
%   -- Public properties
%   .startTime - datetime. A reference absolute start time.
%         The default start time is the object creation time.
%           Up to ICNNA version 1.3.0, the type was datenum.
%   .timestamps - A vector of .lengthx1 timestamps in seconds
%         relative to the .startTime. Note that the initial timestamp
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
%  -- Private properties
%
%   .conds - (Since v1.3.1) Table
%       Conditions (|id|,|name|) pairs. 
%       Both id and names ought to be unique.
%
%       +=====================================================+
%       | NOTE; In dictionary, retrieving the value knowing   |
%       | the key is trivial, but the other way around not so |
%       | much. Matlab dictionaries offer method .entries to  |
%       | get a tabular view of the dictionay, but in the end |
%       | the additional conversion was not convenient. Hence,|
%       | A table implementation was favoured over a          |
%       | dictionary so that retrival of the id given the name|
%       | was as easy as the other way around.                |
%       +=====================================================+
%
%   .cevents - Table. Default is empty.
%         List of condition events.
%         Each row is an event.
%         The list of events has AT LEAST the following columns;
%          + id - The condition id,
%          + onsets - The rows of the table is ALWAYS sort by onsets,
%          + durations,
%          + amplitudes i.e. magnitude or strength.
%          + info - Event information. Whatever the user wants to
%                   store associated to the condition event.
%
%       Onsets and durations are store in the timeline |unit|. Therefore,
%       updating the property |unit| affects the representation of
%       |cevents|.
%
%       Additional columns may be added, but the 4 columns above
%       ought to be present and be named 'onset', 'duration', 'amplitude'
%       and 'info' respectively. Although, the order does not matter in
%       principle, if any of these four columns are missing when setting
%       up the value, a default order will be assumed and the column will
%       be renamed accordingly.
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
%   .condEvents - Table. Read-only. A list of all the events across the conditions
%       in the timeline.
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
%

    properties (Constant, Access=private)
        classVersion = '1.1'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        startTime(1,1) datetime = datetime('now'); % Absolute start time
        timestamps(:,1) double = zeros(0,1); %List of timestamps in seconds relative to .startTime
        nominalSamplingRate(1,1) double {mustBeNonnegative} = 1; %Nominal sampling rate in Hz
        unit(1,:) char {mustBeMember(unit,{'samples','seconds'})} = 'samples';
        timeUnitMultiplier(1,1) int16 = 0;
    end

    properties (SetAccess=private)
        exclusory(:,:) logical = false(0,0); %Pairwise exclusory states
    end

    properties (SetAccess=private, GetAccess=private)
        conds table = table('Size',[0 2],...
                        'VariableTypes',{'uint32','string'},...
                        'VariableNames',{'id','name'}); %Collection of conditions (id,name) pairs
        cevents table = table('Size',[0 5],...
                        'VariableTypes',{'uint32','double','double','double','cell'},...
                        'VariableNames',{'id','onsets','durations','amplitudes','info'});
                                            %Collection of events
    end

   
    properties (Dependent)
        length %Read-only
        nConditions %Read-only
        averageSamplingRate %Read-only
        conditions %Read-only
        nTotalEvents %Read-only
        condEvents %Read-only
            %note that events is a function in matlab. So avoid that name.
    end
    
    methods
        function obj=timeline(varargin)
            %Timeline class constructor
            %
            % obj=icnna.data.core.timeline() creates a default empty timeline with no
            %   conditions defined nor samples (empty timestamps).
            %
            % obj=icnna.data.core.timeline(obj2) acts as a copy constructor
            %   of @icnna.data.core.timeline
            %
            % obj=icnna.data.core.timeline(obj2) Typecasts a @timeline into
            %   an @icnna.data.core.timeline
            %
            % obj=icnna.data.core.timeline(length,nominalSamplingRate)
            %   creates a new @icnna.data.core.timeline of a given
            %   |length| and |nominalSamplingRate| with no conditions
            %   defined.
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
                obj.addConditions(tmpConditions,0);
                obj.exclusory    = logical(t.exclusory);
                return;
            else
                %val=varargin{1};
                tmpLength = varargin{1};
                obj.nominalSamplingRate = varargin{2};
                t = 0:(tmpLength-1);
                obj.timestamps = (1/obj.nominalSamplingRate)*t;
                    %This automatically sets the length (dependent)
                    %Note that at this moment, there is no need to
                    %account for the |timeUnitMultiplier| as it this point
                    %it will be set to 0 i.e. 10^0 = 1.
            end
            %assertInvariants(obj);
        end


      %Getters/Setters


      function res = get.nominalSamplingRate(obj)
         %Gets the object |nominalSamplingRate|
         %
         % Declared sampling rate. It may differ from the
         %real sampling rate (see 'SamplingRate'). This is used for
         %automatically generating timesamples when these latter are
         %unknown.
         res = obj.nominalSamplingRate;
      end
      function set.nominalSamplingRate(obj,val)
         %Sets the object |nominalSamplingRate|
         %
         % Declared sampling rate in Hz. It may
         % differ from the real sampling rate (see obj.averageSamplingRate).
         % This is used for automatically generating timesamples
         % when these latter are unknown.
         %
         % Altering the nominal sampling rate also alters the |cevents|,
         %but won't affect the timestamps.
            if (val == 0)
                warning('icnna:data:core:timeline:set_nominalSamplingRate:ParameterValue',...
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





      function res = get.startTime(obj)
         %Gets the object |startTime|
         %
         % An absolute start date (as a datenum)
         res = obj.startTime;
      end
      function set.startTime(obj,val)
         %Sets the object |startTime|
         %
         %  An absolute start date.
         obj.startTime = datetime(val);
      end




      function res = get.timestamps(obj)
         %Gets the object |timestamps|
         %
         % A vector (of 'Length'x1) of timestamps in seconds
         % expressed relative to the startTime.
         res = obj.timestamps;
      end
      function set.timestamps(obj,val,varargin)
         %Sets the object |timestamps|
         %
         %  A vector (of |length|x1) of timestamps in seconds
         % expressed relative to the startTime. From these, the real
         % average sampling rate (different from the nominal sampling
         % rate) is calculated.
         %
         % Changing the timestamps also changes the length, and hence
         % events on conditions may need to be cropped or removed.
         if (isvector(val) && ~ischar(val) ...
                 && all(val(1:end-1)<val(2:end)) )
             %ensure it is a column vector
             val = reshape(val,numel(val),1);
             obj.timestamps = val;
             obj.cropOrRemoveEvents();
         else
             error('icnna:data:core:timeline:set_timestamps:InvalidParameterValue',...
                 'Value must be a vector of length obj.length.');
         end

         %See note in the log
         %assertInvariants(obj);
      end





      function res = get.conds(obj)
         %Gets the object |conds|
         res = obj.conds;
      end
      function set.conds(obj,val)
         %Sets the object |conds|

         %Assert that there aren't conditions sharing the same id
         ids = uint32(val.id);
         assert(numel(ids) == numel(unique(ids)),...
                'icnna:data:core:timeline:set_conditions:RepeatedConditionNames',...
                'Repeated conditions names.');
         %Assert that there aren't conditions sharing the same name
         names = val.name;
         assert(numel(names) == numel(unique(names)),...
                'icnna:data:core:timeline:set_conditions:RepeatedConditionNames',...
                'Repeated conditions names.');
         tmp = cellfun(@(val) isempty(val), names);
         assert(~any(tmp),...
                'icnna:data:core:timeline:set_conditions:EmptyConditionNames',...
                'Empty condition name');
         obj.conds = sortrows(table(ids,names,...
                                    'VariableNames',{'id','name'}), ...
                              'id');
                    % For convenience sort the conds by id



      end


      function res = get.exclusory(obj)
         %Gets the object |exclusory|
         res = obj.exclusory;
      end
      function set.exclusory(obj,val)
         %Sets the object |exclusory|
         [nRows,nCols] = size(val);
         assert( ndims(val) <= 2 && ...
                nRows == obj.nConditions && nCols == obj.nConditions, ...
             'icnna:data:core:timeline:set.exclusory: Unexpected matrix size.');
         assert( issymmetric(val), ...
             'icnna:data:core:timeline:set.exclusory: Exclusory matrix ought to be symmetric.');
         obj.exclusory = val;

         assert(obj.assertExclusory(), ...
            ['icnna:data:core:timeline:addCondition:ViolatedInvariant: ' ...
             'Inconsistent exclusory behaviour.']);

      end



        function val = get.unit(obj)
        %Retrieves the temporal unit, whether 'samples' or 'seconds'
            val = obj.unit;
        end
        function set.unit(obj,val)
        %Sets the temporal unit, whether 'samples' or 'seconds'
            currentUnit = obj.unit;
            obj.unit = val;
            if ~strcmpi(currentUnit,obj.unit)
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
            %...and update the timestamps accordingly
            if ~isempty(obj.timestamps)
                obj.timestamps = obj.timestamps * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
                %Typecase has to be explicit
            end
            %Ensure all conditions have this unit.
            if strcmp(obj.unit,'seconds')
                obj.cevents.onsets = obj.cevents.onsets * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
                obj.cevents.durations = obj.cevents.durations * ...
                    10^double(currentMultiplier - obj.timeUnitMultiplier);
            end
            
        end







        %-- Dependent properties



      function res = get.length(obj)
         %(DEPENDENT) Gets the object |length|
         %
         % The length of the timeline in samples.
         res = size(obj.timestamps,1);
      end


      function res = get.nConditions(obj)
         %(DEPENDENT) Gets the object |nConditions|
         %
         % The number of conditions declared in the timeline.
         res = size(obj.conds,1);
      end


      function res = get.averageSamplingRate(obj)
         %(DEPENDENT) Gets the object |averageSamplingRate|
         %
         % This is the average sampling rate. This is calculated on the
         % fly from the timestamps and use in many operations
         % e.g. getAvgTaskTime. This is different from the nominal
         % sampling rate.
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



      function res = get.conditions(obj)
         %Gets the object |conditions|
         res = icnna.data.core.condition.empty;
         if (obj.nConditions > 0)
             %Generate the condition objects on the fly.
             tmp = obj.conds;
                %Note that I store the conds dictionary already
                %sorted by keys, so no need to sort here.
             res(obj.nConditions) = icnna.data.core.condition;
             res = arrayfun(@(obj2,val) setfield(obj2,'id',val), res, tmp.id');
             for iCond = 1:obj.nConditions
                 res(iCond).name = tmp.name(iCond);
                 res(iCond).nominalSamplingRate = obj.nominalSamplingRate;
                 res(iCond).unit = obj.unit;
                 res(iCond).timeUnitMultiplier = obj.timeUnitMultiplier;
                 res(iCond).cevents = sortrows(obj.cevents(obj.cevents.id == tmp.id(iCond), ...
                                               {'onsets','durations','amplitudes','info'}),...
                                                'onsets');
    
             end
         end
      end

      function res = get.nTotalEvents(obj)
         %(DEPENDENT) Gets the object |nTotalEvents|
         %
         % Number of total events in the timeline across conditions.
         res = size(obj.cevents,1);
      end

      function res = get.condEvents(obj)
         %(DEPENDENT) Gets the object |condEvents|
         %
         % A list of all the events across the conditions in the timeline.
         res = obj.cevents;
      end



    end

    methods (Access=private)
        idx = findConditions(obj,tags); %Retrieves the indexes of the
                            %conditions with the given |id|(s) or |name|(s)
        cropOrRemoveEvents(obj); %Crops or remove events exceeding
                                 %the timeline length.
        flag = assertExclusory(obj);  %Asserts that the exclusory
                                      %behaviour is respected.
    end



end
