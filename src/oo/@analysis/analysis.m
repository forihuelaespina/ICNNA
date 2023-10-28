classdef analysis
%Manifold Embedding Neuroimage Analysis (MENA).
%An analysis defines a Feature Space H and its embedding into
%a Projection Space Y.
%
%The analysis is linked to a particular Experiment Space,
%and generates the Feature Space H
%depending on how the channels and signals
%are grouped to form the features vector.
%
%
%% What is MENA (Manifold Embedding Neuroimage Analysis)?
%
% MENA capitalises on manifold embedding dimensionality
%reduction techniques to provide a concise representation
%of an full experimental NIRS dataset. Although initially
%developed for NIRS it should be general enough to
%accept other neuroimaging modalities, and even some other
%types of data (e.g. NDI optotrack, HR signal).
%
%
%% The curse of the data source
%
%Different data sources not only produce different signals
%but also have a different number of channels,
%and different sampling rates. Theoretically it should be
%valid to generate a feature vector mixing all this:
%
%   Example: Generate patterns for each subject and session:
%               | Data Source | Sample |  Channel | Signal | 
%  -------------+-------------+--------+----------+--------+
%   Feature 1:  |   NIRS(1)   |   334  |    17    | HbO2   |
%   Feature 2:  |Nellcor HR(2)|    25  |     1    | HR     |
%       ...     |    ...      |   ...  |    ...   |  ...   |
%   Feature M:  |   fMRI(1)   |   334  |120x406x35| BOLD   |
%
%   * Number in brackets represents an example device number
%
%
% Moreover, it is theoretically plausible to create different
%sets of features vectors, and as long as they have the same
%number of features, they can be merged and will still be
%valid for analysis (whatever the meaning ;)...).
%
%So although there is no
%theoretical inconvenience in generating a feature vector
%arising from different data sources,
%
%   +========================================+
%   | CONSTRAINT                             |
%   +========================================+
%   | In the current version; MENA analysis  |
%   | is limited to a single data Source     |
%   | (see dataSourceDefinition)             |
%   +========================================+
%
%This constraint, thus ensuring
%at least the same number of channels and signals. Similar
%preprocessing is assumed thus leading also meaningful
%comparison of samples.
%
%
%% Defining the feature space; Filtering the Experiment Space
%
% A particular analysis may be applied to only a subset of the
%Experiment Space. The user may select which subjects and sessions
%are considered.
%
%
%% Defining the features
%
%% Signal descriptors
%
%Feature vectors are constructed by linking together
%different signals. The user may select which signals
%are to be analyzed i.e. incorporated to the feature vector.
%
%The experiment class keeps a record of declared data sources
%and does not allow to have different data sources sharing
%the same ID. This ensures that a data source ID uniquely
%defines a certain type (and number) of device. In other words,
%as long as the structuredData respect the order of the signals,
%it is safe to assume that a signal is described by the
%dataSource ID and the signal index itself.
%
%   dataSourceID:signal
%
%The signals existing in the experiment is therefore
%
%   dataSource1:signal1
%   dataSource1:signal2
%   ...
%   dataSourceM:signalN
%
% Beware that not all data sources record the same number of signals!
%
% Because of "THE CURSE OF THE DATA SOURCE" (see above)
%the current version of MENA only accepts a single data source.
%
%   See set(obj,'SignalDescriptors',descriptorMatrix)
% 
%
%% Channel group descriptors:
%
%The user then subdivides the range of available channels
%into groups of same length (from individual channels, to
%a single group representing the complete image). It is not
%compulsory to use all channels, but all groups must have
%the same number of channels. Every channel group
%will produce an entry (a pattern) into the Feature Space.
%
% Examples:
%   + Each channel produces its own group and all signals
%   are selected.
%       There will be a point per channel holding
%       information about all available signals
%
%
%   + We like to make comparisons between two regions on
%   a channel by channel basis, perhaps to investigate
%   lateralisation. We can define two groups
%   as follows:
%       Group | Channel set
%       ------+--------------
%         1   | 1 2 3 4
%         2   | 8 9 10 11
%
%      There will be one pattern per group of channels.
%
%The order in which the channels are specified determines
%the order in which they are included in the feature vector,
%therefore it is critical that the grouping is made upon
%a sensible choice, but it is up to the user to define its
%grouping.
%
%A pattern will be generated if and only if all channels
%are available in the Experiment Space. Note that some
%channels may have not produce a point in the Experiment
%Space if their integrity status was different from
%nitegrityStatus.FINE.
%
%The number of features in the feature vectors, or in
%other words, the dimensionality of the Features Space,
%actually depends not only on the channel grouping and
%signal selection but also on the parameters of the
%Experiment Space.
%
%
%% The Analysis Class for Manifold Embedding Neuroimage Analysis
%
%The analysis is something more than the Feature Space.
%It also holds the embedding into a Projection Space.
%The projection is achieved by imposing a certain
%distance metric in the Feature Space and
%then assuming that the data lay onto a manifold.
%The dimensionality is reduced by means of a certain
%embedding technique.
%
%Current supported metrics are:
%   *Euclidean,
%   *1-Correlation,
%   *Geodesic
%   *and the square root of the Jensen-Shannon divergence (JSM).
%
% Of these: Euclidean is the only proper metric in the 
%mathematical sense. Geodesic and JSM although metrics
%in a continuous space, they lose their metric property 
%during the enforced discretization of the problem.
%
%Current supported embedding techniques are:
%   *Classical MultiDimensional Scaling (cMDS), and
%   *Curvilinear Component Analysis (CCA).
%
%Note however that:
%
% * cMDS has been proved to form a duality with PCA
% * Geodesic + cMDS = Isomap (Default)
% * 1-Corr + cMDS = Friston functional space
% * Geodesic + CCA = CDA (Curvilinear Distance Analysis)
%
%
%% Linking the Feature Space and the Projection Space
%
% In order to link patterns in the Feature Space with
%their projections in the embedded space a index register
%matrix I is stored at all times. This matrix is a simple
%matrix with 5 columns
%
% <Subject,
%  Session,
%  Stimulus,
%  Block,
%  ChannelGroup>
%
%Each row correspond to one pattern in the Feature Space and
%its corresponding projection. The column does not
%represent a single channel neessarily, but a group of them.
%
%
%% Visualization
%
%Visualization details are defined in terms of visible/invisible
%clusters.
%
%Through the definition of clusters it is possible to
%customize the view of the dataset. See class cluster for more detail.
%
%% Remarks
%
% A cluster is tighlty linked to the analysis to which its
%patterns it refers. The indexes to the patterns refers to
%those in field I of class Analysis. A cluster has no meaning
%outside an analysis (hence a composition relation between
%class Analysis and class Cluster).
%
%Methods createCluster and removeCluster in the class analysis
%helps to maintain this relationship.
%
%An analysis can only be run if the linked experimentSpace
%has been computed. Re-running an analysis, clears the defined
%clusters.
%
%% Properties
%
%   .id - A numerical identifier.
%   .name - The analysis's logical name
%   .description - The analysis's description
%
%   .metric - Distance Metric. Possible values are:
%           'euclidean' or 'euc' - Default. Euclidean.
%               NOTE: The use of 'euc' is DEPRECATED.
%           'corr' - 1-Correlation
%           'jsm' - Square root of Jensen-Shannon divergence
%           'geo_euclidean' or 'geo' - Default. Geodesic on
%               an ambient Euclidean Space.
%               NOTE: The use of 'geo' is DEPRECATED.
%           'geo_corr' - Geodesic over 1-correlation.
%           'geo_jsm' - Geodesic over the square root of
%               Jensen-Shannon divergence.
%   .embedding - Embedding Technique. Classical multidimensional
%           scaling ('cmds' - Default), curvilinear component analysis
%           ('cca').
%
%   .F - The Experiment Space object.
%       By default the experiment space is given the same
%       name and description than the analysis.
%   .H - The Feature Space. Each pattern is a row. Each feature a column
%   .I - The index register. It links points ion the Feature Space
%       with their corresponding projections in Projection Space.
%       It is also used as anchor to define clusters for visualization.
%   .projectionDimensionality - Dimensionality of the Projection Space Y.
%       Default is 2.
%   .Y - The 2D/3D Projection Space
%   .D - Matrix of pairwise distances in the Feature Space
%   .runStatus - Boolean flag to indicate whether the Analysis
%       has been run with the current configuration.
%       The only way to set it to true
%       is to run the analysis (see method run). It is set to
%       false by redefining any of the analysis parameters or
%       resetting the experiment space.
%       Default false.
%
%   == For Experiment Space data filtering
%   .subjectsIncluded - A list of the IDs of the subjects included
%   .sessionsIncluded - A list of the IDs of the sessions included
%       Note that the ID of a session is stored in its definition.
%
%   == For Feature vector construction
%   .channelGrouping - A matrix holding the channel grouping. Each row
%       is a group of channels, each position is a channel.
%       All groups must have the same number of channels!.
%   .signalDescriptors - A Mx2 matrix of selected signal descriptors.
%       Each row represent a selected signal to be used as feature
%       generator. The first column indicates the dataSource
%       and the second column indicates the signal locations
%       within the structuredData.
%
%   == Visulalization Clusters
%   .clusters - The set of clusters or classes
%
%
%
%% Dependent properties
%
%   .nPatterns - Number of points (patterns) included in the analysis.
%   .nClusters - Number of clusters declared in the analysis.
%
%% References
%
% 1) Leff, D.R.; Orihuela-Espina, F.; Atallah, L.; Darzi, A.W.;
%   Yang, G.Z. (2007). Functional near infrared spectroscopy
%   in novice and expert surgeons--a manifold embedding approach.
%   Medical Image Computing and Computer Assisted Intervention
%   International Conference (MICCAI 2007).	Lecture Notes in
%   Computer Science 4792/2007:270-277
%
% 2) Leff, D.R.; Orihuela-Espina, F.; Atallah, L.; Athanasiou, T.;
%   Leong, J.J.H.; Darzi, A.W.; Yang, G.Z. (2008) Prefrontal
%   reOrganisation Accompanies Learning Associated Refinements
%   In Surgery (POLARIS): A Manifold Embedding Approach
%   Accepted for publication in Computer Assisted Intervention.
%
% 3) Leff, D.R.; Orihuela-Espina, F.; Leong, J.J.H.; Darzi, A.W.;
%   Yang, G.Z. (2008) Modelling Dynamic Fronto-Parietal Behaviour
%   during Minimally Invasive Surgery - a Markovian Trip
%   Distribution Approach. Accepted for publication in
%   Medical Image Computing and Computer Assisted Intervention
%   International Conference (MICCAI 2008).
%
%
%
%% Invariants
%
% See private/assertInvariants
%       
%% Methods
%
% Type methods('analysis') for a list of methods
% 
%
%
% Copyright 2008-23
% @author: Felipe Orihuela-Espina
%
% See also experiment, experimentSpace, cluster
%



