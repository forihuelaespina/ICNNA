classdef experimentSpace
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
%independent blocks from structuredData so that they are the seed
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
%the resampling stage!!) unless .fwDuration is set to -2.
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
%       The only way to set it to true is to compute 
%       the ExperimentSpace or using setVectors. It can be set to false
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
%   .rsBaseline / rs_baseline - Resample stage parameter. Number of samples
%       into which the baseline prior to the stimulus must be
%       resampled. Default 0.
%   .rsTask / rs_task - Resample stage parameter. Number of samples
%       into which the task block of the stimulus must be
%       resampled. Default 20.
%   .rsRest / rs_rest - Resample stage parameter. Number of samples
%       into which the rest after the stimulus must be
%       resampled. Default 0.
%
%   .fwOnset / ws_onset - Window selection (fix window) stage parameter.
%       Number of samples from the onset of the stimulus block
%       which the window starts. If negative, then the selection
%       of samples starts from the baseline subperiod. If 0, then
%       the fix window start matches the start of the task block.
%       Positive values n indicate that the window starts n
%       samples after the task block onset. Default -5
%       (5 secs baseline).
%   .fwDuration / ws_duration - Window selection (fix window) stage parameter.
%       Number of samples that the selected window lasts (as the
%       sum of the baseline (-fw.onset), the delay (fwBreakDelay)
%       and the 'task' itself. Default 25 (20 secs task + 5 secs
%       baseline).
%       If -1, then whole block/trial is used whatever the length of it.
%       If -2, then block is used until the stimulus offset; this option
%       is convenient when dealing with stimulus and/or events are of
%       different length yet a fixed window length is not desired.
%   .fwBreakDelay - ws_breakDelay - Window selection (fix window) stage parameter.
%       Number of samples ignored from the stimulus event onset
%       (this is, NOT from the window selection onset, but from
%       the task subperiod onset itself!). Default is 0, i.e.
%       a continuous selection. A value
%       of n, will discard the first n samples from the task
%       subperiod.
%
%         +========================================================+
%         | IMPORTANT NOTE: The breakDelay is applied at the time  |
%         | of computing the database (using generateDB_WithBreak) |
%         | and NOT at the time of computing the experimentSpace.  |
%         | Altough in principle this is correct, but it is        |
%         | certainly not intuitive, and can lead to errors if     |
%         | someone uses generateDB instead. At some point, I need |
%         | to "fix" this and apply the breakDelay during the      |
%         | computation of the experimentSpace.                    |
%         +========================================================+
%
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
%% Dependent properties
%
%   .numPoints - DEPRECATED. Number of points in the Experiment Space. Use .nPoints instead
%   .nPoints - Number of points in the Experiment Space.
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('experimentSpace') for a list of methods
% 
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also structuredData.getBlock, compute, analysis, generateDB
%



%% Log
%
% File created: 12-Jun-2008
% File last modified (before creation of this log): 4-Jan-2013
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Dependent properties numPoints and nPoints are now
%   explicitly declared as such. Also added comments for these
%   in the class description.
%
% 23-Feb-2024: FOE
%   + Enriched functionality of fwDuration with potential values
%   -1 (whole block) and -2 (until block offset).
%
%
% 17-Apr-2025: FOE
%   + Slight update of comments.
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end



    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
        name(1,:) char='ExperimentSpace0001'; %A name for the experimentSpace
        description(1,:) char=''; %A short description for the object
        sessionNames(1,:) struct = struct('sessID',{},'name',{}); %Collection of session names

        %experimentSpace parameters
        performAveraging(1,1) logical = false; %Flag indicating whether to average or not.
        performResampling(1,1) logical = false; %Flag indicating whether to resample or not.
        performFixWindow(1,1) logical = true; %DEPRECATED
        performNormalization(1,1) logical = false;  %Flag indicating whether to normalize or not.
        %Block splitting stage parameters
        baselineSamples(1,1) double {mustBeInteger} = 15;
        restSamples(1,1) double {mustBeInteger} = -1;
        %Resampling stage parameters
        rsBaseline(1,1) double {mustBeInteger} = 0;
        rsTask(1,1) double {mustBeInteger}  = 20;
        rsRest(1,1) double {mustBeInteger}  = 0;
        %Window Selection stage parameters
        fwOnset(1,1) double {mustBeInteger}  = -5;
        fwDuration(1,1) double {mustBeInteger}  = 25; %20 secs task + 5 secs baseline
        fwBreakDelay(1,1) double {mustBeInteger}  = 0;
        %Normalization stage parameters
        normalizationMethod(1,:) char {mustBeMember(normalizationMethod,{'normal','range'})} = 'normal';
        normalizationMean(1,1) double = 0;
        normalizationVar(1,1) double  = 1;
        normalizationMin(1,1) double  = 0;
        normalizationMax(1,1) double  = 1;
        normalizationScope(1,:) char {mustBeMember(normalizationScope,{'collective','blockIndividual','individual'})} = 'collective';
        normalizationDimension(1,:) char {mustBeMember(normalizationDimension,{'channel','signal','combined'})} = 'combined';
    end


    properties  (SetAccess=private)
        runStatus(1,1) logical = false; %Boolean flag to indicate whether the experimentSpace has been computed with the current configuration
    end


    properties  (SetAccess=private, GetAccess=private)
        Fvectors(:,1) cell = cell(0,1); %A cell array with the Experimental Space vectors
        Findex(:,8) double {mustBeInteger, mustBeNonnegative} = zeros(0,8); %The index to locations of the vectors within theExperimental Space
    end



    properties (Constant=true, GetAccess=public)
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


    properties (Dependent)
      numPoints % DEPRECATED. Number of points in the Experiment Space. Use .nPoints instead
      nPoints   % Number of points in the Experiment Space.

      %Some aliases
      averaged       %Equivalent to performAveraging
      resampled      %Equivalent to performResampling
      normalized     %Equivalent to performNormalization

      rs_baseline   %Equivalent to rsBaseline
      rs_task       %Equivalent to rsTask
      rs_rest       %Equivalent to rsRest

      ws_onset      %Equivalent to fwOnset
      ws_duration   %Equivalent to fwDuration
      ws_breakDelay %Equivalent to fwBreakDelay
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
    end
    
    methods (Access=private)
        assertInvariants(obj);
    end
    
    



    methods

        %Getters/Setters

        function res = get.id(obj)
            %Gets the object |id|
            res = obj.id;
        end
        function obj = set.id(obj,val)
            %Sets the object |id|
            obj.id =  val;
        end


        function res = get.name(obj)
            %Gets the object |name|
            res = obj.name;
        end
        function obj = set.name(obj,val)
            %Sets the object |name|
            obj.name =  val;
        end


        function res = get.description(obj)
            %Gets the object |description|
            res = obj.description;
        end
        function obj = set.description(obj,val)
            %Sets the object |description|
            obj.description =  val;
        end


        function res = get.sessionNames(obj)
            %Gets the object |sessionNames| (read-only)
            res = obj.sessionNames;
        end
        function obj = set.sessionNames(obj,val)
            %Sets the object |sessionNames|
            obj.sessionNames =  val;
        end



        

        function res = get.performAveraging(obj)
            %Gets the object |performAveraging|
            res = obj.performAveraging;
        end
        function obj = set.performAveraging(obj,val)
            %Sets the object |performAveraging|
            obj.performAveraging =  val;
            obj.runStatus = false;
        end


        function res = get.performResampling(obj)
            %Gets the object |performResampling|
            res = obj.performResampling;
        end
        function obj = set.performResampling(obj,val)
            %Sets the object |performResampling|
            obj.performResampling =  val;
            obj.runStatus = false;
        end


        function res = get.performNormalization(obj)
            %Gets the object |performNormalization|
            res = obj.performNormalization;
        end
        function obj = set.performNormalization(obj,val)
            %Sets the object |performNormalization|
            obj.performNormalization =  val;
            obj.runStatus = false;
        end



        function res = get.baselineSamples(obj)
            %Gets the object |baselineSamples|
            res = obj.baselineSamples;
        end
        function obj = set.baselineSamples(obj,val)
            %Sets the object |baselineSamples|
            obj.baselineSamples =  val;
            obj.runStatus = false;
        end



        function res = get.restSamples(obj)
            %Gets the object |restSamples|
            res = obj.restSamples;
        end
        function obj = set.restSamples(obj,val)
            %Sets the object |restSamples|
            obj.restSamples =  val;
            obj.runStatus = false;
        end


        function res = get.rsBaseline(obj)
            %Gets the object |rsBaseline|
            res = obj.rsBaseline;
        end
        function obj = set.rsBaseline(obj,val)
            %Sets the object |rsBaseline|
            obj.rsBaseline =  val;
            obj.runStatus = false;
        end


        function res = get.rsTask(obj)
            %Gets the object |rsTask|
            res = obj.rsTask;
        end
        function obj = set.rsTask(obj,val)
            %Sets the object |rsTask|
            obj.rsTask =  val;
            obj.runStatus = false;
        end


        function res = get.rsRest(obj)
            %Gets the object |rsRest|
            res = obj.rsRest;
        end
        function obj = set.rsRest(obj,val)
            %Sets the object |rsRest|
            obj.rsRest =  val;
            obj.runStatus = false;
        end


        function res = get.fwOnset(obj)
            %Gets the object |fwOnset|
            res = obj.fwOnset;
        end
        function obj = set.fwOnset(obj,val)
            %Sets the object |fwOnset|
            obj.fwOnset =  val;
            obj.runStatus = false;
        end


        function res = get.fwDuration(obj)
            %Gets the object |fwDuration|
            res = obj.fwDuration;
        end
        function obj = set.fwDuration(obj,val)
            %Sets the object |fwDuration|
            obj.fwDuration =  val;
            obj.runStatus = false;
        end


        function res = get.fwBreakDelay(obj)
            %Gets the object |fwBreakDelay|
            res = obj.fwBreakDelay;
        end
        function obj = set.fwBreakDelay(obj,val)
            %Sets the object |fwBreakDelay|
            obj.fwBreakDelay =  val;
            obj.runStatus = false;
        end


        function res = get.normalizationMethod(obj)
            %Gets the object |normalizationMethod|
            res = obj.normalizationMethod;
        end
        function obj = set.normalizationMethod(obj,val)
            %Sets the object |normalizationMethod|
            obj.normalizationMethod =  val;
            obj.runStatus = false;
        end



        function res = get.normalizationMean(obj)
            %Gets the object |normalizationMean|
            res = obj.normalizationMean;
        end
        function obj = set.normalizationMean(obj,val)
            %Sets the object |normalizationMean|
            obj.normalizationMean =  val;
            obj.runStatus = false;
        end


        function res = get.normalizationVar(obj)
            %Gets the object |normalizationVar|
            res = obj.normalizationVar;
        end
        function obj = set.normalizationVar(obj,val)
            %Sets the object |normalizationVar|
            obj.normalizationVar =  val;
            obj.runStatus = false;
        end


        function res = get.normalizationMin(obj)
            %Gets the object |normalizationMin|
            res = obj.normalizationMin;
        end
        function obj = set.normalizationMin(obj,val)
            %Sets the object |normalizationMin|
            obj.normalizationMin =  val;
            obj.runStatus = false;
        end



        function res = get.normalizationMax(obj)
            %Gets the object |normalizationMax|
            res = obj.normalizationMax;
        end
        function obj = set.normalizationMax(obj,val)
            %Sets the object |normalizationMax|
            obj.normalizationMax =  val;
            obj.runStatus = false;
        end



        function res = get.normalizationScope(obj)
            %Gets the object |normalizationScope|
            res = obj.normalizationScope;
        end
        function obj = set.normalizationScope(obj,val)
            %Sets the object |normalizationScope|
            obj.normalizationScope =  val;
            obj.runStatus = false;
        end


        function res = get.normalizationDimension(obj)
            %Gets the object |normalizationDimension|
            res = obj.normalizationDimension;
        end
        function obj = set.normalizationDimension(obj,val)
            %Sets the object |normalizationDimension|
            obj.normalizationDimension =  val;
            obj.runStatus = false;
        end







        

        %Some "read-only" properties

        function res = get.runStatus(obj)
            %Gets the object |runStatus| (read-only)
            res = obj.runStatus;
        end




        function res = get.averaged(obj)
            %Gets the object |averaged|
            res = obj.performAveraging;
        end
        function obj = set.averaged(obj,val)
            %Sets the object |averaged|
            obj.performAveraging =  val;
        end


        function res = get.resampled(obj)
            %Gets the object |resampled|
            res = obj.performResampling;
        end
        function obj = set.resampled(obj,val)
            %Sets the object |resampled|
            obj.performResampling =  val;
        end


        function res = get.normalized(obj)
            %Gets the object |normalized|
            res = obj.performNormalization;
        end
        function obj = set.normalized(obj,val)
            %Sets the object |normalized|
            obj.performNormalization =  val;
        end


        function res = get.rs_baseline(obj)
            %Gets the object |rs_baseline|
            res = obj.rsBaseline;
        end
        function obj = set.rs_baseline(obj,val)
            %Sets the object |rs_baseline|
            obj.rsBaseline =  val;
        end


        function res = get.rs_task(obj)
            %Gets the object |rs_task|
            res = obj.rsTask;
        end
        function obj = set.rs_task(obj,val)
            %Sets the object |rs_task|
            obj.rsTask =  val;
        end


        function res = get.rs_rest(obj)
            %Gets the object |rs_rest|
            res = obj.rsRest;
        end
        function obj = set.rs_rest(obj,val)
            %Sets the object |rs_rest|
            obj.rsRest =  val;
        end


        function res = get.ws_onset(obj)
            %Gets the object |ws_onset|
            res = obj.fwOnset;
        end
        function obj = set.ws_onset(obj,val)
            %Sets the object |ws_onset|
            obj.fwOnset =  val;
        end


        function res = get.ws_duration(obj)
            %Gets the object |ws_duration|
            res = obj.fwDuration;
        end
        function obj = set.ws_duration(obj,val)
            %Sets the object |ws_duration|
            obj.fwDuration =  val;
        end


        function res = get.ws_breakDelay(obj)
            %Gets the object |ws_breakDelay|
            res = obj.fwBreakDelay;
        end
        function obj = set.ws_breakDelay(obj,val)
            %Sets the object |ws_breakDelay|
            obj.fwBreakDelay =  val;
        end


        %Derived properties
    

        function res = get.numPoints(obj)
            %Gets the object |numPoints|
            warning('ICNNA:experimentSpace:get.numPoints:Deprecated',...
                ['The use of numPoints has now been deprecated. ' ...
                 'Please use obj.nPoints instead.']);
            res = size(obj.Findex,1);
        end
    
        function res = get.nPoints(obj)
            %Gets the object |nPoints|
            res = size(obj.Findex,1);
        end



    end

end
