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
% @icnna.data.core.condition (other than memmory limits), each identified
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
%   .length - The experiment duration (in time samples)
%   .startTime - A reference absolute start time (stored as datenum).
%         The default start time is the object creation time. 
%   .timestamps - A vector of .lengthx1 timestamps in seconds
%         relative to the .startTime. Note that the initial timestamp
%         does not have to be 0. When not available, timestamps will
%         automatically generated at 1Hz. If not provided, the nominal
%         sampling rate to automatically generate timestamps.
%   .nominalSamplingRate - A nominal sampling rate in Hz. By default
%         it is set to 1Hz. This is different from the "real" average
%         sampling rate that is calculated on the fly from
%         the timesamples.
%   .conditions - A cell array of conditions. Each condition is a struct
%         with a tag (.conditions{i}.tag), the list of events.
%         (.conditions{i}.events) and a field to store information
%         associated to the events (.conditions{i}.eventsInfo).
%           The list of events is a two column matrix
%         where first column represents event onsets and second
%         column represents event durations.
%   .exclusory - A matrix of pairwise exclusory states.
%	  exclusory(condA,condB)=0 => Non exclusory behaviour
%	  exclusory(condA,condB)=1 => Exclusory behaviour
%
%       From ICNNA version 1.2.2, a condition can have overlapping
%       events with itself. This is controlled with the main diagonal
%       of .exclusory.
%
%% Dependent properties
%
%   .nConditions - Number of conditions. Length of the |conditions|
%       property.
%
%   .samplingRate - Average sampling rate. This is calculated on the
%       fly from the timestamps and use in many operations
%       e.g. getAvgTaskTime. This is different from the nominal
%       sampling rate property.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('timeline') for a list of methods
% 
%
% Copyright 2008-24
% @author: Felipe Orihuela-Espina
%
% See also assertInvariant
%