%% Log
%
% File created: 23-Apr-2008
% File last modified (before creation of this log): 28-Nov-2008
%
% 7-Jun-2023: FOE
%   + Added this log. Got rid of old labels @date and @modified.
%   + Added property classVersion. Set to '1.0' by default.
%   + Added get/set methods support for struct like access to attributes.
%   + For those attributes above also started to simplify the set
%   code replacing it with validation rules on the declaration.
%   + Dependent properties nPatterns and nClusters are now
%   explicitly declared as such. Also added comments for these
%   in the class description.
%
%
% 11-Jun-2023: FOE
%   + Method assertInvariants changed from private to protected.
%   + Private metods are now explicitly declared as private in this
%   class especification rather than put in the folder private/ as
%   before.
%   + Static metods are now explicitly declared as static in this
%   class especification rather than put in the folder private/ as
%   before.
%
%

    properties (Constant, Access=private)
        classVersion = '1.0'; %Read-only. Object's class version.
    end


    properties %(SetAccess=private, GetAccess=private)
        id(1,1) double {mustBeInteger, mustBeNonnegative}=1; %Numerical identifier to make the object identifiable.
	    name(1,:) char='Analysis0001'; %A name for the analysis
        description(1,:) char=''; %A short description for the object
        metric(1,:) char {mustBeMember(metric,{'euclidean','corr','jsm','geo_euclidean','geo_corr','geo_jsm'})}='geo_euclidean'; %Distance Metric
        embedding(1,:) char {mustBeMember(embedding,{'cmds','cca'})}='cmds'; %Embedding Technique
        projectionDimensionality(1,1) double {mustBePositive}=2;

        %for Experiment Space data filtering
        subjectsIncluded=[]; %Subjects included in the data filtering of the ExperimentSpace
        sessionsIncluded=[]; %Sessions included in the data filtering of the ExperimentSpace
        
        %for Feature vector construction
        channelGrouping=[];  %Channel groups included in the data filtering of the ExperimentSpace
        signalDescriptors=[]; %Mx2 <dataSource, signal>; matrix of signal descriptors
    end
        
    properties (SetAccess=private)
        runStatus(1,1) logical =false; %Flag indicating whether the analysis results have been computed for the current configuration.
    end
        
    properties (SetAccess=private, GetAccess=private)
        F(1,1) experimentSpace = experimentSpace; %The Experiment Space.
        H(:,:) double=zeros(0,0); %The Feature Space. Each pattern is a row. Each feature is a column.
        I(:,:) double=zeros(0,5); %The patterns index register
        Y(:,:) double=zeros(0,2); %The 2D/3D Projection Space
        D(:,:) double=zeros(0,0); %Matrix of pairwise distances between patterns (in Feature Space)
        clusters=cell(1,0); %Collection of clusters declared for the analysis
    end
    
    properties (Constant=true, SetAccess=private, GetAccess=protected)
        COL_SUBJECT=1; %Identifies the column for storing the subject ID in the index register
        COL_SESSION=2; %Identifies the column for storing the session ID in the index register
        COL_STIMULUS=3; %Identifies the column for storing the stimulus (condition) ID in the index register
        COL_BLOCK=4; %Identifies the column for storing the block or trial number within the stimulus in the index register
        COL_CHANNELGROUP=5; %Identifies the column for storing the channel group in the index register
    end
    
    properties (Dependent)
      nPatterns % Number of points (patterns) included in the analysis.
      nClusters % Number of clusters declared in the analysis.


      %Some (read-only) aliases
      experimentSpace   %The Experiment Space (F).
      featureSpace      %The Feature Space (H).
      projectionSpace   %The Projection Space (I).
      patternDistances  %Distances among patterns (D).
      patternIndexes    %The patterns index register (I).
    end

    methods
        function obj=analysis(varargin)
        %ANALYSIS Analysis class constructor
        %
        % obj=analysis() creates a default analysis with ID equals 1.
        %
        % obj=analysis(obj2) acts as a copy constructor of analysis
        %
        % obj=analysis(id) creates a new analysis with the given
        %   identifier (id). The name of the analysis is initialised
        %   to 'AnalysisXXXX' where is the id preceded with 0.
        %
        % obj=analysis(id,name) creates a new analysis with the given
        %   identifier (id) and name.
        %
        % obj=analysis(id,name,metric) creates a new analysis
        %   with the given identifier (id) and name, and the
        %   selected distance metric.
        %
        % obj=analysis(id,name,metric,embedding) creates a new analysis
        %   with the given identifier (id) and name, and the
        %   selected distance metric and embedding technique.
        %
        % obj=analysis(id,name,metric,embedding,dim) creates a new
        %   analysis with the given identifier (id) and name, and the
        %   selected distance metric and embedding technique, plus
        %   the selected projection dimensionality.
        if (nargin==0)
            %Keep default values
        elseif isa(varargin{1},'analysis')
            obj=varargin{1};
            return;
        else
            obj.id = varargin{1};
            obj.name = ['Analysis' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj.name =  varargin{2};
            end
            if (nargin>2)
                obj.metric = varargin{3};
            end
            if (nargin>3)
                obj.embedding = varargin{4};
            end
            if (nargin>4)
                obj.projectionDimensionality = varargin{5};
            end
        end
        obj.Y=zeros(0,obj.projectionDimensionality);
        tmp = obj.F;
        tmp.name = obj.name;
        tmp.description = obj.description;
        obj.F = tmp;
        assertInvariants(obj);
        end
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
            tmp = obj.F;
            tmp.name = val;
            obj.F = tmp;
        end


        function res = get.description(obj)
            %Gets the object |description|
            res = obj.description;
        end
        function obj = set.description(obj,val)
            %Sets the object |description|
            obj.description =  val;
            tmp = obj.F;
            tmp.description = val;
            obj.F = tmp;
        end


        function res = get.metric(obj)
            %Gets the object |metric|
            res = obj.metric;
        end
        function obj = set.metric(obj,val)
            %Sets the object |metric|
            if strcmpi(val,'euc'), val = 'euclidean'; end
            obj.metric =  lower(val);
            obj.runStatus=false;
        end


        function res = get.embedding(obj)
            %Gets the object |embedding|
            res = obj.embedding;
        end
        function obj = set.embedding(obj,val)
            %Sets the object |embedding|
            obj.embedding =  lower(val);
            obj.runStatus=false;
        end


        function res = get.projectionDimensionality(obj)
            %Gets the object |projectionDimensionality|
            res = obj.projectionDimensionality;
        end
        function obj = set.projectionDimensionality(obj,val)
            %Sets the object |projectionDimensionality|
            obj.projectionDimensionality =  val;
            obj.runStatus=false;
        end


        function res = get.subjectsIncluded(obj)
            %Gets the object |subjectsIncluded|
            res = obj.subjectsIncluded;
        end
        function obj = set.subjectsIncluded(obj,val)
            %Sets the object |subjectsIncluded|

            %Should be a vector of IDs
            if isempty(val)
                obj.subjectsIncluded=[];
            elseif (isreal(val) && ~ischar(val)...
                    && all(all(floor(val)==val)) && all(all(val>0)))
                %It is not check whether the selected channels
                %exist
                obj.subjectsIncluded=unique(reshape(val,1,numel(val)));
            else
                error('ICNNA:analysis:set:SubjectsIncluded:InvalidInput',...
                    'Subjects included must be a matrix of positive integers.');
            end
            obj.runStatus=false;
        end


        function res = get.sessionsIncluded(obj)
            %Gets the object |sessionsIncluded|
            res = obj.sessionsIncluded;
        end
        function obj = set.sessionsIncluded(obj,val)
            %Sets the object |sessionsIncluded|
            
            %Should be a vector of IDs
            if isempty(val)
                obj.sessionsIncluded=[];
            elseif (isreal(val) && ~ischar(val)...
                    && all(all(floor(val)==val)) && all(all(val>0)))
                %It is not check whether the selected channels
                %exist
                obj.sessionsIncluded=unique(reshape(val,1,numel(val)));
            else
                error('ICNNA:analysis:set:SessionsIncluded:InvalidInput',...
                      'Sessions included must be a matrix of positive integers.');
            end
            obj.runStatus=false;
        end



        function res = get.channelGrouping(obj)
            %Gets the object |channelGrouping|
            res = obj.channelGrouping;
        end
        function obj = set.channelGrouping(obj,val)
            %Sets the object |channelGrouping|
            
            %Should be a matrix where
            %each row is a group, and 
            %each value is a channel.
            if isempty(val)
                obj.channelGrouping=val;
            elseif (isreal(val) && ~ischar(val)...
                    && all(all(floor(val)==val)) && all(all(val>0)))
                %It is not check whether the selected channels
                %exist
                obj.channelGrouping=val;
            else
                error('ICNNA:analysis:set:ChannelGroups:InvalidInput',...
                      'Channel groups must be a matrix of positive integers.');
            end
            obj.runStatus=false;
        end


        function res = get.signalDescriptors(obj)
            %Gets the object |signalDescriptors|
            res = obj.signalDescriptors;
        end
        function obj = set.signalDescriptors(obj,val)
            %Sets the object |signalDescriptors|
            
            %An Mx2 matrix of signal descriptors <dataSource,signal Idx>
            %Note that by now it only accepts 1 data source
            %See "the curse of the data source" in analysis.
            if isempty(val)
                obj.signalDescriptors=val;
            elseif (isreal(val) && ~ischar(val) && size(val,2)==2 ...
                    && all(all(floor(val)==val)) && all(all(val>0)))
                %Accept only 1 data source (i.e. all data Source are the same)
                tmpVal=val(:,1);
                tmpVal=tmpVal-tmpVal(1);
                if (all(tmpVal==0))
                    obj.signalDescriptors=val;
                else
                    error('ICNNA:analysis:set:SignalDescriptors:SingleDataSourceViolation',...
                      ['Current version requires all signals '...
                       'to belong to the same dataSource. Please'...
                       'type ''help analysis'' for more information.']);
                end
            else
                error('ICNNA:analysis:set:SignalDescriptors:InvalidInput',...
                      ['Signal descriptor must be a Mx2 matrix '...
                       '<dataSource,signal Idx>.']);
            end
            obj.runStatus=false;
        end


        function res = get.experimentSpace(obj)
            %Gets the object |experimentSpace| (read-only)
            res = obj.F;
        end
        function obj = set.experimentSpace(obj,val)
            %Sets the object |experimentSpace|
            obj.F =  val;
            obj.runStatus=false;
        end

        %Some "read-only" properties

        function res = get.runStatus(obj)
            %Gets the object |runStatus| (read-only)
            res = obj.runStatus;
        end


        function res = get.featureSpace(obj)
            %Gets the object |featureSpace| (read-only)
            res = obj.H;
        end

        function res = get.projectionSpace(obj)
            %Gets the object |projectionSpace| (read-only)
            res = obj.Y;
        end

        function res = get.patternDistances(obj)
            %Gets the object |PatternDistances| (read-only)
            res = obj.D;
        end

        function res = get.patternIndexes(obj)
            %Gets the object |patternIndexes| (read-only)
            res = obj.I;
        end



        %Derived properties
    

        function res = get.nPatterns(obj)
            %Gets the object |nPatterns|
            res = size(obj.H,1);
        end
    

        function res = get.nClusters(obj)
            %Gets the object |nPatterns|
            res = length(obj.clusters);
        end
    


    end




    methods (Access=protected)
        assertInvariants(obj);
    end
    
    methods (Static, Access=private)
        %External
        n2 = dist2(x, c);
        [centres, options, post, errlog] = kmeans(centres, data, options);
        
        %Mine
        [cost] = emd_calculateCosts(XX,YY,s);
        d  = ic_jsm(s1,s2); %DEPRECATED. Use jsm instead.
        Y  = ic_pdist(X,s);
        Y  = mena_embedding(D,options);
        D  = mena_geodesic(H, n_fcn, n_size); %DEPRECATED. See also geodesic
        DD = mena_getGroundCosts(D,cluster1Idx,cluster2Idx);
        D = mena_metric(H,s);
    end

    methods (Access=private)
        obj=getFeatureSpace(obj);
    end




end