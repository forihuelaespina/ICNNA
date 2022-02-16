%Class timeline
%
%A timeline for recording of events.
% 
% A timeline holds marks corresponding with the occurrence
%of an event at a certain time of the experiment. An example
%of a typical event might be the starting or finishing of a
%block.
%
%
%% Samples vs Timestamps
%
% Although the class Timeline is a sample-guided timeline i.e. operations
%are always expressed in samples, it provides some limited support for
%handling real timings. For this, 2 properties .startTime and .timestamps
%control how the different samples are related to real timing.
%
% A nominal sampling rate is stored. However, a real average sampling
%rate is calculated from the timesamples on the fly for a few purposes
%such as calculating the average task time (i.e. method getAvgTaskTime).
%
% Contrary to samples number (which are always available without extra
%effort), timestamps might not always be available. When this is the case
%this class uses the nominal sampling rate to automatically generate
%timestamps.
%
%% Conditions: Experimental Stimulus
%
%For each experimental stimulus type you define a condition.
%Every condition represent a different stimulus type and it is
%represented by a tag. It is up to the user which is the meaning
%of the condition. Timeline support any number of different
%conditions, each identified by its tag. If the user do not specify
%the numerical label of the condition, they will be automatically
%labelled starting from 'A'.
% @li It is not permitted that the tag is an empty string,
% @li One condition has only one tag.
% @li It is not permitted that a tag is duplicated.
% @li Condition tags are case sensitive i.e. 'A' is not the same as 'a'
%
%
%% Events
%
%Conditions might happen never, once, or more than one
%time. Every time a condition occur during the experiment
%(i.e. the condition holds) an event is inserted in the timeline
%with a mark representing the event onset. The event
%will last for a certain amount of time (duration) and then finish.
%Marks and durations are not associated with real time stamps, but
%with samples indexes. For instance an event which start at time
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
%the event related paradigm, duration of events is simply set to 0.
%
%
%  Sample  30
%        ---+--
% Duration  0
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
%   .length - The experiment duration (in time samples)
%   .startTime - A reference absolute start time (stored as datenum).
%         The default start time is the object creation time. 
%   .timestamps - A vector of .lengthx1 timestamps in seconds
%         relative to the .startTime. Note that the initial timestamp
%         does not have to be 0. When not available, timestamps will
%         automatically generated at 1Hz.
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
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('timeline') for a list of methods
% 
%
% Copyright 2008-12
% @date: 18-Apr-2008
% @author: Felipe Orihuela-Espina
% @modified: 30-Dec-2012
%
% See also assertInvariant
%

%% Log
%
% 29-January-2022 (ESR): Get/Set Methods created in timeline
%   + The methods are added with the new structure. All the properties have 
%   the new structure (length,nominalsamplingrate,starttime and timestamps)
%   + We create .cropOrRemoveEvents file inside the timeline class.
%   

classdef timeline
    properties (SetAccess=private, GetAccess=private)
        length=0;
        startTime = now;
        timestamps = zeros(0,1); %in seconds relative to .startTime
        nominalSamplingRate = 1; %in Hz
        conditions=cell(1,0);
        exclusory=zeros(0,0); %Pairwise exclusory states
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
                val=varargin{1};
                obj=set(obj,'Length',val);
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
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
         %Length
        function val = get.length(obj)
            % The method is converted and encapsulated. 
            % obj is the timeline class
            % val is the value added in the object
            % get.length(obj) = Get the data from the timeline class
            % and look for the length object.
            val = obj.length;
        end

        function obj = set.length(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is the timeline class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type
            if (isscalar(val) && (val==floor(val)))
                
                %Remove or crop events beyond the new length.
                res=obj.cropOrRemoveEvents(val);
                if (res)
                    warning('ICNA:timeline:set:EventsCropped',...
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
                        (1:val-obj.length) / get(obj,'NominalSamplingRate');
                        obj.timestamps = [obj.timestamps; extraTimestamps'];
                elseif val<obj.length
                    %Remove the later timestamps
                    obj.timestamps(val+1:end) = [];
                end
                
                obj.length = val;
                
            else
                error('ICNA:timeline:set:InvalidParameterValue',...
                        'Value must be a scalar natural/integer.');
            end  
        end
            
        %nominalsamplingrate
        function val = get.nominalSamplingRate(obj)
            val = obj.nominalSamplingRate;
        end
        function obj = set.nominalSamplingRate(obj,val)
            if (isscalar(val) && val>0)
                obj.nominalSamplingRate = val;
            else
                error('ICNA:timeline:set:InvalidParameterValue',...
                    'Value must be a scalar natural/integer.');
            end
        end
        
        %starttime
        function  val = get.startTime(obj)
            val = obj.startTime;
        end
        function obj = set.startTime(obj,val)
             if (ischar(val) || isvector(val) || isscalar(val))
                obj.startTime = datenum(val);
             else
                  error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                  'Value must be a date (whether a string, datevec or datenum).');
             end
        end
        
        %timestamps
        function val = get.timestamps(obj)
            val = obj.timestamps;
        end
        function obj = set.timestamps(obj,val)
            if (isvector(val) && ~ischar(val) ...
                && all(val(1:end-1)<val(2:end)) ...
                && numel(val)==obj.get('length'))
                %ensure it is a column vector
                val = reshape(val,numel(val),1);
                obj.timestamps = val;
            else
                error('ICNA:rawData_ETG4000:set:InvalidParameterValue',...
                      'Value must be a vector of length get(obj,''Length'').');
            end
        end
    end
    
    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Access=private)
        idx=findCondition(obj,tag);
    end

end