%% Log
%
% File created: 18-Apr-2008
% File last modified (before creation of this log): 30-Dec-2012
%
% 13-May-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%
%   +=====================================================+
%   | WATCH OUT!!! With the struct like syntax correct    |
%   | maintenance of interdependent properties e.g. length|
%   | and timestamps becomes more difficult, since it is  | 
%   | not possible to transiently violate postconditions  |
%   | invariants. Hence, at this point, ICNNA is no longer|
%   | checking the invariants after updating the          |
%   | timestamps. The obvious way to fix this is to make  |
%   | length a dependent variable (e.g. the length of the |
%   | timestamps, but since this would represent a change |
%   | in the data structure which is not backward         |
%   | compatible this is not yet implemented by now.      |
%   | In the meantime, violations of some class invariants|
%   | are being relaxed to warnings.                      |
%   +=====================================================+
% 
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Added private method cropOrRemoveEvents (extracted from previous
%   nested method in method set).
%   + Dependent properties nConditions and samplingRate are now
%   explicitly declared as such. Also added comments for these
%   in the class description.
%   + Improved some comments.
%   Bug fixing
%   + 2 of the errors were reporting the incorrect class in the error code.
%
%
% 11-Apr-2024: FOE
%   + Starting with ICNNA v1.2.2 conditions can have overlapping events
% with itself. This is controlled with the main diagonal of .exclusory.
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        length(1,1) double {mustBeInteger, mustBeNonnegative}=0; % The length of the timeline in samples.
        startTime = datenum(datetime('now')); % Absolute start time (as datenum)
            %NOTE: Datenum has now been deprecated by matlab and
            %use of datetime is recommended instead.
            %However, I'm keeping datenum for compatibility by now.
        timestamps(:,1) double = zeros(0,1); %List of timestamps in seconds relative to .startTime
        nominalSamplingRate(1,1) double {mustBeNonnegative} = 1; %Nominal sampling rate in Hz
        conditions=cell(1,0); %Collection of conditions
        exclusory=zeros(0,0); %Pairwise exclusory states
    end

    properties (Dependent)
        nConditions
        samplingRate
    end
    
    methods
        function obj=timeline(varargin)
            %TIMELINE Timeline class constructor
            %
            % obj=timeline() creates a default empty timeline with no conditions
            %   defined.
            %
            % obj=timeline(obj2) acts as a copy constructor of timeline
            %
            % obj=timeline(l) creates a new timeline of length l with
            %    no conditions defined.
            %
            % obj=timeline(l,tag,m) creates a new timeline of length l with
            %   a single condition 'tag' whose events are represented in
            %   matrix m. Matrix m will be a two column matrix where first
            %   column represents event onsets and second column represents
            %   event durations.
            %       Example: obj=timeline(90,'A',[30 15; 60 15])
            %            Two events starting at samples 30 and 60, both
            %          lasting for 15 samples.
            %                obj=timeline(90,'A',[])
            %            No events. Note that the [] in the third parameter is still
            %            compulsory.

            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'timeline')
                obj=varargin{1};
                return;
            else
                %val=varargin{1};
                %obj=set(obj,'Length',val);
                obj.length=varargin{1};
                if (nargin==3)
                    if (ischar(varargin{2}))
                        cond.tag = varargin{2};
                    else
                        error('Tag must be a string');
                    end
                    if isempty(varargin{3})
                        cond.events=zeros(0,2);
                        cond.eventsInfo=cell(0,1);
                    else
                        cond.events = varargin{3};
                        cond.eventsInfo=cell(size(cond.events,1),1);
                    end
                    obj.conditions(1)={cond};
                    obj.exclusory=zeros(1,1);
                end
            end
            assertInvariants(obj);
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Access=private)
        idx=findCondition(obj,tag);
        [obj,res]=cropOrRemoveEvents(obj,newLength)
    end


    methods

      %Getters/Setters

      function res = get.length(obj)
         %Gets the object |length|
         %
         % The length of the timeline in samples.
         res = obj.length;
      end
      function obj = set.length(obj,val)
         %Sets the object |length|
         %
         % This is the length of the timeline in number of samples
         %When updating the 'length', if the current timeline has
         %events defined that last beyond the new size, this operation
         %will issue a warning before cropping or removing those events.
         %

         %Remove or crop events beyond the new length.
         [obj,res]=obj.cropOrRemoveEvents(val);
         if (res)
             warning('ICNNA:timeline:set:EventsCropped',...
                 ['Events lasting beyond the new length ' ...
                 'will be cropped or removed.']);
         end

         if val>obj.length
             %Generate extra timestamps
             initStamp = 0;
             if ~isempty(obj.timestamps)
                 initStamp = obj.timestamps(end);
             end
             extraTimestamps = initStamp + ...
                 (1:val-obj.length) / obj.nominalSamplingRate;
             obj.timestamps = [obj.timestamps; extraTimestamps'];
         elseif val<obj.length
             %Remove the later timestamps
             obj.timestamps(val+1:end) = [];
         end

         obj.length = val;
            
         assertInvariants(obj);
      end





      function res = get.nConditions(obj)
         %(DEPENDENT) Gets the object |nConditions|
         %
         % The number of conditions declared in the timeline.
         res = size(obj.conditions,2);
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
         assertInvariants(obj);
      end




      function res = get.samplingRate(obj)
         %(DEPENDENT) Gets the object |samplingRate|
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
            error('ICNA:timeline:set:InvalidParameterValue',...
                  'Value must be a date (whether a string, datevec or datetime).');
        end
        assertInvariants(obj);
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
         
         if (isvector(val) && ~ischar(val) ...
                 && all(val(1:end-1)<val(2:end)) )
             %ensure it is a column vector
             val = reshape(val,numel(val),1);

             assert(size(obj.timestamps,1) == obj.length,...
                 ['ICNNA:timeline:assertInvariants:InvariantViolation ' ...
                 'Number of timestamps mismatches timeline length.']);

             obj.timestamps = val;
         else
             error('ICNA:timeline:set:InvalidParameterValue',...
                 'Value must be a vector of length obj.length.');
         end

         %See note in the log
         assertInvariants(obj);
      end



    end


end
