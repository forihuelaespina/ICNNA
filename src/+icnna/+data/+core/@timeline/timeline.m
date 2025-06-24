classdef timeline
% icnna.data.core.timeline  A timeline for recording of events.
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
%seconds (or any scaling of these e.g. milliseconds). If you need
%backward compatibility to ICNNA versions earlier than v1.2.2 you
%ought to operate in samples.
%
% When timestamps are be available this class uses the nominal
% sampling rate to automatically generate timestamps.
%
%% Conditions as experimental stimulus or factors
%
%For each experimental stimulus type you define an @icnna.data.core.condition.
%Every @icnna.data.core.condition represent a different stimulus type.
% A @icnna.data.core.timeline support any number of different
% @icnna.data.core.condition (other than memory limits), each identified
% by its tag. Within a timeline, all tags ought to be unique.
% 
% @li All tags ought to be unique,
% @li It is not permitted that a tag is an empty string,
% @li Condition tags are case sensitive i.e. 'A' is not the same as 'a'
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
%   .classVersion - (Read only) The class version of the object
%   .id - A numerical identifier.
%   .startTime - A reference absolute start time (stored as datenum).
%         The default start time is the object creation time. 
%   .timestamps - A vector of .lengthx1 timestamps in seconds
%         relative to the .startTime. Note that the initial timestamp
%         does not have to be 0. When not available, timestamps will
%         automatically generated at 1Hz. If not provided, the nominal
%         sampling rate to automatically generate timestamps.
%   .nominalSamplingRate - A nominal sampling rate in Hz. By default
%         it is set to 1Hz. This is different from the "real" average
%         sampling rate (dependent property) that is calculated directy
%         from the timesamples.
%   .conditions - An array of icnna.data.core.conditions.
%       All conditions within a timeline ought to have distinct .id and
%       distinct .tag
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
%  -- Constants provided:
%
%   .CONDITIONS_NON_EXCLUSORY - logical. Represent non-exclusory behaviour (false)
%   .CONDITIONS_EXCLUSORY - logical. Represent exclusory behaviour (true)
%
%% Dependent properties
%
%   .length - The experiment duration (in samples). Length of the
%       timestamps property.
%   .nConditions - Number of conditions. Length of the |conditions|
%       property.
%   .averageSamplingRate - Average sampling rate. This is calculated
%       on the fly from the timestamps and use in many operations
%       e.g. getAvgTaskTime. This is different from the nominal
%       sampling rate property.
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
%   timeline. Class is still unfinished (and not documented)
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

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end

    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        startTime = datenum(datetime('now')); % Absolute start time (as datenum)
            %NOTE: Datenum has now been deprecated by matlab and
            %use of datetime is recommended instead.
            %However, I'm keeping datenum for compatibility by now.
        timestamps(:,1) double = zeros(0,1); %List of timestamps in seconds relative to .startTime
        nominalSamplingRate(1,1) double {mustBeNonnegative} = 0; %Nominal sampling rate in Hz
        conditions(:,1) icnna.data.core.condition; %Collection of conditions
        exclusory(:,:) logical = false(0,0); %Pairwise exclusory states
    end


    properties (Constant) %but public access
        CONDITIONS_EXCLUSORY(1,1) logical = true; %Represents exclusory behaviour.
        CONDITIONS_NON_EXCLUSORY(1,1) logical = false; %Represents non-exclusory behaviour.
    end
   
    properties (Dependent)
        length
        nConditions
        averageSamplingRate
    end
    
    methods
        function obj=timeline(varargin)
            %TIMELINE Timeline class constructor
            %
            % obj=timeline() creates a default empty timeline with no
            %   conditions defined nor samples (empty timestamps).
            %
            % obj=timeline(obj2) acts as a copy constructor of timeline
            %
            % obj=timeline(length,nominalSamplingRate) creates a new
            %   timeline of a given |length| and |nominalSamplingRate|
            %   with no conditions defined.
            %

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'timeline')
                obj = varargin{1};
                return;
            else
                %val=varargin{1};
                tmpLength = varargin{1};
                obj.nominalSamplingRate = varargin{2};
                obj.timestamps = (1/obj.nominalSamplingRate)*[0:tmpLength-1];
                    %This automatically sets the length (dependent)
            end
            %assertInvariants(obj);
        end
    end
    
    % methods (Access=protected)
    %     assertInvariants(obj);
    % end
    
    methods (Access=private)
        idx = findCondition(obj,tag); %Search condition by |id| or |tag|
        obj = cropOrRemoveEvents(obj); %Crops or remove events exceeding
                                        %the timeline length.
    end


    methods

      %Getters/Setters

      function res = get.length(obj)
         %(DEPENDENT) Gets the object |length|
         %
         % The length of the timeline in samples.
         res = size(timestamps,1);
      end


      function res = get.nConditions(obj)
         %(DEPENDENT) Gets the object |nConditions|
         %
         % The number of conditions declared in the timeline.
         res = size(obj.conditions,1);
      end





      function res = get.nominalSamplingRate(obj)
         %Gets the object |nominalSamplingRate|
         %
         % Declared sampling rate. It may differ from the
         %real sampling rate (see 'SamplingRate'). This is used for
         %automatically generating timesamples when these latter are
         %unknown.
         res = obj.nominalSamplingRate;
      end
      function obj = set.nominalSamplingRate(obj,val)
         %Sets the object |nominalSamplingRate|
         %
         % Declared sampling rate in Hz. It may
         % differ from the real sampling rate (see get(obj,'SamplingRate')).
         % This is used for automatically generating timesamples
         % when these latter are unknown. Note however that setting the
         % nominalSamplingRate does not recompute (existing) timestamps.
         obj.nominalSamplingRate = val;
         %assertInvariants(obj);
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
              res = 0;
         elseif obj.length == 1
              res = 1/obj.timestamps(1);
         else
              res = 1/nanmean(obj.timestamps(2:end)-obj.timestamps(1:end-1));
         end
      end




      function res = get.startTime(obj)
         %Gets the object |startTime|
         %
         % An absolute start date (as a datenum)
         res = obj.startTime;
      end
      function obj = set.startTime(obj,val)
         %Sets the object |startTime|
         %
         %  An absolute start date.
        if (ischar(val) || isvector(val) || isscalar(val) || isdatetime(val))
            obj.startTime = datenum(val);
        else
            error('icnna:data:core:timeline:set_startTime:InvalidParameterValue',...
                  'Value must be a date (whether a string, datevec or datetime).');
        end
        %assertInvariants(obj);
      end




      function res = get.timestamps(obj)
         %Gets the object |timestamps|
         %
         % A vector (of 'Length'x1) of timestamps in seconds
         % expressed relative to the startTime.
         res = obj.timestamps;
      end
      function obj = set.timestamps(obj,val,varargin)
         %Sets the object |timestamps|
         %
         %  A vector (of |length|x1) of timestamps in seconds
         % expressed relative to the startTime. From these, the real
         % average sampling rate (different from the nominal sampling
         % rate) is calculated.
         %
         % Changing the timestamps also changes the length, and hence
         % events on condition may need to be cropped or removed.
         if (isvector(val) && ~ischar(val) ...
                 && all(val(1:end-1)<val(2:end)) )
             %ensure it is a column vector
             val = reshape(val,numel(val),1);

             try
                warning('icnna:data:core:timeline:set_timestamps:EventsCropOrRemoved',...
                        'Events may have been crop or removed.')
                obj.timestamps = val;
                obj = cropOrRemoveEvents(obj);
             catch ME
                 error('icnna:data:core:timeline:set_timestamps:InvalidParameterValue',...
                     'Unable to set the timestamps.');
             end
         else
             error('icnna:data:core:timeline:set_timestamps:InvalidParameterValue',...
                 'Value must be a vector of length obj.length.');
         end

         %See note in the log
         %assertInvariants(obj);
      end





      function res = get.conditions(obj)
         %Gets the object |conditions|
         res = obj.conditions;
      end
      function obj = set.conditions(obj,val)
         %Sets the object |conditions|
         obj.conditions = reshape(val,numel(val),1);
         %Assert that there aren't conditions sharing the same id or tag
         ids  = nan(0,1);
         tags = cell(0,1);
         for iCond=1:size(obj.conditions,1)
            ids(iCond)  = obj.conditions(iCond).id;
            tags(iCond) = {obj.conditions(iCond).tag};
         end
         assert(size(ids,1) == size(unique(ids,1)),...
                'icnna:data:core:timeline:set_conditions:RepeatedConditionIDs')
         assert(size(tags,1) == size(unique(tags,1)),...
                'icnna:data:core:timeline:set_conditions:RepeatedConditionTags')

      end




    end


end
