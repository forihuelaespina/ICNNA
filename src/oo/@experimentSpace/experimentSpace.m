%Class ExperimentSpace
%
%An experimentSpace split experiment data into its atomic pieces
%representing blocks or trials of different conditions. This is
%an intermedite representation of the experimental data, namely the
%Experiment Space, ready to be analysed.
%
% * The Experiment Space includes ONLY data for which integrity
%have been check.
%
% * The Experiment Space includes ONLY active data from
%the experiment, filtering out raw and non-active data.
%
%
%% Constructing the Experiment Space.
%
%Any experimentSpace is based on a particular experimental dataset
%(see class experiment). However once the it is constructed,
%the experimentSpace no longer keeps a link to the original dataset
%which generated it. At the time of constructing the space
%(see method compute), each dataSource defined
%in the dataset from every session of every subject, brings
%a number of points to the Experiment Space. This
%point is generated from the active structuredData in the
%dataSource. Note that this means that dataSources with no
%structuredData will actually not bring any points to the
%Experiment space. The number of points depends on the number
%of stimulus or conditions, blocks, and whether averaging is
%across blocks applied.
%
%As new points from active strcuturedData are brought into
%the Experiment Space, it is expected that their timelines
%are compatible (see timeline.areCompatible) to certain degree.
%
%
%Original active data may be expressed at different sampling
%rates. The experimentSpace class does not make any assumption
%about this, so it is responsability of the user to decide
%whether resampling the signals before performing the experimentSpace
%or whether to directly apply the experimentSpace to signals with
%different sampling rates.
%
%% Experiment Space Representation
%
%The Experiment Space is stored in an intermediate representation
%(good old matrix F) which is computed when the experimentSpace is
%created. The Experiment Space is a 7D discrete space:
%
% <Subject,
%  Session,
%  dataSource,
%  Channel,
%  Signal,
%  Stimulus,
%  Block>
%
%This defines a discrete space. Each location of this space
%holds a vector with the ready-to-use data. The length of this
%vector depends on the class parameters.
%
%Note that a signal is uniquely defined not only by the signal
%dimension, but also by dataSource type. Capitalizing on the
%sessionDefinitions, dataSource IDs are standardized across
%subjects and sessions. Hence for a given session, a
%pair <dataSource,Signal> uniquely defines a particular
%source of data.
%
%
%
%% Stages of experimentSpace
%
%The Experiment Space no longer requires a timeline nor
%need to know the integrity of the data. It is indeed
%a cloud of points in a certain space.
%
%Computation of the Experiment Space is equivalent
%to extraction of points from the "experimental" dataset.
%The computation is performed in several stages, some of which can be
%skipped at the user's discretion (see the fields performAveraging,
%performResampling, performNormalization).
%These stages are:
%
% 1) The block splitting stage
%
% At the time of constructing the Space, each active structuredData
%defined in the dataset from every dataSource, of every
%session of every subject, brings
%a number of points to the Experiment Space.
%The number of points depends on the number
%of stimulus or conditions, blocks, and whether averaging is
%across blocks applied. The block splitting stage, extract
%independent blocks fro structuredData so that they are the seed
%of the point in the Experiment Space.
%
%This stage is closely related to the window selection stage
%and their difference may be unclear. The block splitting
%stage defines how to extract the information from the data,
%whereas the window selection indicates which part of this
%information is used. After block splitting, blocks do not
%necessarily have the same length, and the data still preserves
%its 3D conceptual structure (see structuredData class). But during
%the window selection stage, each signal and channel is separated
%to yield different entries in the ExperimentSpace, and importantly
%all vectors will have the same length (this is regardless of
%the resampling stage!!).
% See also the window selection stage for more information.
%
% 2) The resampling stage (Optional)
%
% Signals may be expressed at different sampling rates, or
%the experimental task may be a self-paced task. In both
%cases, data from different blocks and perhaps different
%signals may result in a dispair number of samples. The
%user may want to experimentSpace signals as they come, or to
%resample the signals to ensure they all have the same
%number of samples.
%
%When resampling, the timeline segregates the signal into
%event task or rest blocks. Each task block is considered
%to be formed of three chunks: a rest prior to the onset of
%the stimulus (pre), the task block itself, and a rest
%after the task (post). The user may indicate how many samples
%are desired in each chunk.
%
%Currently all stimulus events are resampled to a common length
%regardless of the origin of their condition. But this may
%change in future versions to allow for finer control.
%
%
% 3) Averaging stage (Optional)
%
% The user can decide whether to average across blocks to reduce
%the signal to noise ratio, or whether
%each block is analysed independently i.e., each block
%will produce an entry (or point) in the Experiment
%Space, to increase the statistical power by having more points.
%
%If the experimentSpace is averaged, then the Block dimension of the
%Experiment Space will always be valued 1 simulating
%this dimension collapse in a hyperplane.
%
%The averaging stage is made on a sample by sample basis
%but aligning task onsets. If no resample has been made
%blocks being averaged may have different length. The new
%block will crop the longer blocks to the size of the smallest.
%
% 4) The window selection stage
%
%Regardless of whether the data has been or not averaged across
%blocks and whether it has been resampled or not, the user
%must still indicate how many samples are taken from the data
%if he wants to discard part of the signal.
%
%The window selection is defined by indicating an onset
%and duration of a window containing the data of interest.
%Since this will only allow to select a "continuous" period,
%an additional break delay permit ignoring the first few
%samples of the task subperiod, hence allowing more
%flexible "non-continuous" selection.
%
% See also the block splitting stage for more information.
%
%  #======================================================#
%  | IMPORTANT                                            |
%  #======================================================#
%  | Any spatial experimentSpace is seen as a particular  |
%  | case of a Window Selection experimentSpace with      |
%  | window duration of 1 sample.                         |
%  #======================================================#
%
%
% 5) Normalization (Optional -NOT YET WORKING)
%
% At this moment the experiment space has indeed been already
%constructed; i.e. all points in the space have been fully
%defined. The normalization stage simply adds a finer definition
%of the data. To define a normalization process the user must
%specify the method, the scope and the dimension.
%
% Available normalization METHODs are:
%
%   +'normal' normalization maps elements of A to mean 
%        and variance [mu var] respectively. Common normalization
%        is zero mean and unit variance.
%   +'range' normalization maps elements of A to range
%        to the interval [min max], normally [0 1] or [-1 1]
%        but any range can be specified.
%
% Available normalization SCOPEs are:
%
%   +'blockindividual' - Each vector is normalised independently.
%       Each subject, session, stimulus and
%       block is normalized independently.
%   +'individual' - Each vector group (all blocks at once)
%       is normalised independently. Each subject, session and
%       stimulus is normalized independently.
%   +'collective' - Data from the whole experiment is normalised at
%        once across subjects, sessions, stimulus and blocks
%
% Available normalization DIMENSIONs are:
%
%   +'channel' - Normalisation happen across each channel considering
%       all measured signals at once. One normalization will be
%       performed per spatial element.
%   +'signal' - Normalisation happen across each signal considering
%       all channels at once. One normalization will be
%       performed per signal. Note that this really mean per pair
%       <dataSource,signal>.
%   +'combined' - Normalisation happen for each channel and each
%       signal every time. There will be one normalisation per
%       triplet <dataSource,signal,channel>.
%
%
%% Remarks
%
% * Averaging will occurr separately for each condition (stimulus).
% * After averaging data, the number of blocks per stimulus is 1.
% * Data from the dataSource will be included from the active
%       structuredData only.
%       All active structuredData source
%       at the time of running the experimentSpace must have their
%       timelines compatible to degree 2 i.e., same conditions and
%       exclusory behaviour (see timeline.compatibility).
% *Currently the Experiment Space include all signals and all
%   clean channels based on its integrity value. Only channels
%   for which the integrity value is integrityStatus.FINE will
%   produce an entry in the Experiment Space.
%   Since integrityStatus.UNCHECK channels will produce no entry,
%   this means that the user is force to run the integrity check
%   before going to the analysis.
%
%       
%% Properties
%
%   .id - A descriptor
%   .name -  A name. Default value is 'ExperimentSpace0001'
%   .description -  A brief description
%   .Fvectors - A cell array with the Experimental Space vectors
%       NOTE that the vectors are not guaranteed to have the same
%       length (e.g. data is only averaged across blocks, or not even
%       that, but not resampled or windowed)
%   .Findex - The index to locations of the vectors
%       within theExperimental Space 
%   .runStatus - Boolean flag to indicate whether the Experiment
%       Space has been computed with the current configuration.
%       The only way to set it to true
%       is to computeExperimentSpace. It can be set to false
%       by redefining any of the computing parameters or
%       resetting the object instance.
%       Default false.
%   .sessionNames - A struct to hold the session names. The struct
%       has two fields:
%               .sessID - The session identifier
%               .name - The session name
%       The length of this struct is equal to the number of distinct
%       sessions in Findex(:,experimentSpace.DIM_SESSION).
%
%  == Computing Parameters
%   .performFixWindow - DEPRECATED. Window selection has become
%       compulsory.
%   .performAveraging - Whether to average or not. Default false.
%   .performResampling - Whether to resample or not. Default false.
%   .performNormalisation - Whether to normalise or not. Default false.
%
%   .baselineSamples - Number of samples to be collected
%       in the baseline when splitting the structuredData
%       into blocks. Default value is 15. (See structuredData.getBlock)
%   .restSamples - Maximum number of samples to be collected
%       for the rest when splitting the structuredData
%       into blocks. Default value is -1 meaning that no maximum
%       number of samples will be collected, but that rest subperiod
%       will extend until next onset or end of timecourse.
%       (See structuredData.getBlock)
%
%   .rsBaseline - Resample stage parameter. Number of samples
%       into which the baseline prior to the stimulus must be
%       resampled. Default 0.
%   .rsTask - Resample stage parameter. Number of samples
%       into which the task block of the stimulus must be
%       resampled. Default 20.
%   .rsRest - Resample stage parameter. Number of samples
%       into which the rest after the stimulus must be
%       resampled. Default 0.
%
%   .fwOnset - Window selection (fix window) stage parameter.
%       Number of samples from the onset of the stimulus block
%       which the window starts. If negative, then the selection
%       of samples starts from the baseline subperiod. If 0, then
%       the fix window start matches the start of the task block.
%       Positive values n indicate that the window starts n
%       samples after the task block onset. Default -5
%       (5 secs baseline).
%   .fwDuration - Window selection (fix window) stage parameter.
%       Number of samples that the selected window lasts (as the
%       sum of the baseline (-fw.onset), the delay (fwBreakDelay)
%       and the 'task' itself. Default 25 (20 secs task + 5 secs baseline).
%   .fwBreakDelay - Window selection (fix window) stage parameter.
%       Number of samples ignored from the stimulus event onset
%       (this is, NOT from the window selection onset, but from
%       the task subperiod onset itself!). Default is 0, i.e.
%       a continuous selection. A value
%       of n, will discard the first n samples from the task
%       subperiod.
%
%   .normalizationMethod - Normalization stage parameter.
%       Indicates normalization method; either 'normal' or
%       'range'. Default 'normal'.
%           See details of normalization methods above.
%   .normalizationMean - Normalization stage parameter.
%       Indicates normalization mean. 
%       Default 0 (zero mean).
%       Only valid if normalization method is 'normal'.
%   .normalizationVar - Normalization stage parameter.
%       Indicates normalization variance. 
%       Default 1 (unit variance).
%       Only valid if normalization method is 'normal'.
%   .normalizationMin - Normalization stage parameter.
%       Indicates normalization range minimum value. 
%       Default 0.
%       Only valid if normalization method is 'range'.
%   .normalizationMax - Normalization stage parameter.
%       Indicates normalization range maximum value. 
%       Default 1.
%       Only valid if normalization method is 'range'.
%   .normalizationScope - Normalization stage parameter.
%       Indicates normalization scope; either 'individual' or
%       'collective'. Default 'collective'.
%   .normalizationDimension - Normalization stage parameter.
%       Indicates normalization dimesion; either 'channel',
%       'signal', or 'combined'. Default 'combined';
%
%
% == Dimension descriptor Constants
%   .DIM_SUBJECT    =1;
%   .DIM_SESSION    =2;
%   .DIM_DATASOURCE =3;  - Indicates the device
%   .DIM_STRUCTUREDDATA=4; - Refers to the active data
%   .DIM_CHANNEL    =5;
%   .DIM_SIGNAL     =6;
%   .DIM_STIMULUS   =7;  - a.k.a. as condition
%   .DIM_BLOCK      =8;  - a.k.a. as trial
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('experimentSpace') for a list of methods
% 
% Copyright 2008-13
% @date: 12-Jun-2008
% @author: Felipe Orihuela-Espina
% @modified: 4-Jan-2013
%
% See also structuredData.getBlock, compute, analysis, generateDB
%

%% Log
%
% 1-Sep-2016 (FOE): Class created.
%
% 20-February-2022 (ESR): Get/Set Methods created in experimentSpace
%   + The methods are added with the new structure. All the properties have 
%   the new structure.
%   + The new structure enables new MATLAB functions
%   + We create a dependent property inside of the experimentSpace class.
%   

classdef experimentSpace
    properties (SetAccess=private, GetAccess=private)
        id=1;
        name='ExperimentSpace0001';
        description='';
        Fvectors=cell(0,1);
        Findex=zeros(0,8);
        sessionNames=struct('sessID',{},'name',{});
        %experimentSpace parameters
        runStatus =false;
        performAveraging = false;
        performResampling = false;
        performFixWindow = true; %DEPRECATED
        performNormalization = false;
        %Block splitting stage parameters
        baselineSamples=15;
        restSamples=-1;
        %Resampling stage parameters
        rsBaseline = 0;
        rsTask = 20;
        rsRest = 0;
        %Window Selection stage parameters
        fwOnset = -5;
        fwDuration = 25; %20 secs task + 5 secs baseline
        fwBreakDelay = 0;
        %Normalization stage parameters
        normalizationMethod='normal';
        normalizationMean=0;
        normalizationVar=1;
        normalizationMin=0;
        normalizationMax=1;
        normalizationScope='collective';
        normalizationDimension='combined';
    end
    
    properties (Constant=true, SetAccess=private, GetAccess=public)
        %Columns indexes
        DIM_SUBJECT=1;
        DIM_SESSION=2;
        DIM_DATASOURCE=3;
        DIM_STRUCTUREDDATA=4; %active structuredData
        DIM_CHANNEL=5;
        DIM_SIGNAL=6;
        DIM_STIMULUS=7;
        DIM_BLOCK=8;
    end
        
    properties(Dependent)
        numPoints
        nPoints
    end
    
    methods
        function obj=experimentSpace(varargin)
            %EXPERIMENTSPACE experimentSpace class constructor
            %
            % obj=experimentSpace() creates a default empty
            %   experimentSpace.
            %
            % obj=experimentSpace(obj2) acts as a copy constructor of
            %   experimentSpace
            %
            % obj=experimentSpace(name) creates a new experimentSpace
            %    with the indicated name.
            %
            
            if (nargin==0)
                %Keep default values
            elseif isa(varargin{1},'experimentSpace')
                obj=varargin{1};
                return;
            else
                obj=set(obj,'Name',varargin{1});
            end
            assertInvariants(obj);
        end
        
        %% Get/Set methods
        %Provide struct like access to properties BUT maintaining class
        %encapsulation.
        
        %Block splitting stage parameters
        %baselineSamples
        function val = get.baselineSamples(obj)
            % The method is converted and encapsulated. 
            % obj is the experimentSpace class
            % val is the value added in the object
            % get.baselineSamples(obj) = Get the data from the experimentSpace class
            % and look for the baselineSamples object.
            val = obj.baselineSamples;
        end
        function obj = set.baselineSamples(obj,val)
            % The method is converted and encapsulated and can be used 
            % as the example in the constructor method.
            % This method allows the change of data values.
            %   obj is experimentSpace class
            %   val = is the provided value, later it is conditioned 
            %   according to the data type.
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>0)
                obj.baselineSamples = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %description
        function val = get.description(obj)
            val = obj.description;
        end
        function obj = setdescription(obj,val)
            if (ischar(val))
                obj.description = val;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a string');
            end
        end
        
        %fwOnset
        function val = get.fwOnset(obj)
            val = obj.fwOnset;
        end
        function obj = set.fwOnset(obj,val)
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val)  && ~ischar(val))
                obj.fwOnset = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be an integer scalar.');
            end
        end
        
        %fwDuration
        function val = get.fwDuration(obj)
            val = obj.fwDuration;
        end
        function obj = set.fwDuration(obj,val)
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0 && ~ischar(val))
                obj.fwDuration = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %fwBreakDelay
        function val = get.fwBreakDelay(obj)
            val = obj.fwBreakDelay;
        end
        function obj = set.fwBreakDelay(obj,val)
            if (isscalar(val) && isreal(val) && val>=0 ...
                && (floor(val)==val) && ~ischar(val))
                obj.fwBreakDelay = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %id
        function val = get.id(obj)
            val = obj.id;
        end
        function obj = set.id(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && (val==floor(val)) && (val>0))
                %Note that a char which can be converted to scalar
                %e.g. will pass all of the above (except the ~ischar)
                obj.id = val;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer.');
            end
        end
        
        %name
        function val = get.name(obj)
            val = obj.name;
        end
        function obj = set.name(obj,val)
            if (ischar(val))
                obj.name = val;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a string');
            end
        end
        
        %normalizationDimension
        function val = get.normalizationDimension(obj)
            val = obj.normalizationDimension;
        end
        function obj = set.normalizationDimension(obj,val)
            switch(lower(val))
                case 'channel'
                    obj.normalizationDimension = 'channel';
                case 'signal'
                    obj.normalizationDimension = 'signal';
                case 'combined'
                    obj.normalizationDimension = 'combined';
                otherwise
                    error('ICNA:experimentSpace:set',...
                      ['Valid normalization scope are ' ...
                      '''individual'' or ''collective''.']);
            end
                obj.runStatus = false;
        end
        
        %normalizationMethod
        function val = get.normalizationMethod(obj)
            val = obj.normalizationMethod;
        end
        function obj= set.normalizationMethod(obj,val)
            switch(lower(val))
                case 'normal'
                    obj.normalizationMethod = 'normal';
                case 'range'
                    obj.normalizationMethod = 'range';
                otherwise
                    error('ICNA:experimentSpace:set',...
                      ['Valid normalization methods are ' ...
                      '''normal'' or ''range''.']);
            end
                obj.runStatus = false;
        end
        
        %normalizationMean
        function val = get.normalizationMean(obj)
            val = obj.normalizationMean;
        end
        function obj = set.normalizationMean(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val))
                obj.normalizationMean = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be an integer.');
            end
        end
        
        %normalizationMin
        function val = get.normalizationMin(obj)
            val = obj.normalizationMin;
        end
        function obj = set.normalizationMin(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && val<obj.normalizationMax)
                obj.normalizationMin = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  ['Value must be an integer and greater than ' ...
                  'the NormalizationMax.']);
            end
        end
        
        %normalizationMax
        function val = get.normalizationMax(obj)
            val = obj.normalizationMax;
        end
        function obj = set.normalizationMax(obj,val)
            if (isscalar(val) && isreal(val) && ~ischar(val) ...
                && val>obj.normalizationMin)
                obj.normalizationMax = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  ['Value must be an integer and greater than ' ...
                  'the NormalizationMin.']);
            end
        end
        
        %---------------------------------------------------------------->
        %Findex Dependent
        %Dependent properties do not store data. 
        %The value of a dependent property depends on some other value, 
        %such as the value of a nondependent property.
        
        %Dependent properties must define get-access methods () to 
        %determine a value for the property when the property is queried: 
        %get.nPoints
        %For example: The nPoints and numPoints are properties
        %dependent of data property.
        
        %We create a dependent property.
        %---------------------------------------------------------------->
        
        %numPoints
        function val = get.numPoints(obj)
            warning('ICNA:experimentSpace:get:Deprecated',...
            ['The use of numPoints has now been deprecated. ' ...
            'Please use get(obj,''nPoints'') instead.']);
            val = size(obj.Findex,1);
        end
        
        %nPoints
        function val = get.nPoints(obj)
            val = size(obj.Findex,1);
        end
        
        %normalizationScope
        function val = get.normalizationScope(obj)
            val = obj.normalizationScope;
        end
        function obj = set.normalizationScope(obj,val)
            switch(lower(val))
            case 'blockindividual'
                obj.normalizationScope = 'blockindividual';
            case 'individual'
                obj.normalizationScope = 'individual';
            case 'collective'
                obj.normalizationScope = 'collective';
            otherwise
                error('ICNA:experimentSpace:set',...
                  ['Valid normalization scope are ' ...
                  '''individual'' or ''collective''.']);
            end
                obj.runStatus = false;
        end
        
        %normalizationVar
        function val = get.normalizationVar(obj)
            val = obj.normalizationVar;
        end
        function obj = set.normalizationVar(obj,val)
            if (isscalar(val) && isreal(val) && val>=0 ...
                && ~ischar(val))
                obj.normalizationVar = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %experimentSpace parameters
        %performAveraging
        function val = get.performAveraging(obj)
            val = obj.performAveraging;
        end
        function obj = set.performAveraging(obj,val)
            if (isscalar(val))
                obj.performAveraging = logical(val);
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
            end
        end
        
        %experimentSpace parameters
        %performResampling
        function val = get.performResampling(obj)
            val = obj.performResampling;
        end
        function obj = set.performResampling(obj,val)
            if (isscalar(val))
                obj.performResampling = logical(val);
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
            end
        end
        
        %experimentSpace parameters
        %performFixWindow
        function val = get.performFixWindow(obj)
            val = obj.performFixWindow;
            warning('ICNA:experimentSpace:set',...
                  ['This has been DEPRECATED. ' ...
                  'Please refer to experimentSpace class ' ...
                  'documentation.']);
        end
        function obj = set.performFixWindow(obj,val)
            warning('ICNA:experimentSpace:set',...
                  ['This has been DEPRECATED. ' ...
                  '''Windowed'' parameter can no longer ' ...
                  'be set. Please refer to experimentSpace class' ...
                  'documentation.']);
        end
        
        %experimentSpace parameters
        %performNormalization
        function val = get.performNormalization(obj)
            val = obj.performNormalization;
        end
        function obj = set.performNormalization(obj,val)
            if (isscalar(val))
                obj.performNormalization = logical(val);
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a logical scalar.');
            end
        end
        
        %restSamples
        function val = get.restSamples(obj)
            val = obj.restSamples;
        end
        function obj = set.restSamples(obj,val)
            if (isscalar(val) && isreal(val) ...
                    && (floor(val)==val))
                %Rest samples can be negative; meaning that all samples
                %will be collected until the next onset
                obj.restSamples = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %rsBaseline
        function val = get.rsBaseline(obj)
            val = obj.rsBaseline;
        end
        function obj = set.rsBaseline(obj,val)
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
                obj.rsBaseline = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer.');
            end
        end
        
        %rsTask
        function val = get.rsTask(obj)
            val = obj.rsTask;
        end
        function obj = set.rsTask(obj,val)
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
                obj.rsTask = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %rsRest
        function val = get.rsRest(obj)
            val = obj.rsRest;
        end
        function obj = set.rsRest(obj,val)
            if (isscalar(val) && isreal(val) ...
                && (floor(val)==val) && val>=0)
                obj.rsRest = val;
                obj.runStatus = false;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a positive integer or 0.');
            end
        end
        
        %experimentSpace parameters
        %runStatus
        function val = get.runStatus(obj)
            val = obj.runStatus;
        end
        
        %sessionNames
        function val = get.sessionNames(obj)
            val = obj.sessionNames;
        end
        function obj = set.sessionNames(obj,val)
            if (isstruct(val) && isfield(val,'sessID') && isfield(val,'name'))
                obj.sessionNames = val;
            else
                error('ICNA:experimentSpace:set',...
                  'Value must be a struct with fields .sessID and .name');
            end
        end
        
        
        
        
            
    end
    
    methods (Access=private)
        assertInvariants(obj);
    end
    
end
