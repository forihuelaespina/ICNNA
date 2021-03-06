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
% Copyright 2008-9
% date: 23-Apr-2008
% last update: 28-Nov-2008
% Author: Felipe Orihuela-Espina
%
% See also experiment, experimentSpace, cluster
%
classdef analysis
    properties (SetAccess=private, GetAccess=private)
        id=1;
	    name='Analysis0001';
        description='';
        metric='geo_euclidean'; %Distance Metric
        embedding='cmds'; %Embedding Technique
        projectionDimensionality=2;
        
        F=experimentSpace; %The Experiment Space.
        H=zeros(0,0); %The Feature Space. Each pattern is a row. Each
              %feature a column
        I=zeros(0,5); %The index register
        Y=zeros(0,2); %The 2D/3D Projection Space
        D=zeros(0,0); %Matrix of pairwise distances (in Feature Space)
        runStatus=false;
        
        %for Experiment Space data filtering
        subjectsIncluded=[];
        sessionsIncluded=[];
        
        %for Feature vector construction
        channelGrouping=[];
        signalDescriptors=[]; %Mx2 <dataSource, signal>
                               %matrix of signal descriptors
        
        clusters=cell(1,0);
    end
    
    properties (Constant=true, SetAccess=private, GetAccess=protected)
        COL_SUBJECT=1;
        COL_SESSION=2;
        COL_STIMULUS=3;
        COL_BLOCK=4;
        COL_CHANNELGROUP=5;
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
            obj=set(obj,'ID',varargin{1});
            obj.name=['Analysis' num2str(obj.id,'%04i')];
            if (nargin>1)
                obj=set(obj,'Name',varargin{2});
            end
            if (nargin>2)
                obj=set(obj,'Metric',varargin{3});
            end
            if (nargin>3)
                obj=set(obj,'Embedding',varargin{4});
            end
            if (nargin>4)
                obj=set(obj,'ProjectionDimensionality',varargin{5});
            end
        end
        obj.Y=zeros(0,obj.projectionDimensionality);
        obj.F=set(obj.F,'Name',get(obj,'Name'));
        obj.F=set(obj.F,'Description',get(obj,'Description'));
        assertInvariants(obj);
        end
    end
    
    
end